# dotfiles/bin/system/transport.nix
{ 
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
}: let
  runtimeDeps = with pkgs; [ curl jq coreutils gnused ];
in {
  yo.scripts.travel = {
    description = "Public transportation helper. Fetches current bus and train schedules. (Sweden)";
    aliases = [ "bus" ];
    category = "🌍 Localization";
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "arrival"; description = "Destination stop or city"; optional = false; }
      { name = "departure"; description = "Departure stop or city"; optional = true; default = config.sops.secrets."users/pungkula/homeStop".path; }
      { name = "apikeyPath"; description = "Trafiklab API key path"; optional = true; default = config.sops.secrets.resrobot.path; }
    ];
    code = ''
      ${cmdHelpers}
      export TZ="Europe/Stockholm"    
      API_KEY=$(cat "$apikeyPath")
      origin="$departure"
      destination="$arrival"
      
      PATH="${lib.makeBinPath runtimeDeps}:$PATH"
      
      get_stop_id() {
        local stop_name="$1"
        local url="https://api.resrobot.se/v2.1/location.name?input=$stop_name&format=json&accessId=$API_KEY"
        
        local response
        response=$(curl -s -w "%{http_code}" "$url")
        local status_code=$(printf '%s' "$response" | tail -c 3)
        local content=$(printf '%s' "$response" | head -c -3)
        
        if [ "$status_code" -ne 200 ]; then
          dt_error "API error: Received status $status_code"
          exit 1
        fi
        
        local stop_id=$(echo "$content" | jq -r '.stopLocationOrCoordLocation[].StopLocation.extId' 2>/dev/null | head -1)
        
        if [ -z "$stop_id" ]; then
          dt_error "No stops found for $stop_name"
          exit 1
        fi
        
        echo "$stop_id"
      }
      
      get_next_route() {
        local origin_id="$1"
        local dest_id="$2"
        local url="https://api.resrobot.se/v2.1/trip?format=json&originId=$origin_id&destId=$dest_id&passlist=0&showPassingPoints=0&numF=3&accessId=$API_KEY"
        
        local response
        response=$(curl -s -w "%{http_code}" "$url")
        local status_code=$(printf '%s' "$response" | tail -c 3)
        local content=$(printf '%s' "$response" | head -c -3)
        
        if [ "$status_code" -eq 400 ]; then
          dt_error "Bad request - Invalid stop combination"
          exit 1
        elif [ "$status_code" -ne 200 ]; then
          dt_error "API error: Received status $status_code"
          exit 1
        fi
        
        echo "$content"
      }
      
      format_time() {
        local time_str="$1"
        if [ -n "$time_str" ] && [ ''${#time_str} -ge 16 ]; then
          echo "$time_str" | cut -c 12-16  # Extract HH:MM from YYYY-MM-DDTHH:MM:SS
        else
          echo "N/A"
        fi
      }
      
      calculate_duration() {
        local start="$1"
        local end="$2"
        
        if [ -z "$start" ] || [ -z "$end" ] || [ "$start" = "N/A" ] || [ "$end" = "N/A" ]; then
          echo "N/A"
          return
        fi
        
        local start_time="''${start:11:5}"
        local end_time="''${end:11:5}"
        
        local start_hour="''${start_time:0:2}"
        local start_min="''${start_time:3:2}"
        local end_hour="''${end_time:0:2}"
        local end_min="''${end_time:3:2}"
        

        if ! [[ "$start_hour" =~ ^[0-9]+$ ]] || ! [[ "$start_min" =~ ^[0-9]+$ ]] ||
           ! [[ "$end_hour" =~ ^[0-9]+$ ]] || ! [[ "$end_min" =~ ^[0-9]+$ ]]; then
          echo "N/A"
          return
        fi

        local start_minutes=$((10#$start_hour * 60 + 10#$start_min))
        local end_minutes=$((10#$end_hour * 60 + 10#$end_min))
        local duration=$((end_minutes - start_minutes))
        
        if [ $duration -lt 0 ]; then
          duration=$((duration + 24 * 60))
        fi
        
        printf "%dh %02dm" $((duration / 60)) $((duration % 60))
      }
      
      display_trip() {
        local idx="$1"
        local origin_name="$2"
        local dest_name="$3"
        local dep_time="$4"
        local arr_time="$5"
        local transport_type="$6"
        local line_number="$7"
        
        local dep_short=$(format_time "$dep_time")
        local arr_short=$(format_time "$arr_time")
        local duration=$(calculate_duration "$dep_time" "$arr_time")
        
        local minutes_until="?"
        if [ -n "$dep_time" ] && [ ''${#dep_time} -ge 16 ]; then
          local now_epoch=$(date +%s)
          local date_part="''${dep_time:0:10}"
          local time_part="''${dep_time:11:5}"
          
          if dep_epoch=$(date -d "$date_part $time_part" +%s 2>/dev/null); then
            minutes_until=$(((dep_epoch - now_epoch) / 60))
          fi
        fi
        

        if ! [ "$minutes_until" -eq "$minutes_until" ] 2>/dev/null || [ -z "$minutes_until" ]; then
          minutes_until="?"
        fi
        
        local time_color="\\033[32m"  # Green
        if [ "$minutes_until" != "?" ] && [ "$minutes_until" -lt 5 ] 2>/dev/null; then
          time_color="\\033[31m"  # Red
        elif [ "$minutes_until" != "?" ] && [ "$minutes_until" -lt 15 ] 2>/dev/null; then
          time_color="\\033[33m"  # Yellow
        fi        

        if [ "$idx" -eq 0 ]; then
          echo -e "\n\\033[1mRoute: $origin_name → $dest_name\\033[0m"
          echo "────────────────────────────────────────────────────────────"
        fi        

        printf "%2d. ''${time_color}%3s min\\033[0m │ %s → %s │ " "$((idx+1))" "$minutes_until" "$dep_short" "$arr_short"
        printf "⏱ $duration │ "
        echo -e "🚌 \\033[1m''${transport_type} ''${line_number}\\033[0m"
      }
      
      origin_id=$(get_stop_id "$origin")
      dest_id=$(get_stop_id "$destination")
      
      trips_json=$(get_next_route "$origin_id" "$dest_id")
      

      echo -e "\n\\033[1mUpcoming Trips\\033[0m"
      
      trip_count=$(echo "$trips_json" | jq -r '.Trip | length' 2>/dev/null)
      if [ -z "$trip_count" ] || [ "$trip_count" -eq 0 ]; then
        dt_info "No trips found"
        exit 0
      fi
      

      for i in $(seq 0 $((trip_count - 1))); do
        trip=$(echo "$trips_json" | jq -c ".Trip[$i]" 2>/dev/null)
        if [ -z "$trip" ] || [ "$trip" = "null" ]; then
          continue
        fi
        
       origin_name=$(echo "$trip" | jq -r '.LegList.Leg[0].Origin.name // "Unknown"' 2>/dev/null)
       dest_name=$(echo "$trip" | jq -r '.LegList.Leg[0].Destination.name // "Unknown"' 2>/dev/null)
       dep_date=$(echo "$trip" | jq -r '.LegList.Leg[0].Origin.date // ""' 2>/dev/null)
       dep_time_val=$(echo "$trip" | jq -r '.LegList.Leg[0].Origin.time // ""' 2>/dev/null)
       arr_date=$(echo "$trip" | jq -r '.LegList.Leg[0].Destination.date // ""' 2>/dev/null)
       arr_time_val=$(echo "$trip" | jq -r '.LegList.Leg[0].Destination.time // ""' 2>/dev/null)

       dep_time="''${dep_date}T''${dep_time_val}"
       arr_time="''${arr_date}T''${arr_time_val}"
       
       transport_type="Transport"
       line_number="N/A"
        
        product=$(echo "$trip" | jq -c '.LegList.Leg[0].Product' 2>/dev/null)
        if [ -n "$product" ] && [ "$product" != "null" ]; then
          if echo "$product" | jq -e 'type == "array"' &>/dev/null; then
            transport_type=$(echo "$product" | jq -r '.[0].catOut // "Transport"' 2>/dev/null)
            line_number=$(echo "$product" | jq -r '.[0].num // "N/A"' 2>/dev/null)
          else
            transport_type=$(echo "$product" | jq -r '.catOut // "Transport"' 2>/dev/null)
            line_number=$(echo "$product" | jq -r '.num // "N/A"' 2>/dev/null)
          fi
        fi
        
        if [ -n "$origin_name" ] && [ -n "$dest_name" ]; then
          display_trip "$i" "$origin_name" "$dest_name" "$dep_time" "$arr_time" "$transport_type" "$line_number"
        fi
      done
      
      if [ "$logLevel" = "DEBUG" ]; then
        echo -e "\n\\033[2m----- RAW DATA -----\\033[0m"
        echo "$trips_json" | jq .
      fi
    '';    
  };

  yo.bitch = { 
    intents = {
      travel = {
        priority = 3;
        data = [{
          sentences = [
            "när går bussen från {departure} till {arrival}"
            "vilken tid går bussen från {departure} till {arrival}"
            "när går bussen till {arrival} från {departure}"
            "vilken tid går bussen till {arrival} från {departure}"
            "när går (tåg|tåget) från {departure} till {arrival}"
            "vilken tid går (tåg|tåget) från {departure} till {arrival}"
            "när går (tåg|tåget) till {arrival} från {departure}"
            "vilken tid går (tåg|tåget) till {arrival} från {departure}"           
            "mår går tåget till {arrival}"
            "vilken tid går tåget till {arrival}"
            "mår går bussen till {arrival}"
            "vilken tid går bussen till {arrival}"
          ];    
          lists = {
            departure.wildcard = true;
            arrival.wildcard = true;    
          };
        }];
      };
    };
  };
     
  sops = {
    secrets = {
      resrobot = {
        sopsFile = ./../../secrets/resrobot.yaml;
        owner = config.this.user.me.name;
        group = config.this.user.me.name;
        mode = "0440";
      };
      "users/pungkula/homeStop" = {
        sopsFile = ./../../secrets/users/pungkula/homeStop.yaml;
        owner = config.this.user.me.name;
        group = config.this.user.me.name;
        mode = "0440";
      };      
    };
  };}
