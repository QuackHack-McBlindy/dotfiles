# dotfiles/bin/lib.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{
  config,
  lib,
  pkgs,
  ...
} : let
  zigbeeDevices = config.house.zigbee.devices or {};
  scenes        = config.house.zigbee.scenes or {};

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


  numberValues = max:
    builtins.concatLists (builtins.genList
      (i: [
        { "in" = toString i;      out = toString i; }
        { "in" = swedishNumber i; out = toString i; }
      ])
      (max + 1));

  numberValuesOneBased = max:
    builtins.concatLists (builtins.genList
      (i: let n = i + 1; in [
        { "in" = toString n;      out = toString n; }
        { "in" = swedishNumber n; out = toString n; }
      ])
      max);

  deviceAliases = lib.listToAttrs (lib.concatMap (device:
    let
      fn      = device.friendly_name;
      aliases = lib.optionals (device.aliases != null) device.aliases;
    in if aliases == [] then [] else [
      (lib.nameValuePair fn aliases)
    ]
  ) (lib.attrValues zigbeeDevices));

  roomAliases = lib.mapAttrsToList (roomName: roomCfg:
    let
      aliases  = lib.optionals (roomCfg.aliases != null) roomCfg.aliases;
      allNames = lib.unique ([ roomName ] ++ aliases);
    in {
      aliases   = lib.concatStringsSep "|" allNames;
      canonical = roomName;
    }
  ) (config.house.rooms or {});

  roomAliasMap = lib.foldl' (acc: entry:
    let ins = lib.splitString "|" entry.aliases;
    in lib.foldl' (a: i: a // { "${lib.toLower i}" = entry.canonical; }) acc ins
  ) {} roomAliases;

  roomValues = map (r: { "in" = r.aliases; out = r.canonical; }) roomAliases;
  roomValuesFlat = lib.unique (
    lib.concatMap (entry: lib.splitString "|" entry."in") roomValues
  );

  normalizedDeviceMap = lib.mapAttrs' (_id: d:
    lib.nameValuePair (lib.toLower d.friendly_name) d.friendly_name
  ) zigbeeDevices;

  roomDevicesMap = let
    grouped = lib.groupBy (d: d.room) (lib.attrValues zigbeeDevices);
  in lib.mapAttrs (_room: devs: map (d: d.friendly_name) devs) grouped;

  roomBashMap = lib.mapAttrs (_room: devs: lib.concatStringsSep "|" devs) roomDevicesMap;

  typeMap = lib.mapAttrs' (_id: d:
    lib.nameValuePair (lib.toLower d.friendly_name) (d.type or "unknown")
  ) zigbeeDevices;

  allDevicesList = lib.attrValues normalizedDeviceMap;
  allDevicesStr  = lib.concatStringsSep "|" allDevicesList;

  deviceNames = lib.sort (a: b: a < b)
    (map (d: d.friendly_name) (lib.attrValues zigbeeDevices));

  roomNames = if (builtins.hasAttr "rooms" config.house) then
    builtins.attrNames config.house.rooms
  else
    lib.unique (map (d: d.room) (lib.attrValues zigbeeDevices));

  sceneNames = builtins.attrNames scenes;

  deviceValues = let
    reservedNames = [ "hall" "kitchen" "bedroom" "bathroom" "wc" "livingroom" "switch" "all" "every" ];
    sanitize = str: lib.replaceStrings [ "/" " " ] [ "" "_" ] str;

    swedishPatterns = base: baseRaw: [
      base
      "${baseRaw}n" "${baseRaw}t" "${baseRaw}en" "${baseRaw}et"
      "${baseRaw}ar" "${baseRaw}or" "${baseRaw}er"
      "${baseRaw}na" "${baseRaw}orna" "${baseRaw}erna"
      "${baseRaw}lampan" "${baseRaw}lampor" "${baseRaw}lamporna"
      "${baseRaw}ljus" "${baseRaw}lamp"
    ];

    buildVariants = raw:
      let
        baseRaw    = lib.toLower raw;
        base       = sanitize baseRaw;
        baseWords  = lib.splitString " " base;
        isAmbiguous = lib.any (w: lib.elem w reservedNames) baseWords;
        variants = lib.unique (
          [ base
            (sanitize (lib.replaceStrings [ " " ] [ "" ] base))
            (lib.replaceStrings [ "_" ] [ " " ] base)
          ] ++ lib.unique (swedishPatterns base baseRaw)
            ++ [ "${base}s" "${base} light" ]
        );
      in { inherit isAmbiguous variants; };
  in lib.filter (x: x != null) (
    lib.mapAttrsToList (_: device:
      let
        aliases    = deviceAliases.${device.friendly_name} or [];
        main       = buildVariants device.friendly_name;
        aliasPats  = map buildVariants aliases;
        valid      = lib.filter (p: !p.isAmbiguous) ([ main ] ++ aliasPats);
        variations = lib.unique (lib.concatMap (p: p.variants) valid);
      in if variations == [] then null else {
        "in" = lib.concatStringsSep "|" variations;
        out  = device.friendly_name;
      }
    ) zigbeeDevices
  );

  deviceValuesFlat = lib.unique (
    lib.concatMap (entry: lib.splitString "|" entry."in") deviceValues
  );

  sceneValues = let
    reservedSceneNames = [ "max" "dark" "off" "on" "all" "every" ];
    sanitizeScene = str:
      lib.toLower (lib.replaceStrings [ " " "-" "_" ] [ "" "" "" ] str);

    swedishScenePatterns = base: baseRaw: [
      base
      "${baseRaw}n" "${baseRaw}t" "${baseRaw}en" "${baseRaw}et"
      "${baseRaw} scen" "${baseRaw} scenen"
      "${baseRaw} läge" "${baseRaw} läget"
    ];
  in [
    { "in" = "tänd|tänk|max|maxa|maxxa|maxad|maximum";    out = "max"; }
    { "in" = "på|tänd|aktiv";                              out = "max"; }
    { "in" = "mörk|mörker|mörkt|släckt|avstängd";          out = "dark"; }
    { "in" = "av|släck|släckt|stängd|stäng";               out = "dark"; }
    { "in" = "mys|myspys|mysig|chill|chilla";              out = "Chill Scene"; }
  ] ++ (lib.mapAttrsToList (sceneId: sceneConfig:
    let
      baseRaw     = lib.toLower (sceneConfig.friendly_name or sceneId);
      base        = sanitizeScene baseRaw;
      baseWords   = lib.splitString " " base;
      isAmbiguous = lib.any (w: lib.elem w reservedSceneNames) baseWords;
      swedishVar  = if isAmbiguous then [] else lib.unique (swedishScenePatterns base baseRaw);
      variations  = lib.unique (
        [ base
          (sanitizeScene (lib.replaceStrings [ " " ] [ "" ] base))
          (lib.replaceStrings [ "_" "-" ] [ " " " " ] base)
          sceneId
        ] ++ swedishVar
      );
    in {
      "in" = lib.concatStringsSep "|" variations;
      out  = sceneId;
    }
  ) scenes);

  colorValues = [
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
    { "in" = "slumpmässig|random|valfri färg"; out = "random"; }
  ];

  temperatureValues = builtins.genList (i: {
    "in" = toString (i + 153);
    out  = toString (i + 153);
  }) 347;

  brightnessParamValues = builtins.map (n: toString n) (lib.range 0 100);
  brightnessVoiceValues = numberValuesOneBased 100;

  switchStateValues = [
    { "in" = "tänd|sätt på|slå på|starta|aktivera|på";      out = "ON"; }
    { "in" = "släck|stäng av|slå av|avaktivera|stäng|av";   out = "OFF"; }
  ];

  queryStateValues = [
    { "in" = "öppen|öppet|oppen|open";                   out = "öppen"; }
    { "in" = "stängd|stängt|stangd|closed";              out = "stängd"; }
    { "in" = "tänd|tänt|tand|on|på|pa";                  out = "tänd"; }
    { "in" = "släckt|släkt|slackt|off|av";               out = "släckt"; }
    { "in" = "rörelse|rörelser|motion|rörlig|aktiv|någon|nån|nått|några|folk|person|personer"; out = "rörelse"; }
  ];


  blindsValues = [
    { "in" = "up|upp";     out = "up"; }
    { "in" = "ner|ned";    out = "down"; }
    { "in" = "öppna";      out = "open"; }
    { "in" = "stäng";      out = "close"; }
  ];

  allLightsValues = [
    { "in" = "all|alla|allt"; out = "true"; }
  ];

  getTempValues = [
    { "in" = "temp|temperatur|grader"; out = "true"; }
    { "in" = "varm|varmt|kall|kallt";  out = "true"; }
  ];

  getBatValues = [
    { "in" = "batteri|battery|batteriet";     out = "true"; }
    { "in" = "batterinivå|batterinivån";      out = "true"; }
  ];

  timerParamValues = builtins.map (n: toString n) (lib.range 0 59);

  timerListValues = [
    { "in" = "länge|kvar"; out = "true"; }
  ];

  durationValues = [
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

  mkBashMap = name: attrs:
    let
      entries = lib.mapAttrsToList (k: v:
        "  [${lib.escapeShellArg k}]=${lib.escapeShellArg (toString v)}") attrs;
    in ''
      declare -A ${name}=(
      ${lib.concatStringsSep "\n" entries}
      )
    '';

  clockPrepValues = [
    { "in" = "över"; out = "över"; }
    { "in" = "i";    out = "i"; }
    { "in" = "halv"; out = "halv"; }
  ];

  clockMinuteWordValues =
    [ { "in" = "kvart"; out = "15"; } ]
    ++ numberValuesOneBased 29;

  clockHourValues = numberValuesOneBased 23
    ++ [ { "in" = "noll|midnatt"; out = "0"; } ];

  hoursParamValues = builtins.map (n: toString n) (lib.range 0 23);

  wildcard = { wildcard = true; values = []; };

  everyValues = [
    { "in" = "1|en";       out = "1"; }
    { "in" = "5|fem";      out = "5"; }
    { "in" = "10|tio";     out = "10"; }
    { "in" = "15|femton";  out = "15"; }
    { "in" = "30|trettio"; out = "30"; }
    { "in" = "60|sextio";  out = "60"; }
  ];

  devicePatternMap = lib.listToAttrs (lib.concatMap (entry:
    map (pat: lib.nameValuePair pat entry.out)
      (lib.splitString "|" entry."in")
  ) deviceValues);

in {
  inherit
    devicePatternMap
    wildcard everyValues
    clockPrepValues clockMinuteWordValues clockHourValues hoursParamValues
    swedishNumbers swedishNumber
    numberValues numberValuesOneBased
    deviceAliases deviceNames deviceValues deviceValuesFlat
    roomAliases roomNames roomValues roomValuesFlat roomAliasMap
    roomDevicesMap roomBashMap
    sceneNames sceneValues
    colorValues temperatureValues
    brightnessParamValues brightnessVoiceValues
    switchStateValues queryStateValues
    blindsValues allLightsValues getTempValues getBatValues
    timerParamValues timerListValues
    durationValues
    normalizedDeviceMap typeMap
    allDevicesList allDevicesStr
    mkBashMap;

}
