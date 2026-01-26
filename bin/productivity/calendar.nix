# dotfiles/bin/productivity/calendar.nix ⮞ https://github.com/quackhack-mcblundy/dotfiles
{ # 🦆 says ⮞ cool calendar yo
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {
  yo = {
    scripts = {
      calendar = {
        description = "Calendar assistant. Provides easy calendar access. Interactive terminal calendar, or manage the calendar through yo commands or with voice.";
        category = "⚡ Productivity";
        aliases = [ "kal" ];
        runEvery = "05";
        helpFooter = ''
          ${cmdHelpers}        
          echo "## ──────⋆⋅☆⋅⋆────── ##"
          echo "## Calendar" && echo ""
          echo "This calendar has 4 modes."
          echo "Show - Displays a interactive calendar, use the arrow keys to move around and see your calendar events."
          echo "Add - Add a calendar event."
          echo "Remove - Removes a calendar event"
          echo "Upcoming - Displays a simple list of all upcoming events within 7 days."
          echo "List - All calendar entries shown in a list"
          echo ""
          echo "Interactive Controls:"
          echo "  Arrow Keys - Navigate between days"
          echo "  Enter/A - Add event on selected day"
          echo "  R - Remove event from selected day"
          echo "  E - Edit events on selected day"
          echo "  Q - Quit"
          echo "## ──────⋆⋅☆⋅⋆────── ##" 
        '';
        parameters = [
          { name = "operation"; description = "Supported values: add, remove, list, show"; optional = false; default = "list"; }
          { name = "calenders"; description = "Supported formats: local filepath and url, comma separated list."; default = config.this.user.me.dotfilesDir + "/home/björklöven.ics,/home/pungkula/Downloads/basic.ics"; }       
        ];
        code = ''
          ${cmdHelpers}

          IFS=',' read -ra ICS_FILES <<< "$calenders"
          TEMP_DIR=$(mktemp -d)
          trap 'rm -rf "$TEMP_DIR"' EXIT

          publish_to_mqtt() {
            local date="$1"
            local events="$2"
            
            local json_payload
            json_payload=$(jq -n \
              --arg today_date "$date" \
              --arg today_events "$events" \
              '{today_date: $today_date, today_events: $today_events}' 2>/dev/null)
            
            if [ -z "$json_payload" ]; then
              json_payload="{\"today_date\":\"$date\",\"today_events\":\"$events\"}"
            fi
            
            if command -v mosquitto_pub >/dev/null 2>&1; then
              yo mqtt_pub --topic "zigbee2mqtt/calendar" .-message "$json_payload" 2>/dev/null || true
              echo "Published to MQTT: $json_payload"
            else
              echo "Warning: mosquitto_pub not found. Install mosquitto-clients to enable MQTT publishing."
            fi
          }

          
          
          get_todays_events() {
            local today=$(date +%Y%m%d)
          
            local events=$(
              for file in "''${ICS_FILES[@]}"; do
                [[ -f "$file" ]] && \
                awk -v today="$today" '
                  BEGIN {RS="BEGIN:VEVENT"; FS="\n"}
                  {
                    date=""; summary=""
                    for(i=1;i<=NF;i++) {
                      if($i ~ /^DTSTART(;VALUE=DATE)?/) {
                        split($i,dt,":"); date=dt[2]
                      }
                      if($i ~ /^SUMMARY/) {
                        summary=substr($i,index($i,":")+1)
                      }
                    }
                    if(date==today && summary!="") {
                      print summary
                    }
                  }
                ' "$file"
              done
            )
          
            if [ -z "$events" ]; then
              echo "Nothing today..."
            else
              echo "$events" | paste -sd ", " -
            fi
          }
          
          
          


          list_calendar_events() {
            for file in "''${ICS_FILES[@]}"; do
              [[ -f "$file" ]] && \
              awk '
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
                      printf "%-12s %s\n", formatted_date, summary
                    }
                  }
                }' "$file"
            done | sort
          }

          show_upcoming() {
            local today=$(date +%Y%m%d)
            local next_week=$(date -d "+7 days" +%Y%m%d)
  
            for file in "''${ICS_FILES[@]}"; do
              [[ -f "$file" ]] && \
              awk -v today="$today" -v next_week="$next_week" '
                BEGIN {RS = "BEGIN:VEVENT"; FS = "\n"}
                /DTSTART;VALUE=DATE/ {
                  for(i = 1; i <= NF; i++) {
                    if($i ~ /^DTSTART;VALUE=DATE/) {
                      split($i, dt, ":")
                      date = dt[2]
                      if(date >= today && date <= next_week) {
                        formatted_date = substr(date,1,4) "-" substr(date,5,2) "-" substr(date,7,2)
                      }
                    }
                    if($i ~ /^SUMMARY/ && formatted_date != "") {
                      summary = substr($i, index($i, ":") + 1)
                      printf "%-12s %s\n", formatted_date, summary
                    }
                  }
                  formatted_date = ""
                }' "$file"
            done | sort
          }
          
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
            MAGENTA="\033[1;35m"
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

              events=()
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
              
              echo -e "\n''${MAGENTA}Controls:''${RESET} Arrow Keys=Navigate  ''${GREEN}Enter/A''${RESET}=Add  ''${RED}R''${RESET}=Remove  ''${YELLOW}E''${RESET}=Edit  ''${CYAN}Q''${RESET}=Quit"
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
              
              for i in "''${!event_list[@]}"; do
                local event="''${event_list[$i]}"
                [[ -z "$event" ]] && continue
                echo "  $((i+1)). $event"
              done
            }

            add_event() {
              local date_str=$1
              local desc=$2
    
              if [[ -z "$desc" ]]; then
                echo -n "Enter event description: "
                read -r desc
                [[ -z "$desc" ]] && { echo "Event creation cancelled."; return 1; }
              fi
    
              local ics_date=$(date -d "$date_str" +%Y%m%d)
              local uid="''${ics_date}-$(uuidgen | cut -c1-8)"
              local ics_file="''${ICS_FILES[0]}"
    
              if [[ -z "''${events[$date_str]}" ]]; then
                events["$date_str"]="$desc"
              else
                events["$date_str"]+="|$desc"
              fi
    
              # 🦆 says ⮞ rebuild ics file
              rebuild_ics
              echo "Event added: $date_str - $desc"
            }

            remove_event() {
              local date_str=$1
              local desc=$2
    
              if [[ -z "''${events[$date_str]}" ]]; then
                echo "No events found for $date_str"
                return 1
              fi
    
              local IFS='|'
              local event_list=("''${events[$date_str]//|/ }")
              event_list=(''${events[$date_str]//|/ })
              
              if [[ -z "$desc" ]]; then
                # 🦆 says ⮞ interactive removal
                echo "Select event to remove:"
                for i in "''${!event_list[@]}"; do
                  echo "  $((i+1)). ''${event_list[$i]}"
                done
                echo -n "Enter event number: "
                read -r choice
                
                if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ''${#event_list[@]} )); then
                  echo "Invalid selection."
                  return 1
                fi
                
                desc="''${event_list[$((choice-1))]}"
              fi
    
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
    
              if [ ''${#new_events[@]} -eq 0 ]; then
                unset events["$date_str"]
              else
                events["$date_str"]=$(IFS='|'; echo "''${new_events[*]}")
              fi
    
              rebuild_ics
              echo "Event removed: $date_str - $desc"
            }

            edit_events() {
              local date_str=$1
              
              if [[ -z "''${events[$date_str]}" ]]; then
                echo "No events found for $date_str"
                return 1
              fi
    
              local IFS='|'
              local event_list=(''${events[$date_str]//|/ })
              
              echo "Current events for $date_str:"
              for i in "''${!event_list[@]}"; do
                echo "  $((i+1)). ''${event_list[$i]}"
              done
              
              echo -e "\nOptions:"
              echo "  1. Edit an event"
              echo "  2. Add another event"
              echo "  3. Remove an event"
              echo "  4. Cancel"
              
              echo -n "Select option: "
              read -r option
              
              case "$option" in
                1)
                  echo -n "Enter event number to edit: "
                  read -r choice
                  if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ''${#event_list[@]} )); then
                    echo "Invalid selection."
                    return 1
                  fi
                  
                  local old_event="''${event_list[$((choice-1))]}"
                  echo -n "Enter new description [''${old_event}]: "
                  read -r new_desc
                  
                  if [[ -n "$new_desc" ]]; then
                    event_list[$((choice-1))]="$new_desc"
                    events["$date_str"]=$(IFS='|'; echo "''${event_list[*]}")
                    rebuild_ics
                    echo "Event updated."
                  fi
                  ;;
                2)
                  add_event "$date_str"
                  ;;
                3)
                  remove_event "$date_str"
                  ;;
                4)
                  echo "Edit cancelled."
                  ;;
                *)
                  echo "Invalid option."
                  ;;
              esac
            }

            validate_date() {
              local date="$1"
              # Accept multiple date formats
              if [[ "$date" =~ ^[0-9]{8}$ ]]; then
                # Convert YYYYMMDD to YYYY-MM-DD
                date="''${date:0:4}-''${date:4:2}-''${date:6:2}"
              fi
              
              if ! date -d "$date" >/dev/null 2>&1; then
                dt_error "Error: Invalid date format: $date. Use YYYY-MM-DD or YYYYMMDD"
                return 1
              fi
              echo "$date"
              return 0
            }

            validate_ics_file() {
              local file="$1"
              if [[ ! -f "$file" ]]; then
                dt_error "Error: Calendar file not found: $file"
                return 1
              fi
              if ! grep -q "BEGIN:VCALENDAR" "$file"; then
                dt_error "Error: Not a valid ICS file: $file"
                return 1
              fi
              return 0
            }

            rebuild_ics() {
              for file in "''${ICS_FILES[@]}"; do
                # 🦆 says ⮞ only rebuild the first ics file 
                if [[ "$file" == "''${ICS_FILES[0]}" ]]; then
                  cp "$file" "$file.bak" 2>/dev/null || true
                  
                  echo "BEGIN:VCALENDAR" > "$file"
                  echo "VERSION:2.0" >> "$file"
                  echo "CALSCALE:GREGORIAN" >> "$file"
                  
                  for date_str in "''${!events[@]}"; do
                    IFS='|' read -ra event_list <<< "''${events[$date_str]}"
                    for event in "''${event_list[@]}"; do
                      [[ -n "$event" ]] || continue
                      local ics_date=$(date -d "$date_str" +%Y%m%d)
                      local uid="''${ics_date}-$(uuidgen | cut -c1-8)"
                      echo "BEGIN:VEVENT" >> "$file"
                      echo "DTSTART;VALUE=DATE:$ics_date" >> "$file"
                      echo "SUMMARY:$event" >> "$file"
                      echo "UID:$uid" >> "$file"
                      echo "END:VEVENT" >> "$file"
                    done
                  done
                  
                  echo "END:VCALENDAR" >> "$file"
                fi
              done
            }

            load_events
            while true; do
              draw_calendar
              show_events
              
              read -rsn1 key
              case "$key" in
                $'\x1b') # 🦆 says ⮞ escape sequence
                  read -rsn2 -t 0.1 key2
                  key+="$key2"
                  case "$key" in
                    $'\x1b[A') # 🦆 says ⮞ up arrow
                      selected_date=$(date -d "$selected_date -7 days" +%Y-%m-%d)
                      ;;
                    $'\x1b[B') # 🦆 says ⮞ down arrow
                      selected_date=$(date -d "$selected_date +7 days" +%Y-%m-%d)
                      ;;
                    $'\x1b[C') # 🦆 says ⮞ right arrow
                      selected_date=$(date -d "$selected_date +1 day" +%Y-%m-%d)
                      ;;
                    $'\x1b[D') # 🦆 says ⮞ left arrow
                      selected_date=$(date -d "$selected_date -1 day" +%Y-%m-%d)
                      ;;
                  esac
                  ;;
                "") # 🦆 says ⮞ enter key
                  add_event "$selected_date"
                  echo -e "\nPress any key to continue..."
                  read -rsn1
                  ;;
                a|A)
                  add_event "$selected_date"
                  echo -e "\nPress any key to continue..."
                  read -rsn1
                  ;;
                r|R)
                  remove_event "$selected_date"
                  echo -e "\nPress any key to continue..."
                  read -rsn1
                  ;;
                e|E)
                  edit_events "$selected_date"
                  echo -e "\nPress any key to continue..."
                  read -rsn1
                  ;;
                q|Q)
                  echo -e "\nExiting calendar."
                  exit 0
                  ;;
              esac
            done
          }
          
          case "$operation" in
            show)
              show_calendar
              ;;
            list)
              list_calendar_events
              # Publish today's events to MQTT
              today_events=$(get_todays_events)
              publish_to_mqtt "$(date +%Y-%m-%d)" "$today_events"
              ;;
            upcoming)
              show_upcoming
              ;;
            add)
              if [[ $# -lt 2 ]]; then
                echo "Usage: $0 add YYYY-MM-DD \"Event Description\""
                echo "       $0 add YYYYMMDD \"Event Description\""
                exit 1
              fi
              validated_date=$(validate_date "$1")
              if [[ $? -ne 0 ]]; then
                exit 1
              fi
              add_event "$validated_date" "$2"
              ;;
            remove)
              if [[ $# -lt 2 ]]; then
                echo "Usage: $0 remove YYYY-MM-DD \"Event Description\""
                echo "       $0 remove YYYYMMDD \"Event Description\""
                exit 1
              fi
              validated_date=$(validate_date "$1")
              if [[ $? -ne 0 ]]; then
                exit 1
              fi
              remove_event "$validated_date" "$2"
              ;;
            *)
              show_calendar
              ;;
          esac          
        '';
        voice = {
          sentences = [
            "vad har jag planerat [idag|imorgon]"
            "visa min kalender för {day}"
            "har jag något inbokat [idag|imorgon]"
            "vad händer [på] [dag] [idag]"
            "vad har jag [i] kalendern [idag]"
            "visa [min] kalender [för] [idag]"
            "kalender [händelser] [idag]"
          ];
        };  
      };
    };
    
  };}
