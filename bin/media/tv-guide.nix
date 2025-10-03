# dotfiles/bin/media/tv-guide.nix
{ # 🦆 says ⮞ Fancy markdown & Text-To-Speech EPG in da terminal! 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let 
in { # 🦆 says ⮞ yo    
  yo.scripts.tv-guide = {
    description = "TV-guide assistant..";
    aliases = [ "tvg" ];
    category = "🎧 Media Management";
    autoStart = false;
    logLevel = "DEBUG";
    parameters = [
      { name = "search"; description = "TV show to search for"; optional = true; }  
      { name = "channel"; description = "TV show to search for"; optional = true; }      
      { name = "jsonFilePath"; description = "Optional option to write as JSON file in addation to the EPG"; optional = true; default = "/home/" + config.this.user.me.name + "/epg.json"; }      
    ];
    code = ''
      ${cmdHelpers}
      channel="$channel"
      search="$search"
      jsonFilePath="''${jsonFilePath:-/home/${config.this.user.me.name}/epg.json}"
      
      if [ ! -f "$jsonFilePath" ]; then
        yo tv-scraper
        sleep 6
      fi
      
      clean_title() {
        echo "$1" | ${pkgs.gnused}/bin/sed 's/<[^>]*>//g' | ${pkgs.gnused}/bin/sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; s/&apos;/'"'"'/g'
      }
      
      extract_epg_time() {
        local epg_time="$1"
        echo "''${epg_time:8:2}:''${epg_time:10:2}"
      }
      
      epg_to_epoch() {
        local epg_time="$1"
        local year="''${epg_time:0:4}"
        local month="''${epg_time:4:2}"
        local day="''${epg_time:6:2}"
        local hour="''${epg_time:8:2}"
        local minute="''${epg_time:10:2}"
        date -d "''${year}-''${month}-''${day} ''${hour}:''${minute}" +%s 2>/dev/null || echo "0"
      }
      
      get_channel_name() {
        ${pkgs.jq}/bin/jq -r --arg id "$1" '
          (.channels // [])[] | select(.id == $id) | .name
        ' "$jsonFilePath"
      }
      
      get_progress_bar() {
        local start_time="$1"
        local end_time="$2"
        local width=50     
        local start_epoch=$(epg_to_epoch "$start_time")
        local end_epoch=$(epg_to_epoch "$end_time")
        local now_epoch=$(date +%s)      
        
        if [ "$start_epoch" -eq 0 ] || [ "$end_epoch" -eq 0 ]; then
          echo "──────────────────────────────────────────────────"
          return
        fi
        
        local total_duration=$((end_epoch - start_epoch))
        local elapsed=$((now_epoch - start_epoch))
        local progress=0
        
        if [ "$total_duration" -gt 0 ]; then
          progress=$((elapsed * 100 / total_duration))
        fi
     
        if (( progress < 0 )); then progress=0; fi
        if (( progress > 100 )); then progress=100; fi
        
        local filled=$((progress * width / 100))
        local empty=$((width - filled)) 
        local bar=""
        for ((i=0; i<filled; i++)); do bar+="█"; done
        for ((i=0; i<empty; i++)); do bar+="─"; done
        
        if (( progress < 50 )); then
          bar="\033[32m$bar\033[0m"
        elif (( progress < 75 )); then
          bar="\033[33m$bar\033[0m"
        else
          bar="\033[31m$bar\033[0m"
        fi
        
        echo "$bar"
      }

      schedule_future_program() {
          local chan_id="$1"
          local start_epoch="$2"
          local title="$3"
          local current_epoch=$(date +%s)
          local delay_seconds=$((start_epoch - current_epoch))
    
          if [ "$delay_seconds" -gt 0 ] && [ "$delay_seconds" -lt 86400 ]; then
              local delay_minutes=$(( (delay_seconds + 59) / 60 ))
              local start_time_formatted=$(extract_epg_time "$4")
              dt_info "Schemalägger '$title' på kanal $chan_id om $delay_minutes minuter (kl $start_time_formatted)"
              yo say "Programmet $title sänds på $chan_iid klockan $start_time_formatted . Jag ser till att starta det åt dig när det är dax!"
              echo "yo tv --typ livetv --search '$chan_id' --device '$DEVICE'" | 
              at now + $delay_minutes minutes 2>/dev/null &&
              dt_info "Program schemalagt att starta klockan $start_time_formatted"
          fi
      }
      
      display_channel_info() {
        local chan_id="$1"
        local title="$2"
        local start_time="$3"
        local end_time="$4"
        local progress_bar="$5"  
        title=$(clean_title "$title") 
        local start_fmt=$(extract_epg_time "$start_time")
        local end_fmt=$(extract_epg_time "$end_time")
        local channel_name=$(get_channel_name "$chan_id")
        local title_length=''${#title}
        local padding=$(( (50 - title_length) / 2 ))
        printf "\n%*s" $padding ""
        echo -e "\033[1m$title\033[0m"
        
        echo -e "\033[1m$chan_id\033[0m - $channel_name"
        echo "─────────────────────────────────────────────────────────────────────────────"
        
        echo -e "$start_fmt $progress_bar $end_fmt"
      }
      
      is_program_current() {
        local start_time="$1"
        local end_time="$2"
        local start_epoch=$(epg_to_epoch "$start_time")
        local end_epoch=$(epg_to_epoch "$end_time")
        local now_epoch=$(date +%s)
        
        [ "$start_epoch" -le "$now_epoch" ] && [ "$now_epoch" -lt "$end_epoch" ]
      }
      
      # 🦆 says ⮞ channel search, yo!
      if [ -n "$channel" ]; then
        dt_debug "Kollar vad som går på kanal $channel just nu..."
        
        # 🦆 says ⮞ get all programs for da channel and find current program
        programs=$(${pkgs.jq}/bin/jq -r --arg chan "$channel" '
          (.channels[].programs // [])[] | 
          select(.channel_id == $chan) |
          "\(.title)|\(.start)|\(.stop)"
        ' "$jsonFilePath")
        
        found_current=false
        while IFS='|' read -r title start_time end_time; do
          if is_program_current "$start_time" "$end_time"; then
            title=$(clean_title "$title")
            progress_bar=$(get_progress_bar "$start_time" "$end_time")
            yo say "Kanal $channel $title"
            display_channel_info "$channel" "$title" "$start_time" "$end_time" "$progress_bar"
            found_current=true
            break
          fi
        done <<< "$programs"
        
        if [ "$found_current" = "false" ]; then
          channel_name=$(get_channel_name "$channel")
          dt_error "Inget program hittades på $channel_name just nu."
        fi
      
      # 🦆 says ⮞ program search, yolo!
      elif [ -n "$search" ]; then
          dt_debug "Söker efter program som matchar: $search"
    
          # 🦆 says ⮞ search all programs
          results=$(${pkgs.jq}/bin/jq -r --arg query "$search" '
            (.channels[].programs // [])[] | 
            select(.title | ascii_downcase | contains($query | ascii_downcase)) | 
            "\(.channel_id)|\(.title)|\(.start)|\(.stop)|\(.description)"
          ' "$jsonFilePath")
    
          if [ -z "$results" ]; then
              dt_debug "Inga program matchade din sökning."
          else
              current_epoch=$(date +%s)
              found_current=false
        
              dt_debug "Program som matchar $search"
              while IFS='|' read -r chan_id title start_time end_time description; do
                  # 🦆 says ⮞ clean title
                  cleaned_title=$(clean_title "$title")
                  cleaned_desc=$(clean_title "$description")
                  
                  start_epoch=$(epg_to_epoch "$start_time")
                  start_formatted=$(extract_epg_time "$start_time")
                  channel_name=$(get_channel_name "$chan_id")
            
                  # 🦆 says ⮞ airing now?
                  if is_program_current "$start_time" "$end_time"; then
                      progress_bar=$(get_progress_bar "$start_time" "$end_time")
                      display_channel_info "$chan_id" "$cleaned_title" "$start_time" "$end_time" "$progress_bar"
                      if [ "$found_current" = "false" ]; then
                          dt_info "Startar aktuellt program: $cleaned_title"
                          yo tv --typ livetv --search "$chan_id" --device "$DEVICE"
                          found_current=true
                      fi
                  else
                      # 🦆 says ⮞ airing later? scheduling info
                      echo -e "\n\033[33m[KOMMER] $start_formatted - $channel_name\033[0m"
                      echo -e "  $cleaned_title"
                      if [ -n "$cleaned_desc" ] && [ "$cleaned_desc" != "No description" ]; then
                          echo -e "  \033[90m$cleaned_desc\033[0m"
                      fi
                
                      # 🦆 says ⮞ schedule channel change
                      if [ "$start_epoch" -gt "$current_epoch" ]; then
                          schedule_future_program "$chan_id" "$start_epoch" "$cleaned_title" "$start_time"
                      fi
                  fi
              done <<< "$results"
          fi
          
      # 🦆 says ⮞ show all currently playing shows
      else
          dt_debug "Aktuella program just nu:"
          # 🦆 says ⮞ filter by current time
          results=$(${pkgs.jq}/bin/jq -r '
            (.channels[].programs // [])[] | 
            "\(.channel_id)|\(.title)|\(.start)|\(.stop)"
          ' "$jsonFilePath")
    
          if [ -z "$results" ]; then
              dt_info "Inga aktuella program hittades."
          else
              dt_debug "Aktuella program"
              current_programs=""
              while IFS='|' read -r chan_id title start_time end_time; do
                  if is_program_current "$start_time" "$end_time"; then
                      printf "%03d|%s|%s|%s\n" "$chan_id" "$title" "$start_time" "$end_time" >> /tmp/current_programs.$$
                  fi
              done <<< "$results"
              
              if [ -f /tmp/current_programs.$$ ]; then
                  sort -t'|' -k1,1n /tmp/current_programs.$$ | while IFS='|' read -r chan_id title start_time end_time; do
                      chan_id=$(echo "$chan_id" | sed 's/^0*//')
                      cleaned_title=$(clean_title "$title")
                      progress_bar=$(get_progress_bar "$start_time" "$end_time")
                      display_channel_info "$chan_id" "$cleaned_title" "$start_time" "$end_time" "$progress_bar"
                  done
                  rm -f /tmp/current_programs.$$
              else
                  dt_info "Inga aktuella program hittades."
              fi
          fi
      fi
    '';   
    voice = {
      sentences = [
        "vilken kanal (spelas|sänds) {search} på"  
        "vad (sänds|visas) på [kanal] {channel} [just nu]"       
      ];    
      lists = {
        channel.values = lib.flatten (map (device: 
            lib.mapAttrsToList (id: channel: {
                "in" = "[${channel.name}|${id}]";
                out = id;
            }) device.channels
        ) (lib.attrValues config.house.tv));
        search.wildcard = true;
      };    
    };
  };}
