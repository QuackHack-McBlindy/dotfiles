# dotfiles/bin/network/api.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ simple bash api to hold timers, shopping list and stuff like dat
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  # 🦆 says ⮞ Get MQTT host configuration from battery script
  sysHosts = self.nixosConfigurations or {};
  mqttHost = let
    mqttHosts = lib.filter (host:
      let cfg = sysHosts.${host}.config or {};
      in cfg.services.mosquitto.enable or false
    ) (lib.attrNames sysHosts);
  in
    if mqttHosts != [] then lib.head mqttHosts else null;

  # 🦆 says ⮞ Import zigbee device configuration
  zigbeeDevices = config.house.zigbee.devices or {};

  # 🦆 says ⮞ Create normalized device map for fuzzy matching
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ All devices list
  allDevicesList = lib.attrValues normalizedDeviceMap;

  # 🦆 says ⮞ Fuzzy matching functions
  fuzzyMatchScript = ''
    trigram_similarity() {
      local str1="$1"
      local str2="$2"
      local str1_lower="''${str1,,}"
      local str2_lower="''${str2,,}"
      declare -a tri1 tri2
      
      for ((i=0; i<''${#str1_lower}-2; i++)); do
        tri1+=( "''${str1_lower:i:3}" )
      done
      
      for ((i=0; i<''${#str2_lower}-2; i++)); do
        tri2+=( "''${str2_lower:i:3}" )
      done
      
      local matches=0
      for t in "''${tri1[@]}"; do
        for t2 in "''${tri2[@]}"; do
          if [ "$t" = "$t2" ]; then
            ((matches++))
            break
          fi
        done
      done
      
      local total=$(( ''${#tri1[@]} + ''${#tri2[@]} ))
      (( total == 0 )) && echo 0 && return
      echo $(( 100 * 2 * matches / total ))
    }
    
    levenshtein() {
      local a="$1" b="$2"
      local len_a=''${#a} len_b=''${#b}
      
      [ "$len_a" -eq 0 ] && echo "$len_b" && return
      [ "$len_b" -eq 0 ] && echo "$len_a" && return
      
      local i j cost del ins alt min
      local -a d
      
      for ((i=0; i<=len_a; i++)); do
          d[i*((len_b+1))+0]=$i
      done
      for ((j=0; j<=len_b; j++)); do
          d[0*((len_b+1))+j]=$j
      done
      
      for ((i=1; i<=len_a; i++)); do
          for ((j=1; j<=len_b; j++)); do
              [ "''${a:i-1:1}" = "''${b:j-1:1}" ] && cost=0 || cost=1
              del=$(( d[(i-1)*((len_b+1))+j] + 1 ))
              ins=$(( d[i*((len_b+1))+j-1] + 1 ))
              alt=$(( d[(i-1)*((len_b+1))+j-1] + cost ))
              
              min=$del
              [ $ins -lt $min ] && min=$ins
              [ $alt -lt $min ] && min=$alt
              d[i*((len_b+1))+j]=$min
          done
      done
      
      echo ''${d[len_a*((len_b+1))+len_b]}
    }
    
    levenshtein_similarity() {
      local a="$1" b="$2"
      local len_a=''${#a} len_b=''${#b}
      local max_len=$(( len_a > len_b ? len_a : len_b ))
      (( max_len == 0 )) && echo 100 && return 
      local dist=$(levenshtein "$a" "$b")
      local score=$(( 100 - (dist * 100 / max_len) ))
      [ "''${a:0:1}" = "''${b:0:1}" ] && score=$(( score + 10 ))  
      echo $(( score > 100 ? 100 : score ))
    }
    
    normalize_string() {
      echo "$1" | 
        tr '[:upper:]' '[:lower:]' |
        sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' |
        sed -e 's/[[:space:]]\+/ /g'
    }
    
    fuzzy_find_device() {
      local search_term="$1"
      shift
      local devices=("$@")
      local best_match=""
      local best_score=0
      local normalized_search=$(normalize_string "$search_term")
      
      for device in "''${devices[@]}"; do
        local normalized_device=$(normalize_string "$device")
        local current_score=0
        
        if [ "$normalized_search" = "$normalized_device" ]; then
          echo "$device"
          return 0
        fi
        
        local all_words_match=1
        local search_words=($normalized_search)
        local device_words=($normalized_device)
        for word in "''${search_words[@]}"; do
          local word_found=0
          for device_word in "''${device_words[@]}"; do
            if [ "$word" = "$device_word" ]; then
              word_found=1
              break
            fi
          done
          if [ $word_found -eq 0 ]; then
            all_words_match=0
            break
          fi
        done
        
        if [ $all_words_match -eq 1 ]; then
          current_score=$(( 80 + (''${#search_words[@]} * 5) ))
        fi
        
        if [ $current_score -eq 0 ] && [[ "$normalized_device" == *"$normalized_search"* ]]; then
          current_score=75
        fi
        
        if [ $current_score -eq 0 ] && [[ "$normalized_search" == *"$normalized_device"* ]]; then
          current_score=70
        fi
        
        if [ $current_score -eq 0 ]; then
          local trigram_score=$(trigram_similarity "$normalized_search" "$normalized_device")
          local levenshtein_score=$(levenshtein_similarity "$normalized_search" "$normalized_device")
          current_score=$(( (trigram_score + levenshtein_score) / 2 ))
          local shared_words=0
          for sword in "''${search_words[@]}"; do
            for dword in "''${device_words[@]}"; do
              if [ "$sword" = "$dword" ]; then
                ((shared_words++))
                break
              fi
            done
          done
          if [ $shared_words -gt 0 ]; then
            current_score=$(( current_score + (shared_words * 10) ))
          fi
          
          current_score=$(( current_score > 100 ? 100 : current_score ))
        fi
        
        if [ $current_score -gt $best_score ]; then
          best_score=$current_score
          best_match="$device"
        fi
      done
      
      if [ $best_score -ge 50 ]; then
        echo "$best_match"
        return 0
      else
        return 1
      fi
    }
  '';

  handlerScript = ''
    #!/usr/bin/env bash
    DEBUG="${DEBUG:-false}"
    log() {
      if [[ "$DEBUG" != "false" ]]; then
        echo "[API] $*" >&2
      fi
    }

    send_response() {
      local status_code="$1"
      local body="$2"
      local content_type="''${3:-application/json}"
      local length=$(echo -n "$body" | wc -c)

      cat << RESPONSE
HTTP/1.1 $status_code
Content-Type: $content_type
Access-Control-Allow-Origin: *
Content-Length: $length

$body
RESPONSE
    }


    ${fuzzyMatchScript}

    get_zigbee_state() {
      local device_name="$1"
      local state_file="/var/lib/zigduck/state.json"
      
      if [[ ! -f "$state_file" ]]; then
        echo "{\"error\":\"State file not found\"}"
        return 1
      fi
      
      if [[ -z "$device_name" || "$device_name" == "all" ]]; then
        # Return all devices
        ${pkgs.jq}/bin/jq '.' "$state_file"
      else
        # Fuzzy match device name
        available_devices=(
          ${lib.concatStringsSep "\n          " (map (d: "\"${d}\"") allDevicesList)}
        )
        
        matched_device=$(fuzzy_find_device "$device_name" "''${available_devices[@]}")
        
        if [ $? -ne 0 ] || [ -z "$matched_device" ]; then
          echo "{\"error\":\"Device '$device_name' not found\"}"
          return 1
        fi
        
        # Get device state
        ${pkgs.jq}/bin/jq --arg device "$matched_device" '.[$device]' "$state_file"
      fi
    }

    get_zigbee_devices() {
      cat << EOF
    {
      "devices": [
        ${lib.concatStringsSep "," (lib.mapAttrsToList (id: device: 
          "{\"id\":\"${id}\",\"name\":\"${device.friendly_name}\",\"type\":\"${device.type}\"}"
        ) zigbeeDevices)}
      ]
    }
    EOF
    }

    handle_request() {
      local method=""
      local path=""
      local body=""
      local content_length=""
      read -r request_line
      log "Request: $request_line"
      method=$(echo "$request_line" | awk '{print $1}')
      path=$(echo "$request_line" | awk '{print $2}')
      
      while IFS= read -r header; do
        [[ -z "$header" || "$header" = $'\r' ]] && break
        if [[ "$header" =~ ^[Cc]ontent-[Ll]ength:[[:space:]]*([0-9]+) ]]; then
          content_length="''${BASH_REMATCH[1]}"
        fi
      done

      if [[ -n "$content_length" ]] && [[ "$content_length" -gt 0 ]]; then
        read -r -n "$content_length" body
        log "Body: $body"
      fi

      case "$path" in
        "/" )
          send_response "200 OK" '{"service":"yo-api","endpoints":["/timers","/alarms","/shopping","/zigbee","/health"]}' ;;
        "/timers"|"/api/timers" )
          if output=$(yo timer --list 2>/dev/null); then
            send_response "200 OK" "$output"
          else
            send_response "500 Internal Server Error" '{"error":"Failed to fetch timers"}'
          fi ;;
        "/alarms"|"/api/alarms" )
          if output=$(yo alarm --list 2>/dev/null); then
            send_response "200 OK" "$output"
          else
            send_response "500 Internal Server Error" '{"error":"Failed to fetch alarms"}'
          fi ;;
        "/shopping"|"/shopping-list"|"/api/shopping" )
          if output=$(yo shop-list --list 2>/dev/null); then
            if [[ -n "$output" ]]; then
              json_items=$(printf '%s\n' "$output" | jq -R -s 'split("\n")[:-1]')
              send_response "200 OK" "{\"items\":$json_items}"
            else
              send_response "500 Internal Server Error" '{"error":"Failed to fetch shopping list"}'
            fi  
          fi ;;
        "/reminders"|"/remmind"|"/api/reminders" )
          if output=$(yo reminder --list 2>/dev/null); then
            if [[ -n "$output" ]]; then
              json_items=$(printf '%s\n' "$output" | jq -R -s 'split("\n")[:-1]')
              send_response "200 OK" "{\"items\":$json_items}"
            else
              send_response "500 Internal Server Error" '{"error":"Failed to fetch reminders"}'
            fi  
          fi ;;
          
        "/zigbee"|"/api/zigbee" )
          # Parse query parameters
          if [[ "$path" == *"?"* ]]; then
            query_string="''${path#*\?}"
            path="''${path%\?*}"
            device_param=$(echo "$query_string" | grep -oE 'device=([^&]*)' | cut -d'=' -f2)
          else
            device_param=""
          fi
          
          if output=$(get_zigbee_state "$device_param"); then
            send_response "200 OK" "$output"
          else
            send_response "500 Internal Server Error" "$output"
          fi ;;
        "/zigbee/devices"|"/api/zigbee/devices" )
          output=$(get_zigbee_devices)
          send_response "200 OK" "$output" ;;
          
        "/health" )
          send_response "200 OK" '{"status":"healthy","service":"yo-api","timestamp":"'"$(date -Iseconds)"'"}' ;;
        * )
          send_response "404 Not Found" '{"error":"Endpoint not found","path":"'"$path"'"}' ;;
      esac
    }
    handle_request
  '';  
  
in { 
  networking.firewall.allowedTCPPorts = [9815];
  # 🦆 says ⮞ fancy cat'z...
  environment.systemPackages = [ pkgs.socat pkgs.netcat ];
  # 🦆 says ⮞  da script yo
  yo.scripts.api = {
    description = "Simple API for collecting system data";
    category = "🌐 Networking";
    autoStart = builtins.elem config.this.host.hostname [ "homie" ];
    parameters = [
      { name = "host"; description = "IP to run server on"; default = "0.0.0.0"; }
      { name = "port"; description = "Port for the service"; default = 9815;  } 
    ]; 
    code = ''
      ${cmdHelpers} 

      HOST="$host"
      PORT="$port"

      if command -v ss >/dev/null 2>&1 && ss -tuln | grep -q ":$PORT "; then
        echo "Error: Port $PORT is already in use" >&2
        exit 1
      fi

      echo "Starting yo API server on $HOST:$PORT" >&2
      echo "Endpoints:" >&2
      echo "  GET /timers     - List timers" >&2
      echo "  GET /alarms     - List alarms" >&2
      echo "  GET /shopping   - List shopping items" >&2
      echo "  GET /zigbee     - Get all zigbee device states" >&2
      echo "  GET /zigbee?device=<name> - Get specific device state" >&2
      echo "  GET /zigbee/devices - List available zigbee devices" >&2
      echo "  GET /health     - Health check" >&2
      echo "Press Ctrl+C to stop" >&2

      TMP_HANDLER=$(mktemp)
      cat > "$TMP_HANDLER" << 'EOF'
      ${handlerScript}
EOF
      chmod +x "$TMP_HANDLER"
      socat TCP-LISTEN:"$PORT",bind="$HOST",reuseaddr,fork EXEC:"$TMP_HANDLER"

      trap 'rm -f "$TMP_HANDLER"' EXIT
    '';
    
  };}
