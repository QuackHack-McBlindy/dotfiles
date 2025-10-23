# dotfiles/bin/home/state.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ fetchez the state of specified device 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let # 🦆 says ⮞ configuration directory for diz module
  zigduckDir = "/home/" + config.this.user.me.name + "/.config/zigduck";
  # 🦆 says ⮞ findz da mosquitto host
  sysHosts = lib.attrNames self.nixosConfigurations;
  mqttHost = let
    sysHosts = lib.attrNames self.nixosConfigurations;
    mqttHosts = lib.filter (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) sysHosts;
  in
    if mqttHosts != [] then lib.head mqttHosts else null;

  # 🦆 says ⮞ get MQTT broker IP yo
  mqttHostIp = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or "127.0.0.1"
    else "127.0.0.1";

  zigbeeDevices = config.house.zigbee.devices;

  lightDevices = lib.filterAttrs (_: device: device.type == "light") zigbeeDevices;
 
  # 🦆 says ⮞ case-insensitive device matchin'
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ devices by room
  roomDevicesMap = let
    grouped = lib.groupBy (device: device.room) (lib.attrValues zigbeeDevices);
  in lib.mapAttrs (room: devices: 
      map (d: d.friendly_name) devices
    ) grouped;

  allDevicesList = lib.attrValues normalizedDeviceMap;

  # 🦆 says ⮞ device validation list
  deviceList = builtins.attrNames normalizedDeviceMap;

  zigbeeCfg = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.services.zigbee2mqtt.settings or {}
    else {};

  # 🦆 says ⮞ precompute device & group mappings
  devicesSet = zigbeeCfg.devices or {};
  groupsSet = zigbeeCfg.groups or {};

  # 🦆 says ⮞ room bash map with only lights, using | as separator
  roomBashMap = lib.mapAttrs' (room: devices:
    lib.nameValuePair room (lib.concatStringsSep "|" devices)
  ) roomDevicesMap;

  # 🦆 says ⮞ all devices as pipe separated string
  allDevicesStr = lib.concatStringsSep "|" allDevicesList;
in { 
  yo.scripts.state = {
    description = "Fetches the state of the specified device.";
    category = "🛖 Home Automation";     
    logLevel = "INFO";
    parameters = [   
      { name = "device"; description = "Device to fetch state for"; default = "Dimmer Switch Kök"; }
    ];      
    code = ''
      ${cmdHelpers}
      STATE_FILE="/var/lib/zigduck/state.json"
      MQTT_HOST="${mqttHost}"
	
      available_devices=(
        ${lib.concatStringsSep "\n        " (map (d: "\"${d}\"") allDevicesList)}
      )
      
      dt_debug "Available devices count: ''${#available_devices[@]}"
      dt_debug "Available devices: ''${available_devices[*]}"
      
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
        dt_debug "Searching for: '$normalized_search' in ''${#devices[@]} devices"
        
        for device in "''${devices[@]}"; do
          local normalized_device=$(normalize_string "$device")
          local current_score=0
          
          if [ "$normalized_search" = "$normalized_device" ]; then
            dt_debug "Exact match: '$device' (score: 100)"
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
            current_score=$(( 80 + (''${#search_words[@]} * 5) )) # Base 80 + bonus for more words
            dt_debug "All words match: '$device' (score: $current_score)"
          fi
          
          if [ $current_score -eq 0 ] && [[ "$normalized_device" == *"$normalized_search"* ]]; then
            current_score=75
            dt_debug "Substring match: '$device' (score: $current_score)"
          fi
          
          if [ $current_score -eq 0 ] && [[ "$normalized_search" == *"$normalized_device"* ]]; then
            current_score=70
            dt_debug "Reverse substring match: '$device' (score: $current_score)"
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
            dt_debug "Device: '$device' - Trigram: $trigram_score%, Levenshtein: $levenshtein_score%, Combined: $current_score%"
          fi
          
          if [ $current_score -gt $best_score ]; then
            best_score=$current_score
            best_match="$device"
          fi
        done
        
        if [ $best_score -ge 50 ]; then
          dt_debug "Best match: '$best_match' (score: $best_score%)"
          echo "$best_match"
          return 0
        else
          dt_error "No good match found for '$search_term'. Best was '$best_match' with $best_score% similarity"
          return 1
        fi
      }
      
      # 🦆 says ⮞ state helper
      get_device_state() {
        local device_name="$1"
        local state_data="$2"
        local normalized_name=$(normalize_string "$device_name")
        
        # 🦆 says ⮞ BLINDS / SHADES
        local position=$(echo "$state_data" | ${pkgs.jq}/bin/jq -r --arg device "$device_name" '.[$device].position // empty')
        if [ -n "$position" ] && [ "$position" != "null" ]; then
          if [ "$position" = "0" ]; then
            echo "CLOSED"
          elif [ "$position" = "100" ]; then
            echo "OPEN"
          else
            echo "$position%"
          fi
          return
        fi
        
        # 🦆 says ⮞ DOOR / WINDOW SENSORS
        local contact=$(echo "$state_data" | ${pkgs.jq}/bin/jq -r --arg device "$device_name" '.[$device].contact // empty')
        if [ -n "$contact" ] && [ "$contact" != "null" ]; then
          if [ "$contact" = "true" ]; then
            echo "CLOSED"
          else
            echo "OPEN"
          fi
          return
        fi
        
        # 🦆 says ⮞ MOTION SENSORS
        local occupancy=$(echo "$state_data" | ${pkgs.jq}/bin/jq -r --arg device "$device_name" '.[$device].occupancy // empty')
        if [ -n "$occupancy" ] && [ "$occupancy" != "null" ]; then
          if [ "$occupancy" = "true" ]; then
            echo "MOTION"
          else
            echo "NOMOTION"
          fi
          return
        fi
                
        # 🦆 says ⮞ STATE        
        local state=$(echo "$state_data" | ${pkgs.jq}/bin/jq -r --arg device "$device_name" '.[$device].state // "N/A"')
        if [ "$state" != "N/A" ] && [ "$state" != "null" ]; then
          echo "$state"
          return
        fi
        
        # 🦆 says ⮞ device online? based on link quality & last_seen
        local linkquality=$(echo "$state_data" | ${pkgs.jq}/bin/jq -r --arg device "$device_name" '.[$device].linkquality // 0')
        local last_seen=$(echo "$state_data" | ${pkgs.jq}/bin/jq -r --arg device "$device_name" '.[$device].last_seen // empty')
        if [ -n "$last_seen" ] && [ "$last_seen" != "null" ]; then
          last_seen_epoch=$(${pkgs.coreutils}/bin/date -d "$last_seen" +%s 2>/dev/null || echo 0)
          now_epoch=$(${pkgs.coreutils}/bin/date +%s)
          diff=$(( now_epoch - last_seen_epoch ))
        else
          diff=999999
        fi
        if [ "$linkquality" -gt 1 ] && [ "$diff" -le 86400 ]; then
          echo "ONLINE"
        else
          echo "OFFLINE"
        fi
      }
  
      dt_debug "MQTT_HOST: $MQTT_HOST"
      dt_debug "Input device: $device"   
      matched_device=$(fuzzy_find_device "$device" "''${available_devices[@]}")    
      if [ $? -ne 0 ] || [ -z "$matched_device" ]; then
        dt_error "Could not find device matching '$device'"
        exit 1
      fi
      
      dt_debug "Using device: $matched_device"
      
      # 🦆 says ⮞ get state file data
      state_data=$(ssh "$MQTT_HOST" cat "$STATE_FILE")
      # 🦆 says ⮞ fetch da state
      state=$(get_device_state "$matched_device" "$state_data")   
      dt_debug "State: $state"
      last_seen=$(echo "$state_data" | ${pkgs.jq}/bin/jq -r --arg device "$matched_device" '.[$device].last_seen // empty')

      # 🦆 says ⮞ start building voice responnse
      if [ "$last_seen" != "null" ] && [ -n "$last_seen" ]; then
        formatted_last_seen=$(
          ${pkgs.coreutils}/bin/date -d "$last_seen" '+%A den %d %B %Y, klockan %H:%M:%S' --locale=sv_SE.UTF-8 2>/dev/null ||
          ${pkgs.coreutils}/bin/date -d "@$(echo "$last_seen" | cut -c1-10)" '+%A den %d %B %Y, klockan %H:%M:%S' --locale=sv_SE.UTF-8 2>/dev/null ||
          echo "Unknown"
        )
      else
        formatted_last_seen=""
      fi
            
      if [ "$formatted_last_seen" != "null" ] && [ -n "$formatted_last_seen" ] && [ "$formatted_last_seen" != "Unknown" ]; then
        updated="Senast uppdaterad den $formatted_last_seen"
      else
        updated=""
      fi      
      echo "$state"
     
      case "$state" in
        "ON")
          if_voice_say "$matched_device är påslagen."
          dt_debug "TTS: $matched_device är påslagen."
          ;;
        "OFF")
          if_voice_say "$matched_device är avslagen."
          dt_debug "TTS: $matched_device är avslagen."
          ;;
        "OPEN")
          if_voice_say "$matched_device är öppen."
          dt_debug "TTS: $matched_device är öppen."
          ;;
        "CLOSED")
          if_voice_say "$matched_device är stängd."
          dt_debug "TTS: $matched_device är stängd."
          ;;
        "MOTION")
          if_voice_say "Rörelse upptäckt på $matched_device."
          dt_debug "TTS: Rörelse upptäckt på $matched_device."
          ;;
        "NOMOTION")
          if_voice_say "Ingen rörelse på $matched_device."
          dt_debug "TTS: Ingen rörelse på $matched_device."
          ;;
        "ONLINE")
          if_voice_say "$matched_device är online."
          dt_debug "TTS: $matched_device är online."
          ;;
        "OFFLINE")
          if_voice_say "Varning! $matched_device är offline."
          dt_debug "TTS: Varning! $matched_device är offline."
          ;;
        *%)
          if_voice_say "$matched_device är öppen till $state."
          dt_debug "TTS: $matched_device är öppen till $state."
          ;;
      esac
    '';
    voice = {
      enabled = true;	
      priority = 5;
      sentences = [ 
        "är {device} på[slagen] [slagen]"
        "är {device} på eller av"
        "är {device} öppen"
        "är {device} stängd"
        "är {device} [öppen|stängd]"
        "vad är status på {device}"
        "status {device}"
      ];
      lists = {
        device.values = let
          reservedNames = [ "hall" "kök" "sovrum" "toa" "wc" "vardagsrum" "kitchen" "switch" ];
          sanitize = str:
            lib.replaceStrings [ "/" ] [ "" ] str;
        in
          lib.filter (x: x != null) (
            lib.mapAttrsToList (_: device:
              let
                baseRaw = lib.toLower device.friendly_name;
                base = sanitize baseRaw;
                baseWords = lib.splitString " " base;
                isAmbiguous = lib.any (word: lib.elem word reservedNames) baseWords;
                hasLampSuffix = lib.hasSuffix "lampa" base;
                lampanVariant = if hasLampSuffix then [ "${base}n" ] else [];  
                enVariant = [ "${base}en" ];
                variations = lib.unique ([
                  base
                  (sanitize (lib.replaceStrings [ " " ] [ "" ] base))
                ] ++ lampanVariant ++ enVariant);
              in if isAmbiguous then null else {
                "in" = "[" + lib.concatStringsSep "|" variations + "]";
                out = device.friendly_name;
              }
            ) zigbeeDevices
          );
      };
    };
    
  };}
