# dotfiles/bin/system/travel.nix  ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Swedish Public Transportation assistant.
  config,
  self,
  lib,
  pkgs,
  cmdHelpers,
  ...
}: let
in { # 🦆 says ⮞ voice intents
  # 🦆 says ⮞ da script yo
  yo.scripts.travel = {
    description = "Public transportation helper. Fetches current bus, boat, train and air travel schedules. (Sweden)";
    category = "🌍 Localization";
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "arrival"; description = "Destination stop or city"; optional = false; default = config.sops.secrets."users/pungkula/homeStop".path; }
      { name = "departure"; description = "Departure stop or city"; optional = true; default = config.sops.secrets."users/pungkula/homeStop".path; }
      { name = "type"; description = "Optionally specify a transportation type"; optional = true; }      
      { name = "apikeyPath"; description = "Trafiklab API key path"; optional = true; default = config.sops.secrets.resrobot.path; }
    ];
    code = ''
      ${cmdHelpers}      
      API_KEY=$(cat "$apikeyPath")
      if [[ "$departure" == /* ]]; then
        if [[ -f "$departure" ]]; then
          origin="$(cat "$departure")"
        else
          dt_error "File $departure not found."
          exit 1
        fi
      else
        origin="$departure"
      fi 
      if [[ "$arrival" == /* ]]; then
        if [[ -f "$arrival" ]]; then
          destination="$(cat "$arrival")"
        else
          dt_error "File $arrival not found."
          exit 1
        fi
      else
        destination="$arrival"
      fi
      transport_type="$type"
      export TZ="Europe/Stockholm"      
   
      # 🦆 says ⮞ type mappin'
      declare -A TYPE_MATCH=(
        ["bus"]="BLT"
        ["train"]=""
        ["air"]="FLY"
        ["tram"]="TRM"
        ["metro"]="MTB"
        ["ferry"]="SHP"
      )
      declare -A CODE_TO_SWEDISH=(
        ["BLT"]="bussen"
        ["TRM"]="spårvagnen"
        ["SHP"]="färjan"
        ["MTB"]="tunnelbanan"
        ["FLY"]="flyget"
        # [""]="tåget"
      )

      get_swedish_type_name() {
        case "$1" in
          bus) echo "bussen" ;;
          train) echo "tåget" ;;
          air) echo "flyget" ;;
          tram) echo "spårvagnen" ;;
          metro) echo "tunnelbanan" ;;
          ferry) echo "färjan" ;;
          *) echo "fordonet" ;;
        esac
      }
      get_icon_for_type() {
        local type="$1"
        case "$type" in
          bus) echo "🚌" ;;
          train) echo "🚆" ;;
          air) echo "✈️" ;;
          tram) echo "🚋" ;;
          metro) echo "🚇" ;;
          ferry) echo "⛴️" ;;
          *) echo "❓" ;;
        esac
      }

      # 🦆 says ⮞ fetch stop id'z
      get_stop_id() {
        local stop_name="$1"
#        dt_debug "Fetching stop ID for: $stop_name" 
        local encoded_stop_name
        encoded_stop_name=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$stop_name")
        local url="https://api.resrobot.se/v2.1/location.name?input=$encoded_stop_name&format=json&accessId=$API_KEY"
        local response
        response=$(curl -s "$url")
#        dt_debug "Location API response: $response"

        local stop_id
        stop_id=$(echo "$response" | jq -r '.stopLocationOrCoordLocation[]?.StopLocation?.extId' 2>/dev/null | head -1)

        if [ -n "$stop_id" ] && [ "$stop_id" != "null" ]; then
          echo "$stop_id"
          return
        fi

        # 🦆 says ⮞ fallback to CoordLocation (lat/lon)
        local lat
        local lon
        lat=$(echo "$response" | jq -r '.stopLocationOrCoordLocation[]?.CoordLocation?.lat' 2>/dev/null | head -1)
        lon=$(echo "$response" | jq -r '.stopLocationOrCoordLocation[]?.CoordLocation?.lon' 2>/dev/null | head -1)

        if [ -n "$lat" ] && [ -n "$lon" ]; then
          echo "$lat,$lon"  # Special marker
          return
        fi

        dt_error "No stops found for $stop_name"
      }
      
      # 🦆 says ⮞ fetchin' route info
      get_next_route() {
        local origin_id="$1"
        local dest_id="$2"
        local origin_param=""
        local dest_param=""

        if [[ "$origin_id" == *,* ]]; then
          local lat="''${origin_id%%,*}"
          local lon="''${origin_id##*,}"
          origin_param="originCoordLat=$lat&originCoordLong=$lon"
        else
          origin_param="originId=$origin_id"
        fi

        if [[ "$dest_id" == *,* ]]; then
          local lat="''${dest_id%%,*}"
          local lon="''${dest_id##*,}"
          dest_param="destCoordLat=$lat&destCoordLong=$lon"
        else
          dest_param="destId=$dest_id"
        fi
        local url="https://api.resrobot.se/v2.1/trip?format=json&$origin_param&$dest_param&passlist=0&showPassingPoints=0&numF=3&accessId=$API_KEY"
#        dt_debug "API URL: $url"
        local response
        response=$(curl -s "$url")

        echo "$response"
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
        local start_epoch=$(date -d "$start" +%s 2>/dev/null)
        local end_epoch=$(date -d "$end" +%s 2>/dev/null)      
        if [ -z "$start_epoch" ] || [ -z "$end_epoch" ]; then
          echo "N/A"
          return
        fi        
        local duration=$((end_epoch - start_epoch))
        printf "%dh %02dm" $((duration / 3600)) $(( (duration % 3600) / 60 ))
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
          if dep_epoch=$(date -d "$dep_time" +%s 2>/dev/null); then
            minutes_until=$(((dep_epoch - now_epoch) / 60))
          fi
        fi
        
        if ! [[ "$minutes_until" =~ ^[0-9]+$ ]]; then
          minutes_until="?"
        fi
        
        local time_color="\\033[32m"  # Green
        if [ "$minutes_until" != "?" ]; then
          if [ "$minutes_until" -lt 5 ]; then
            time_color="\\033[31m"  # Red
          elif [ "$minutes_until" -lt 15 ]; then
            time_color="\\033[33m"  # Yellow
          fi
        fi
        
        if [ "$idx" -eq 0 ]; then
          echo -e "\n\\033[1mRoute: $origin_name → $dest_name\\033[0m"
          echo "────────────────────────────────────────────────────────────"
        fi
        
        printf "%2d. ''${time_color}%3s min\\033[0m │ %s → %s │ " "$((idx+1))" "$minutes_until" "$dep_short" "$arr_short"
        printf "⏱ $duration │ "
        icon=$(get_icon_for_type "$type")
        echo -e "$icon \\033[1m''${transport_type} ''${line_number}\\033[0m"
      }
      
      origin_id=$(get_stop_id "$origin")
      dest_id=$(get_stop_id "$destination")
      dt_debug "Using Origin ID: $origin_id, Destination ID: $dest_id"
      
      trips_json=$(get_next_route "$origin_id" "$dest_id")      
      if [ -z "$trips_json" ]; then
        dt_error "Empty trip data from API"
        exit 1
      fi
      
      trip_count=$(echo "$trips_json" | jq -r '.Trip | length' 2>/dev/null)
      dt_debug "Found $trip_count trips"
      
      if [ -z "$trip_count" ] || [ "$trip_count" -eq 0 ]; then
        dt_info "No trips found"
        exit 0
      fi
      
      tts_messages=()
      echo -e "\n\\033[1mUpcoming Trips\\033[0m"
      displayed_count=0
      tts_phrases=()
      for i in $(seq 0 $((trip_count - 1))); do
        tts_type=""
        case "$transport_type" in
          "BLT") tts_type="bussen" ;;
          "TRM") tts_type="spårvagnen" ;;
          "SHP") tts_type="färjan" ;;
          "MTB") tts_type="tunnelbanan" ;;
          "FLY") tts_type="flyget" ;;
          "")    tts_type="tåget" ;;
          *)     tts_type="fordonet" ;;
        esac
        trip=$(echo "$trips_json" | jq -c ".Trip[$i]" 2>/dev/null)
        if [ -z "$trip" ] || [ "$trip" = "null" ]; then
          continue
        fi
        dep_short=$(format_time "$dep_time")
        msg="$tts_type från $origin_name till $dest_name"
        msg+=" avgår klockan $dep_short"
        [ -n "$line_number" ] && [ "$line_number" != "N/A" ] && msg+=" med linje $line_number"
    
        tts_messages+=("$msg")         
        origin_name=$(echo "$trip" | jq -r '.Origin.name')
        dest_name=$(echo "$trip" | jq -r '.Destination.name') 
        dep_time=$(echo "$trip" | jq -r '.Origin.date + "T" + .Origin.time')
        arr_time=$(echo "$trip" | jq -r '.Destination.date + "T" + .Destination.time')

        minutes_until="?"
        if [ -n "$dep_time" ] && [ ''${#dep_time} -ge 16 ]; then
          now_epoch=$(date +%s)
          if dep_epoch=$(date -d "$dep_time" +%s 2>/dev/null); then
            minutes_until=$(((dep_epoch - now_epoch) / 60))
          fi
        fi
        
        dep_date=$(echo "$trip" | jq -r '.LegList.Leg[0].Origin.date // ""' 2>/dev/null)
        dep_time_val=$(echo "$trip" | jq -r '.LegList.Leg[0].Origin.time // ""' 2>/dev/null)
        arr_date=$(echo "$trip" | jq -r '.LegList.Leg[0].Destination.date // ""' 2>/dev/null)
        arr_time_val=$(echo "$trip" | jq -r '.LegList.Leg[0].Destination.time // ""' 2>/dev/null)
        
        transport_type="Transport"
        line_number="N/A"
        
        product=$(echo "$trip" | jq -c '.LegList.Leg[0].Product' 2>/dev/null)

        transport_type="Transport"
        line_number="N/A"
        product_code=""

        if [ -n "$product" ] && [ "$product" != "null" ]; then
          if echo "$product" | jq -e 'type == "array"' &>/dev/null; then
            transport_type=$(echo "$product" | jq -r '.[0].catOut // "Transport"' 2>/dev/null)
            line_number=$(echo "$product" | jq -r '.[0].num // "N/A"' 2>/dev/null)
            product_code=$(echo "$product" | jq -r '.[0].catCode // empty' 2>/dev/null)
          else
            transport_type=$(echo "$product" | jq -r '.catOut // "Transport"' 2>/dev/null)
            line_number=$(echo "$product" | jq -r '.num // "N/A"' 2>/dev/null)
            product_code=$(echo "$product" | jq -r '.catCode // empty' 2>/dev/null)
          fi
        fi

        # 🦆 says ⮞ skip if type is set and dont match 
        if [ -n "$type" ]; then
          expected_cat="''${TYPE_MATCH[$type]}"
          if [ -n "$expected_cat" ] && [[ "$transport_type" != "$expected_cat" ]]; then
            continue
          fi
        fi

        if [ -n "$origin_name" ] && [ -n "$dest_name" ]; then
          if [ -n "$type" ]; then
            swedish_type=$(get_swedish_type_name "$type")
          else
            swedish_type="''${CODE_TO_SWEDISH[$transport_type]}"
            [[ -z "$swedish_type" ]] && swedish_type="fordonet"
          fi

          line_info=""
          if [ -n "$line_number" ] && [ "$line_number" != "N/A" ]; then
            line_info=" med linje $line_number"
          fi

          if [[ "$minutes_until" =~ ^[0-9]+$ ]]; then
            time_info=" om $minutes_until minuter"
          else
            dep_short=$(format_time "$dep_time")
            time_info=" klockan $dep_short"
          fi

          if [ $displayed_count -eq 0 ]; then
            phrase="Nästa $swedish_type$line_info$time_info"
          elif [ $displayed_count -eq 1 ]; then
            phrase="Sedan$line_info$time_info"
          else
            phrase="Därefter$line_info$time_info"
          fi
        
          tts_phrases+=("$phrase")
        
          display_trip "$displayed_count" "$origin_name" "$dest_name" "$dep_time" "$arr_time" "$transport_type" "$line_number"
          displayed_count=$((displayed_count + 1))
        fi
      done
        
      dt_debug "----- RAW DATA -----"
      if echo "$trips_json" | jq empty &>/dev/null; then
        dt_debug "$trips_json" | jq .
      else
        echo "" 
      fi
      if ((''${#tts_phrases[@]} > 0)); then
        tts_final=""
        for idx in "''${!tts_phrases[@]}"; do
          if [[ $idx -gt 0 ]]; then
            tts_final+=". "
          fi
          tts_final+="''${tts_phrases[$idx]}"
        done
        tts_final+="."
        tts "$tts_final"
      fi
    '';
    voice = {
      priority = 2;
      sentences = [
        # 🦆 says ⮞ using default --departure
        "mår går tåget till {arrival}"
        "vilken tid går tåget till {arrival}"
        "mår går bussen till {arrival}"
        "vilken tid går bussen till {arrival}"
        # 🦆 says ⮞ using default --arrival
        "mår går tåget från {departure}"
        "vilken tid går tåget från {departure}"
        "mår går bussen från {departure}"
        "vilken tid går bussen från {departure}"
        # 🦆 says ⮞ call using type, arrival, and departure
        "när går {type} från {departure} till {arrival}"
        "vilken tid går {type} från {departure} till {arrival}"
        "när går {type} till {arrival} från {departure}"
        "vilken tid går {type} till {arrival} från {departure}"
      ];    
      lists = {
        departure.wildcard = true;
        arrival.wildcard = true;    
        type.values = [
          { "in" = "[bus|buss|bussen]"; out = "bus"; }
          { "in" = "[tåg|tåget]"; out = "train"; }
          { "in" = "[flyg|flyget]"; out = "air"; }              
          { "in" = "[spårvagn|spårvagnen|vagnen]"; out = "tram"; }
          { "in" = "[tunnelbana|tunnelbanan]"; out = "metro"; }              
          { "in" = "[färja|färjan|båt|båten]"; out = "ferry"; }
        ];
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
