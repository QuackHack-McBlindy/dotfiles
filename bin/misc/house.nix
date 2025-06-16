# dotfiles/bin/misc/house.nix
# 🦆 says ⮞ home controller
{ 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let

  zigduckDir = "/home/" + config.this.user.me.name + "/.config/zigduck";

#  sysHosts = lib.attrNames self.nixosConfigurations;
  mqttHost = let
    sysHosts = lib.attrNames self.nixosConfigurations;
    mqttHosts = lib.filter (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) sysHosts;
  in
    if mqttHosts != [] then lib.head mqttHosts else null;

  # Get MQTT broker IP (fallback to localhost)
  mqttHostIp = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or "127.0.0.1"
    else "127.0.0.1";

  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = { # 🦆 says ⮞ inb4 long annoying list  
    # Kitchen   🦆 says > oh crap
    "0x0017880103ca6e95" = { # 🦆 says ⮞ scroll
      friendly_name = "Dimmer Switch Kök";# 🦆 says ⮞ scroll sad duck, scroll ='(
      room = "kitchen"; # 🦆 says ⮞ i'll tell u when to stop ='(
      type = "dimmer";
      endpoint = 1;
    };
    "0x0017880102f0848a" = {
      friendly_name = "Spotlight kök 1";
      room = "kitchen";
      type = "light";
      endpoint = 11;
    };
    "0x0017880102f08526" = {
      friendly_name = "Spotlight Kök 2";
      room = "kitchen";
      type = "light";
      endpoint = 11;
    };
    "0x0017880103a0d280" = {
      friendly_name = "Uppe";
      room = "kitchen";
      type = "light";
      endpoint = 11;
    };
    "0x0017880103e0add1" = {
      friendly_name = "Golvet";
      room = "kitchen";
      type = "light";
      endpoint = 11;
    };
    "0xa4c13873044cb7ea" = {
      friendly_name = "Kök Bänk Slinga";
      room = "kitchen";
      type = "light";
      endpoint = 11;
    };
    "0x70ac08fffe9fa3d1" = {
      friendly_name = "Motion Sensor Kök";
      room = "kitchen";
      type = "motion";
      endpoint = 1;
    };
    "0xa4c1380afa9f7f3e" = {
      friendly_name = "Smoke Alarm Kitchen";
      room = "kitchen";
      type = "sensor";
      endpoint = 1;
    };
    "0x0c4314fffe179b05" = {
      friendly_name = "Fläkt";
      room = "kitchen";
      type = "power plug";
      endpoint = 1;
    };    
    # 🦆 says ⮞ LIVING ROOM
    "0x0017880104f78065" = {
      friendly_name = "Dimmer Switch Vardagsrum";
      room = "livingroom";
      type = "dimmer";
      endpoint = 1;
    };
    "0x54ef4410003e58e2" = {
      friendly_name = "Roller Shade";
      room = "livingroom";
      type = "blind";
      endpoint = 1;
    };
    "0x0017880104540411" = {
      friendly_name = "PC";
      room = "livingroom";
      type = "light";
      endpoint = 11;
    };
    "0x0017880102de8570" = {
      friendly_name = "Rustning";
      room = "livingroom";
      type = "light";
      endpoint = 11;
    };

    # 🦆 says ⮞ HALLWAY
    "0x00178801021311c4" = {
      friendly_name = "Motion Sensor Hall";
      room = "hallway";
      type = "motion";
      endpoint = 1;
    };
    "0x0017880103eafdd6" = {
      friendly_name = "Tak Hall";
      room = "hallway";
      type = "light";
      endpoint = 11;
    };
    "0x000b57fffe0e2a04" = {
      friendly_name = "Vägg";
      room = "hallway";
      type = "light";
      endpoint = 1;
    };

    # 🦆 says ⮞ WC
    "0x001788010361b842" = {
      friendly_name = "WC 1";
      room = "wc";
      type = "light";
      endpoint = 11;
    };
    "0x0017880103406f41" = {
      friendly_name = "WC 2";
      room = "wc";
      type = "light";
      endpoint = 11;
    };

    # 🦆 says ⮞ BEDROOM
    "0x0017880104f77d61" = {
      friendly_name = "Dimmer Switch Sovrum";
      room = "bedroom";
      type = "dimmer";
      endpoint = 1;
    };
    "0x0017880106156cb0" = {
      friendly_name = "Taket Sovrum 1";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };
    "0x0017880103c7467d" = {
      friendly_name = "Taket Sovrum 2";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };
    "0x0017880109ac14f3" = {
      friendly_name = "Sänglampa";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };
    "0x0017880104051a86" = {
      friendly_name = "Sänggavel";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };
    "0xf4b3b1fffeaccb27" = {
      friendly_name = "Motion Sensor Sovrum";
      room = "bedroom";
      type = "motion";
      endpoint = 1;
    };
    "0x0017880103f44b5f" = {
      friendly_name = "Dörr";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };
    "0x00178801001ecdaa" = {  # 🦆 says ⮞ THATS TOO FAST!!
      friendly_name = "Bloom";
      room = "bedroom";
      type = "light";
      endpoint = 11; # 🦆 says ⮞ SLOW DOWN DUCKIE!!
    };
    # 🦆 says ⮞ MISCELLANEOUS
    "0x000b57fffe0f0807" = {
      friendly_name = "IKEA 5 Dimmer";
      room = "other";
      type = "remote";
      endpoint = 1;
    };
    "0x70ac08fffe6497be" = {
      friendly_name = "On/Off Switch 1";
      room = "other";
      type = "remote";
      endpoint = 1;
    };
    "0x70ac08fffe65211e" = {
      friendly_name = "On/Off Switch 2";
      room = "other";
      type = "remote";
      endpoint = 1;
    };
    "0x0017880103c73f85" = {
      friendly_name = "Unknown 1";
      room = "other";
      type = "misc";
      endpoint = 1;
    };  
    "0x0017880103f94041" = {
      friendly_name = "Unknown 2";
      room = "other";
      type = "misc";
      endpoint = 1;
    };      
    "0x0017880103c753b8" = {
      friendly_name = "Unknown 3";
      room = "other";
      type = "misc";
      endpoint = 1;
    };      
    "0x540f57fffe85c9c3" = {
      friendly_name = "Unknown 4";
      room = "other";
      type = "misc";
      endpoint = 1;
    };    
    "0x00178801037e754e" = {
      friendly_name = "Unknown 5";
      room = "other";
      type = "misc";
      endpoint = 1; 
    };    
  }; # 🦆 says ⮞ that's way too many devices huh

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
            "gör {brightness} {device} {color} procent"
            "gör {brightness} procent {color} {device}"
            "sätt {device} till {color} {brightness} procent"
            "gör {device} {brightness} procent {color}"
            "gör {device} {color} {brightness} procent"
            "gör {device} {color} och {brightness} procent"
          ];        
          lists = {
#            device.wildcard = true;

            state.values = [
              { "in" = "tänd"; out = "on"; }             
              { "in" = "släck"; out = "off"; } 
              { "in" = "stäng"; out = "off"; } 
              { "in" = "starta"; out = "on"; }   
#              { "in" = "av"; out = "off"; }             
              { "in" = "på"; out = "on"; } 
            ];  
            brightness.values = builtins.genList (i: {
              "in" = toString (i + 1);
              out = toString (i + 1);
            }) 100;
            color.values = [
              { "in" = "röd"; out = "red"; }    
              { "in" = "rött"; out = "red"; }                  
              { "in" = "grön"; out = "green"; } 
              { "in" = "grönt"; out = "green"; }                  
              { "in" = "blå"; out = "blue"; } 
              { "in" = "blått"; out = "blue"; }                  
              { "in" = "gul"; out = "yellow"; }   
              { "in" = "gult"; out = "yellow"; }                  
              { "in" = "orange"; out = "orange"; }             
              { "in" = "lila"; out = "purple"; } 
              { "in" = "rosa"; out = "pink"; } 
              { "in" = "vit"; out = "white"; }   
              { "in" = "vitt"; out = "white"; }                  
              { "in" = "svart"; out = "black"; } 
              { "in" = "grå"; out = "gray"; }   
              { "in" = "brunt"; out = "brown"; } 
              { "in" = "cyan"; out = "cyan"; }   
              { "in" = "magenta"; out = "magenta"; } 
            ];
            device.values = [
              { "in" = "golvet"; out = "Golvet"; }    
              { "in" = "vardagsrum"; out = "livingroom"; }
              { "in" = "kök"; out = "kitchen"; }
              { "in" = "sovrum"; out = "bedroom"; }
              { "in" = "hall"; out = "hallway"; }
              { "in" = "wc"; out = "wc"; }
              { "in" = "köket"; out = "köket"; }
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
      { name = "state"; description = "State of the device or group"; optional = true; } 
      { name = "brightness"; description = "Brightness value of the device or group"; optional = true; }    
      { name = "color"; description = "Color to set on the device"; optional = true; }    
      { name = "temperature"; description = "Light color temperature to set on the device"; optional = true; }          
      { name = "user"; description = "Mosquitto username to use"; default = "mqtt"; }    
      { name = "passwordfile"; description = "File path containing password for Mosquitto user"; default = config.sops.secrets.mosquitto.path; }    
    ];
    code = ''
      ${cmdHelpers}
 #     set -euo pipefail
      # 🦆 says ⮞ create case insensitive map of device friendly_name
      declare -A device_map=(
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "['${lib.toLower k}']='${v}'") normalizedDeviceMap)}
      )
      available_devices=(
        ${toString deviceList}
      )      
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
      # 🦆 says ⮞ temporary fallback logic for parsing
      if [[ -z "$DEVICE" && -z "$STATE" && -z "$BRIGHTNESS" && -z "$COLOR" && $# -gt 0 ]]; then
        INPUT="$*"
        for word in $INPUT; do
          case "$word" in
            sovrum|vardagsrum|kök|hall|wc)
              DEVICE="$word"
              ;;
            rött|blått|grönt|red|blue|green|gul|orange|vit|rosa|lila|cyan|magenta)
              COLOR="$word"
              ;;
            ''*[!0-9]*) ;;
            *)
              BRIGHTNESS="$word"
              ;;
          esac
        done
        [[ "$DEVICE" =~ ^(sovrum|vardagsrum|kök|hall|wc)$ ]] && AREA="$DEVICE"
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
              say_duck "❌ Invalid color: $color_input"
              exit 1
            }
          fi
        fi
        
        if [[ "$state" == "off" ]]; then
          mqtt_publish "zigbee2mqtt/$dev/set" '{"state":"OFF"}'
          say_duck "Turned off $dev"
        else
          # 🦆 says ⮞ Validate brightness value
          if [[ -n "$brightness" ]]; then
            if ! [[ "$brightness" =~ ^[0-9]+$ ]] || [ "$brightness" -lt 1 ] || [ "$brightness" -gt 100 ]; then
              say_duck "Ogiltig ljusstyrka: $brightness%. Ange 1-100."
              exit 1
            fi
            # Convert percentage to 0-254 scale
            brightness=$((brightness * 254 / 100))
          fi
          local payload='{"state":"ON"'
          [[ -n "$brightness" ]] && payload+=", \"brightness\":$brightness"
          [[ -n "$hex_code" ]] && payload+=", \"color\":{\"hex\":\"$hex_code\"}"
          payload+="}"
          mqtt_publish "zigbee2mqtt/$dev/set" "$payload"
          say_duck "Set $dev: $payload"
        fi
      }
      
      if [[ -n "$DEVICE" ]]; then
        input_lower=$(echo "$DEVICE" | tr '[:upper:]' '[:lower:]')
        exact_name="''${device_map["''$input_lower"]:-}"   
        if [[ -n "$exact_name" ]]; then
          control_device "$exact_name" "$STATE" "$BRIGHTNESS" "$COLOR"
          exit 0
        elif [[ -z "$AREA" ]]; then
          AREA="$DEVICE"
          say_duck "⚠️ Device '$DEVICE' not found, trying as area '$AREA'"
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
  
  
  

