# dotfiles/bin/productivity/calendar.nix
{ 
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {
  yo = {
    scripts = {
      calendar = {
        description = "Calendar assistant";
        category = "⚡ Productivity";
        aliases = [ "kal" ];
        helpFooter = ''
          ${cmdHelpers}        
          echo "## ──────⋆⋅☆⋅⋆────── ##"
          echo "## Calendar" && echo ""
          echo "This calendar has 4 modes."
          echo "Show - Displays a interactive calendar, use the arrow keys to move around and see your calendar events."
          echo "Add - Add a calendar event."
          echo "Remove - Removes a calendar event""
          echo "List - Displays a simple list of all upcoming events within 7 days."
          echo "## ──────⋆⋅☆⋅⋆────── ##"
     
        '';
        parameters = [
          { name = "operation"; description = "Supported values: add, remove, list, show"; optional = false; }
          { name = "calenders"; description = "Supported formats: local filepath and url, comma separated list."; default = "/home/pungkula/calendar1.ics,/home/pungkula/calendar2.ics,https;//mydomain.org/calendar.ics"; }       
        ];
        code = ''
          ${cmdHelpers}

          IFS=',' read -ra ICS_FILES <<< "$calenders"
          TEMP_DIR=$(mktemp -d)
          trap 'rm -rf "$TEMP_DIR"' EXIT
          
          downloaded_files=()
          for i in "''${!ICS_FILES[@]}"; do
            file="''${ICS_FILES[$i]}"
            if [[ $file == http* ]]; then
              filename="$TEMP_DIR/calendar_$i.ics"
              curl -s "$file" -o "$filename"
              downloaded_files+=("$filename")
            else
              downloaded_files+=("$file")
            fi
          done
          
          ICS_FILES=("''${downloaded_files[@]}")
          
          show_calendar() {
            TEMP_EVENTS_FILE="$TEMP_DIR/calendar_events.tmp"
            RED="\033[1;31m"
            GREEN="\033[1;32m"
            YELLOW="\033[1;33m"
            BLUE="\033[1;34m"
            CYAN="\033[1;36m"
            RESET="\033[0m"
            
            selected_date=$(date +%Y-%m-%d)
            declare -A events
            
            load_events() {
              rm -f "$TEMP_EVENTS_FILE"
              for file in "''${ICS_FILES[@]}"; do
                [[ -f "$file" ]] && \
                awk -v file="$file" '
                  BEGIN {RS = "BEGIN:VEVENT"; FS = "\n"}
                  /DTSTART;VALUE=DATE/ {
                    for(i = 1; i <= NF; i++) {
                      if($i ~ /^DTSTART;VALUE=DATE/) {
                        split($i, dt, ":")
                        date = dt[2]
                        formatted_date = substr(date,1,4) "-" substr(date,5,2) "-" substr(date,7,2)
                      }
                      if($i ~ /^SUMMARY/) {
                        summary = substr($i, index($i, ":") + 1)
                        print formatted_date "\t" summary
                      }
                    }
                  }' "$file" >> "$TEMP_EVENTS_FILE"
              done

              while IFS=$'\t' read -r date summary; do
                events["$date"]+="$summary|"
              done < "$TEMP_EVENTS_FILE"
            }

            draw_calendar() {
              clear
              local year=$(date -d "$selected_date" +%Y)
              local month=$(date -d "$selected_date" +%m)
              local day=$(date -d "$selected_date" +%d)
              local today=$(date +%d)
              
              month=$((10#$month))
              day=$((10#$day))
              today=$((10#$today))
              
              local first_dow=$(date -d "$year-$month-01" +%u)
              local days_in_month=$(date -d "$year-$month-01 +1 month -1 day" +%d)
              days_in_month=$((10#$days_in_month))
              
              local pad=$((first_dow - 1))
              
              local star_day=0
              if (( days_in_month >= 25 )); then
                local dow_25=$(date -d "$year-$month-25" +%u)  # 1-7 (Mon-Sun)
                if (( dow_25 == 6 || dow_25 == 7 )); then
                  star_day=$((25 - (dow_25 - 5)))
                else
                  star_day=25
                fi
              fi

              echo -e "''${CYAN}$(date -d "$year-$month-01" "+%B %Y")''${RESET}"
              echo -e "Mo Tu We Th Fr ''${RED}Sa''${RESET} ''${RED}Su''${RESET}"
              
              for ((i=0; i<$pad; i++)); do echo -n "   "; done
              
              for ((d=1; d<=$days_in_month; d++)); do
                printf -v date_str "%d-%02d-%02d" $year $month $d
                
                local dow=$(date -d "$date_str" +%u)
                
                local display_num=$d
                if [[ $d -eq $star_day ]]; then
                  display_num="💫"
                fi

                if [[ "$date_str" == "$selected_date" ]]; then
                  echo -ne "''${GREEN}\033[7m"
                elif [[ $dow -eq 6 || $dow -eq 7 ]]; then  # Saturday or Sunday
                  echo -ne "''${RED}"
                fi
                
                [[ -n "''${events[$date_str]}" ]] && echo -ne "''${YELLOW}"
                
                if [[ "$display_num" == "💫" ]]; then
                  printf "%-2s" "$display_num"
                else
                  printf "%2d" "$d"
                fi
                echo -ne "''${RESET} "
                
                if [[ $dow -eq 7 ]]; then
                  echo
                fi
              done
              echo
            }

            show_events() {
              local date_str=$(date -d "$selected_date" +%Y-%m-%d)
              local event_str="''${events[$date_str]}"
              
              if [[ -z "$event_str" || "$event_str" == "|" ]]; then
                echo -e "\nEvents for $(date -d "$selected_date" +%F):"
                echo "  No events"
                return
              fi
              
              local IFS='|'
              local event_list=($event_str)
              
              echo -e "\nCalendar events for $(date -d "$selected_date" +%F):"
              
              for event in "''${event_list[@]}"; do
                [[ -z "$event" ]] && continue
                echo "  - $event"
              done
            }

            add_event() {
              local date_str=$1
              local desc=$2
    
              [[ -z "$desc" ]] && { echo "Error: Missing event description"; return 1; }
    
              local ics_date=$(date -d "$date_str" +%Y%m%d)
              local uid="''${ics_date}-$(uuidgen | cut -c1-8)"
              local ics_file="''${ICS_FILES[0]}"
    
              echo "BEGIN:VEVENT
            DTSTART;VALUE=DATE:$ics_date
            SUMMARY:$desc
            UID:$uid
            END:VEVENT" >> "$ics_file"
    
              if [[ -z "''${events[$date_str]}" ]]; then
                events["$date_str"]="$desc"
              else
                events["$date_str"]+="|$desc"
              fi
    
              echo "Event added: $date_str - $desc"
            }

            remove_event() {
              local date_str=$1
              local desc=$2
    
              if [[ -z "''${events[$date_str]}" ]]; then
                echo "No events found for $date_str"
                return 1
              fi
    
              IFS='|' read -ra event_list <<< "''${events[$date_str]}"
              local new_events=()
              local found=0
    
              for event in "''${event_list[@]}"; do
                if [[ "$event" == "$desc" ]]; then
                  found=1
                else
                  new_events+=("$event")
                fi
              done
    
              if [[ $found -eq 0 ]]; then
                echo "Event not found: $desc"
                return 1
              fi
    
              events["$date_str"]=$(IFS='|'; echo "''${new_events[*]}")
    
              rebuild_ics
    
              echo "Event removed: $date_str - $desc"
            }

            rebuild_ics() {
              for file in "''${ICS_FILES[@]}"; do
                cp "$file" "$file.bak"
        
                echo "BEGIN:VCALENDAR" > "$file"
                echo "VERSION:2.0" >> "$file"
                echo "CALSCALE:GREGORIAN" >> "$file"
        
                for date_str in "''${!events[@]}"; do
                  IFS='|' read -ra event_list <<< "''${events[$date_str]}"
                  [[ -n "$event" ]] || continue
                  local ics_date=$(date -d "$date_str" +%Y%m%d)
                  echo "BEGIN:VEVENT" >> "$file"
                  echo "DTSTART;VALUE=DATE:$ics_date" >> "$file"
                  echo "SUMMARY:$event" >> "$file"
                  echo "UID:''${ics_date}-$(uuidgen | cut -c1-8)" >> "$file"
                  echo "END:VEVENT" >> "$file"
                done

        
              echo "END:VCALENDAR" >> "$file"
              done
            }

            load_events
            while true; do
              draw_calendar
              show_events
              
              read -rsn1 key
              case "$key" in
                $'\x1b') # escape sequence
                  read -rsn2 -t 0.1 key2
                  key+="$key2"
                  case "$key" in
                    $'\x1b[A') # up arrow
                      selected_date=$(date -d "$selected_date -7 days" +%Y-%m-%d)
                      ;;
                    $'\x1b[B') # down arrow
                      selected_date=$(date -d "$selected_date +7 days" +%Y-%m-%d)
                      ;;
                    $'\x1b[C') # right arrow
                      selected_date=$(date -d "$selected_date +1 day" +%Y-%m-%d)
                      ;;
                    $'\x1b[D') # left arrow
                      selected_date=$(date -d "$selected_date -1 day" +%Y-%m-%d)
                      ;;
                  esac
                  ;;
                q) exit 0 ;;
              esac
            done
          }
          
          case "$operation" in
            show)
              show_calendar
              ;;
            list)
              echo "TOOD Implement simple list of all events in upcoming 7 days"
              ;;
            add)
              if [[ $# -lt 2 ]]; then
                echo "Usage: $0 add YYYY-MM-DD \"Event Description\""
                exit 1
              fi
              add_event "$1" "$2"
              ;;
            remove)
              if [[ $# -lt 2 ]]; then
                echo "Usage: $0 remove YYYY-MM-DD \"Event Description\""
                exit 1
              fi
              remove_event "$1" "$2"
              ;;
            *)
              show_calendar
              ;;

          esac          
        '';
        voice = {
          sentences = [
            "påminn mig om [att] {item}" 
            "kan du påminna mig om [att] {item}"
            "vad händer [i dag|imorgon|nästa vecka]"
            "lägg till {item} [i kalendern]"
            "lista kalenderhändelser"
            "ta bort påminnelse {id}"
          ];
          lists.item.wildcard = true;
          lists.id.wildcard = true;
        };  
      };
    };
    
  };}
