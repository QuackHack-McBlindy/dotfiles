# dotfiles/bin/misc/zigbee.nix
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
      lights = {
        data = [{
          sentences = [
            "{state} alla lampor"
            "{state} alla lampor {device}"
            "{state} ljuset i {device}"
            "{state} belysningen i {device}"
            "{state} alla lampor i {device}"
            "släck {device}"
            
            # Set color
            "ändra {color} till {device}"
            "ändra färg på {color} till {device}"
            "färga {color} {device}"
            "gör {color} {device}"

            # 🦆 says ⮞  Brightness control
            "sänk ljusstyrkan i {device}"
            "höj ljusstyrkan i {device}"
            "öka ljusstyrkan i {device}"
            "maxa ljusstyrkan i {device}"
            "dämpa ljuset i {device}"

            # 🦆 says ⮞  Implicit commands
            "{device} belysning i {color}"
            "{device} ljus i {color}"
            "maxa ljuset"
            "släck allt"
            "tänd allt"
            "blått ljus"
            "ljust i {device}"
          ];        
          lists = {
            device.values = [
              { "in" = "fläkt"; out = "Fläkt"; }
              { "in" = "dörr"; out = "Dörr"; }
              { "in" = "pc"; out = "PC"; }
              { "in" = "rustning"; out = "Rustning"; }
              { "in" = "bloom"; out = "Bloom"; }
              { "in" = "lampor"; out = "all"; }
              { "in" = "ljus"; out = "all"; }
              { "in" = "kök"; out = "kitchen"; } 
              { "in" = "köket"; out = "kitchen"; }            
              { "in" = "vardagsrum"; out = "livingroom"; } 
              { "in" = "vardagsrummet"; out = "livingroom"; }           
              { "in" = "toa"; out = "wc"; } 
              { "in" = "toan"; out = "wc"; }
              { "in" = "toalett"; out = "wc"; } 
              { "in" = "toaletten"; out = "wc"; }
              { "in" = "wc"; out = "wc"; }              
              { "in" = "dass"; out = "wc"; }                                                         
              { "in" = "hall"; out = "hallway"; } 
              { "in" = "hallen"; out = "hallway"; }       
              { "in" = "sovrum"; out = "bedroom"; } 
              { "in" = "sovrummet"; out = "bedroom"; }      
              { "in" = "tv"; out = "entertainment"; } 
              { "in" = "teve"; out = "entertainment"; }
              { "in" = "teven"; out = "entertainment"; } 
              { "in" = "tvn"; out = "entertainment"; }    
              { "in" = "all"; out = "all"; } 
              { "in" = "allt"; out = "all"; }
              { "in" = "alla"; out = "all"; } 
              { "in" = "lampor"; out = "all"; } 
              { "in" = "lamporna"; out = "all"; } 
              { "in" = "belysning"; out = "all"; } 
              { "in" = "ljuset"; out = "all"; } 
            ];  
            state.values = [
              { "in" = "tänd"; out = "on"; } 
              { "in" = "ljus"; out = "on"; }
              { "in" = "start"; out = "on"; } 
              { "in" = "starta"; out = "on"; }
              { "in" = "max"; out = "max"; }
              { "in" = "maxxa"; out = "max"; }
                            
              { "in" = "släck"; out = "off"; } 
              { "in" = "släcka"; out = "off"; }
              { "in" = "stäng"; out = "off"; } 
              { "in" = "stänga"; out = "off"; }      
            ];
#            area.values = [              

#            ];  
            color.values = [
              { "in" = "röd"; out = "red"; }
              { "in" = "rött"; out = "red"; }
              { "in" = "rosa"; out = "pink"; }              
              { "in" = "grön"; out = "green"; }
              { "in" = "grönt"; out = "green"; }
              { "in" = "blå"; out = "blue"; }
              { "in" = "blått"; out = "blue"; }
              { "in" = "vit"; out = "white"; }
              { "in" = "vitt"; out = "white"; }
              { "in" = "gul"; out = "yellow"; }
              { "in" = "gult"; out = "yellow"; }
              { "in" = "lila"; out = "purple"; }
              { "in" = "ljust"; out = "bright"; }
              { "in" = "warm"; out = "warm"; }
              { "in" = "varm"; out = "warm"; }
              { "in" = "varmt"; out = "warm"; }
              { "in" = "kall"; out = "cold"; }                                          
              { "in" = "kallt"; out = "cold"; }
            ];
            brightness.values = [
              { "in" = "max"; out = "254"; }
              { "in" = "maxa"; out = "254"; }
              { "in" = "full"; out = "254"; }
              { "in" = "dämpa"; out = "50"; }
              { "in" = "halv"; out = "127"; }
              { "in" = "mörkt"; out = "10"; }
            ];  
          };
        }];
      };  
    };
  };

  yo.scripts.lights = {
    description = "Control lights and other home automatioon devices";
    category = "🧩 Miscellaneous";
    aliases = [ "zb" ];
#    helpFooter = ''
#    '';
    parameters = [  
      { name = "device"; description = "Device to control"; optional = true; }
      { name = "state"; description = "State of the device or group"; optional = true; }    
#      { name = "area"; description = "Device or group to control"; optional = true; }
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
      
      # Configuration
      STATE_DIR="${zigduckDir}"
      DEVICE="''${device:-}"
      STATE="''${state:-}"
      BRIGHTNESS="''${brightness:-}"
      COLOR="''${color:-}"
      TEMP="''${temperature:-}"
#      AREA="''${area:-}"
      MQTT_BROKER="${mqttHostIp}"
      PWFILE="$passwordfile"
      MQTT_USER="$user"
      MQTT_PASSWORD=$(<"$PWFILE")
          
      # Helper: Publish MQTT command
      mqtt_publish() {
        local topic="$1"
        local payload="$2"
        mosquitto_pub -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t "$topic" -m "$payload"
      }
      
      # Helper: Control device with color processing
      control_device() {
        local dev="$1"
        local state="$2"
        local brightness="$3"
        local color_input="$4"
        
        local hex_code=""
        if [[ -n "$color_input" ]]; then
          if [[ "$color_input" =~ ^#[0-9a-fA-F]{6}$ ]]; then
            # Use directly if already a HEX code
            hex_code="$color_input"
          else
            # Convert color name to HEX
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
          local payload='{"state":"ON"'
          [[ -n "$brightness" ]] && payload+=", \"brightness\":$brightness"
          [[ -n "$hex_code" ]] && payload+=", \"color\":{\"hex\":\"$hex_code\"}"
          payload+="}"
          mqtt_publish "zigbee2mqtt/$dev/set" "$payload"
          say_duck "Set $dev: $payload"
        fi
      }
      
      # Main execution logic
      if [[ -n "$DEVICE" ]]; then
        input_lower=$(echo "$DEVICE" | tr '[:upper:]' '[:lower:]')
        exact_name="''${device_map["''$input_lower"]:-}"
        
        if [[ -n "$exact_name" ]]; then
          # Generate unique color for each device if color is specified
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

      
      #######################################
      ##    FAILOVER MECHANISM (Conceptual)
      # TODO: Implement actual failover logic
      # This would monitor the system and transfer control to a backup host
      # if the primary becomes unresponsive for more than 1 minute
      #
      # while true; do
      #   if ! check_primary_alive; then
      #     echo "⚠️ Primary down! Transferring to backup..."
      #     yo deploy <backup-host> && reboot
      #     break
      #   fi
      #   sleep 30
      # done
    ''; 
  };}
  
  
  

