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
#  zigbeeDevices = config.house.zigbee.devices;
  zigbeeDevices = lib.filterAttrs (_: v: lib.isAttrs v) config.house.zigbee.devices;
  # 🦆 says ⮞ Group devices by room (with validation)

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
  # 🦆 says ⮞ convert into Bash map yo
  groupDeviceBashMap = lib.mapAttrs' (name: group:
    lib.nameValuePair name (lib.concatStringsSep "|" (group.devices or []))
  ) groupsSet;
  # 🦆 says ⮞ group mapping
#  bashGroupMap = lib.mapAttrsToList (name: id: 
#    "[${lib.toLower name}]='${id}'"
#  ) (lib.mapAttrs' (id: cfg: 
#    lib.nameValuePair (lib.toLower cfg.friendly_name) id
#  ) groupsSet);
  # 🦆 says ⮞ room mapping
#  bashRoomMap = lib.mapAttrsToList (room: devices: 
#    "[${room}]='${lib.concatStringsSep "|" devices}'"
#  ) (lib.mapAttrs (room: devices: 
#    map (d: d.friendly_name) devices
#  ) roomDevicesMap);
  # 🦆 says ⮞ Room bash map with only lights, using | as separator
  roomBashMap = lib.mapAttrs' (room: devices:
    lib.nameValuePair room (lib.concatStringsSep "|" devices)
  ) roomDevicesMap;

  groupedByRoom = lib.groupBy (device: device.room) (lib.attrValues zigbeeDevices);
  # 🦆 says ⮞bash mappin' of groups
  bashGroupMap = lib.mapAttrsToList (id: cfg: 
    "[${lib.toLower cfg.friendly_name}]='${id}'"
  ) groupsSet;
  # 🦆 says ⮞ bash mappin of roomz yo
  bashRoomMap = lib.mapAttrsToList (room: devices: 
    let
      friendly_names = map (d: 
        if lib.isAttrs d then d.friendly_name 
        else throw "Invalid device in room ${room}: ${toString d}"
      ) devices;
    in
      "[${room}]='${lib.concatStringsSep "|" friendly_names}'"
  ) groupedByRoom;


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
            "stäng {state} {device}"
            "starta {state} {device}"
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
      # 🦆 says ⮞ Group mapping: friendly name (lowercase) -> group ID
      declare -A group_map=( ${toString bashGroupMap} )
      # 🦆 says ⮞ Room mapping: room name (lowercase) -> pipe-separated device names
      declare -A room_map=( ${toString bashRoomMap} )
      AREA=""
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
      control_group() {
        local group_id="$1"
        local state="$2"
        local brightness="$3"
        local color_input="$4"
        local hex_code=""
        
        if [[ -n "$color_input" ]]; then
          hex_code=$(color2hex "$color_input") || {
            echo "$(date) - ❌ Unknown color: $color_input" >> "$STATE_DIR/voice-debug.log"
            say_duck "fuck ❌ Invalid color: $color_input"
            exit 1
          }
        fi
      
        if [[ "$state" == "off" ]]; then
          mqtt_publish "zigbee2mqtt/$group_id/set" '{"state":"OFF"}'
          say_duck "Turned off group $group_id"
        else
          if [[ -n "$brightness" ]]; then
            brightness=$((brightness * 254 / 100))
          fi
          local payload='{"state":"ON"'
          [[ -n "$brightness" ]] && payload+=", \"brightness\":$brightness"
          [[ -n "$hex_code" ]] && payload+=", \"color\":{\"hex\":\"$hex_code\"}"
          payload+="}"
          mqtt_publish "zigbee2mqtt/$group_id/set" "$payload"
          say_duck "Set group $group_id: $payload"
        fi
      }
      
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
        else
          # Try substring match in devices
          for dev in "''${!device_map[@]}"; do
            if [[ "$dev" == *"$input_lower"* ]]; then
              exact_name="''${device_map[$dev]}"
              control_device "$exact_name" "$STATE" "$BRIGHTNESS" "$COLOR"
              exit 0
            fi
          done
    
          # Try substring match in groups
          for group_friendly in "''${!group_map[@]}"; do
            if [[ "$group_friendly" == *"$input_lower"* ]]; then
              group_id="''${group_map[$group_friendly]}"
              control_group "$group_id" "$STATE" "$BRIGHTNESS" "$COLOR"
              exit 0
            fi
          done
          
          # If not found, treat as area
          AREA="$DEVICE"
          say_duck "⚠️ Device '$DEVICE' not found, trying as area '$AREA'"
        fi
      fi
    
      # Area handling
      if [[ -n "$AREA" ]]; then
        normalized_area=$(echo "$AREA" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        # Try as group
        group_id=''${group_map[$normalized_area]}
        if [[ -n "$group_id" ]]; then
          control_group "$group_id" "$STATE" "$BRIGHTNESS" "$COLOR"
          exit 0
        fi
    
        # Try as room
        devices_str=''${room_map[$normalized_area]}
        if [[ -n "$devices_str" ]]; then
          IFS='|' read -ra devices <<< "$devices_str"
          for device in "''${devices[@]}"; do
            control_device "$device" "$STATE" "$BRIGHTNESS" "$COLOR"
          done
          exit 0
        fi
    
        say_duck "❌ No device, group, or room named '$AREA'"
        exit 1
      fi
    
      # If we get here with no device and no area
      say_duck "❌ Missing device or area"
      exit 1
    

    ''; 
  };

  yo.bitch.intents.fanOff.data = [{ sentences = [ "(stäng|stänga) [av] (fläkt|fläck|fkäckt|fläckten|fläkten)" ];}];
  yo.bitch.intents.fanOn.data = [{ sentences = [ "(start|starta) (fläkt|fläck|fkäckt|fläckten|fläkten)" ];}];  
  yo.bitch.intents.goodmorning.data = [{ sentences = [ "godmorgon" "god morgon" ];}];    
  yo.bitch.intents.goodnight.data = [{ sentences = [ "godnatt" "god natt" "jag vill inte se ut" ];}];    
  yo.bitch.intents.blindsUp.data = [{ sentences = [ "jag vill [kunna] se ut" "(persienner|persiennerna) upp" ];}];    
  yo.bitch.intents.blindsDown.data = [{ sentences = [ "jag vill inte [kunna] se ut" "(persienner|persiennerna) (ner|ned)" ];}];    
  yo.scripts.fanOff.code = "zig Fläkt off";
  yo.scripts.fanOn.code = "zig Fläkt on";
  yo.scripts.goodmorning.code = ''
    yo-say "godmorgon bruschhaan kebab"
    zig 'Roller Shade' on    
  '';
  yo.scripts.goodnight.code = ''
    yo-say "natti natti putti nuttiii brusschaan!" 
    scene dark
    zig "Roller Shade" off
  '';
  yo.scripts.blindsUp.code = "zig 'Roller Shade' on";
  yo.scripts.blindsDown.code = "zig 'Roller Shade' off";
  }
