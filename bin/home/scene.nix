# dotfiles/bin/home/scene.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
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

  yo.scripts.scene = {
    description = "Activate a scene by name.";
    category = "🛖 Home Automation";
    parameters = [ { name = "name"; description = "Scene name"; } ];
    code = ''zigduck-cli --scene "$name"'';
    voice = {
      priority = 2;
      sentences = [
        "aktivera scen {name}"
        "sätt scen {name}"
        "kör scen {name}"
        "tänd scen {name}"
      ];
      lists.name.values = [
        { "in" = "max|allt|allt på";  out = "max"; }
        { "in" = "dark|mörkt|släckt"; out = "dark"; }
        { "in" = "dark fast|snabb släckt"; out = "dark-fast"; }
        { "in" = "kitchen instant|kök direkt"; out = "kitchenInstant"; }
        { "in" = "kitchen fade off|kök tona ut"; out = "kitchenFadeOff"; }
        { "in" = "kitchen green instant|kök grön direkt"; out = "kitchenGreenInstant"; }
        { "in" = "chill"; out = "Chill Scene"; }
        { "in" = "green d"; out = "Green D"; }
        { "in" = "tv area 1|tv1"; out = "tv-area1"; }
        { "in" = "tv area 2|tv2"; out = "tv-area2"; }
        { "in" = "tv area 3|tv3"; out = "tv-area3"; }
      ];

    };

  };}
