# dotfiles/bin/network/speed.nix
{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.scripts.speed = {
    description = "Test your internets Download speed";
    category = "🌐 Networking";
    aliases = [ "st" ];
    helpFooter = ''
      SPEED_FILE="''${XDG_CACHE_HOME:-$HOME/.cache}/speedtest_speeds"
      if [[ -f "$SPEED_FILE" ]]; then
        echo -e "\n\033[1mLast 5 Speedtests:\033[0m"
        cat "$SPEED_FILE"
        awk '{ total += $1 } END { 
          if (NR > 0) {
            printf "\n\033[1;36mAverage Speed: %.2f MB/s\033[0m\n", total/NR 
          }
        }' "$SPEED_FILE"
      fi
    '';
    code = ''
      #!/usr/bin/env bash
      set -euo pipefail

      CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}"
      SPEED_FILE="$CACHE_DIR/speedtest_speeds"
      COLOR=""
      mkdir -p "$CACHE_DIR"

      pretty_print() {
        local SPEED=$1
        local SPEED_FLOAT=$(echo "$SPEED" | awk '{print $1}')

        # Threshold comparisons
        if (($(echo "$SPEED_FLOAT >= 100" | bc))); then
          COLOR="\033[1;32m"
          ICON="🚀"
        elif (($(echo "$SPEED_FLOAT >= 50" | bc))); then
          COLOR="\033[1;33m"
          ICON="⚡"
        else
          COLOR="\033[1;31m"
          ICON="🐢"
        fi

        echo -e "$COLOR$ICON $SPEED \033[0m"
      }

      # Run speedtest
      if ! SPEED=$(curl -s -w '%{speed_download}\n' -o /dev/null http://speedtest.tele2.net/500MB.zip); then
        echo -e "\033[1;31mError: Failed to perform speed test\033[0m" >&2
        exit 1
      fi

      # Convert to MB/s
      SPEED=$(echo "$SPEED" | awk '{ printf "%.2f MB/s", $1/1024/1024 }')

      echo "$SPEED" >> "$SPEED_FILE"

      tail -n 5 "$SPEED_FILE" > "$SPEED_FILE.tmp" && mv "$SPEED_FILE.tmp" "$SPEED_FILE"

      pretty_print "$SPEED"

      echo -e "\n\033[1mLast 5 Speedtests:\033[0m"
      awk '
        {
          total += $1
          print NR ". " $0
        }
        END {
          if (NR > 0) {
            avg = total / NR
            printf "\n\033[1;36mAverage Speed: %.2f MB/s\033[0m\n", avg
          }
        }
      ' "$SPEED_FILE"
    '';
  };
  
  
  yo.bitch = {
#    language = "sv";    
    intents = {
      speed = {
        data = [{
          sentences = [
            "nätverks test"
            "network speedtest"
          ];
          lists = {
            #search.wildcard = true;
            #typ.values = [
           #   { "in" = "(serien|tvserien|tv-serien)"; out = "tv"; }
           #   { "in" = "(podd|pod|podcast)"; out = "podcast"; }
          #    { "in" = "(slump|slumpa|random|musik)"; out = "jukebox"; }
          #    { "in" = "(artist|artisten|band|bandet|grupp|gruppen)"; out = "music"; }
          #    { "in" = "(låt|låten|sång|sången|biten)"; out = "song"; }
         #   ];
          };
        }];
      };
    };
    
  };}
