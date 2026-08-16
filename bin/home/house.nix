{ 
  lib,
  config,
  pkgs,
  ...
} : let 
  zigduckDir = "/home/" + config.this.user.me.name + "/.config/zigduck";
  scenes = config.house.zigbee.scenes;
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
  yo.scripts.house = {
    description = "High-performance unified CLI for controlling all smart home devices.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "DEBUG";

    parameters = [   
      { name = "device"; description = "Device to control"; optional = true; }
      { name = "state"; type = "string"; description = "State of the device or group"; } 
      { name = "brightness"; description = "Brightness value (1-100)"; optional = true; type = "int"; }    
      { name = "color"; description = "Color name or hex code"; optional = true; }    
      { name = "temperature"; description = "Light color temperature (153-500)"; optional = true; }          
      { name = "scene"; description = "Activate a predefined scene"; optional = true; }     
      { name = "all-lights"; description = "Control all lights"; type = "bool"; optional = false; default = false; }        
      { name = "room"; description = "Room to target"; optional = true; }        
      #{ name = "pair"; type = "bool"; description = "Activate zigbee2mqtt pairing and start searching for new devices"; default = false; }
      { name = "json"; description = "Raw JSON to send to device"; optional = true; }
      { name = "hue-key-file"; description = ""; optional = true; default = config.sops.secrets.hueBridgeAPI.path; }
    ];
    binary = /run/current-system/sw/bin/zigduck-cli;
    voice = {
      priority = 1;
      sentences = [
        #"{state} {all-lights} (lampor|lamporna)"
        # 🦆 says ⮞ multi taskerz
        "{device} {state} i {room} och [ändra] färg[en] [till] {color} [och] ljusstyrka[n] [till] {brightness} procent"
        "{state} {device} [till] {color} [färg] [och] {brightness} procent [ljusstyrka]"
        "{state} {room} [till] {color} [färg] [och] {brightness} procent [ljusstyrka]"
        "{state} {room} och ljusstyrka {brightness} procent"
        #"{scene} alla lampor"
        "{scene} (belysning|belysningen)"
        "{state} {all-lights} lampor"
        "{state} {device} (lampor|igen)"   
        "{state} lamporna i {device}"
        "stäng {state} {device}"
        "starta {state} {device}"
        # 🦆 says ⮞ color control
        "(ändra|gör) färgen [på|i] {device} till {color}"
        "(ändra|gör) {device} {color}"
        # 🦆 says ⮞ pairing mode
        "{pair} [ny|nya] [zigbee] (enhet|enheter)"
        # 🦆 says ⮞ brightness control
        "justera {device} till {brightness} procent"
      ];        
      lists = {
        state.values = [
          { "in" = "tänd"; out = "ON"; }             
          { "in" = "släck"; out = "OFF"; }
          { "in" = "[gör|ändra]"; out = "ON"; }
        ];
        brightness.range = {
          type = "number";
          from = 1;
          to = 100;
          multiplier = 1;
        };
        #brightness.values = builtins.genList (i: {
        #  "in" = toString (i + 1);
        #  out = toString (i + 1);
        #}) 100;
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
              "in" = "[" + lib.concatStringsSep "|" variations + "]";
              out = device.friendly_name;
            }
          ) zigbeeDevices
        );
  
        color.values = [
          { "in" = "[röd|rött|röda]"; out = "red"; }
          { "in" = "[grön|grönt|gröna]"; out = "green"; }
          { "in" = "[blå|blått|blåa]"; out = "blue"; }
          { "in" = "[gul|gult|gula]"; out = "yellow"; }
          { "in" = "[orange|orangefärgad|orangea]"; out = "orange"; }
          { "in" = "[lila|lilla|violett|violetta]"; out = "purple"; }
          { "in" = "[rosa|rosafärgad|rosaaktig]"; out = "pink"; }
          { "in" = "[vit|vitt|vita]"; out = "white"; }
          { "in" = "[svart|svarta]"; out = "black"; }
          { "in" = "[grå|grått|gråa]"; out = "gray"; }
          { "in" = "[brun|brunt|bruna]"; out = "brown"; }
          { "in" = "[cyan|cyanblå|turkosblå]"; out = "cyan"; }
          { "in" = "[magenta|cerise|fuchsia]"; out = "magenta"; }
          { "in" = "[turkos|turkosgrön]"; out = "turquoise"; }
          { "in" = "[teal|blågrön]"; out = "teal"; }
          { "in" = "[lime|limegrön]"; out = "lime"; }
          { "in" = "[maroon|mörkröd]"; out = "maroon"; }
          { "in" = "[oliv|olivgrön]"; out = "olive"; }
          { "in" = "[navy|marinblå]"; out = "navy"; }
          { "in" = "[lavendel|ljuslila]"; out = "lavender"; }
          { "in" = "[korall|korallröd]"; out = "coral"; }
          { "in" = "[guld|guldfärgad]"; out = "gold"; }
          { "in" = "[silver|silverfärgad]"; out = "silver"; }
          { "in" = "[slumpmässig|random|valfri färg]"; out = "random"; }
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
          { "in" = "[tänd||tänk|max|maxa|maxxa|maxad|maximum]"; out = "max"; }
          { "in" = "[på|tänd|aktiv]"; out = "max"; }
          
          { "in" = "[mörk|mörker|mörkt|släckt|avstängd]"; out = "dark"; }
          { "in" = "[av|släck|släckt|stängd|stäng]"; out = "dark"; }

          { "in" = "[mys|myspys|mysig|chill|chilla]"; out = "Chill Scene"; }
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
            "in" = "[" + lib.concatStringsSep "|" variations + "]";
            out = sceneId;
          }
        ) scenes);
        
        pair.values = [
          { "in" = "[para|paras]"; out = "true"; }
        ];

        all-lights.values = [
          { "in" = "[all|alla]"; out = "true"; }
        ];
        
        room.values = [
          { "in" = "[kök|köket|kitchen]"; out = "kitchen"; }
          { "in" = "[vardagsrum|vardagsrummet]"; out = "livingroom"; }
          { "in" = "[sovrum|sovrummet|bedroom]"; out = "bedroom"; }
          { "in" = "[badrum|badrummet|wc|toilet]"; out = "bathroom"; }
          { "in" = "[hall|hallen|hallway]"; out = "hallway"; }
        ];        
      };
    };
  };
}
