# dotfiles/bin/home/ping.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  devices,
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
  yo.scripts.ping = {
    description = "Turns kitchen fan on/off";
    category = "🛖 Home Automation";
    parameters = [
      { name = "device"; description = "IP of the device to call"; default = devices.ESP32-S3-BOX-3.ip; }
    ];
    code = ''
      ${cmdHelpers}
      curl http://$device/api/settings/speaker/play/ding
    '';
    voice = {
      priority = 2;
      fuzzy = {
        enable = true;
        threshold = 0.5;
      };
      sentences = [
        "(ping|pinga|pling|plinga|kling|klinga) {device}"
      ];
      lists = {
        device.values = [
          { "in" = "watch|klock|klocka|klockan"; out = devices.watch.ip; }
          { "in" = "box|esp32|box3|boxen|låda|lådan"; out = devices.ESP32-S3-BOX-3.ip; }
        ];
      };
    };

  };}
