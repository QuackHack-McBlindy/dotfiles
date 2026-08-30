#!/bin/bash

SERVER_HOST="127.0.0.1"
SERVER_PORT="12345"
ROOM="oneshot"
CHUNK_SAMPLES=1600
INPUT_DEVICE="default"
FIFO="/tmp/ptt_audio_$$.fifo"
MAX_DURATION=5

if ! exec 3<>/dev/tcp/$SERVER_HOST/$SERVER_PORT; then
    echo "Error: Could not connect to $SERVER_HOST:$SERVER_PORT" >&2
    exit 1
fi
echo "Connected to $SERVER_HOST:$SERVER_PORT" >&2

room_len=${#ROOM}
printf -v room_len_le '\\x%02x\\x%02x\\x%02x\\x%02x' \
    $((room_len & 0xff)) \
    $(((room_len >> 8) & 0xff)) \
    $(((room_len >> 16) & 0xff)) \
    $(((room_len >> 24) & 0xff))
printf "%b%s" "$room_len_le" "$ROOM" >&3

printf '\x10' >&3

if ! mkfifo "$FIFO"; then
    echo "Error: Could not create FIFO $FIFO" >&2
    exit 1
fi

CLEANED=0
ARECORD_PID=""
PERL_PID=""
cleanup() {
    [[ $CLEANED -eq 1 ]] && return
    CLEANED=1

    if [[ -n "$ARECORD_PID" ]] && kill -0 "$ARECORD_PID" 2>/dev/null; then
        kill "$ARECORD_PID" 2>/dev/null
        wait "$ARECORD_PID" 2>/dev/null
    fi
    if [[ -n "$PERL_PID" ]] && kill -0 "$PERL_PID" 2>/dev/null; then
        kill "$PERL_PID" 2>/dev/null
        wait "$PERL_PID" 2>/dev/null
    fi

    printf '\x12' >&3 2>/dev/null
    sleep 0.2

    exec 3>&- 2>/dev/null
    rm -f "$FIFO"
}

trap cleanup INT TERM EXIT

arecord -D "$INPUT_DEVICE" -f S16_LE -c 1 -r 16000 -t raw 2>/tmp/arecord_err > "$FIFO" &
ARECORD_PID=$!

perl -e '
    use strict;
    use warnings;
    $| = 1;
    my $chunk_samples = 1600;
    my $chunk_bytes = $chunk_samples * 2;
    binmode(STDIN);
    binmode(STDOUT);
    while (read(STDIN, my $buf, $chunk_bytes) == $chunk_bytes) {
        my @samples = unpack("s<*", $buf);
        my $f32buf = pack("f<*", map { $_ / 32768.0 } @samples);
        print STDOUT "\x11";
        print STDOUT pack("V", $chunk_samples);
        print STDOUT $f32buf;
    }
' < "$FIFO" >&3 &
PERL_PID=$!
echo "Perl streaming started (PID $PERL_PID)" >&2


( sleep "$MAX_DURATION"; kill "$ARECORD_PID" "$PERL_PID" 2>/dev/null ) &

wait $ARECORD_PID $PERL_PID

exit 0
