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
      { name = "state"; description = "State of the device or group"; default = "on"; } 
      { name = "brightness"; description = "Brightness value of the device or group"; optional = true; type = "int"; }    
      { name = "color"; description = "Color to set on the device"; optional = true; }    
      { name = "temperature"; description = "Light color temperature to set on the device"; optional = true; }          
      { name = "scene"; description = "Activate a predefined scene"; optional = true; }                
      { name = "user"; description = "Mosquitto username to use"; default = "mqtt"; }    
      { name = "passwordfile"; description = "File path containing password for Mosquitto user"; default = config.sops.secrets.mosquitto.path; }
      { name = "flake"; description = "Path containing flake.nix"; default = config.this.user.me.dotfilesDir; }    
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
      touch "$STATE_DIR/voice-debug.log"        
      if [[ "$DEVICE" == "all_lights" ]]; then
        if [[ "$STATE" == "on" ]]; then
          scene max
          if_voice_say "Jag maxade alla lampor brorsan."
        elif [[ "$STATE" == "off" ]]; then
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
        "{device} {state} och färg {color}"
        "{device} {state} och ljusstyrka {brightness} procent"
        "(gör|ändra) {device} [till] {color} [färg] [och] {brightness} procent [ljusstyrka]"  
        "(tänd|tänk|släck|starta|stäng) {device}"
        "{slate} alla lampor i {device}"
        "{state} {device} lampor"   
        "{state} lamporna i {device}"
        "{state} alla lampor"
        "stäng {state} {device}"
        "starta {state} {device}"
        # 🦆 says ⮞ color control
        "(ändra|gör) färgen [på|i] {device} till {color}"
        "(ändra|gör) {device} {color}"
            
        # 🦆 says ⮞ brightness control
        "justera {device} till {brightness} procent"
      ];        
      lists = {
        state.values = [
          { "in" = "[tänd|tända|tänk|start|starta|på]"; out = "ON"; }             
          { "in" = "[släck|släcka|slick|av|stäng|stäng av]"; out = "OFF"; } 
        ];
        brightness.values = builtins.genList (i: {
          "in" = toString (i + 1);
          out = toString (i + 1);
        }) 100;
        device.values = let
          reservedNames = [ "hall" "kök" "sovrum" "toa" "wc" "vardagsrum" "kitchen" "switch" ];
          sanitize = str:
            lib.replaceStrings [ "/" ] [ "" ] str;
        in [
          { "in" = "[vardagsrum|vardagsrummet]"; out = "livingroom"; }
          { "in" = "[kök|köket]"; out = "kitchen"; }
          { "in" = "[sovrum|sovrummet]"; out = "bedroom"; }
          { "in" = "[hall|hallen]"; out = "hallway"; }
          { "in" = "[toa|toan|toalett|toaletten|wc]"; out = "wc"; }
          { "in" = "[all|alla|allt]"; out = "ALL_LIGHTS"; }    
        ];

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
      };
    };
    
  };}
