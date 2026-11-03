# dotfiles/bin/lib.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 says ⮞ voice helperz
  config,
  lib,
  pkgs,
  ...
} : let
  zigbeeDevices = config.house.zigbee.devices or {};
  zigbeeScenes  = config.house.zigbee.scenes or {};
  zigbeeRooms   = config.house.rooms or {};

  asList = v: if v == null then [] else v;

  # 🦆 says ⮞ HELPERS
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

  hundredsWord = h:
    if h == 1 then "etthundra"
    else if h == 2 then "tvåhundra"
    else if h == 3 then "trehundra"
    else null;

  swedishNumber = n:
    if n < 0 then toString n
    else if n < builtins.length swedishNumbers
    then builtins.elemAt swedishNumbers n
    else if n <= 300 then
      let
        h    = builtins.div n 100;
        rest = n - h * 100;
      in
        hundredsWord h
        + (if rest == 0 then "" else builtins.elemAt swedishNumbers rest)
    else toString n;

  numberFromZeroTo = max:
    builtins.concatLists (builtins.genList
      (i: [
        { "in" = toString i;      out = toString i; }
        { "in" = swedishNumber i; out = toString i; }
      ])
      (max + 1));

  numberFromOneTo = max:
    builtins.concatLists (builtins.genList
      (i: let n = i + 1; in [
        { "in" = toString n;      out = toString n; }
        { "in" = swedishNumber n; out = toString n; }
      ])
      max);

  #  🦆 says ⮞ READS VOICE LISTS OUT VALUES
  paramFrom = vs: lib.unique (map (v: v.out) vs);

  # 🦆 says ⮞ HOUSE LISTS
  devices = lib.mapAttrsToList (_: d:
    let
      names = lib.unique (map lib.toLower (
        [ d.friendly_name ] ++ asList (d.aliases or null)
      ));
    in {
      "in" = lib.concatStringsSep "|" names;
      out  = d.friendly_name;
    }
  ) zigbeeDevices;

  rooms = lib.mapAttrsToList (name: cfg:
    let
      names = lib.unique (map lib.toLower (
        [ name ] ++ asList (cfg.aliases or null)
      ));
    in {
      "in" = lib.concatStringsSep "|" names;
      out  = name;
    }
  ) zigbeeRooms;

  scenes = lib.mapAttrsToList (sceneName: cfg:
    let
      names = lib.unique (map lib.toLower (
        [ sceneName ] ++ asList (cfg._aliases or null)
      ));
    in {
      "in" = lib.concatStringsSep "|" names;
      out  = sceneName;
    }
  ) zigbeeScenes;

  # 🦆 says ⮞ VOICE LISTS
  colors = [
    { "in" = "röd|rött|röda";                out = "red"; }
    { "in" = "grön|grönt|gröna";             out = "green"; }
    { "in" = "blå|blått|blåa";               out = "blue"; }
    { "in" = "gul|gult|gula";                out = "yellow"; }
    { "in" = "orange|orangefärgad|orangea";  out = "orange"; }
    { "in" = "lila|lilla|violett|violetta";  out = "purple"; }
    { "in" = "rosa|rosafärgad|rosaaktig";    out = "pink"; }
    { "in" = "vit|vitt|vita";                out = "white"; }
    { "in" = "svart|svarta";                 out = "black"; }
    { "in" = "grå|grått|gråa";               out = "gray"; }
    { "in" = "brun|brunt|bruna";             out = "brown"; }
    { "in" = "cyan|cyanblå|turkosblå";       out = "cyan"; }
    { "in" = "magenta|cerise|fuchsia";       out = "magenta"; }
    { "in" = "turkos|turkosgrön";            out = "turquoise"; }
    { "in" = "teal|blågrön";                 out = "teal"; }
    { "in" = "lime|limegrön";                out = "lime"; }
    { "in" = "maroon|mörkröd";               out = "maroon"; }
    { "in" = "oliv|olivgrön";                out = "olive"; }
    { "in" = "navy|marinblå";                out = "navy"; }
    { "in" = "lavendel|ljuslila";            out = "lavender"; }
    { "in" = "korall|korallröd";             out = "coral"; }
    { "in" = "guld|guldfärgad";              out = "gold"; }
    { "in" = "silver|silverfärgad";          out = "silver"; }
    { "in" = "slumpmässig|random|valfri";    out = "random"; }
  ];

  brightness = numberFromOneTo 100;

  durations = [
    { "in" = "120|två minuter|2 minuter";                    out = "120"; }
    { "in" = "180|tre minuter|3 minuter";                    out = "180"; }
    { "in" = "300|fem minuter|5 minuter";                    out = "300"; }
    { "in" = "600|tio minuter|10 minuter";                   out = "600"; }
    { "in" = "900|femton minuter|15 minuter|en kvart";       out = "900"; }
    { "in" = "1200|tjugo minuter|20 minuter";                out = "1200"; }
    { "in" = "1800|trettio minuter|30 minuter|en halvtimme"; out = "1800"; }
    { "in" = "2700|fyrtiofem minuter|45 minuter";            out = "2700"; }
    { "in" = "3600|sextio minuter|60 minuter|en timme";      out = "3600"; }
  ];

  clock = {
    preps = [
      { "in" = "över"; out = "över"; }
      { "in" = "i";    out = "i"; }
      { "in" = "halv"; out = "halv"; }
    ];
    minuteWords = [ { "in" = "kvart"; out = "15"; } ] ++ numberFromOneTo 29;
    hours       = numberFromOneTo 23
                  ++ [ { "in" = "noll|midnatt"; out = "0"; } ];
    minutes     = numberFromZeroTo 59;
    seconds     = numberFromZeroTo 59;
  };

  temperature = builtins.genList (i: {
    "in" = toString (i + 153);
    out  = toString (i + 153);
  }) 347;

  # 🦆 says ⮞ PARAMETER VALIDATION (derived)
  param = {
    hours      = paramFrom clock.hours;
    minutes    = paramFrom clock.minutes;
    seconds    = paramFrom clock.seconds;
    brightness = paramFrom brightness;
  };

  # 🦆 says ⮞ LOOKUPS
  deviceMap = lib.listToAttrs (lib.concatMap (entry:
    map (pat: lib.nameValuePair pat entry.out)
      (lib.splitString "|" entry."in")
  ) devices);

  roomMap = lib.foldl' (acc: entry:
    let pats = lib.splitString "|" entry."in";
    in lib.foldl' (a: p: a // { "${p}" = entry.out; }) acc pats
  ) {} rooms;

  normalizedDeviceMap = lib.mapAttrs' (_id: d:
    lib.nameValuePair (lib.toLower d.friendly_name) d.friendly_name
  ) zigbeeDevices;

  typeMap = lib.mapAttrs' (_id: d:
    lib.nameValuePair (lib.toLower d.friendly_name) (d.type or "unknown")
  ) zigbeeDevices;

  deviceNames = lib.sort (a: b: a < b)
    (map (d: d.friendly_name) (lib.attrValues zigbeeDevices));

  roomNames = if zigbeeRooms != {} then
    builtins.attrNames zigbeeRooms
  else
    lib.unique (map (d: d.room) (lib.attrValues zigbeeDevices));

  sceneNames = builtins.attrNames zigbeeScenes;

  roomDevices = let
    grouped = lib.groupBy (d: d.room) (lib.attrValues zigbeeDevices);
  in lib.mapAttrs (_room: devs: map (d: d.friendly_name) devs) grouped;

  roomBashMap = lib.mapAttrs (_room: devs: lib.concatStringsSep "|" devs) roomDevices;

  allDevicesStr = lib.concatStringsSep "|" (lib.attrValues normalizedDeviceMap);

  # 🦆 says ⮞ BASH HELPER
  mkBashMap = name: attrs:
    let
      entries = lib.mapAttrsToList (k: v:
        "  [${lib.escapeShellArg k}]=${lib.escapeShellArg (toString v)}") attrs;
    in ''
      declare -A ${name}=(
      ${lib.concatStringsSep "\n" entries}
      )
    '';

in {
  inherit
    # 🦆 ⮞ voice lists (in/out)
    devices rooms scenes
    colors brightness durations clock temperature

    # 🦆 ⮞ param validation (plain strings)
    param

    # 🦆 ⮞ helpers
    numberFromZeroTo numberFromOneTo paramFrom

    # 🦆 ⮞ lookups
    deviceMap roomMap roomBashMap typeMap allDevicesStr
    deviceNames roomNames sceneNames roomDevices

    # 🦆 ⮞ bash
    mkBashMap;
}
