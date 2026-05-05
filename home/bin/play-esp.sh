#!/bin/bash

ESP_PORT=12345
SAMPLE_RATE=16000
CHANNELS=2

ESP_IP=$(jq -r '.[] | select(.room == "esp") | .ip' ~/.config/yo/clients.json | head -1)
if [ -z "$ESP_IP" ]; then
    echo "ESP IP not found in ~/.config/yo/clients.json"
    exit 1
fi

if [ $# -ne 1 ]; then
    echo "Usage:"
    echo "$0 <file_or_playlist>"
    echo "$0 <http_or_https_url>"
    echo "$0 mic"
    exit 1
fi

INPUT="$1"

send_track() {
    local track="$1"
    echo "  ⮞ $track" >&2
    ffmpeg -nostdin -i "$track" \
        -f s16le -acodec pcm_s16le \
        -ar $SAMPLE_RATE -ac $CHANNELS \
        -loglevel error - 2>/dev/null
}

echo "Streaming to $ESP_IP:$ESP_PORT ..."

exec 3>/dev/tcp/$ESP_IP/$ESP_PORT || {
    echo "Failed to connect to $ESP_IP:$ESP_PORT"
    exit 1
}

case "$INPUT" in
    *.m3u | *.m3u8 | *.pls)
        echo "Reading playlist: $INPUT"

        while IFS= read -r line; do
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"

            [[ -z "$line" || "$line" == \#* ]] && continue

            send_track "$line" >&3
        done < <(
            if [[ "$INPUT" =~ ^https?:// ]]; then
                curl -sL "$INPUT"
            else
                cat "$INPUT"
            fi
        )
        ;;
    *)
        send_track "$INPUT" >&3
        ;;
esac

exec 3>&-

echo "Done!"
