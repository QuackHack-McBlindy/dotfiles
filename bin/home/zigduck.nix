# dotfiles/bin/home/zigduck.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # From Quack to Stack: A Declarative Zigbee and home automation system
  self, # 🦆 says ⮞ Welcome to QuackHack-McBLindy'z Quacky Hacky Home of Fun! 
  lib, 
  config, # 🦆 says ⮞ duck don't write automations - duck write infra with junkie comments on each line.... quack
  pkgs,
  cmdHelpers, # 🦆 with MQTT dreams and zigbee schemes.
  ... 
} : let # yo follow 🦆 home ⬇⬇ 🦆 says diz way plz? quack quackz
  # 🦆 says ⮞ Directpry  for this configuration 
  zigduckDir = "/var/lib/zigduck";
  # 🦆 says ⮞ don't stick it to the duck - encrypted Zigbee USB coordinator backup filepath
  backupEncryptedFile = "${config.this.user.me.dotfilesDir}/secrets/zigbee_coordinator_backup.json";
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = lib.findSingle (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) null null sysHosts;    
  mqttHostip = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or (
      let
        resolved = builtins.readFile (pkgs.runCommand "resolve-host" {} ''
          ${pkgs.dnsutils}/bin/host -t A ${mqttHost} > $out
        '');
      in
        lib.lists.head (lib.strings.splitString " " (lib.lists.elemAt (lib.strings.splitString "\n" resolved) 0))
    )
    else (throw "No Mosquitto host found in configuration");
  mqttAuth = "-u mqtt -P $(cat ${config.sops.secrets.mosquitto.path})";
   
  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = config.house.zigbee.devices;
  
  # 🦆 says ⮞ case-insensitive device matching
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ device validation list
  deviceList = builtins.attrNames normalizedDeviceMap;

  # 🦆 says ⮞ scene simplifier? or not
  sceneLight = {state, brightness ? 200, hex ? null, temp ? null}:
    let
      colorValue = if hex != null then { inherit hex; } else null;
    in
    {
      inherit state brightness;
    } // (if colorValue != null then { color = colorValue; } else {})
      // (if temp != null then { color_temp = temp; } else {});

  # 🎨 Scenes  🦆 YELLS ⮞ SCENES!!!!!!!!!!!!!!!11
  scenes = config.house.zigbee.scenes; # 🦆 says ⮞ Declare light states, quack dat's a scene yo!   

  # 🦆 says ⮞ Generate scene commands    
  makeCommand = device: settings:
    let
      json = builtins.toJSON settings;
    in
      ''
      mqtt_pub -t "zigbee2mqtt/${device}/set" -m '${json}'
      '';
      
  sceneCommands = lib.mapAttrs
    (sceneName: sceneDevices:
      lib.mapAttrs (device: settings: makeCommand device settings) sceneDevices
    ) scenes;  

  # 🦆 says ⮞ Filter devices by rooms
  byRoom = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.room} = (acc.${dev.room} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # 🦆 says ⮞ Filter by device type
  byType = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.type} = (acc.${dev.type} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # 🦆 says ⮞ dis creates group configuration for Z2M yo
  groupConfig = lib.mapAttrs' (room: ids: {
    name = room;
    value = {
      friendly_name = room;
      devices = map (id: 
        let dev = zigbeeDevices.${id};
        in "${id}/${toString dev.endpoint}"
      ) ids;
    };
  }) byRoom;

  # 🦆 says ⮞ gen json from `config.house.tv`  
  tvDevicesJson = pkgs.writeText "tv-devices.json" (builtins.toJSON config.house.tv);

  # 🦆 says ⮞ dis creates device configuration for Z2M yo
  deviceConfig = lib.mapAttrs (id: dev: {
    friendly_name = dev.friendly_name;
  }) zigbeeDevices;

  # 🦆 says ⮞ IEEE not very human readable - lets fix dat yo
  ieeeToFriendly = lib.mapAttrs (ieee: dev: dev.friendly_name) zigbeeDevices;
  mappingJSON = builtins.toJSON ieeeToFriendly;
  mappingFile = pkgs.writeText "ieee-to-friendly.json" mappingJSON;

  # 🦆 says ⮞ not to be confused with facebook - this is not even duckbook
  deviceMeta = builtins.toJSON (
    lib.listToAttrs (
      lib.filter (attr: attr.name != null) (
        lib.mapAttrsToList (_: dev: {
          name = dev.friendly_name;
          value = {
            room = dev.room;
            type = dev.type;
            id = dev.friendly_name;
            endpoint = dev.endpoint;
          };
        }) zigbeeDevices
      )
    )
  );# 🦆 says ⮞ yaaaaaaaaaaaaaaay

in {
  # 🦆 says ⮞ zigduck bash the original og yo
  yo.scripts.zigduck = { # 🦆 says ⮞ dis is where my home at
    description = "[🦆🏡] yo zigduck - Home automation system written in Bash";
    category = "🛖 Home Automation"; # 🦆 says ⮞ thnx for following me home
    #autoStart = config.this.host.hostname == "homie"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
    #aliases = [ "hem" ]; # 🦆 says ⮞ and not laughing at me
    # 🦆 says ⮞ run `yo zigduck --help` to display your battery states!
    helpFooter = '' 
      # 🦆 says ⮞ TODO - TUI/GUI Group Control within help command  # 🦆 says ⮜ dis coold be cool yeah?!
      STATE_DIR=/var/lib/zigbee
      STATE_FILE="state.json"
      WIDTH=100
      cat <<EOF | ${pkgs.glow}/bin/glow --width $WIDTH -
## ──────⋆⋅☆⋅⋆────── ##
## 🔋 Battery Status
$(${pkgs.jq}/bin/jq -r --slurpfile mapping ${mappingFile} '
  to_entries[] |
  select(.value.battery != null) |
  .key as $ieee |
  .value.battery as $battery |
  ($mapping[0] | .[$ieee] // $ieee) as $display_name |
  "### 🖥️ Device: `\($display_name)`\n**Battery:** \($battery)% " +
  (
    if $battery >= 75 then "🔋"
    elif $battery >= 30 then "🟡"
    else "🪫"
    end
  ) + "\n"
' $STATE_DIR/$STATE_FILE)
## ──────⋆⋅☆⋅⋆────── ##
EOF
    '';
    logLevel = "INFO";
    parameters = [ # 🦆 says ⮞ set your mosquitto user & password
      { name = "user"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "pwfile"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
    ]; # 🦆 says ⮞ Script entrypoint yo
    code = ''
      ${cmdHelpers} # 🦆 says ⮞ load default helper functions 
      DEBUG_MODE=DEBUG # 🦆 says ⮞ if true, duck logs flood
      ZIGBEE_DEVICES='${deviceMeta}'
      MQTT_BROKER="${mqttHostip}" && dt_debug "$MQTT_BROKER"
      MQTT_USER="$user" && dt_debug "$MQTT_USER"
      MQTT_PASSWORD=$(cat "$pwfile")
      STATE_DIR="${zigduckDir}"
      STATE_FILE="$STATE_DIR/state.json"
      TIMER_DIR="$STATE_DIR/timers" 
      BACKUP_ID=""
      BACKUP_TMP_FILE=""

      LARMED_FILE="$STATE_DIR/security_state.json"
      umask 077
      mkdir -p "$STATE_DIR" && mkdir -p "$TIMER_DIR"
      if [ ! -f "$STATE_FILE" ]; then
        echo "{}" > "$STATE_FILE"
        chmod 600 "$STATE_FILE"
      fi   

      update_device_state() {
        local device="$1"
        local key="$2"
        local value="$3"  
        local tmpfile
        tmpfile=$(mktemp 2>/dev/null || echo "/tmp/tmp.XXXXXX")
        tmpfile=$(mktemp 2>/dev/null || echo "$STATE_DIR/tmp.XXXXXX")
  
        if [ $? -ne 0 ]; then
          tmpfile="$STATE_DIR/tmp.$$.$RANDOM"
        fi
  
        touch "$tmpfile" 2>/dev/null || {
          dt_error "Cannot create temp file: $tmpfile"
          return 1
        }  
        chmod 600 "$tmpfile" 2>/dev/null  
        dt_debug "Updating state: $device.$key = $value"
  
        if [ -f "$STATE_FILE" ]; then
          ${pkgs.jq}/bin/jq --arg dev "$device" --arg key "$key" --arg val "$value" \
            '.[$dev][$key] = $val' "$STATE_FILE" > "$tmpfile" 2>/dev/null
        else
          echo "{}" | ${pkgs.jq}/bin/jq --arg dev "$device" --arg key "$key" --arg val "$value" \
            '.[$dev][$key] = $val' > "$tmpfile" 2>/dev/null
        fi  
        if [ $? -eq 0 ]; then
          mv "$tmpfile" "$STATE_FILE" 2>/dev/null && \
          chmod 644 "$STATE_FILE" 2>/dev/null
          dt_debug "Successfully updated state for $device"
        else
          dt_error "jq failed to update state for $device.$key"
          rm -f "$tmpfile" 2>/dev/null
          return 1
        fi
      }      
      
      if [ ! -f "$LARMED_FILE" ]; then
        echo '{"larmed":false}' > "$LARMED_FILE"
      fi

      set_larmed() {
        local state="$1"
        jq -n --argjson val "$state" '{larmed: $val}' > "$LARMED_FILE"
        mqtt_pub -t "zigbee2mqtt/security/state" -m "$(cat "$LARMED_FILE")"
        
        if [ "$state" = "true" ]; then
          dt_warning "🛡️ Security system ARMED"
          yo notify "🛡️ Security armed"
        else
          dt_warning "🛡️ Security system DISARMED"
          yo notify "🛡️ Security disarmed"
        fi
      }
      get_state() {
        local device="$1"
        local key="$2"
        ${pkgs.jq}/bin/jq -r ".\"$device\".\"$key\" // empty" "$STATE_FILE"
      }      
      get_larmed() {
        ${pkgs.jq}/bin/jq -r '.larmed' "$LARMED_FILE"
      }
      # 🦆 says ⮞ device parser for zigduck
      device_check() { 
        linkquality=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.linkquality // empty') && dt_debug "linkquality: $linkquality"
        last_seen=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.last_seen // empty') && dt_debug "last_seen: $last_seen"
        occupancy=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.occupancy // empty') && dt_debug "occupancy: $occupancy"
        action=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.action // empty') && dt_debug "action: $action"
        contact=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.contact // empty') && dt_debug "contact: $contact"
        position=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.position // empty') && dt_debug "position: $position"
        state=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.state // empty') && dt_debug "state: $state"
        brightness=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.brightness // empty') && dt_debug "brightness: $brightness"
        color=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.color // empty') && dt_debug "color: $color"
        water_leak=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.water_leak // empty') && dt_debug "water_leak: $water_leak"
        waterleak=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.waterleak // empty') && dt_debug "waterleak: $waterleak"
        temperature=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.temperature // empty') && dt_debug "temperature: $temperature"

        battery=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.battery // empty') && dt_debug "battery: $battery"
        battery_state=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.battery_state // empty') && dt_debug "battery state: $battery_state"
        tamper=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.tamper // empty') && dt_debug "Tamper: $tamper"
        smoke=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.smoke // empty') && dt_debug "Smoke: $smoke"
                
        device_name="''${topic#zigbee2mqtt/}" && dt_debug "device_name: $device_name"
        dev_room=$(${pkgs.jq}/bin/jq ".\"$device_name\".room" $STATE_DIR/zigbee_devices.json) && dt_debug "dev_room: $dev_room"
        dev_type=$(${pkgs.jq}/bin/jq ".\"$device_name\".type" $STATE_DIR/zigbee_devices.json) && dt_debug "dev_type: $dev_type"     
        dev_id=$(${pkgs.jq}/bin/jq ".\"$device_name\".id" $STATE_DIR/zigbee_devices.json) && dt_debug "dev_id: $dev_id"  
        room="''${dev_room//\"/}"
      
        should_update() {
          case "$device_name" in
            */set|*/availability)
              dt_debug "Skipping update for device: $device_name (set/availability topic)"
              return 1
            ;;
            *)
              dt_debug "Will update state for device: $device_name"
              return 0  
            ;;
          esac
        }

        if should_update; then
          [ -n "$battery" ] && update_device_state "$device_name" "battery" "$battery"
          [ -n "$temperature" ] && update_device_state "$device_name" "temperature" "$temperature"
          [ -n "$state" ] && update_device_state "$device_name" "state" "$state"
          [ -n "$brightness" ] && update_device_state "$device_name" "brightness" "$brightness"
          [ -n "$color" ] && update_device_state "$device_name" "color" "$color"        
          [ -n "$position" ] && update_device_state "$device_name" "position" "$position"
          [ -n "$contact" ] && update_device_state "$device_name" "contact" "$contact"
          [ -n "$tamper" ] && update_device_state "$device_name" "tamper" "$tamper"
          [ -n "$smoke" ] && update_device_state "$device_name" "smoke" "$smoke"
          [ -n "$battery_state" ] && update_device_state "$device_name" "Battery state" "$battery_state"
          [ -n "$occupancy" ] && update_device_state "$device_name" "occupancy" "$occupancy"
         
          [ -n "$last_seen" ] && update_device_state "$device_name" "last_seen" "$last_seen"        
          [ -n "$linkquality" ] && update_device_state "$device_name" "linkquality" "$linkquality"       
        else
          dt_debug "Skipped state update for device: $device_name"
        fi
      }
  
      # 🦆 says ⮞ zigbee coordinator backup function
      perform_zigbee_backup() {
        BACKUP_ID="zigbee_backup_$(${pkgs.coreutils}/bin/date +%Y%m%d_%H%M%S)"
        BACKUP_TMP_FILE="$(mktemp)"
        say_duck "Triggering Zigbee coordinator backup: $BACKUP_ID"
        mqtt_pub -t "zigbee2mqtt/bridge/request/backup" -m "{\"id\": \"$BACKUP_ID\"}"
      }
      # 🦆 says ⮞ handle backup response function
      handle_backup_response() {
        local line="$1"
        local backup_id=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.id')        
        if [ "$backup_id" != "$BACKUP_ID" ]; then
          dt_info "ignoring backup response for ID: $backup_id (waiting for $BACKUP_ID)"
          return
        fi      
        local status=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.status')
        if [ "$status" = "ok" ]; then
          echo "$line" | ${pkgs.jq}/bin/jq -r '.data.backup' > "$BACKUP_TMP_FILE"
          dt_debug "Encrypting Zigbee coordinator backup with sops..."   
          if "''${config.pkgs.yo}/bin/yo-sops" "$BACKUP_TMP_FILE" > "${backupEncryptedFile}"; then
            dt_info "Backup saved to: ${backupEncryptedFile}"
          else
            say_duck "fuck ❌ encryption failed for zigbee coordinator backup!"
            dt_critical "Encryption failed for zigbee coordinator backup!"
          fi
          rm -f "$BACKUP_TMP_FILE"
        else
          local error_msg=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.error')
          say_duck "❌ Backup failed: $error_msg"
          dt_critical "Backup failed: $error_msg"
        fi    
        # 🦆 says ⮞ reset states
        BACKUP_ID=""
        BACKUP_TMP_FILE=""
      }  
      # 🦆 says ⮞ main loop - ducks can't listen but mosquitto's can apparently    
      start_listening() {
        echo "$ZIGBEE_DEVICES" | ${pkgs.jq}/bin/jq 'map({(.id): .}) | add' > $STATE_DIR/zigbee_devices.json
        ${pkgs.jq}/bin/jq 'map(select(.friendly_name != null) | {(.friendly_name): .}) | add' $STATE_DIR/zigbee_devices.json \
          > $STATE_DIR/zigbee_devices_by_friendly_name.json
        # 🦆 says ⮞ last echo
        echo "[🦆🏡] ⮞ Welcome Home" 
        
        # 🦆 says ⮞ performance tracking
        declare -A processing_times
        declare -A message_counts
        local total_messages=0
        local slow_threshold=100 # 🦆 says ⮞ ms        
        
        # 🦆 says ⮞ Subscribe and split topic and payload
        mqtt_sub "zigbee2mqtt/#" | while IFS='|' read -r topic line; do
          dt_debug "TOPIC: 
          $topic" && dt_debug "PAYLOAD: 
          $line"         
          # 🦆 says ⮞ backup handling
          if [ "$topic" = "zigbee2mqtt/bridge/response/backup" ]; then handle_backup_response "$line"; fi          
          # 🦆 says ⮞ trigger backup from MQTT
          if [ "$topic" = "zigbee2mqtt/backup/request" ]; then perform_zigbee_backup; fi

          # 🦆 says ⮞ TV  DEVICES CHANNEL STATE 
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("tvChannel")' > /dev/null; then
              channel=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.tvChannel')
              ip=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.ip // "192.168.1.223"')
              if [ -n "$channel" ]; then
                  dt_info "TV channel change requested! Channel: $channel . IP: $ip"
                  device_name=$(${pkgs.jq}/bin/jq -r --arg ip "$ip" '
                      to_entries[] | select(.value.ip == $ip) | .key
                  ' "${tvDevicesJson}")
                  if [ -n "$device_name" ] && [ "$device_name" != "null" ]; then
                      dt_info "Changing channel on $device_name ($ip) to: $channel"
                      yo tv --typ livetv --device "$ip" --search "$channel"
                  else
                      dt_warning "Unknown TV device IP: $ip, attempting channel change anyway"
                      yo tv --typ livetv --device "$ip" --search "$channel"
                  fi
              fi
              continue
          fi

          # 🦆 says ⮞ TV CHANNEL STATE UPDATES          
          if [[ "$topic" == zigbee2mqtt/tv/*/channel ]]; then
              device_ip=$(echo "$topic" | cut -d'/' -f3)
              channel_id=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.channel_id')
              channel_name=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.channel_name')
              device_name=$(${pkgs.jq}/bin/jq -r --arg ip "$device_ip" '
                  to_entries[] | select(.value.ip == $ip) | .key
              ' "${tvDevicesJson}")
              if [ -n "$device_name" ] && [ "$device_name" != "null" ]; then
                  dt_info "📺 $device_name live tv channel: $channel_name"
                  update_device_state "tv_$device_name" "current_channel" "$channel_id"
                  update_device_state "tv_$device_name" "current_channel_name" "$channel_name"
                  update_device_state "tv_$device_name" "last_update" "$(${pkgs.coreutils}/bin/date -Iseconds)"
              fi
              continue
          fi
          
          # 🦆 says ⮞ ENERGY CONSUMPTION & PRICE
          if [ "$topic" = "zigbee2mqtt/tibber/price" ]; then
              current_price=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.current_price')
              if [ -n "$current_price" ]; then
  
                update_device_state "tibber" "current_price" "$current_price"
                  dt_info "Energy price updated: $current_price SEK/kWh"
              fi
              continue
          fi

          if [ "$topic" = "zigbee2mqtt/tibber/usage" ]; then
              monthly_usage=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.monthly_usage')
              if [ -n "$monthly_usage" ]; then
                  update_device_state "tibber" "monthly_usage" "$monthly_usage"
                  dt_info "Energy usage updated: $monthly_usage kWh"
              fi
              continue
          fi

          # 🦆 says ⮞ 🚨 alarm
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("security")' > /dev/null; then 
            if [ "$LARMED" = "true" ]; then
              dt_info "Larmed apartment"
              yo notify "Larm på"
            fi
          fi
          
          # 🦆 says ⮞ 🔋 battery
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("battery")' > /dev/null; then
            device_check
            prev_battery=$(${pkgs.jq}/bin/jq -r ".\"$device_name\".battery" "$STATE_FILE")

            if [ "$battery" != "$prev_battery" ] && [ "$prev_battery" != "null" ]; then
              dt_info "🔋 Battery update for $device_name: ''${prev_battery}% > ''${battery}%"
            fi
          fi

          # 🦆 says ⮞ 🌡️ temperature
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("temperature")' > /dev/null; then
            device_check
            prev_temp=$(${pkgs.jq}/bin/jq -r ".\"$device_name\".temperature" "$STATE_FILE")
            if [ "$temperature" != "$prev_temp" ] && [ "$prev_temp" != "null" ]; then
              dt_info "🌡️ Temperature update for $device_name: ''${prev_temp}°C > ''${temperature}°C"
            fi
          fi
         
          # 🦆 says ⮞ left home yo
          # call with: mosquitto_pub -h IP -t "zigbee2mqtt/leaving_home" -m "LEFT"
          if [ "$line" = "LEFT" ]; then
            set_larmed true            
          fi
          # 🦆 says ⮞ returned homez
          # calll mosquitto_pub -h "${mqttHostip}" -t "zigbee2mqtt/returning_home" -m "RETURN" 
          if [ "$line" = "RETURN" ]; then
            set_larmed false
          fi

          # 🦆 says ⮞ ❤️‍🔥 SMOKE SMOKE SMOKE
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("smoke")' > /dev/null; then
            device_check            
            if [ "$smoke" = "true" ]; then
              yo notify "❤️‍🔥❤️‍🔥❤️‍🔥 FIRE !!! ❤️‍🔥❤️‍🔥❤️‍🔥"
              echo "❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥"
              dt_critical "❤️‍🔥❤️‍🔥 SMOKE! in in $device_name $dev_room"
            fi
          fi
          
          # 🦆 says ⮞ 🕵️ quick quack motion detect
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("occupancy")' > /dev/null; then
            device_check   
            dt_info "🕵️ Occupancy update for $device_name: $occupancy (prev: $(get_state "$device_name" "occupancy"))"  
            if [ "$occupancy" = "true" ]; then
              # 🦆 says ⮞ save for easy user localisation
              echo "{\"last_active_room\": \$dev_room\, \"timestamp\": \"$(${pkgs.coreutils}/bin/date -Iseconds)\"}" > "$STATE_DIR/last_motion.json"
              dt_info "🕵️ Motion in $device_name $dev_room"
              # 🦆 says ⮞ track last motion time 
              update_device_state "apartment" "last_motion" "$(${pkgs.coreutils}/bin/date +%s)"
              # 🦆 says ⮞ If current time is within motion > light timeframe - turn on lights
              if is_dark_time; then
                room_lights_on "$room"
                reset_room_timer "$room"
              else
                dt_debug "❌ Daytime - no lights activated by motion."
              fi
            else
              dt_debug "🛑 No more motion in $device_name $dev_room"    
              update_device_state "$device_name" "occupancy" "false"
            fi
          fi

          # 🦆 says ⮞ 💧 water sensor
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("water_leak")' > /dev/null; then
            device_check            
            if [[ "$water_leak" == "true" || "$waterleak" == "true" ]]; then
              dt_critical "💧 WATER LEAK DETECTED in $dev_room on $device_name"
              yo notify "💧 WATER LEAK DETECTED in $dev_room on $device_name"
              sleep 15
              yo notify "WATER LEAK DETECTED in $dev_room on $device_name"
            fi
          fi
          
          # 🦆 says ⮞ 🚪 door and window sensor yo 
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("contact")' > /dev/null; then
            device_check
            dt_info "🚪 Door open in $dev_room ($device_name)"
            current_time=$(${pkgs.coreutils}/bin/date +%s)
            last_motion=$(get_state "apartment" "last_motion")
            time_diff=$((current_time - last_motion))
            dt_debug "TIME: $current_time | LAST MOTION: $last_motion | TIME DIFF: $time_diff"
            # 🦆 says ⮞ diz iz a fun one - if i've been gone for >2 hours
            if [ $time_diff -gt 7200 ]; then 
              dt_info "Welcoming you home! (no motion for 2 hours, door opened"
              # 🦆 says ⮞ then greet me welcome home - so i can say "quack? thanx yo!"
              sleep 5 && yo say --text "Välkommen hem!" --host "desktop"
            else
              dt_info "🛑 NOT WELCOMING:🛑 only $((time_diff/60)) minutes since last motion"
            fi
          fi       

          # 🦆 says ⮞ 🪟 BLIND & shaderz
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("position")' > /dev/null; then
            device_check
            if [ "$dev_type" = "blind" ]; then 
              if [ "$position" = "0" ]; then
                dt_info "🪟 Rolled DOWN $device_name in $dev_room"
              fi     
              if [ "$position" = "100" ]; then
                dt_info "🪟 Rolled UP $device_name in $dev_room"
              fi
            fi  
          fi  

          # 🦆 says ⮞ 🔌 power plugz & energy meterz
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("state")' > /dev/null; then
            device_check     
            if [[ "$dev_type" == "plug" || "$dev_type" == "power" || "$dev_type" == "outlet" ]]; then
              if [ "$state" = "ON" ]; then      
                dt_info "🔌 $device_name Turned ON in $dev_room"
              fi       
              if [ "$state" = "OFF" ]; then
                dt_info "🔌 $device_name Turned OFF in $dev_room"
              fi  
            else  

          # 🦆 says ⮞ 💡 state change (debug)      
              if [ "$state" = "OFF" ]; then
                dt_debug "💡 $device_name Turned OFF in $dev_room"
              fi  
              if [ "$state" = "ON" ]; then
                dt_debug "💡 $device_name Turned ON in $dev_room"
              fi                
            fi  
          fi 

          # 🦆 says ⮞ 🎚 Dimmer Switch actions
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("action")' > /dev/null; then
            device_check       
            if [ "$action" == "on_press_release" ]; then
              # 🦆 says ⮞ turn on all lights in the room
              room_lights_on "$room"
            # 🦆 says ⮞ yo homie, turn the fan on when grillin'
            if [ "$clean_room" == "kitchen" ]; then mqtt_pub -t "zigbee2mqtt/Fläkt/set" -m '{"state":"ON"}'; fi
            fi
            if [ "$action" == "on_hold_release" ]; then scene "max" && dt_debug "✅💡 MAX LIGHTS ON"; fi
            if [ "$action" == "up_press_release" ]; then
              clean_room=$(echo "$dev_room" | sed 's/"//g')
                ${pkgs.jq}/bin/jq -r --arg room "$clean_room" 'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' $STATE_DIR/zigbee_devices.json |
                  while read -r light_id; do
                    dt_debug "🔺 Increasing brightness on $light_id in $clean_room"
                    mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"brightness_step":50,"transition":3.5}'
                  done
            fi
            if [ "$action" == "up_hold_release" ]; then dt_debug "$action"; fi
            if [ "$action" == "down_press_release" ]; then
              clean_room=$(echo "$dev_room" | sed 's/"//g')
              ${pkgs.jq}/bin/jq -r --arg room "$clean_room" 'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' $STATE_DIR/zigbee_devices.json |
                while read -r light_id; do
                  dt_debug "🔻 Decreasing $light_id in $clean_room"
                  mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"brightness_step":-50,"transition":3.5}'
                done
            fi
            if [ "$action" == "down_hold_release" ]; then dt_debug "$action"; fi
            if [ "$action" == "off_press_release" ]; then room_lights_off "$room"; fi
            if [ "$action" == "off_hold_release" ]; then scene "dark" && dt_debug "DARKNESS ON"; fi
          fi
          
          # 🦆 says ⮞ 🛒 shopping list functionality
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("shopping_action")' > /dev/null; then
            shopping_action=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.shopping_action')
            item=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.item // ""')  
            SHOPPING_LIST_FILE="$STATE_DIR/shopping_list.txt"  
            case "$shopping_action" in
              "add")
                if [ -n "$item" ]; then
                  echo "$item" >> "$SHOPPING_LIST_FILE"
                  dt_info "🛒 Added '$item' to shopping list"
                  mqtt_pub -t "zigbee2mqtt/shopping_list/updated" -m "{\"action\": \"add\", \"item\": \"$item\"}"
                  yo notify "🛒 Added: $item"
                fi
                ;;
              "remove")
                if [ -n "$item" ]; then
                  grep -v -i -- "^$item\$" "$SHOPPING_LIST_FILE" > "$SHOPPING_LIST_FILE.tmp" && mv "$SHOPPING_LIST_FILE.tmp" "$SHOPPING_LIST_FILE"
                  dt_info "🛒 Removed '$item' from shopping list"
                  mqtt_pub -t "zigbee2mqtt/shopping_list/updated" -m "{\"action\": \"remove\", \"item\": \"$item\"}"
                  yo notify "🛒 Removed: $item"
                fi
                ;;
              "clear")
                > "$SHOPPING_LIST_FILE"
                dt_info "🛒 Cleared shopping list"
                mqtt_pub -t "zigbee2mqtt/shopping_list/updated" -m "{\"action\": \"clear\"}"
                yo notify "🛒 List cleared"
                ;;
              "view")
                if [ -f "$SHOPPING_LIST_FILE" ] && [ -s "$SHOPPING_LIST_FILE" ]; then
                  list_content=$(cat "$SHOPPING_LIST_FILE" | tr '\n' ',' | sed 's/,$//')
                  mqtt_pub -t "zigbee2mqtt/shopping_list/current" -m "{\"items\": \"$list_content\"}"
                else
                  mqtt_pub -t "zigbee2mqtt/shopping_list/current" -m "{\"items\": \"\"}"
                fi
                ;;
            esac
            continue
          fi
          
          # 🦆 says ⮞ 🤖 yo do commands
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("command")' > /dev/null; then
            command=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.command')
            if [ -n "$command" ]; then
              dt_info "yo do execution requested from web interface: yo do $command"
              yo do "$command" &
            fi
            continue
          fi

          # 🦆 says ⮞ 📺 yo TV commands
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("tvCommand")' > /dev/null; then
            command=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.tvCommand')
            ip=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.ip')
            if [ -n "$command" ]; then
              dt_info "TV command receieved! Command: $command . IP: $ip"
              yo tv --typ $command --device $ip
            fi
            continue
          fi
          
          local end_time=$(date +%s%N)
          local duration=$(( (end_time - start_time) / 1000000 ))
        
          # 🦆 says ⮞ update MA for this topic type
          local current_avg=''${processing_times["$topic"]:-0}
          processing_times["$topic"]=$(( (current_avg + duration) / 2 ))
          message_counts["$topic"]=$(( ''${message_counts["$topic"]:-0} + 1 ))
        
          # 🦆 says ⮞ slow? log it
          if [ $duration -gt $slow_threshold ]; then
            dt_warning "Slow processing: $topic took ''${duration}ms"
          fi
        
          # 🦆 says ⮞ log performance every 100 messages
          if [ $((total_messages % 100)) -eq 0 ]; then
            dt_info "[🦆📶] - Total messages: $total_messages"
            for topic_type in "''${!processing_times[@]}"; do
              local avg_time=''${processing_times["$topic_type"]}
              local count=''${message_counts["$topic_type"]}
              dt_debug "  $topic_type: avg ''${avg_time}ms, count $count"
            done
          fi
             
        done
      }
            
      # 🦆 says ⮞ ran diz thang
      dt_info "🚀 Starting zigduck automation system"  
      say_duck "🚀 quack to the moon yo!"
      dt_info "📡 Listening to all Zigbee events..."
      start_listening             
    '';
  };
   
  # 🦆 says ⮞ how does ducks say ssschh?
  sops.secrets = {
    mosquitto = { # 🦆 says ⮞ quack, stupid!
      sopsFile = ./../../secrets/mosquitto.yaml; 
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    }; # 🦆 says ⮞ Z2MQTT encryption key - if changed needs re-pairing devices
    z2m_network_key = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) { 
      sopsFile = ./../../secrets/z2m_network_key.yaml; 
      owner = "zigbee2mqtt";
      group = "zigbee2mqtt";
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    };
    z2m_mosquitto = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) { 
      sopsFile = ./../../secrets/z2m_mosquitto.yaml; 
      owner = "zigbee2mqtt";
      group = "zigbee2mqtt";
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    };
  };

  environment.systemPackages = [
    pkgs.clang
    # 🦆 says ⮞ Dependencies 
    pkgs.mosquitto
    pkgs.zigbee2mqtt # 🦆 says ⮞ wat? dat's all?
    # 🦆 says ⮞ scene fireworks  
    (pkgs.writeScriptBin "scene-roll" ''
      ${cmdHelpers}
      ${lib.concatStringsSep "\n" (lib.flatten (lib.mapAttrsToList (_: cmds: lib.mapAttrsToList (_: cmd: cmd) cmds) sceneCommands))}
    '')
    # 🦆 says ⮞ activate a scene yo
    (pkgs.writeScriptBin "scene" ''
      ${cmdHelpers}
      MQTT_BROKER="${mqttHostip}"
      MQTT_USER=$(nix eval "${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.scripts.zigduck.parameters" --json | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "user") | .default')
      MQTT_PASSWORD=$(cat "${config.sops.secrets.mosquitto.path}")
      SCENE="$1"      
      # 🦆 says ⮞ no scene == random scene
      if [ -z "$SCENE" ]; then
        SCENE=$(shuf -n 1 -e ${lib.concatStringsSep " " (lib.map (name: "\"${name}\"") (lib.attrNames sceneCommands))})
      fi      
      case "$SCENE" in
      ${
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (sceneName: cmds:
            let
              commandLines = lib.concatStringsSep "\n    " (
                lib.mapAttrsToList (_: cmd: cmd) cmds
              );
            in
              "\"${sceneName}\")\n    ${commandLines}\n    ;;"
          ) sceneCommands
        )
      }
      *)
        say_duck "fuck ❌"
        exit 1
        ;;
      esac
    '')     
    # 🦆 says ⮞ activate a scene yo
    (pkgs.writeScriptBin "zig" ''
      ${cmdHelpers}
      set -euo pipefail
      # 🦆 says ⮞ create case insensitive map of device friendly_name
      declare -A device_map=(
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "['${lib.toLower k}']='${v}'") normalizedDeviceMap)}
      )
      available_devices=(
        ${toString deviceList}
      )    
      DEVICE="$1" # 🦆 says ⮞ device to control      
      STATE="''${2:-}" # 🦆 says ⮞ state change        
      BRIGHTNESS="''${3:-100}"
      COLOR="''${4:-}"
      TEMP="''${5:-}"
      ZIGBEE_DEVICES='${deviceMeta}'
      MQTT_BROKER="${mqttHostip}"
      MQTT_USER=$(nix eval "${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.scripts.zigduck.parameters" --json | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "user") | .default')
      MQTT_PASSWORD=$(cat "${config.sops.secrets.mosquitto.path}") # ⮜ 🦆 says password file 
      # 🦆 says ⮞ Zigbee coordinator backup
      if [[ "$DEVICE" == "backup" ]]; then
        mqtt_pub -t "zigbee2mqtt/backup/request" -m '{"action":"backup"}'
        say_duck "Zigbee coordinator backup requested! - processing on server..."
        exit 0
      fi         
      # 🦆 says ⮞ validate device
      input_lower=$(echo "$DEVICE" | tr '[:upper:]' '[:lower:]')
      exact_name=''${device_map["$input_lower"]}
      if [[ -z "$exact_name" ]]; then
        say_duck "fuck ❌ device not found: $DEVICE" >&2
        say_duck "Available devices: ${toString (builtins.attrNames zigbeeDevices)}" >&2
        exit 1
      fi
      # 🦆 says ⮞ if COLOR da lamp prob want hex yo
      if [[ -n "$COLOR" ]]; then
        COLOR=$(color2hex "$COLOR") || {
          say_duck "fuck ❌ Invalid color: $COLOR" >&2
          exit 1
        }
      fi
      # 🦆 says ⮞ turn off the device
      if [[ "$STATE" == "off" ]]; then
        mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m '{"state":"OFF"}'
        say_duck " turned off $DEVICE"
        exit 0
      fi    
      # 🦆 says ⮞ turn down the device brightness
      if [[ "$STATE" == "down" ]]; then
        say_duck "🔻 Decreasing $light_id in $clean_room"
        mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m '{"brightness_step":-50,"transition":3.5}'
        exit 0
      fi      
      # 🦆 says ⮞ turn up the device brightness
      if [[ "$STATE" == "up" ]]; then
        say_duck "🔺 Increasing brightness on $light_id in $clean_room"
        mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m '{"brightness_step":50,"transition":3.5}'
        exit 0
      fi      
      # 🦆 says ⮞ construct payload
      PAYLOAD="{\"state\":\"ON\""
      [[ -n "$BRIGHTNESS" ]] && PAYLOAD+=", \"brightness\":$BRIGHTNESS"
      [[ -n "$COLOR" ]] && PAYLOAD+=", \"color\":{\"hex\":\"$COLOR\"}"
      PAYLOAD+="}"
      # 🦆 says ⮞ publish payload
      mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m "$PAYLOAD"
      say_duck "$PAYLOAD"   
    '') 
  ];  

  systemd.services.zigduck = {
    serviceConfig = {
      User = config.this.user.me.name;
      Group = config.this.user.me.name;
      StateDirectory = "zigduck";
      StateDirectoryMode = "0755";
    };
    preStart = ''
      if [ ! -f "${zigduckDir}/state.json" ]; then
        echo "{}" > "${zigduckDir}/state.json"
        chown ${config.this.user.me.name}:${config.this.user.me.name} "${zigduckDir}/state.json"
        chmod 644 "${zigduckDir}/state.json"
      fi
    
      mkdir -p "${zigduckDir}/timers"
      chown ${config.this.user.me.name}:${config.this.user.me.name} "${zigduckDir}/timers"
      chmod 755 "${zigduckDir}/timers"
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/zigduck 0755 ${config.this.user.me.name} ${config.this.user.me.name} - -"
    "d /var/lib/zigduck/timers 0755 ${config.this.user.me.name} ${config.this.user.me.name} - -"
    "f /var/lib/zigduck/state.json 0644 ${config.this.user.me.name} ${config.this.user.me.name} - -"
  ];




  # 🦆 says ⮞ let's do some ducktastic decryption magic into yaml files before we boot services up duck duck yo
  systemd.services.zigbee2mqtt = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) {
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" "network.target" ];
    environment.ZIGBEE2MQTT_DATA = "/var/lib/zigbee";
    preStart = '' 
      mkdir -p ${config.services.zigbee2mqtt.dataDir}    
      # 🦆 says ⮞ our real mosquitto password quack quack
      mosquitto_password=$(cat ${config.sops.secrets.z2m_mosquitto.path}) 
      # 🦆 says ⮞ Injecting password into config...
      sed -i "s|/run/secrets/mosquitto|$mosquitto_password|" ${config.services.zigbee2mqtt.dataDir}/configuration.yaml  
      # 🦆 says ⮞ da real zigbee network key boom boom quack quack yo yo
      TMPFILE="${config.services.zigbee2mqtt.dataDir}/tmp.yaml"
      CFGFILE="${config.services.zigbee2mqtt.dataDir}/configuration.yaml"
      # 🦆 says ⮞ starting awk decryption magic..."
      ${pkgs.gawk}/bin/awk -v keyfile="${config.sops.secrets.z2m_network_key.path}" '
        /(^|[[:space:]])network_key:/ { found = 1 }

        { lines[NR] = $0 }

        END {
          if (found) {
            for (i = 1; i <= NR; i++) print lines[i]
          } else {
            print lines[1]
            print "  network_key:"
            while ((getline line < keyfile) > 0) {
              print "    " line
            }
            close(keyfile)
            for (i = 2; i <= NR; i++) print lines[i]
          }
        }
      ' "$CFGFILE" > "$TMPFILE"      
      mv "$TMPFILE" "$CFGFILE"
    ''; # 🦆 says ⮞ thnx fo quackin' along!
  };} # 🦆 says ⮞ sleep tight!
# 🦆 says ⮞ QuackHack-McBLindy out!
# ... 🛌🦆💤
