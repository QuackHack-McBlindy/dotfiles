# dotfiles/bin/home/kitchenFan.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ dang diz fan is noisey
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let # 🦆 says ⮞ configuration directory for diz module
  zigduck-cli = self.inputs.zigduck.packages.${pkgs.stdenv.hostPlatform.system}.zigduck-cli;

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

  # 🦆 says ⮞ Room bash map with only lights, using | as separator
  roomBashMap = lib.mapAttrs' (room: devices:
    lib.nameValuePair room (lib.concatStringsSep "|" devices)
  ) roomDevicesMap;

  # 🦆 says ⮞ All devices as a pipe-separated string
  allDevicesStr = lib.concatStringsSep "|" allDevicesList;
in { 
  yo.scripts.kitchenFan = {
    description = "Turns kitchen fan on/off";
    category = "🛖 Home Automation";  
    parameters = [    
      { name = "state"; description = "State of the device"; default = "on"; }     
    ];      
    code = ''
      ${cmdHelpers}
      if [[ "$state" == "on" ]]; then
        ${zigduck-cli}/bin/zigduck-cli --device Fläkt --state ON
      else
        ${zigduck-cli}/bin/zigduck-cli --device Fläkt --state OFF
      fi
    '';
    voice = {
      priority = 2;
      fuzzy = {
        enable = true;
        threshold = 0.5;
      };
      sentences = [
        "(fläkt|fläck|fkäckt|fläckten|fläkten) {state}" 
      ];
      lists = {
        state.values = [
          { "in" = "på|starta"; out = "ON"; }             
          { "in" = "av|släck|stäng"; out = "OFF"; } 
        ];
      };  
    };
    
  };}

