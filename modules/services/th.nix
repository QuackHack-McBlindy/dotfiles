# dotfiles/modules/services/triggerhappy.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞ keyboard bindings
  config,
  lib,
  pkgs,
  ...
} : let
  pidFile = "/tmp/ptt.pid";
in {
    config = lib.mkIf (lib.elem "th" config.this.host.modules.services) {
      environment.systemPackages = [ pkgs.triggerhappy ];
      
      services.triggerhappy = {
        enable = true;
        #user = config.this.user.me.name;
        bindings = [
          { # key names as defined in: 
            # https://github.com/torvalds/linux/blob/cf72cbb39da84b6f02f90c07f33b102fc10b16f0/include/uapi/linux/input-event-codes.h
            keys = [ "KEY_CALC" ]; # 140
            event = "press";
            cmd = ''
              if [ -f ${pidFile} ]; then
                kill "$(cat ${pidFile})" 2>/dev/null
                rm -f ${pidFile}
              fi
  
              bash -c '
                SERVER_HOST="127.0.0.1"
                SERVER_PORT="12345"
                ROOM="oneshot"
                CHUNK_SAMPLES=1600
                INPUT_DEVICE="default"
  
                if ! exec 3<>/dev/tcp/$SERVER_HOST/$SERVER_PORT; then
                  exit 1
                fi
  
                room_len=''${#ROOM}
                printf -v room_len_le '"'"'\\x%02x\\x%02x\\x%02x\\x%02x'"'"' \
                  ''$((room_len & 0xff)) \
                  ''$(((room_len >> 8) & 0xff)) \
                  ''$(((room_len >> 16) & 0xff)) \
                  ''$(((room_len >> 24) & 0xff))
                printf "%b%s" "$room_len_le" "$ROOM" >&3
  
                printf '"'"'\x10'"'"' >&3
                CLEANED=0
                PIPELINE_PID=""
                cleanup() {
                  [[ $CLEANED -eq 1 ]] && return
                  CLEANED=1
  
                  if [[ -n "$PIPELINE_PID" ]]; then
                    PGID=$(ps -o pgid= -p "$PIPELINE_PID" 2>/dev/null | tr -d " ")
                    if [[ -n "$PGID" ]]; then
                      kill -TERM -"$PGID" 2>/dev/null
                      sleep 0.2
                      kill -KILL -"$PGID" 2>/dev/null
                    fi
                    wait "$PIPELINE_PID" 2>/dev/null
                  fi
  
                  printf '"'"'\x12'"'"' >&3 2>/dev/null
                  exec 3>&- 2>/dev/null
                }
                trap cleanup INT TERM EXIT
  
                arecord -D "$INPUT_DEVICE" -f S16_LE -c 1 -r 16000 -t raw 2>/tmp/arecord_err | \
                perl -e '"'"'
                  use strict;
                  use warnings;
                  $| = 1;
                  my $chunk_samples = 1600;
                  my $bytes_per_sample = 2;
                  my $chunk_bytes = $chunk_samples * $bytes_per_sample;
                  binmode(STDIN);
                  binmode(STDOUT);
                  while (read(STDIN, my $buf, $chunk_bytes) == $chunk_bytes) {
                    my @samples = unpack("s<*", $buf);
                    my $f32buf = pack("f<*", map { $_ / 32768.0 } @samples);
                    print STDOUT "\x11";
                    print STDOUT pack("V", $chunk_samples);
                    print STDOUT $f32buf;
                  }
                '"'"' >&3 &
                PIPELINE_PID=$!
  
                while kill -0 "$PIPELINE_PID" 2>/dev/null; do
                  sleep 1
                done
  
                exit 0
              ' &
  
              echo $! > ${pidFile}
            '';
          }
          {
            keys = [ "KEY_CALC" ];
            event = "release";
            cmd = ''
              if [ -f ${pidFile} ]; then
                kill "$(cat ${pidFile})" 2>/dev/null
                rm -f ${pidFile}
              fi
            '';
          }
        ];
      };  
        
    };}
