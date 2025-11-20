# dotfiles/bin/home/house.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ main home controller
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

  # 🦆 says ⮞ get MQTT broker IP (fallback to localhost)
  mqttHostIp = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or "127.0.0.1"
    else "127.0.0.1";

  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = config.house.zigbee.devices;

  # 🦆 says ⮞ Filter to only include light devices
  lightDevices = lib.filterAttrs (_: device: device.type == "light") zigbeeDevices;
 
  # 🦆 says ⮞ case-insensitive device matching
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ Group devices by room
  roomDevicesMap = let
    grouped = lib.groupBy (device: device.room) (lib.attrValues zigbeeDevices);
  in lib.mapAttrs (room: devices: 
      map (d: d.friendly_name) devices
    ) grouped;

  # 🦆 says ⮞ All devices list for 'all' area
  allDevicesList = lib.attrValues normalizedDeviceMap;

  # 🦆 says ⮞ device validation list
  deviceList = builtins.attrNames normalizedDeviceMap;

  # 🦆 says ⮞ Get Zigbee configuration
  zigbeeCfg = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.services.zigbee2mqtt.settings or {}
    else {};

  # 🦆 says ⮞ Precompute device and group mappings
  devicesSet = zigbeeCfg.devices or {};
  groupsSet = zigbeeCfg.groups or {};

  # 🦆 says ⮞ Room bash map with only lights, using | as separator
  roomBashMap = lib.mapAttrs' (room: devices:
    lib.nameValuePair room (lib.concatStringsSep "|" devices)
  ) roomDevicesMap;

  # 🦆 says ⮞ All devices as a pipe-separated string
  allDevicesStr = lib.concatStringsSep "|" allDevicesList;
in { # 🦆 says ⮞ Voice Intents
  yo.scripts.house = {
    description = "Control lights and other home automatioon devices";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "DEBUG";
    helpFooter = ''  
      MQTT_HOST="${mqttHost}"
      ZIGDUCKDIR="${zigduckDir}"
      STATE_FILE="$ZIGDUCKDIR/state.json"
      if [[ "$MQTT_HOST" == "$HOSTNAME" ]]; then
        BATTERY_DATA=$(cat $STATE_FILE)
      else
        BATTERY_DATA=$(ssh ${mqttHost} cat /home/pungkula/.config/zigduck/state.json)
      fi
      mk_table() {
        echo "| State  | Device | Battery | Temperature |"
        echo "| :- | :-- | :-- | :-- |"
        while IFS= read -r line; do
          [ -z "$line" ] && continue        
          device=$(echo "$line" | cut -d'|' -f2)
          state=$(echo "$line" | cut -d'|' -f1)
          battery=$(echo "$line" | cut -d'|' -f3)
          temp=$(echo "$line" | cut -d'|' -f4)
          device_single_line=$(echo "$device" | tr '\n' ' ' | sed 's/ \{2,\}/ /g')   
          echo "| $device_single_line | $state | $battery | $temp |"
        done <<< "$1"
      }
      TABLE_DATA=$(
        echo "$BATTERY_DATA" | \
        jq -r '
          to_entries[] 
          | .key as $key 
          | .value as $v
          | {
              key: $key,
              state: (
                if $v.state? == "ON" or $v.state? == "OFF" then $v.state
                elif $v.position? == "100" then "OPEN"
                elif $v.contact? == "true" then "CLOSED"
                elif $v.contact? == "false" then "OPEN"
                else null
                end
              ),
              battery: (if $v.battery? and $v.battery != "null" then $v.battery | tonumber else null end),
              temperature: (if $v.temperature? and $v.temperature != "null" then $v.temperature else null end)
            }
          | select(.state != null or .battery != null or .temperature != null)
          | [
              .key,
              (if .state then .state else "" end),
              (if .battery != null then (if .battery > 40 then "🔋" else "🪫" end) + " \(.battery)%" else "" end),
              (if .temperature != null then "\(.temperature)°C" else "" end)
            ]
          | join("|")' 
      )
      echo -e "\n## ──────⋆⋅☆⋅⋆────── ##"
      echo "## Device Status"
      mk_table "$TABLE_DATA"
    '';
    parameters = [   
      { name = "device"; description = "Device to control"; optional = true; }
      { name = "state"; type = "string"; description = "State of the device or group"; } 
      { name = "brightness"; description = "Brightness value of the device or group"; optional = true; type = "int"; }    
      { name = "color"; description = "Color to set on the device"; optional = true; }    
      { name = "temperature"; description = "Light color temperature to set on the device"; optional = true; }          
      { name = "scene"; description = "Activate a predefined scene"; optional = true; }     
      { name = "room"; description = "Room to target"; optional = true; }        
      { name = "user"; description = "Mosquitto username to use"; default = "mqtt"; }    
      { name = "passwordfile"; description = "File path containing password for Mosquitto user"; default = config.sops.secrets.mosquitto.path; }
      { name = "flake"; description = "Path containing flake.nix"; default = config.this.user.me.dotfilesDir; }
      { name = "pair"; type = "bool"; description = "Activate zigbee2mqtt pairring and start searching for new devices"; default = false; }
      { name = "cheapMode"; type = "bool"; description = "Energy saving mode. Turns off the lights again after X seconds."; default = false; }
    ];
    code = ''
      ${cmdHelpers}
 #     set -euo pipefail
      # 🦆 says ⮞ create case insensitive map of device friendly_name
      declare -A device_map=( ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "['${lib.toLower k}']='${v}'") normalizedDeviceMap)} )
      available_devices=( ${toString deviceList} )      
      DOTFILES="$flake"
      STATE_DIR="${zigduckDir}"
      DEVICE="$device"
      STATE="$state"
      SCENE="$scene"
      BRIGHTNESS="$brightness"
      COLOR="$color"
      TEMP="$temperature"
      MQTT_BROKER="${mqttHostIp}"
      PWFILE="$passwordfile"
      MQTT_USER="$user"
      MQTT_PASSWORD=$(cat "$PWFILE")
      ROOM="$device"
      touch "$STATE_DIR/voice-debug.log"        
      if [[ "$cheapMode" == "true" ]]; then
        reset_room_timer "$ROOM"
        dt_info "Restarting room timer for $ROOM" 
        exit 0
      fi
      if [[ -n "$SCENE" && -z "$DEVICE" ]]; then
        scene "$SCENE"
        exit 0
      fi
      
      if [[ "$pair" == "true" ]]; then
        echo "🦆 Activating Zigbee2MQTT pairing mode for 120 seconds..."
        mqtt_pub -t "zigbee2mqtt/bridge/request/permit_join" -m '{"value": true, "time": 120}'    
        dt_info "📡 Searching for new Zigbee devices... Put your device in pairing mode now!"
        dt_info "⏰ Pairing mode! 120 sec... (Ctrl+C to stop early)"
        cleanup() {
          dt_debug "Disabling pairing mode..."
          mqtt_pub -t "zigbee2mqtt/bridge/request/permit_join" -m '{"value": false}'
          exit 0
        }
        trap cleanup INT TERM EXIT
        ${pkgs.mosquitto}/bin/mosquitto_sub -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" \
        -t "zigbee2mqtt/bridge/event" -t "zigbee2mqtt/bridge/log" | while IFS= read -r line; do
        
        dt_debug "Received: $line"
                   
        if echo "$line" | jq -e '.type == "device_joined"' > /dev/null 2>&1; then
          device_data=$(echo "$line" | jq -r '.data')
          friendly_name=$(echo "$device_data" | jq -r '.friendly_name')
          ieee_address=$(echo "$device_data" | jq -r '.ieee_address')
          echo "✅ New device joined: $friendly_name ($ieee_address)"
        fi
                
        if echo "$line" | jq -e '.type == "device_interview"' > /dev/null; then
          interview_data=$(echo "$line" | jq -r '.data')
          status=$(echo "$interview_data" | jq -r '.status')
          ieee_address=$(echo "$interview_data" | jq -r '.ieee_address')
                    
          if [[ "$status" == "successful" ]]; then
            model=$(echo "$interview_data" | jq -r '.definition.model // "unknown"')
            vendor=$(echo "$interview_data" | jq -r '.definition.vendor // "unknown"')
            description=$(echo "$interview_data" | jq -r '.definition.description // "unknown"')      
            dt_info "🎉 Device interview successful!"
            dt_info "Model: $model"
            dt_info "Vendor: $vendor" 
            dt_info "Description: $description"
            dt_info "IEEE: $ieee_address"
                        
            cat << EOF
🦆 says ⮞ To add this device to your Nix configuration, add to `house.zigbee.devices`:

''${ieee_address} = {
  friendly_name = "$friendly_name";
  room = "unknown"; # ⮜ 🦆 says ⮞ Set the room name
  type = "unknown"; # ⮜ 🦆 says ⮞ Set device type (light, dimmer, sensor, motion, outlet, remote, pusher, blind)
  endpoint = 11;     # ⮜ 🦆 says ⮞ Set endpoint if needed
  icon = "mdi:toggle-switch"; # ⮜ 🦆 says ⮞ Set icon for frontend
  batteryType = "CR2450"; }; # ⮜ 🦆 says ⮞ Optional option if device has a battery. (AAA, CR1, CR2032, CR2450) 
};

EOF
            elif [[ "$status" == "failed" ]]; then
              dt_warning "❌ Device interview failed for $ieee_address"
            fi
          fi
        
          if echo "$line" | jq -e '.message != null' > /dev/null 2>&1; then
            message=$(echo "$line" | jq -r '.message')
            level=$(echo "$line" | jq -r '.level // "info"')
            
            if [[ "$level" == "info" ]]; then
              dt_info "Bridge: $message"
            elif [[ "$level" == "warning" ]]; then
              dt_warning "Bridge: $message"
            elif [[ "$level" == "error" ]]; then
              dt_error "Bridge: $message"
            else
              dt_debug "Bridge: $message"
            fi
          fi
        done
    
        cleanup
      fi
      if [[ "$DEVICE" == "ALL_LIGHTS" ]]; then
        if [[ "$STATE" == "ON" ]]; then
          scene max
          if_voice_say "Jag maxade alla lampor brorsan."
        elif [[ "$STATE" == "OFF" ]]; then
          scene dark
          if_voice_say "Nu blev det mörkt!"
        else
          echo "$(date) - ❌ Unknown state for all_lights: $STATE" >> "$STATE_DIR/voice-debug.log"
          say_duck "❌ Unknown state for all_lights: $STATE"
          exit 1
        fi
        exit 0
      fi
      control_device() {
        local dev="$1"
        local state="$2"
        local brightness="$3"
        local color_input="$4"      
        local hex_code=""
        if [[ "$dev" == "Smoke Alarm Kitchen" ]]; then
          dt_info "$dev is a sensor, exiting"
          return 0
        fi
        if [[ -n "$color_input" ]]; then
          if [[ "$color_input" =~ ^#[0-9a-fA-F]{6}$ ]]; then
            hex_code="$color_input"
          else
            hex_code=$(color2hex "$color_input") || {
              echo "$(date) - ❌ Unknown color: $color_input" >> "$STATE_DIR/voice-debug.log"
              say_duck "fuck ❌ Invalid color: $color_input"
              exit 1
            }
          fi
        fi
        
        if [[ -n "$SCENE" ]]; then
          scene $SCENE
          say_duck "Activated scene $SCENE"
        fi   
        
        if [[ "$state" == "off" ]]; then
          mqtt_pub -t "zigbee2mqtt/$dev/set" -m '{"state":"OFF"}'
          say_duck "Turned off $dev"
          if_voice_say "Stängde av $dev"
        else
          # 🦆 says ⮞ Validate brightness value
          if [[ -n "$brightness" ]]; then
            if ! [[ "$brightness" =~ ^[0-9]+$ ]] || [ "$brightness" -lt 1 ] || [ "$brightness" -gt 100 ]; then
              echo "Unknown brightness: $brightness" >> "$STATE_DIR/voice-debug.log"
              say_duck "Ogiltig ljusstyrka: $brightness%. Ange 1-100."
              exit 1
            fi
            brightness=$((brightness * 254 / 100))
          fi
          local payload='{"state":"ON"'
          [[ -n "$brightness" ]] && payload+=", \"brightness\":$brightness"
          [[ -n "$hex_code" ]] && payload+=", \"color\":{\"hex\":\"$hex_code\"}"
          payload+="}"
          mqtt_pub -t "zigbee2mqtt/$dev/set" -m "$payload"
          say_duck "Set $dev: $payload"
          if_voice_say "Klart kompis"
        fi
      }
      
      if [[ -n "$DEVICE" ]]; then
        input_lower=$(echo "$DEVICE" | tr '[:upper:]' '[:lower:]')
        exact_name="''${device_map["''$input_lower"]:-}"   
        if [[ -n "$exact_name" ]]; then
          control_device "$exact_name" "$STATE" "$BRIGHTNESS" "$COLOR"
          exit 0

        else
          for dev in "''${!device_map[@]}"; do
            if [[ "$dev" == *"$input_lower"* ]]; then
              exact_name="''${device_map[$dev]}"
              break
            fi
          done
          
          if [[ -n "$exact_name" ]]; then
            control_device "$exact_name" "$STATE" "$BRIGHTNESS" "$COLOR"
            exit 0
          fi
          
          group_topics=($(jq -r '.groups | keys[]' "$STATE_DIR/zigbee_devices.json"))
          for group in "''${group_topics[@]}"; do
            if [[ "$(echo "$group" | tr '[:upper:]' '[:lower:]')" == *"$input_lower"* ]]; then
              control_group "$group" "$STATE" "$BRIGHTNESS" "$COLOR"
              exit 0
            fi
          done
             
          AREA="$DEVICE"
          say_duck "⚠️ Device '$DEVICE' not found, trying as area '$AREA'"
          echo "$(date) - ⚠️ Device $DEVICE not found as area" >> "$STATE_DIR/voice-debug.log"
        fi
      fi
            
      control_room() {
        local room="$1"
        if [[ -z "$room" ]]; then
          echo "Usage: control_room <room-name>"
          return 1
        fi
      
        readarray -t devices < <(nix eval $DOTFILES#nixosConfigurations.desktop.config.house --json \
          | jq -r --arg room "$room" '
              .zigbee.devices
              | to_entries
              | map(select(.value.room == $room and .value.type == "light"))
              | map(.value.friendly_name)
              | .[]')
      
        for light_id in "''${devices[@]}"; do
          local hex_code=""
               
          if [[ -n "$COLOR" ]]; then
            hex_code=$(color2hex "$COLOR") || {
              echo "$(date) - ❌ Unknown color: $COLOR" >> "$STATE_DIR/voice-debug.log"
              say_duck "❌ Invalid color: $COLOR"
              continue
            }
          fi
      
          local payload='{"state":"ON"'
          [[ -n "$BRIGHTNESS" ]] && payload+=", \"brightness\":$BRIGHTNESS"
          [[ -n "$hex_code" ]] && payload+=", \"color\":{\"hex\":\"$hex_code\"}"
          payload+="}"
      
          if [[ "$light_id" == *"Smoke"* || "$light_id" == *"Sensor"* || "$light_id" == *"Alarm"* ]]; then
            echo "Skipping invalid light device: $light_id" >> "$STATE_DIR/voice-debug.log"
            continue
          fi

      
          mqtt_pub -t "zigbee2mqtt/$light_id/set" -m "$payload"
          say_duck "$light_id $payload"
        done
      }
      
      if [[ -n "$AREA" ]]; then
        normalized_area=$(echo "$AREA" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        control_room $AREA
      fi        
    ''; 
    voice = {
      priority = 1;
      sentences = [
        # 🦆 says ⮞ multi taskerz
        "{device} {state} i {room} och [ändra] färg[en] [till] {color} [och] ljusstyrka[n] [till] {brightness} procent"
        "{device} {state} och ljusstyrka {brightness} procent"
        "(gör|ändra) {device} [till] {color} [färg] [och] {brightness} procent [ljusstyrka]"  
        "(tänd|tänk|släck|starta|stäng) {device}"
        #"{state} {device}"
        "{slate} alla lampor i {device}"
        "{state} {device} (lampor|igen)"   
        "{state} lamporna i {device}"
        "{state} alla lampor"
        "stäng {state} {device}"
        "starta {state} {device}"
        # 🦆 says ⮞ color control
        "(ändra|gör) färgen [på|i] {device} till {color}"
        "(ändra|gör) {device} {color}"
        # 🦆 says ⮞ pairing mode
        "{pair} [ny|nya] [zigbee] (enhet|enheter)"
        # 🦆 says ⮞ brightness control
        "justera {device} till {brightness} procent"
      ];        
      lists = {
        state.values = [
          { "in" = "[tänd|tända|tänk|start|starta|på|tönd|tömd]"; out = "ON"; }             
          { "in" = "[släck|släcka|slick|av|stäng|stäng av]"; out = "OFF"; } 
        ];
        brightness.values = builtins.genList (i: {
          "in" = toString (i + 1);
          out = toString (i + 1);
        }) 100;
        device.values = let
          reservedNames = [ "hall" "kitchen" "bedroom" "bathroom" "wc" "livingroom" "kitchen" "switch" "all" "every" ];
          sanitize = str:
            lib.replaceStrings [ "/" " " ] [ "" "_" ] str;
    
          # 🦆 says ⮞ natural Swedish patterns
          swedishPatterns = base: baseRaw: [
            # 🦆 says ⮞ base name
            base
      
            # 🦆 says ⮞ definite form (the X)
            "${baseRaw}n"           # 🦆says⮞ en-words
            "${baseRaw}t"           # 🦆says⮞ ett-words  
            "${baseRaw}en"
            "${baseRaw}et"
      
            # 🦆says⮞ plural forms
            "${baseRaw}ar"
            "${baseRaw}or"
            "${baseRaw}er"
            "${baseRaw}na"          # 🦆says⮞ plural definite
            "${baseRaw}orna"
            "${baseRaw}erna"
      
            # 🦆says⮞ common Swedish light/lamp patterns
            "${baseRaw}lampan"
            "${baseRaw}lampor"
            "${baseRaw}lamporna"
            "${baseRaw}ljus"
            "${baseRaw}lamp"
          ];
    
        in [
          { "in" = "[vardagsrum|vardagsrummet|stora rummet|förrum]"; out = "livingroom"; }
          { "in" = "[kök|köket]"; out = "kitchen"; }
          { "in" = "[sovrum|sovrummet|sängkammaren|sovrummet]"; out = "bedroom"; }
          { "in" = "[badrum|badrummet|toaletten|wc]"; out = "bathroom"; }
          { "in" = "[hall|hallen|korridor|korridoren]"; out = "hallway"; }
          { "in" = "[alla|allting|allt|alla lampor|varje lampa]"; out = "ALL_LIGHTS"; }    
        ] ++
        (lib.filter (x: x != null) (
          lib.mapAttrsToList (_: device:
           let
              baseRaw = lib.toLower device.friendly_name;
              base = sanitize baseRaw;
              baseWords = lib.splitString " " base;
              isAmbiguous = lib.any (word: lib.elem word reservedNames) baseWords;
        
              # 🦆says⮞ gen Swedish variations
              swedishVariations = lib.unique (swedishPatterns base baseRaw);
        
              # 🦆says⮞ English as fallback
              englishVariants = [ "${base}s" "${base} light" ];
        
              variations = lib.unique (
                [
                  base
                  (sanitize (lib.replaceStrings [ " " ] [ "" ] base))
                  (lib.replaceStrings [ "_" ] [ " " ] base)
                ] ++ swedishVariations ++ englishVariants
              );
            in if isAmbiguous then null else {
              "in" = "[" + lib.concatStringsSep "|" variations + "]";
              out = device.friendly_name;
            }
          ) zigbeeDevices
        ));

# 🦆 says ⮞ automatically add all zigbee devices  
#            ] ++
#            (lib.filter (x: x != null) (
#              lib.mapAttrsToList (_: device:
#               let
#                  baseRaw = lib.toLower device.friendly_name;
#                  base = sanitize baseRaw;
#                  baseWords = lib.splitString " " base;
#                  isAmbiguous = lib.any (word: lib.elem word reservedNames) baseWords;
#                  hasLampSuffix = lib.hasSuffix "lampa" base;
#                  lampanVariant = if hasLampSuffix then [ "${base}n" ] else [];  
#                  enVariant = [ "${base}en" ]; # ← always add the 'en' variant 
#                  variations = lib.unique (
#                    [
#                      base
#                      (sanitize (lib.replaceStrings [ " " ] [ "" ] base))
##                    ] ++ lampanVariant ++ enVariant
#                  );
#                in if isAmbiguous then null else {
#                  "in" = "[" + lib.concatStringsSep "|" variations + "]";
#                  out = device.friendly_name;
#               }
#              ) zigbeeDevices
#            ));      
        color.values = [
          { "in" = "[röd|rött|röda]"; out = "red"; }
          { "in" = "[grön|grönt|gröna]"; out = "green"; }
          { "in" = "[blå|blått|blåa]"; out = "blue"; }
          { "in" = "[gul|gult|gula]"; out = "yellow"; }
          { "in" = "[orange|orangefärgad|orangea]"; out = "orange"; }
          { "in" = "[lila|lilla|violett|violetta]"; out = "purple"; }
          { "in" = "[rosa|rosafärgad|rosaaktig]"; out = "pink"; }
          { "in" = "[vit|vitt|vita]"; out = "white"; }
          { "in" = "[svart|svarta]"; out = "black"; }
          { "in" = "[grå|grått|gråa]"; out = "gray"; }
          { "in" = "[brun|brunt|bruna]"; out = "brown"; }
          { "in" = "[cyan|cyanblå|turkosblå]"; out = "cyan"; }
          { "in" = "[magenta|cerise|fuchsia]"; out = "magenta"; }
          { "in" = "[turkos|turkosgrön]"; out = "turquoise"; }
          { "in" = "[teal|blågrön]"; out = "teal"; }
          { "in" = "[lime|limegrön]"; out = "lime"; }
          { "in" = "[maroon|mörkröd]"; out = "maroon"; }
          { "in" = "[oliv|olivgrön]"; out = "olive"; }
          { "in" = "[navy|marinblå]"; out = "navy"; }
          { "in" = "[lavendel|ljuslila]"; out = "lavender"; }
          { "in" = "[korall|korallröd]"; out = "coral"; }
          { "in" = "[guld|guldfärgad]"; out = "gold"; }
          { "in" = "[silver|silverfärgad]"; out = "silver"; }
          { "in" = "[slumpmässig|random|valfri färg]"; out = "random"; }
        ];
        temperature.values = builtins.genList (i: {
           "in" = toString i;
            out = toString i;
        }) 500;
        pair.values = [
          { "in" = "[para|paras]"; out = "true"; }
        ];
        room.values = [
          { "in" = "[kök|köket|kitchen]"; out = "kitchen"; }
          { "in" = "[vardagsrum|vardagsrummet]"; out = "livingroom"; }
          { "in" = "[sovrum|sovrummet|bedroom]"; out = "bedroom"; }
          { "in" = "[badrum|badrummet|wc|toilet]"; out = "wc"; }
          { "in" = "[hall|hallen|hallway]"; out = "hallway"; }
                                        
        ];        
      };
    };
    
  };}
