# dotfiles/bin/home/bed.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ bed controller
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
in { 
  yo.scripts.bed = {
    description = "Bed controller";
    category = "🛖 Home Automation";   
    parameters = [    
      { name = "part"; description = "Which part of the bed (head/feet)"; default = "head"; }
      { name = "state"; description = "Move up or down"; default = "up"; }     
    ];      
    code = ''
      ${cmdHelpers}
      case "$part" in
        head|huvud)
          case "$state" in
            on|up|upp)
              zig 'Bed Head' on
              ;;
            off|down|ned|ner)
              zig 'Bed Head' off
              ;;
          esac
          ;;
        feet|fot|fötter)
          case "$state" in
            on|up|upp)
              zig 'Bed Feet' on
              ;;
            off|down|ned|ner)
              zig 'Bed Feet' off
              ;;
          esac
          ;;
      esac
    '';
    voice = {
      enabled = false;
      sentences = [
        "(huvud|sänghuvud) {state}"
        "(fot|fötter|sängfot) {state}"
        "säng {part} {state}"
      ];
      lists = {
        part.values = [
          { "in" = "[huvud|head]"; out = "head"; }
          { "in" = "[fot|fötter|feet]"; out = "feet"; }
        ];
        state.values = [
          { "in" = "[upp|uppe|up]"; out = "up"; }             
          { "in" = "[ned|ner|down]"; out = "down"; } 
        ];
      };  
    };
  
  };}

