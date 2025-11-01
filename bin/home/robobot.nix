# dotfiles/bin/home/robobot.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ simplifies configuration of the Fingerbot Plus
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
  yo.scripts.robobot = {
    description = "Designed to simplify configuring the Zigbee Fingerbot Plus";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "DEBUG";
    parameters = [   
      { name = "device"; description = "Device to control"; optional = true; }
      { name = "mode"; description = "Working mode. Click, switch or program"; default = "on"; }     
      { name = "state"; type = "string"; description = "On/off state of the switch"; default = "ON"; }           
      { name = "delay"; type = "int"; description = "Sustain time"; default = 5; } 
      { name = "reverse"; description = "Reverse"; optional = true; type = "bool"; }    
      { name = "lower"; type = "int"; description = "Down movement limit"; }    
      { name = "upper"; type = "int"; description = "Up movement limit"; optional = true; }          
      { name = "touch"; type = "bool";  description = "Touch control"; default = false; }                
      { name = "user"; description = "Mosquitto username to use"; default = "mqtt"; }    
      { name = "passwordfile"; description = "File path containing password for Mosquitto user"; default = config.sops.secrets.mosquitto.path; }
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

      MQTT_BROKER="${mqttHostIp}"
      PWFILE="$passwordfile"
      MQTT_USER="$user"
      MQTT_PASSWORD=$(cat "$PWFILE")

      declare -A device_map=( ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "['${lib.toLower k}']='${v}'") normalizedDeviceMap)} )
      DEVICE_KEY=$(echo "$device" | tr '[:upper:]' '[:lower:]')
      FRIENDLY_NAME="${device_map[$DEVICE_KEY]:-$device}"

      if [ -z "$FRIENDLY_NAME" ]; then
        echo "❌ Unknown device: $device"
        exit 1
      fi

      PAYLOAD=$(jq -n \
        --arg mode "$mode" \
        --arg state "$state" \
        --argjson delay $delay \
        --arg reverse "$reverse" \
        --argjson lower $lower \
        --argjson upper $upper \
        --arg touch "$touch" \
        '{mode:$mode, state:$state, delay:$delay, reverse:$reverse, lower:$lower, upper:$upper, touch:$touch}')

      echo "Sending command to $FRIENDLY_NAME via $MQTT_BROKER"
      echo "$PAYLOAD"

      mqtt_pub -t "zigbee2mqtt/$FRIENDLY_NAME/set" -m "$PAYLOAD"   
    ''; 
    
  };}
