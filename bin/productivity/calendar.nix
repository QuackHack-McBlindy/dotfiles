{ self, config, pkgs, cmdHelpers, ... }:
{
  yo = {
    scripts = {
      calendar = {
        description = "Calendar assistant";
        category = "⚡ Productivity";
        aliases = [ "kal" ];
        helpFooter = ''
          ${cmdHelpers}
          echo "## ──────⋆⋅☆⋅⋆────── ##"
          echo "## Calendar"
          echo "## ──────⋆⋅☆⋅⋆────── ##"
  
          echo "## ──────⋆⋅☆⋅⋆────── ##"        
        '';
        parameters = [{ name = "operation"; description = "Supported values: add, remove, list."; optional = false; }];
        code = ''
          ${cmdHelpers}
          
         CALENDAR_SOURCES=(
              "/home/pungkula/calendar.ics"
              "https://mydomain.org/calendar.ics"
          )
          TODO_FILES=("/home/pungkula/todo.txt")
          DURATION_DAYS=7
          
          current_weekday=$(date +%A)
          declare -A weekday_map=(
              ["Monday"]="måndag" ["Tuesday"]="tisdag" ["Wednesday"]="onsdag"
              ["Thursday"]="torsdag" ["Friday"]="fredag" ["Saturday"]="lördag" ["Sunday"]="söndag"
          )
          swedish_weekday=''${weekday_map[$current_weekday]}
          
          today_date=$(date +%Y-%m-%d)
          tomorrow_date=$(date -d "+1 day" +%Y-%m-%d)
          end_date=$(date -d "+$DURATION_DAYS days" +%Y-%m-%d)
          
          declare -A events
          for calendar in "''${CALENDAR_SOURCES[@]}"; do
              if [[ $calendar == http* ]]; then
                  ical_data=$(curl -s "$calendar")
              else
                  ical_data=$(<"$calendar")
              fi
          
              echo "$ical_data" | awk -v today="$today_date" -v tomorrow="$tomorrow_date" -v end="$end_date" '
              BEGIN { RS = "BEGIN:VEVENT"; FS = "\n" }
              /DTSTART/ {
                  summary = ""; start = ""
                  for (i = 1; i <= NF; i++) {
                      if ($i ~ /^SUMMARY/) summary = substr($i, index($i, ":") + 1)
                      if ($i ~ /^DTSTART;VALUE=DATE:/) start = substr($i, index($i, ":") + 1)
                      if ($i ~ /^DTSTART:/ && !start) start = substr($i, index($i, ":") + 1)
                  }
          
                  if (!start || !summary) next
                  
                  gsub(/\\,/, ",", summary)
                  gsub(/\\n/, " ", summary)
                  
                  if (length(start) == 8) 
                      event_date = substr(start,1,4) "-" substr(start,5,2) "-" substr(start,7,2)
                  else if (start ~ /T/)
                      event_date = substr(start,1,10)
                  else next
          
                  if (event_date >= today && event_date <= end) {
                      events[event_date][summary] = 1
                  }
              }
              END {
                  for (date in events) {
                      for (summary in events[date]) {
                          print date "|" summary
                      }
                  }
              }' | while IFS='|' read -r event_date summary; do
                  events["$event_date|$summary"]=1
              done
          done
          

          print_header() {
              echo -e "\n\033[1m$1\033[0m"
          }
          
          today_printed=0
          tomorrow_printed=0
          upcoming_printed=0

          # Fixed Swedish weekday names array
          weekday_names=("måndag" "tisdag" "onsdag" "torsdag" "fredag" "lördag" "söndag")
          
          for key in "''${!events[@]}"; do
              IFS='|' read -r event_date summary <<< "$key"
              
              if [[ $event_date == "$today_date" ]]; then
                  formatted_date="Idag"
                  if (( today_printed == 0 )); then
                      print_header "Idag:"
                      today_printed=1
                  fi
              elif [[ $event_date == "$tomorrow_date" ]]; then
                  formatted_date="Imorgon"
                  if (( tomorrow_printed == 0 )); then
                      print_header "Imorgon:"
                      tomorrow_printed=1
                  fi
              else
                  if (( upcoming_printed == 0 )); then
                      print_header "Kommande evenemang:"
                      upcoming_printed=1
                  fi
                  dow_num=$(date -d "$event_date" +%u)
                  index=$((dow_num - 1))
                  dow="''${weekday_names[index]}"
                  formatted_date="$dow den $(date -d "$event_date" "+%d %B")"
              fi
              echo "$formatted_date: $summary"
          done | sort -t'|' -k1
          
          total_items=0
          for file in "''${TODO_FILES[@]}"; do
              if [[ -f $file ]]; then
                  count=$(grep -c '^[^-].*' "$file")
                  total_items=$((total_items + count))
              fi
          done
          
          echo -e "\nDu har $total_items stycken objekt på Att Göra listan idag!"               
        '';
      };
    };
    
    
    bitch = {
      intents = {
        calendar = {
          data = [{
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
          }];  
        };  
      };
    };  
  };}
