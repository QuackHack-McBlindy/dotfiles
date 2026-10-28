# dotfiles/bin/home/power.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  self,
  lib,
  config,
  pkgs,
  ...
} : let
  zigbeeDevices = config.house.zigbee.devices;
  scenes = config.house.zigbee.scenes;
  sceneNames = builtins.attrNames scenes;

  swedishNumbers = [
    "noll" "ett" "två" "tre" "fyra" "fem" "sex" "sju" "åtta" "nio" "tio"
    "elva" "tolv" "tretton" "fjorton" "femton" "sexton" "sjutton" "arton" "nitton"
    "tjugo" "tjugoett" "tjugotvå" "tjugotre" "tjugofyra" "tjugofem" "tjugosex" "tjugosju" "tjugoåtta" "tjugonio"
    "trettio" "trettioett" "trettiotvå" "trettiotre" "trettiofyra" "trettiofem" "trettiosex" "trettiosju" "trettioåtta" "trettionio"
    "fyrtio" "fyrtioett" "fyrtiotvå" "fyrtiotre" "fyrtiofyra" "fyrtiofem" "fyrtiosex" "fyrtiosju" "fyrtioåtta" "fyrtionio"
    "femtio" "femtioett" "femtiotvå" "femtiotre" "femtiofyra" "femtiofem" "femtiosex" "femtiosju" "femtioåtta" "femtionio"
    "sextio" "sextioett" "sextiotvå" "sextiotre" "sextiofyra" "sextiofem" "sextiosex" "sextiosju" "sextioåtta" "sextionio"
    "sjuttio" "sjuttioett" "sjuttiotvå" "sjuttiotre" "sjuttiofyra" "sjuttiofem" "sjuttiosex" "sjuttiosju" "sjuttioåtta" "sjuttionio"
    "åttio" "åttioett" "åttiotvå" "åttiotre" "åttiofyra" "åttiofem" "åttiosex" "åttiosju" "åttioåtta" "åttionio"
    "nittio" "nittioett" "nittiotvå" "nittiotre" "nittiofyra" "nittiofem" "nittiosex" "nittiosju" "nittioåtta" "nittionio"
    "etthundra"
  ];

  swedishNumber = n: builtins.elemAt swedishNumbers n;
  brightnessValues = builtins.map (n: toString n) (lib.range 0 100);

  deviceNames = map (d: d.friendly_name) (lib.attrValues zigbeeDevices);
  roomNames = if (builtins.hasAttr "rooms" config.house) then
    builtins.attrNames config.house.rooms
  else
    lib.unique (map (d: d.room) (lib.attrValues zigbeeDevices));


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

  yo.scripts.power = {
    description = "Check whether a device's power is above or below a threshold. Returns true/false.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "device"; description = "Device to check"; }
      { name = "above";  description = "Return true if power > this many watts"; optional = true; }
      { name = "below";  description = "Return true if power < this many watts"; optional = true; }
    ];

    code = ''
      D="''${device:-}"
      [ -z "$D" ] && { echo "false"; exit 1; }

      POWER=$(zigduck-cli --state-json 2>/dev/null | jq -r --arg d "$D" '.[$d].power // "0"' 2>/dev/null)
      [[ "$POWER" =~ ^[0-9.]+$ ]] || POWER=0

      RESULT=false
      if [ -n "''${above:-}" ] && [ -n "$POWER" ]; then
        [ "$(echo "$POWER > $above" | bc)" = "1" ] && RESULT=true
      elif [ -n "''${below:-}" ] && [ -n "$POWER" ]; then
        [ "$(echo "$POWER < $below" | bc)" = "1" ] && RESULT=true
      fi
      echo "$RESULT"
    '';

    voice = {
      priority = 2;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;
      sentences = [
        "{device} drar mer än {above} watt"
        "{device} drar över {above} watt"
        "{device} använder mer än {above} watt"
        "{device} drar mindre än {below} watt"
        "{device} använder mindre än {below} watt"
      ];
      lists = {
        device = { wildcard = true; values = []; };
        above.values = [
          { "in" = "10|tio";        out = "10"; }
          { "in" = "20|tjugo";      out = "20"; }
          { "in" = "50|femtio";     out = "50"; }
          { "in" = "100|etthundra"; out = "100"; }
        ];
        below.values = [
          { "in" = "5|fem";         out = "5"; }
          { "in" = "10|tio";        out = "10"; }
          { "in" = "20|tjugo";      out = "20"; }
        ];
      };
    };

  };}
