{ 
  self,
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  zigbeeDevices = config.house.zigbee.devices;
  scenes = config.house.zigbee.scenes;
in {

  yo.scripts.zigduck-cli = {
    description = "Control smart home devices.";
    category = "Home Automation";
    logLevel = "INFO";
    parameters = [   
      { name = "device"; description = "Device to control"; optional = true; }
      { name = "state"; type = "string"; description = "State of the device or group"; } 
      { name = "brightness"; description = "Brightness value (1-100)"; optional = true; type = "int"; }    
      { name = "color"; description = "Color name or hex code"; optional = true; }    
      { name = "temperature"; description = "Light color temperature (153-500)"; optional = true; }          
      { name = "scene"; description = "Activate a predefined scene"; optional = true; }     
      { name = "all-lights"; description = "Control all lights"; type = "bool"; optional = false; default = false; }        
      { name = "room"; description = "Room to target"; optional = true; }
      { name = "blinds"; description = "Control all blinds (up/down/open/close)"; optional = true; }      
      { name = "pair"; type = "bool"; description = "Activate zigbee2mqtt pairing and start searching for new devices"; default = false; }
    ];
    code = ''
       'hello world'
    '';
    voice = {
      priority = 1;
      fuzzy = {
        enable = true;
        threshold = 0.4;
      };  
    };
  };

  yo.scripts.zigduck-cli.voice.sentences = [
    # english patterns
    "(turn|switch) {state} {device} in the {room} and set color to {color} [and] brightness to {brightness} percent"
    "(turn|switch) {state} {device} and brightness {brightness} percent"
    "set {device} to {color} [and] {brightness} percent [brightness]"
    "set [the] {scene} [scene]"
    "(turn|switch){state} {all-lights} lights"
    "{state} the {device} [lights]"
    "turn {state} the {device}"
    "start {state} {device}"
    # color control
    "change the color of {device} to {color}"
    "set {device} to {color}"
    # pairing mode
    "{pair} [new|any] [zigbee] device[s]"
    # brightness control
    "adjust {device} to {brightness} percent"
    "[all] (blind|blinds) {blinds}"
    "roll {blinds} [all] (blind|blinds|cover|covers)"
  ];

  yo.scripts.zigduck-cli.voice.lists = {
    state.values = [
      { "in" = "on|activate"; out = "ON"; }
      { "in" = "off|deactivate"; out = "OFF"; }
    ];

    brightness.range = {
      type = "number";
      from = 1;
      to = 100;
      multiplier = 1;
    };

    device.values = let
      # sanitize device names for regex patterns
      sanitize = str: lib.replaceStrings [ "/" " " ] [ "" "_" ] str;

      # generic english variations for a device name
      englishPatterns = base: baseRaw: [
        base
        "${baseRaw}"                 # original
        "the ${baseRaw}"             # with article
        "${baseRaw}s"                # plural
        "the ${baseRaw}s"            # plural with article
        "${baseRaw} light"
        "${baseRaw} lamp"
        "${baseRaw} lights"
        "${baseRaw} lamps"
      ];
    in
      # built-in generic phrases (no hardcoded room names)
      [
        { "in" = "[all|everything|every light|all lights]"; out = "ALL_LIGHTS"; }
      ]
      ++
      # dynamically generate device patterns from config
      (lib.filter (x: x != null) (
        lib.mapAttrsToList (_: device:
          let
            baseRaw = lib.toLower device.friendly_name;
            base = sanitize baseRaw;
            variations = lib.unique (englishPatterns base baseRaw);
          in {
            "in" = "[" + lib.concatStringsSep "|" variations + "]";
            out = device.friendly_name;
          }
        ) zigbeeDevices
      ));

    color.values = [
      { "in" = "[red|reddish]"; out = "red"; }
      { "in" = "[green|greenish]"; out = "green"; }
      { "in" = "[blue|bluish]"; out = "blue"; }
      { "in" = "[yellow|yellowish]"; out = "yellow"; }
      { "in" = "[orange|orangish]"; out = "orange"; }
      { "in" = "[purple|violet]"; out = "purple"; }
      { "in" = "[pink|pinkish]"; out = "pink"; }
      { "in" = "[white|whitish]"; out = "white"; }
      { "in" = "[black|dark]"; out = "black"; }
      { "in" = "[gray|grey]"; out = "gray"; }
      { "in" = "[brown|brownish]"; out = "brown"; }
      { "in" = "[cyan|teal|turquoise]"; out = "cyan"; }
      { "in" = "[magenta|fuchsia]"; out = "magenta"; }
      { "in" = "[turquoise|teal]"; out = "turquoise"; }
      { "in" = "[teal|teal blue]"; out = "teal"; }
      { "in" = "[lime|lime green]"; out = "lime"; }
      { "in" = "[maroon|dark red]"; out = "maroon"; }
      { "in" = "[olive|olive green]"; out = "olive"; }
      { "in" = "[navy|navy blue]"; out = "navy"; }
      { "in" = "[lavender|light purple]"; out = "lavender"; }
      { "in" = "[coral|coral red]"; out = "coral"; }
      { "in" = "[gold|golden]"; out = "gold"; }
      { "in" = "[silver|silvery]"; out = "silver"; }
      { "in" = "[random|any color|surprise me]"; out = "random"; }
    ];

    temperature.values = builtins.genList (i: {
      "in" = toString (i + 153);
      out = toString (i + 153);
    }) 347; # 153-500

    scene.values = let
      sanitizeScene = str: lib.toLower (lib.replaceStrings [ " " "-" "_" ] [ "" "" "" ] str);
      englishScenePatterns = base: baseRaw: [
        base
        "${baseRaw}"
        "the ${baseRaw}"
        "${baseRaw} scene"
        "the ${baseRaw} scene"
      ];
    in
      # built-in generic scene synonyms (common ones)
      [
        { "in" = "[max|maximum|bright|full|all on|turn on]"; out = "max"; }
        { "in" = "[dark|off|dim|minimum|all off|turn off]"; out = "dark"; }
      ]
      ++
      # dynamically generate scene patterns from config
      (lib.mapAttrsToList (sceneId: sceneConfig:
        let
          baseRaw = lib.toLower (sceneConfig.friendly_name or sceneId);
          base = sanitizeScene baseRaw;
          variations = lib.unique (englishScenePatterns base baseRaw);
        in {
          "in" = "[" + lib.concatStringsSep "|" variations + "]";
          out = sceneId;
        }
      ) scenes);

    pair.values = [
      { "in" = "[pair|start pairing|discover|search for devices]"; out = "true"; }
    ];

    all-lights.values = [
      { "in" = "[all|every|all lights|every light]"; out = "true"; }
    ];

    room.values = let
      # generate room patterns from config.house.rooms (or fallback from devices)
      roomNames = if (builtins.hasAttr "rooms" config.house) then
        builtins.attrNames config.house.rooms
      else
        builtins.attrNames (lib.groupBy (d: d.room) (lib.attrValues zigbeeDevices));

      sanitizeRoom = str: lib.toLower (lib.replaceStrings [ " " "/" ] [ "" "_" ] str);
      englishRoomPatterns = room: [
        room                                   # original
        "the ${room}"                          # with article
        "${room}s"                             # plural
        "the ${room}s"                         # plural with article
        (sanitizeRoom room)                    # sanitized (if spaces)
        "the ${sanitizeRoom room}"
      ];
    in
      lib.forEach roomNames (room: {
        "in" = "[" + lib.concatStringsSep "|" (lib.unique (englishRoomPatterns room)) + "]";
        out = room;
      });

    blinds.values = [
      { "in" = "[up|upp]"; out = "up"; }
      { "in" = "[down]"; out = "down"; }

      { "in" = "[open]"; out = "open"; }
      { "in" = "[close]"; out = "close"; }  
    ];

  };}
