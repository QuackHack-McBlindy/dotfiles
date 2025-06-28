# dotfiles/bin/misc/house.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ home controller
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  zigduckDir = "/home/" + config.this.user.me.name + "/.config/zigduck";

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
in {  
  yo.bitch = { 
    intents = {
      house = {
        data = [{
          sentences = [
            # Multi taskerz
            "{device} {state} och färg {color}"
            "{device} {state} och ljusstyrka {brightness} procent"
            "(gör|ändra) {device} [till] {color} [färg] [och] {brightness} procent [ljusstyrka]"  
            "(tänd|tänk|släck|starta|stäng) {device}"
            "{slate} alla lampor i {device}"
            "{state} {device} lampor"   
            "{state} lamporna i {device}"
            "{state} alla lampor"
            # Color Control
            "(ändra|gör) färgen [på|i] {device} till {color}"
            # Brightness Control
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
            device.values = [
              { "in" = "[vardagsrum|vardagsrummet]"; out = "livingroom"; }
              { "in" = "[kök|köket]"; out = "kitchen"; }
              { "in" = "[sovrum|sovrummet]"; out = "bedroom"; }
              { "in" = "[hall|hallen]"; out = "hallway"; }
              { "in" = "[toa|toan|toalett|toaletten|wc]"; out = "wc"; }
              { "in" = "[all|alla|allt]"; out = "ALL_LIGHTS"; }              
            ];  
            color.values = [
              { "in" = "[röd|rött]"; out = "red"; }            
              { "in" = "[grön|grönt]"; out = "green"; }              
              { "in" = "[blå|blått]"; out = "blue"; }       
              { "in" = "[gul|gult]"; out = "yellow"; }          
              { "in" = "orange"; out = "orange"; }             
              { "in" = "[lila|lilla]"; out = "purple"; } 
              { "in" = "rosa"; out = "pink"; } 
              { "in" = "[vit|vitt]"; out = "white"; }   
              { "in" = "grå"; out = "gray"; }   
              { "in" = "brunt"; out = "brown"; } 
              { "in" = "cyan"; out = "cyan"; }   
              { "in" = "magenta"; out = "magenta"; } 
            ];
          };
        }];
      };  
    };
  };

  yo.scripts.house = {
    description = "Control lights and other home automatioon devices";
    category = "🛖 Home Automation";
    aliases = [ "lights" ];
#    helpFooter = ''
#    '';
    parameters = [   
      { name = "device"; description = "Device to control"; optional = true; }
      { name = "state"; description = "State of the device or group"; default = "on"; } 
      { name = "brightness"; description = "Brightness value of the device or group"; optional = true; type = "int"; }    
      { name = "color"; description = "Color to set on the device"; optional = true; }    
      { name = "temperature"; description = "Light color temperature to set on the device"; optional = true; }          
      { name = "user"; description = "Mosquitto username to use"; default = "mqtt"; }    
      { name = "passwordfile"; description = "File path containing password for Mosquitto user"; default = config.sops.secrets.mosquitto.path; }    
    ];
    code = ''
      ${cmdHelpers}
 #     set -euo pipefail
      # 🦆 says ⮞ create case insensitive map of device friendly_name
      declare -A device_map=( ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "['${lib.toLower k}']='${v}'") normalizedDeviceMap)} )
      available_devices=( ${toString deviceList} )      
      STATE_DIR="${zigduckDir}"
      DEVICE="$device"
      STATE="$state"
      BRIGHTNESS="$brightness"
      COLOR="$color"
      TEMP="$temperature"
      MQTT_BROKER="${mqttHostIp}"
      PWFILE="$passwordfile"
      MQTT_USER="$user"
      MQTT_PASSWORD=$(<"$PWFILE")
      touch "$STATE_DIR/voice-debug.log"
      # 🦆 says ⮞ special handling for all_lights device alias
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
        
        if [[ "$state" == "off" ]]; then
          mqtt_publish "zigbee2mqtt/$dev/set" '{"state":"OFF"}'
          say_duck "Turned off $dev"
          if_voice_say "Stängde av $dev"
        else
          # 🦆 says ⮞ Validate brightness value
          if [[ -n "$brightness" ]]; then
            if ! [[ "$brightness" =~ ^[0-9]+$ ]] || [ "$brightness" -lt 1 ] || [ "$brightness" -gt 100 ]; then
              echo "$(date) - ❌ Unknown brightness: $brightness" >> "$STATE_DIR/voice-debug.log"
              say_duck "Ogiltig ljusstyrka: $brightness%. Ange 1-100."
              exit 1
            fi
            brightness=$((brightness * 254 / 100))
          fi
          local payload='{"state":"ON"'
          [[ -n "$brightness" ]] && payload+=", \"brightness\":$brightness"
          [[ -n "$hex_code" ]] && payload+=", \"color\":{\"hex\":\"$hex_code\"}"
          payload+="}"
          mqtt_publish "zigbee2mqtt/$dev/set" "$payload"
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
#
        else
          # Try partial match
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

          # Check if it's a group
          group_topics=($(jq -r '.groups | keys[]' "$STATE_DIR/zigbee_devices.json"))
          for group in "''${group_topics[@]}"; do
            if [[ "$(echo "$group" | tr '[:upper:]' '[:lower:]')" == *"$input_lower"* ]]; then
              control_group "$group" "$STATE" "$BRIGHTNESS" "$COLOR"
              exit 0
            fi
          done
       
#        
#        elif [[ -z "$AREA" ]]; then
          AREA="$DEVICE"
          say_duck "⚠️ Device '$DEVICE' not found, trying as area '$AREA'"
          echo "$(date) - ⚠️ Device $DEVICE not found as area" >> "$STATE_DIR/voice-debug.log"
        fi
      fi

      control_room() {
        local clean_room=$(echo "$1" | sed 's/"//g')
        jq -r --arg room "$clean_room" \
          'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' \
          "$STATE_DIR/zigbee_devices.json" |
        while read -r light_id; do
          local hex_code=""
          if [[ -n "$COLOR" ]]; then
            hex_code=$(color2hex "$COLOR") || {
              echo "$(date) - ❌ Unknown coolor: $COLOR" >> "$STATE_DIR/voice-debug.log"
              say_duck "❌ Invalid color: $COLOR"
              continue
            }
          fi
          local payload='{"state":"ON"'
          [[ -n "$BRIGHTNESS" ]] && payload+=", \"brightness\":$BRIGHTNESS"
          [[ -n "$hex_code" ]] && payload+=", \"color\":{\"hex\":\"$hex_code\"}"
          payload+="}"
          mqtt_pub -t "zigbee2mqtt/$light_id/set" -m "$payload"
          say_duck "$light_id $payload"
        done
      } 
      if [[ -n "$AREA" ]]; then
        normalized_area=$(echo "$AREA" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        control_room $AREA
      fi        
    ''; 
  };}
  
  
  

