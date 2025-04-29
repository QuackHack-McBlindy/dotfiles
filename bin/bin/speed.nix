# bin/speed.ni
{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.scripts.speed = {
    description = "Test your internets Download speed";
    aliases = [ "st" ];
    helpFooter = ''
      SPEED_FILE="speedtest_speeds.txt"
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
      SPEED_FILE="speedtest_speeds.txt"
      COLOR=""
        SPEED_FILE="speedtest_speeds.txt"
        COLOR=""
      
        # Function to display the speed in pretty colors
        pretty_print() {
          SPEED=$1
          SPEED_FLOAT=$(echo "$SPEED" | awk '{print $1}')

          # Use >= for threshold comparisons
          if [[ $(echo "$SPEED_FLOAT >= 100" | bc) -eq 1 ]]; then
            COLOR="\033[1;32m"
            ICON="🚀"
          elif [[ $(echo "$SPEED_FLOAT >= 50" | bc) -eq 1 ]]; then
            COLOR="\033[1;33m"
            ICON="⚡"
          else
            COLOR="\033[1;31m"
            ICON="🐢"
          fi

          echo -e "$COLOR$ICON $SPEED \033[0m"
        }

        # Run speedtest with error handling
        if ! SPEED=$(curl -s -w '%{speed_download}\n' -o /dev/null http://speedtest.tele2.net/500MB.zip); then
          echo -e "\033[1;31mError: Failed to perform speed test\033[0m"
          exit 1
        fi

        # Convert to MB/s
        SPEED=$(echo "$SPEED" | awk '{ printf "%.2f MB/s", $1/1024/1024 }')

        # Save speed to file
        echo "$SPEED" >> "$SPEED_FILE"

        # Keep only last 5 entries
        tail -n 5 "$SPEED_FILE" > "$SPEED_FILE.tmp" && mv "$SPEED_FILE.tmp" "$SPEED_FILE"

        # Display results
        pretty_print "$SPEED"

        # Display last 5 results with simplified average calculation
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
  };}
