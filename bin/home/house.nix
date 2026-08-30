{ 
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
  yo.scripts.house = {
    description = "High-performance unified CLI for controlling all smart home devices.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "DEBUG";

    parameters = [   
      { name = "device"; description = "Device to control"; optional = true; values = deviceNames; }
      { name = "state"; type = "string"; description = "State of the device or group"; values = [ "ON" "OFF" ]; } 
      { name = "brightness"; description = "Brightness value (1-100)"; optional = true; type = "string"; values = brightnessValues; }
      { name = "color"; description = "Color name or hex code"; optional = true; }    
      { name = "temperature"; description = "Light color temperature (153-500)"; optional = true; }          
      { name = "scene"; description = "Activate a predefined scene"; optional = true; values = sceneNames; }
      { name = "all-lights"; description = "Control all lights"; type = "bool"; optional = false; default = false; }        
      { name = "room"; description = "Room to target"; optional = true; values = roomNames; }
      { name = "blinds"; description = "Control all blinds (up/down/open/close)"; optional = true; }
      { name = "get-temp"; description = "Fetch temperature in a room"; type = "bool"; optional = true; }
      { name = "get-bat"; description = "Fetch battery status for a device"; type = "bool"; optional = true; }
      #{ name = "pair"; type = "bool"; description = "Activate zigbee2mqtt pairing and start searching for new devices"; optional = true; }
    ];
    binary = self.inputs.zigduck.packages.x86_64-linux.zigduck-cli + "/bin/zigduck-cli";
    voice = {
      priority = 2;
      fuzzy = {
        enable = true;
        threshold = 0.5;
      };  
      sentences = [
        # 🦆 says ⮞ multi taskerz
        "{device} {state} i {room} och [ändra] färg[en] [till] {color} [och] ljusstyrka[n] [till] {brightness} procent"
        "{state} {device} [till] {color} [färg] [och] {brightness} procent [ljusstyrka]"
        "{state} {room} [till] {color} [färg] [och] {brightness} procent [ljusstyrka]"
        "{state} {room} och [ljusstyrka|ljusstyrkan] {brightness} procent"
        "(sätt|ställ|ändra|justera) {device} till {brightness} procent"
        "(sätt|ställ|ändra|justera) ljusstyrkan [på] {device} till {brightness} procent"
        "(gör|ställ) {device} (ljusare|mörkare)"
        "{device} till {brightness} procent"
        "{brightness} procent [ljusstyrka] på {device}"
        "{brightness} procent [ljusstyrka] i {room}"
        #"{scene} alla lampor"
        "{scene} (belysning|belysningen)"
        "{state} [av] {all-lights} (lampor|lamporna)"
        "{state} {device} (lampor|igen)"   
        "{state} [alla|allt] (lampor|lamporna|ljus) i {room}"
        "{state} (lamporna|ljusen) [i] {room}"
        "{state} {room}"
        "{state} belysningen i {room}"
        "{state} [på|av] i {room}"
        "{state} [alla|allt] (lampor|lamporna|ljus) i {room}"
        "{state} {device}"
        # 🦆 says ⮞ color control
        "(ändra|gör) färgen [på|i] {device} till {color}"
        "(ändra|gör) {device} {color}"
        "(ändra|gör) {room} {color}"
        # 🦆 says ⮞ pairing mode
        #"{pair} [ny|nya] [zigbee] (enhet|enheter)"
        # 🦆 says ⮞ brightness control
        "justera {device} till {brightness} procent"
        # 🦆 says ⮞ fetch temp
        "vad är {get-temp} i {room} [just] [nu]"
        "vad är det för {get-temp} i {room} [nu]"
        "hur många {get-temp} är det i {room} [just] [nu]"
        "hur {get-temp} är det i {room} [just] [nu]"
        # 🦆 says ⮞ fetch battery
        "hur mycket {get-bat} återstår (på|i) {device}"
        "hur mycket {get-bat} är det kvar (på|i) {device}"
        #"har {device} lite {get-bat} [kvar]"
        "är det mycket {get-bat} kvar på {device}"
        "vad har {device} för {get-bat} [nivå|procent]"
        # 🦆 says ⮞ contorl all blinds
        "(hissa|dra|veva|ta) {blinds} (persienner|persiennerna)"
        "{state} {all-lights} (lampor|lamporna)"
      ];        
      lists = {
        state.values = [
          { "in" = "tänd|sätt på|slå på|starta|aktivera|på"; out = "ON"; }
          { "in" = "släck|stäng av|slå av|avaktivera|stäng|av"; out = "OFF"; }
        ];
        brightness.values = builtins.concatLists (builtins.genList (
          i: let n = i + 1; in [
            { "in" = toString n; out = toString n; }
            { "in" = swedishNumber n; out = toString n; }
          ]
        ) 100);

        device.values = let
          reservedNames = [ "hall" "kitchen" "bedroom" "bathroom" "wc" "livingroom" "switch" "all" "every" ];
          sanitize = str:
            lib.replaceStrings [ "/" " " ] [ "" "_" ] str;
    
          # 🦆 says ⮞ natural Swedish patterns
          swedishPatterns = base: baseRaw: [
            # 🦆 says ⮞ base name
            base      
            # 🦆 says ⮞ definite form (the X)
            "${baseRaw}n"           # 🦆says⮞ en-words
            "${baseRaw}t"           # 🦆says⮞ ett-words  
            "${baseRaw}en"
            "${baseRaw}et"   
            # 🦆says⮞ plural forms
            "${baseRaw}ar"
            "${baseRaw}or"
            "${baseRaw}er"
            "${baseRaw}na"          # 🦆says⮞ plural definite
            "${baseRaw}orna"
            "${baseRaw}erna" 
            # 🦆says⮞ common Swedish light/lamp patterns
            "${baseRaw}lampan"
            "${baseRaw}lampor"
            "${baseRaw}lamporna"
            "${baseRaw}ljus"
            "${baseRaw}lamp"
          ];   
        in lib.filter (x: x != null) (
          lib.mapAttrsToList (_: device:
            let
              baseRaw = lib.toLower device.friendly_name;
              base = sanitize baseRaw;
              baseWords = lib.splitString " " base;
              isAmbiguous = lib.any (word: lib.elem word reservedNames) baseWords;
    
              # 🦆says⮞ gen Swedish variations
              swedishVariations = lib.unique (swedishPatterns base baseRaw);
    
              # 🦆says⮞ English as fallback
              englishVariants = [ "${base}s" "${base} light" ];
    
              variations = lib.unique (
                [
                  base
                  (sanitize (lib.replaceStrings [ " " ] [ "" ] base))
                  (lib.replaceStrings [ "_" ] [ " " ] base)
                ] ++ swedishVariations ++ englishVariants
              );
            in if isAmbiguous then null else {
              "in" = lib.concatStringsSep "|" variations;
              out = device.friendly_name;
            }
          ) zigbeeDevices
        );
  
        color.values = [
          { "in" = "röd|rött|röda"; out = "red"; }
          { "in" = "grön|grönt|gröna"; out = "green"; }
          { "in" = "blå|blått|blåa"; out = "blue"; }
          { "in" = "gul|gult|gula"; out = "yellow"; }
          { "in" = "orange|orangefärgad|orangea"; out = "orange"; }
          { "in" = "lila|lilla|violett|violetta"; out = "purple"; }
          { "in" = "rosa|rosafärgad|rosaaktig"; out = "pink"; }
          { "in" = "vit|vitt|vita"; out = "white"; }
          { "in" = "svart|svarta"; out = "black"; }
          { "in" = "grå|grått|gråa"; out = "gray"; }
          { "in" = "brun|brunt|bruna"; out = "brown"; }
          { "in" = "cyan|cyanblå|turkosblå"; out = "cyan"; }
          { "in" = "magenta|cerise|fuchsia"; out = "magenta"; }
          { "in" = "turkos|turkosgrön"; out = "turquoise"; }
          { "in" = "teal|blågrön"; out = "teal"; }
          { "in" = "lime|limegrön"; out = "lime"; }
          { "in" = "maroon|mörkröd"; out = "maroon"; }
          { "in" = "oliv|olivgrön"; out = "olive"; }
          { "in" = "navy|marinblå"; out = "navy"; }
          { "in" = "lavendel|ljuslila"; out = "lavender"; }
          { "in" = "korall|korallröd"; out = "coral"; }
          { "in" = "guld|guldfärgad"; out = "gold"; }
          { "in" = "silver|silverfärgad"; out = "silver"; }
          { "in" = "slumpmässig|random|valfri färg"; out = "random"; }
        ];
        
        temperature.values = builtins.genList (i: {
          "in" = toString (i + 153);
          out = toString (i + 153);
        }) 347; # 153-500
        
        scene.values = let
          reservedSceneNames = [ "max" "dark" "off" "on" "all" "every" ];
          sanitizeScene = str:
            lib.toLower (lib.replaceStrings [ " " "-" "_" ] [ "" "" "" ] str);
            
          # 🦆 says ⮞ natural Swedish scene patterns
          swedishScenePatterns = base: baseRaw: [
            # 🦆 says ⮞ base scene name
            base
            # 🦆 says ⮞ definite form
            "${baseRaw}n"
            "${baseRaw}t" 
            "${baseRaw}en"
            "${baseRaw}et"
            # 🦆 says ⮞ common scene patterns
            "${baseRaw} scen"
            "${baseRaw} scenen"
            "${baseRaw} läge"
            "${baseRaw} läget"
          ];      
        in [
          # 🦆 says ⮞ scenes
          { "in" = "tänd||tänk|max|maxa|maxxa|maxad|maximum"; out = "max"; }
          { "in" = "på|tänd|aktiv"; out = "max"; }
          
          { "in" = "mörk|mörker|mörkt|släckt|avstängd"; out = "dark"; }
          { "in" = "av|släck|släckt|stängd|stäng"; out = "dark"; }

          { "in" = "mys|myspys|mysig|chill|chilla"; out = "Chill Scene"; }
        ] ++
        (lib.mapAttrsToList (sceneId: sceneConfig:
          let
            baseRaw = lib.toLower sceneConfig.friendly_name or sceneId;
            base = sanitizeScene baseRaw;
            baseWords = lib.splitString " " base;
            isAmbiguous = lib.any (word: lib.elem word reservedSceneNames) baseWords;
    
            # 🦆 says ⮞ generate Swedish variations
            swedishVariations = if isAmbiguous then [] else lib.unique (swedishScenePatterns base baseRaw);
    
            variations = lib.unique (
              [
                base
                (sanitizeScene (lib.replaceStrings [ " " ] [ "" ] base))
                (lib.replaceStrings [ "_" "-" ] [ " " " " ] base)
                sceneId
              ] ++ swedishVariations
            );
          in {
            "in" = lib.concatStringsSep "|" variations;
            out = sceneId;
          }
        ) scenes);
        
        #pair.values = [
        #  { "in" = "[para|paras]"; out = "true"; }
        #];

        all-lights.values = [
          { "in" = "all|alla|allt"; out = "true"; }
        ];
        
        room.values = [
          { "in" = "kök|köket|kitchen"; out = "kitchen"; }
          { "in" = "vardagsrum|vardagsrummet"; out = "livingroom"; }
          { "in" = "sovrum|sovrummet|bedroom"; out = "bedroom"; }
          { "in" = "badrum|badrummet|wc|toilet"; out = "WC"; }
          { "in" = "hall|hallen|hallway"; out = "hallway"; }
        ];  
        
        
        blinds.values = [
          { "in" = "up|upp"; out = "up"; }
          { "in" = "ner|ned"; out = "down"; }

          { "in" = "öppna"; out = "open"; }
          { "in" = "stäng"; out = "close"; }  
        ];
        get-temp.values = [
          { "in" = "temp|temperatur|grader"; out = "true"; }
          { "in" = "varm|varmt|kall|kallt"; out = "true"; }      
        ];
        get-bat.values = [
          { "in" = "batteri|battery|batteriet"; out = "true"; }
          { "in" = "batterinivå|batterinivån"; out = "true"; }
          
        ];
      };
    };

  };}

