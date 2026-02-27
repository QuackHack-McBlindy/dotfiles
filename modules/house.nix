# dotfiles/modules/house.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ here we define options that help us control our house yo 
  self,
  config,
  lib,
  pkgs,
  ...
} : let
  inherit (lib) types mkOption mkEnableOption mkMerge;  
  format = pkgs.formats.yaml { };
  configFile = format.generate "zigbee2mqtt.yaml" config.house.zigbee.settings;

  defaultPaths = root: {
    tv = root + "/TV";
    movies = root + "/Movies";
    music = root + "/Music";
    musicVideos = root + "/Music_Videos";
    otherVideos = root + "/Other_Videos";
    podcasts = root + "/Podcasts";
  };

  cmdHelpers = ''
    # 🦆 duck say ⮞ diis need explaination?!
    say_duck() {
      echo -e "\e[3m\e[38;2;0;150;150m🦆 duck say \e[1m\e[38;2;255;255;0m⮞\e[0m\e[3m\e[38;2;0;150;150m $1\e[0m"
    }  
    # 🦆 says ⮞ publish Mosquitto msgz
    mqtt_pub() {
      ${pkgs.mosquitto}/bin/mosquitto_pub -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" "$@"
    }
    # 🦆 says ⮞ outputs random hex within color range from plain text color names
    color2hex() {
      local color="$1"
      declare -A color_ranges=(
        ["red"]="255,0,0:165,0,0"
        ["green"]="0,255,0:0,100,0"
        ["blue"]="0,0,255:0,0,165"
        ["yellow"]="255,255,0:200,200,0"
        ["orange"]="255,165,0:205,100,0"
        ["purple"]="128,0,128:80,0,80"
        ["pink"]="255,192,203:220,150,160"
        ["white"]="255,255,255:240,240,240"
        ["black"]="10,10,10:0,0,0"
        ["gray"]="160,160,160:80,80,80"
        ["brown"]="165,42,42:120,30,30"
        ["cyan"]="0,255,255:0,200,200"
        ["magenta"]="255,0,255:180,0,180"
      )
      local r g b
      if [[ -z "$color" || "$color" == "random" || -z "''${color_ranges[''$color]}" ]]; then
        r=$(( RANDOM % 256 ))
        g=$(( RANDOM % 256 ))
        b=$(( RANDOM % 256 ))
      else
        IFS=':' read -r min_range max_range <<< "''${color_ranges[$color]}"
        IFS=',' read -r min_r min_g min_b <<< "$min_range"
        IFS=',' read -r max_r max_g max_b <<< "$max_range"
        r=$(( min_r + RANDOM % (max_r - min_r + 1) ))
        g=$(( min_g + RANDOM % (max_g - min_g + 1) ))
        b=$(( min_b + RANDOM % (max_b - min_b + 1) ))
      fi
      printf "%02x%02x%02x\n" "$r" "$g" "$b"
    }
    color2xy() { # 🦆 duck say ⮞ outputs xy as json
      local color="$1"
      declare -A color_ranges=(
        ["red"]="0.675,0.322:0.692,0.308"
        ["green"]="0.17,0.7:0.214,0.709"
        ["blue"]="0.14,0.08:0.153,0.048"
        ["yellow"]="0.452,0.47:0.507,0.472"
        ["orange"]="0.6,0.38:0.62,0.37"
        ["purple"]="0.28,0.13:0.265,0.11"
        ["pink"]="0.35,0.28:0.38,0.3"
        ["white"]="0.3227,0.329:0.313,0.337"
        ["black"]="0.15,0.08:0.12,0.06"
        ["gray"]="0.3227,0.329:0.3,0.31"
        ["brown"]="0.6,0.34:0.62,0.32"
        ["cyan"]="0.16,0.23:0.18,0.25"
        ["magenta"]="0.38,0.18:0.4,0.2"
        ["coolwhite"]="0.31,0.32:0.29,0.3"
        ["warmwhite"]="0.44,0.41:0.46,0.43"
        ["neutralwhite"]="0.35,0.35:0.37,0.37"
      )
      local x y

      if [[ -z "$color" || "$color" == "random" || -z "''${color_ranges[$color]}" ]]; then
        x=$(LC_ALL=C awk -v seed=$RANDOM 'BEGIN {srand(seed); printf "%.4f\n", 0.1 + rand() * 0.6}')
        y=$(LC_ALL=C awk -v seed=$RANDOM 'BEGIN {srand(seed); printf "%.4f\n", 0.05 + rand() * 0.6}')
      else
        IFS=':' read -r min_range max_range <<< "''${color_ranges[$color]}"
        IFS=',' read -r min_x min_y <<< "$min_range"
        IFS=',' read -r max_x max_y <<< "$max_range"
        
        x=$(LC_ALL=C awk -v min="$min_x" -v max="$max_x" -v seed=$RANDOM 'BEGIN {srand(seed); printf "%.4f\n", min + rand() * (max - min)}')
        y=$(LC_ALL=C awk -v min="$min_y" -v max="$max_y" -v seed=$RANDOM 'BEGIN {srand(seed); printf "%.4f\n", min + rand() * (max - min)}')
      fi
      
      LC_ALL=C awk -v x="$x" -v y="$y" 'BEGIN {printf "[%.4f,%.4f]\n", x, y}'
    }    
    
    # 🦆 says ⮞ hex to xy converter
    hex_to_xy() {
      local hex="$1"
      local r g b 
      hex=$(echo "$hex" | sed 's/^#//')
      [[ ''${#hex} -eq 6 ]] || { echo "0.5 0.4"; return 1; }
  
      r=$((16#''${hex:0:2}))
      g=$((16#''${hex:2:2}))
      b=$((16#''${hex:4:2}))
  
      local r_cor g_cor b_cor
      r_cor=$(echo "scale=4; $r / 255" | bc -l)
      g_cor=$(echo "scale=4; $g / 255" | bc -l)
      b_cor=$(echo "scale=4; $b / 255" | bc -l)
  
      r_cor=$(echo "scale=4; if ($r_cor > 0.04045) { e(2.4 * l($r_cor / 1.055 + 0.055)) } else { $r_cor / 12.92 }" | bc -l)
      g_cor=$(echo "scale=4; if ($g_cor > 0.04045) { e(2.4 * l($g_cor / 1.055 + 0.055)) } else { $g_cor / 12.92 }" | bc -l)
      b_cor=$(echo "scale=4; if ($b_cor > 0.04045) { e(2.4 * l($b_cor / 1.055 + 0.055)) } else { $b_cor / 12.92 }" | bc -l)
  
      local x y z
      x=$(echo "scale=4; ($r_cor * 0.649926 + $g_cor * 0.103455 + $b_cor * 0.197109)" | bc -l)
      y=$(echo "scale=4; ($r_cor * 0.234327 + $g_cor * 0.743075 + $b_cor * 0.022598)" | bc -l)
      z=$(echo "scale=4; ($r_cor * 0.000000 + $g_cor * 0.053077 + $b_cor * 1.035763)" | bc -l)
  
      local total
      total=$(echo "scale=4; $x + $y + $z" | bc -l)  
      if [[ $(echo "$total == 0" | bc -l) -eq 1 ]]; then
        echo "0.5 0.4"
      else
        local x_y y_y
        x_y=$(echo "scale=4; $x / $total" | bc -l)
        y_y=$(echo "scale=4; $y / $total" | bc -l)
        echo "$x_y $y_y"
      fi
    }
  '';

  getAllMotionSensors = 
    let devices = config.house.zigbee.devices or {};
    in lib.filterAttrs (_: device: device.type == "motion") devices;

  getMotionSensorNames = 
    let motionSensors = getAllMotionSensors;
    in lib.mapAttrsToList (_: device: device.friendly_name) motionSensors;

  roomType = types.submodule {
    options = {
      icon = mkOption {
        type = types.str;
        description = "Material Design (mdi) icon representing the room.";
      };
    };
  }; 

  # 🦆 says ⮞ color conversion helper function
  colorToHex = color:
    if color ? hex then color.hex
    else if color ? xy then
      let
        x = lib.elemAt color.xy 0;
        y = lib.elemAt color.xy 1;
        # XY to RGB approximation (for sRGB gamut)
        r = lib.clamp 0 255 (lib.toInt ((3.2406 * x - 1.5372 * y - 0.4986 * (1 - x - y)) * 255));
        g = lib.clamp 0 255 (lib.toInt ((-0.9689 * x + 1.8758 * y + 0.0415 * (1 - x - y)) * 255));
        b = lib.clamp 0 255 (lib.toInt ((0.0557 * x - 0.2040 * y + 1.0570 * (1 - x - y)) * 255));
      in
      "#" + 
      (lib.fixedWidthString 2 "0" (lib.toHexString r)) +
      (lib.fixedWidthString 2 "0" (lib.toHexString g)) +
      (lib.fixedWidthString 2 "0" (lib.toHexString b))
    else if color ? hue && color ? saturation then
      let
        # Convert Hue (0-65535) and Sat (0-254) to degrees/percentage
        hue_deg = (color.hue * 360) / 65535;
        sat_pct = color.saturation / 254.0;
        # Simplified HSV to RGB conversion
        c = sat_pct;
        h_prime = hue_deg / 60.0;
        x = c * (1 - lib.abs((builtins.mod h_prime 2) - 1));
        m = 1 - c;
      
        # Determine RGB based on hue sector
        rgb1 = 
          if h_prime < 1 then [c x 0]
          else if h_prime < 2 then [x c 0]
          else if h_prime < 3 then [0 c x]
          else if h_prime < 4 then [0 x c]
          else if h_prime < 5 then [x 0 c]
          else [c 0 x];
      
        r1 = lib.elemAt rgb1 0;
        g1 = lib.elemAt rgb1 1;
        b1 = lib.elemAt rgb1 2;
      
        r = lib.clamp 0 255 (lib.toInt ((r1 + m) * 255));
        g = lib.clamp 0 255 (lib.toInt ((g1 + m) * 255));
        b = lib.clamp 0 255 (lib.toInt ((b1 + m) * 255));
      in
      "#" + 
      (lib.fixedWidthString 2 "0" (lib.toHexString r)) +
      (lib.fixedWidthString 2 "0" (lib.toHexString g)) +
      (lib.fixedWidthString 2 "0" (lib.toHexString b))
    else "#ffffff";  # Default white



  # 🦆 says ⮞ auto what
  automationActionType = types.oneOf [
    (types.str)
    (types.submodule {
      options = {
        type = mkOption {
          type = types.enum ["mqtt" "shell" "scene"];
          default = "shell";
          description = "Type of automation action";
        };
        command = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "The shell command to execute (for shell type)";
        };
        topic = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "MQTT topic (for mqtt type)";
        };
        message = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "MQTT message (for mqtt type)";
        };
        scene = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Scene name (for scene type)";
        };
      };
    })
  ];

  # 🦆 says ⮞ dimmer action configuration
  dimmerActionType = types.submodule {
    options = {
      enable = mkEnableOption "Enable this dimmer action";
      description = mkOption {
        type = types.str;
        description = "Description of this action";
      };
      extra_actions = mkOption {
        type = types.listOf automationActionType;
        default = [];
        description = "Additional actions to perform when this dimmer action triggers";
      };
      override_actions = mkOption {
        type = types.listOf automationActionType;
        default = [];
        description = "If defined, replaces default behavior with these actions";
      };
    };
  };

  # 🦆 duck say ⮞ supported boards
  supportedBoards = {
    esp32s3box = {
      board = "esp32:esp32:esp32s3box";
      sketch = "esp32s3box.ino";
    };
    esp32s3-twatch = {
      board = "esp32:esp32:esp32s3dev";
      sketch = "esp32s3-twatch.ino";
    };
  };

  getAllFriendlyNames = 
    let devices = config.house.zigbee.devices or {};
    in lib.mapAttrsToList (_: device: device.friendly_name) devices;

  friendlyNamesSet = 
    let names = getAllFriendlyNames;
    in builtins.listToAttrs (map (name: { inherit name; value = true; }) names);

  deviceExistsByFriendlyName = deviceName:
    builtins.hasAttr deviceName friendlyNamesSet;

  roomExists = roomName:
    builtins.hasAttr roomName (config.house.rooms or {});

  isValidHexColor = color: 
    let cleanColor = lib.removePrefix "#" color;
    in lib.strings.match "[0-9A-Fa-f]{6}" cleanColor != null;

  isValidBrightness = brightness: 
    brightness >= 0 && brightness <= 254;

  isValidState = state: 
    builtins.elem state ["ON" "OFF"];

  validateScene = sceneName: sceneDevices:
    let
      availableNames = getAllFriendlyNames;
    in
    lib.flatten (lib.mapAttrsToList (deviceName: settings:
      [
        {
          assertion = deviceExistsByFriendlyName deviceName;
          message = "🦆 duck say ⮞ fuck ❌ Scene '${sceneName}' references non-existent device '${deviceName}'. Available: ${lib.concatStringsSep ", " (lib.take 10 availableNames)}${if lib.length availableNames > 10 then "..." else ""}";
        }
        {
          assertion = settings ? state -> isValidState settings.state;
          message = "🦆 duck say ⮞ fuck ❌ Scene '${sceneName}' device '${deviceName}' has invalid state '${settings.state}' (must be ON or OFF)";
        }
        {
          assertion = settings ? brightness -> isValidBrightness settings.brightness;
          message = "🦆 duck say ⮞ fuck ❌ Scene '${sceneName}' device '${deviceName}' has invalid brightness ${toString settings.brightness} (must be 0-254)";
        }
        {
          assertion = settings ? color -> (
            # 🦆says⮞ hex validation
            (settings.color ? hex && isValidHexColor settings.color.hex) ||
            # 🦆says⮞ xy coordinates validation
            (settings.color ? xy && lib.isList settings.color.xy && lib.length settings.color.xy == 2) ||
            # 🦆says⮞ hue/saturation validation  
            (settings.color ? hue && settings.color ? saturation && lib.isInt settings.color.hue && lib.isInt settings.color.saturation) ||
            # 🦆says⮞ color temperature validation
            (settings.color ? ct && lib.isInt settings.color.ct)
          );
          message = "🦆 duck say ⮞ fuck ❌ Scene '${sceneName}' device '${deviceName}' has invalid color format (must have hex, xy, hue/sat, or ct)";
        }
      ]
    ) sceneDevices);

  validateDevice = deviceId: device:
    [
      {
        assertion = roomExists device.room;
        message = "🦆 duck say ⮞ fuck ❌ Device '${device.friendly_name}' (${deviceId}) assigned to non-existent room '${device.room}'";
      }
      {
        assertion = isValidState "ON";
        message = "🦆 duck say ⮞ fuck ❌ Device '${device.friendly_name}' state validation failed";
      }
    ];

  validateMotionSensors = automationName: sensors:
    let
      availableSensors = getMotionSensorNames;
      invalidSensors = lib.filter (sensor: !lib.elem sensor availableSensors) sensors;
    in
      lib.optional (invalidSensors != []) {
        assertion = false;
        message = "🦆 duck say ⮞ fuck ❌ Automation '${automationName}' references non-existent motion sensors: ${toString invalidSensors}. Available: ${toString availableSensors}";
      };

  # 🦆 duck say ⮞ validation collector
  sceneValidations = lib.flatten (
    lib.mapAttrsToList validateScene (config.house.zigbee.scenes or {})
  );

  deviceValidations = lib.flatten (
    lib.mapAttrsToList validateDevice (config.house.zigbee.devices or {})
  );

  motionSensorValidations = lib.flatten (
    lib.mapAttrsToList (name: automation: 
      validateMotionSensors name (automation.motion_sensors or [])
    ) (config.house.zigbee.automations.presence_based or {})
  );

  # 🦆 says ⮞ duplicate friendly names
  duplicateFriendlyNameValidation = 
    let
      friendlyNames = getAllFriendlyNames;
      uniqueNames = lib.unique friendlyNames;
    in
    [{
      assertion = lib.length friendlyNames == lib.length uniqueNames;
      message = "🦆 duck say ⮞ fuck ❌ Duplicate friendly names found: ${toString (lib.subtractLists uniqueNames friendlyNames)}";
    }];

  isMqttEnabled = config.house.zigbee.mosquitto != null && 
                  (config.house.zigbee.mosquitto.username != null || 
                   config.house.zigbee.mosquitto.passwordFile != null);

  # 🦆 says ⮞ validate MQTT triggered automations
  validateMqttTriggered = automationName: automation:
    let
      availableTopics = [
        "zigbee2mqtt/+/action"
        "zigbee2mqtt/+/click"
        "zigbee2mqtt/+/occupancy"
        "zigbee2mqtt/+/contact"
        "zigbee2mqtt/+/brightness"
        "house/+/command"
        "automation/+/trigger"
      ];
    in
      [{
        assertion = automation.topic != "";
        message = "🦆 duck say ⮞ fuck ❌ MQTT automation '${automationName}' has empty topic";
      }];

  mqttTriggeredValidations = lib.flatten (
    lib.mapAttrsToList validateMqttTriggered (config.house.zigbee.automations.mqtt_triggered or {})
  );

  # 🦆 says ⮞ validation for MQTT configuration
  mqttValidations = [
    {
      assertion = config.house.zigbee.mosquitto != null -> 
        (config.house.zigbee.mosquitto.username != null) == (config.house.zigbee.mosquitto.passwordFile != null);
      message = "🦆 duck say ⮞ fuck ❌ MQTT authentication requires both username and passwordFile to be set together";
    }
    {
      assertion = config.house.zigbee.mosquitto != null && config.house.zigbee.mosquitto.ssl.enable -> 
        (config.house.zigbee.mosquitto.ssl.clientCertFile != null) == (config.house.zigbee.mosquitto.ssl.clientKeyFile != null);
      message = "🦆 duck say ⮞ fuck ❌ MQTT SSL client authentication requires both clientCertFile and clientKeyFile";
    }
  ];

  # 🦆 says ⮞ validation for syncBox TV
  syncBoxTvValidation = {
    assertion = config.house.zigbee.hueSyncBox != null && 
                config.house.zigbee.hueSyncBox.enable && 
                config.house.zigbee.hueSyncBox.syncBox.tv != "" -> 
                builtins.hasAttr config.house.zigbee.hueSyncBox.syncBox.tv config.house.tv;
    message = let
      syncBox = config.house.zigbee.hueSyncBox;
      tv = syncBox.syncBox.tv;
      availableTvs = lib.attrNames config.house.tv;
    in "🦆 duck say ⮞ fuck ❌ Hue Sync Box references non-existent TV '${tv}'. Available TVs: ${toString availableTvs}";
  };


  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = config.house.zigbee.devices;
  
  # 🦆 says ⮞ case-insensitive device matching
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ device validation list
  deviceList = builtins.attrNames normalizedDeviceMap;

  # 🦆 says ⮞ scene simplifier? or not
#  sceneLight = {state, brightness ? 200, hex ? null, temp ? null}:
#    let
#      colorValue = if hex != null then { inherit hex; } else null;
#    in
#    {
#      inherit state brightness;
#    } // (if colorValue != null then { color = colorValue; } else {})
#      // (if temp != null then { color_temp = temp; } else {});
  sceneLight = {state, brightness ? null, hex ? null, temp ? null, hue ? null, sat ? null, xy ? null, ct ? null, effect ? "none", alert ? "none", transition ? null}:
    let
      # Determine color mode based on what's provided
      colorValue = if hex != null then { inherit hex; } 
        else if xy != null then { inherit xy; }
        else if hue != null && sat != null then { inherit hue sat; }
        else if ct != null then { inherit ct; }
        else if temp != null then { ct = temp; }  # Map temp to ct for compatibility
        else null;
    in
    {
      inherit state;
    } // (if brightness != null then { inherit brightness; } else {})
      // (if colorValue != null then { color = colorValue; } else {})
      // (if effect != null && effect != "none" then { inherit effect; } else {})
      // (if alert != null && alert != "none" then { inherit alert; } else {})
      // (if transition != null then { inherit transition; } else {});


  # 🎨 Scenes  🦆 YELLS ⮞ SCENES!!!!!!!!!!!!!!!11
  scenes = config.house.zigbee.scenes; # 🦆 says ⮞ Declare light states, quack dat's a scene yo!   

  # 🦆 says ⮞ Generate scene commands    
  makeCommand = device: settings:
    let
      json = builtins.toJSON settings;
    in
      ''
      yo mqtt_pub --topic "zigbee2mqtt/${device}/set" .-message '${json}'
      '';
      
  sceneCommands = lib.mapAttrs
    (sceneName: sceneDevices:
      lib.mapAttrs (device: settings: makeCommand device settings) sceneDevices
    ) scenes;  

  # 🦆 says ⮞ Filter devices by rooms
  byRoom = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.room} = (acc.${dev.room} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # 🦆 says ⮞ Filter by device type
  byType = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.type} = (acc.${dev.type} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # 🦆 says ⮞ dis creates group configuration for Z2M yo
  groupConfig = lib.mapAttrs' (room: ids: {
    name = room;
    value = {
      friendly_name = room;
      devices = map (id: 
        let dev = zigbeeDevices.${id};
        in "${id}/${toString dev.endpoint}"
      ) ids;
    };
  }) byRoom;

  # 🦆 says ⮞ gen json from `config.house.tv`  
  tvDevicesJson = pkgs.writeText "tv-devices.json" (builtins.toJSON config.house.tv);

  # 🦆 says ⮞ dis creates device configuration for Z2M yo
  deviceConfig = lib.mapAttrs (id: dev: {
    friendly_name = dev.friendly_name;
  }) zigbeeDevices;

  # 🦆 says ⮞ IEEE not very human readable - lets fix dat yo
  ieeeToFriendly = lib.mapAttrs (ieee: dev: dev.friendly_name) zigbeeDevices;
  mappingJSON = builtins.toJSON ieeeToFriendly;
  mappingFile = pkgs.writeText "ieee-to-friendly.json" mappingJSON;

  # 🦆 says ⮞ not to be confused with facebook - this is not even duckbook
  deviceMeta = builtins.toJSON (
    lib.listToAttrs (
      lib.filter (attr: attr.name != null) (
        lib.mapAttrsToList (_: dev: {
          name = dev.friendly_name;
          value = {
            room = dev.room;
            type = dev.type;
            id = dev.friendly_name;
            endpoint = dev.endpoint;
          };
        }) zigbeeDevices
      )
    )
  );# 🦆 says ⮞ yaaaaaaaaaaaaaaay

  # 🦆 says ⮞ for da dashboard
  statusCardType = with lib.types; submodule {
    options = {
      enable = mkEnableOption "this status card";
      title = mkOption { type = str; };
      icon = mkOption { type = str; };
      color = mkOption { type = str; default = "#2ecc71"; };
      theme = lib.mkOption {
        type = lib.types.str;
        default = "neon";
        description = "Theme for this card (neon, minimal, dark, glass, colorful)";
      };
      group = mkOption {
        type = str;
        default = "default";
        example = "sensors";
        description = "Status cards are ordered by it's group name";
      };        
      # 🦆 says ⮞ for custom cards
      source = mkOption {
        type = enum [ "file" ];
        default = "file";
      };      
      # 🦆 says ⮞ file source options
      filePath = mkOption { 
        type = str; 
        default = ""; 
        description = "Path to JSON file for file source";
      };    
      # 🦆 says ⮞ MAIN value configuration
      jsonField = mkOption { 
        type = str; 
        default = ""; 
        description = "JSON field to extract from file for main value";
      };    
      detailsJsonField = mkOption { 
        type = nullOr str; 
        default = null;
        description = "JSON field to extract from file for details (optional)";
      };   
      # 🦆 says ⮞ display configuration
      format = mkOption { 
        type = str; 
        default = "{value}"; 
        description = "Format string for main value. Use {value} placeholder";
      };   
      detailsFormat = mkOption { 
        type = str; 
        default = "{value}"; 
        description = "Format string for details value. Use {value} placeholder";
      };
      chart = mkOption { 
        type = bool; 
        default = false; 
        description = "Wether to show a history chart in the status card";
      };
      historyField = mkOption { 
        type = str; 
        default = "history"; 
        description = "JSON field to extract history data from for the chart";
      };

      # 🦆 says ⮞ automate clickable actions
      on_click_action = mkOption { 
        type = lib.types.listOf automationActionType;
        default = [];
        description = "Actions to perform when clicking this status card";
      };    
  
      # 🦆 says ⮞ fallback values
      defaultValue = mkOption { type = str; default = ""; };
      defaultDetails = mkOption { type = str; default = ""; };   
      # 🦆 says ⮞ legacy support - will be used if detailsJsonField is null
      details = mkOption { 
        type = str; 
        default = ""; 
        description = "Static details text (used if detailsJsonField is not set)";
      };

    };
  };

in { # 🦆 says ⮞ Options for da house
    options.house = {
      # 🦆 says ⮞ mainly used to cast media to tv
      https = {
        domainNameFile = lib.mkOption {
          type = lib.types.path;
          description = ''
            File containing full https url.
            This should be served as webserver. (TLS req?)
            Example: "https://my-domain.com"
          '';
          default = "";
        };
      };  
      # 🦆 says ⮞ set media root & the rest is overrides
      media = with lib; {
        root = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Root directory for all media";
        };

        movies = mkOption {
          type = types.path;
          description = "Movies directory";
        };

        tv = mkOption {
          type = types.path;
          description = "TV shows directory";
        };

        music = mkOption {
          type = types.path;
          description = "Music directory";
        };

        musicVideos = mkOption {
          type = types.path;
          description = "Music videos directory";
        };

        otherVideos = mkOption {
          type = types.path;
          description = "Other videos directory";
        };

        podcasts = mkOption {
          type = types.path;
          description = "Podcasts directory";
        };
      };    
    
      # 🦆 says ⮞ hostname to play sounds on (TTS, timers, alarms etc)
      soundHost = lib.mkOption {
        type = lib.types.str;
        description = "hostname of the machine that should play sounds (TTS, timers, alarms etc)";
        default = "";
        example = "desktop";
      };
      
      # 🦆 says ⮞ dashboard configuraiton
      dashboard = {
        passwordFile = lib.mkOption {
          type = lib.types.path;
          description = "Passwordfile for the dashboard API";
          default = "";
        };
      
        pages = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              icon = lib.mkOption {
                type = lib.types.str;
                description = "Icon for the tab (FontAwesome class, MDI class, or image URL)";
                default = "fas fa-question";
              };
              code = lib.mkOption {
                type = lib.types.str;
                description = "HTML and JavaScript code for the page";
                default = "";
              };
              title = lib.mkOption {
                type = lib.types.str;
                description = "Title for the page (optional)";
                default = "";
              };
              files = lib.mkOption {
                type = lib.types.attrsOf (lib.types.oneOf [lib.types.path lib.types.str]);
                default = {};
                description = "Files to be symlinked to the http server for this page";
              };
              css = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Additional CSS for this page";
              };              
            };
          });
          default = {};
          description = "Custom pages for the dashboard";
        };

        # 🦆 says ⮞ junk card TODO remove   
        betaCard = {
          enable = (mkEnableOption "the beta card") // { default = false; };
        };
        
        statusCards = lib.mkOption {
          type = lib.types.attrsOf statusCardType;
          default = {};
          description = "Configurable status cards for the dashboard";
        };
      };
      
      # 🦆 duck say ⮞ set house rooms
      rooms = mkOption {
        type = types.attrsOf roomType;
        default = {
          bedroom.icon = "mdi:bedroom";
          hallway.icon = "mdi:hallway";
          kitchen.icon = "mdi:sofa";
          livingroom.icon = "mdi:toilet";
          wc.icon = "mdi:toilet";
          other.icon = "mdi:misc";
        };
        description = "A set of rooms in the house with their attributes.";
      };

      # 🦆 says ⮞ Service configuration for Zigduck Rust, API Rust, and DuckDash
      services = lib.mkOption {
        type = types.submodule {
          options = {
            # 🦆 says ⮞ SSL configuration type for services
            sslOptions = types.submodule {
              options = {
                enable = mkEnableOption "Enable SSL/TLS for this service";
                certFile = mkOption {
                  type = types.nullOr types.path;
                  default = null;
                  description = "Path to SSL certificate file";
                };
                keyFile = mkOption {
                  type = types.nullOr types.path;
                  default = null;
                  description = "Path to SSL private key file";
                };
                caCertFile = mkOption {
                  type = types.nullOr types.path;
                  default = null;
                  description = "Path to CA certificate file for client verification";
                };
                verifyClient = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Enable client certificate verification";
                };
              };
            };
      
            zigduck-rs = {
              enable = lib.mkEnableOption "Enable the Zigduck Rust service (home automation)" // {
                default = false;
              };
              host = lib.mkOption {
                type = lib.types.str;
                default = "0.0.0.0";
                description = "Host address for Zigduck Rust service to bind to";
                example = "127.0.0.1";
              };
              port = lib.mkOption {
                type = lib.types.port;
                default = 8080;
                description = "Port for Zigduck Rust service";
                example = 8080;
              };
              openFirewall = mkEnableOption "Open firewall port for Zigduck Rust service" // {
                default = false;
              };
              user = lib.mkOption {
                type = lib.types.str;
                default = "zigduck";
                description = "User to run Zigduck Rust service as";
              };
              group = lib.mkOption {
                type = lib.types.str;
                default = "zigduck";
                description = "Group to run Zigduck Rust service as";
              };
              dataDir = lib.mkOption {
                type = lib.types.str;
                default = "/var/lib/zigduck-rs";
                description = "Data directory for Zigduck Rust service";
              };
              stateDir = lib.mkOption {
                type = lib.types.str;
                default = "/var/lib/zigduck-rs";
                description = "State directory for Zigduck Rust service";
              };
              logLevel = lib.mkOption {
                type = lib.types.enum ["error" "warn" "info" "debug" "trace"];
                default = "info";
                description = "Log level for Zigduck Rust service";
              };
              environmentFile = lib.mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Environment file for Zigduck Rust service";
              };
              extraConfig = lib.mkOption {
                type = lib.types.attrs;
                default = {};
                description = "Extra configuration options for Zigduck Rust service";
              };
              ssl = lib.mkOption {
                type = types.nullOr (types.submodule {
                  options = {
                    enable = mkEnableOption "Enable SSL/TLS for Zigduck Rust service";
                    certFile = mkOption {
                      type = types.path;
                      description = "Path to SSL certificate file";
                    };
                    keyFile = mkOption {
                      type = types.path;
                      description = "Path to SSL private key file";
                    };
                    caCertFile = mkOption {
                      type = types.nullOr types.path;
                      default = null;
                      description = "Path to CA certificate file for client verification";
                    };
                  };
                });
                default = null;
                description = "SSL/TLS configuration for Zigduck Rust service";
              };
            };
      
            api-rs = {
              enable = lib.mkEnableOption "Enable the API Rust service" // {
                default = false;
              };
              host = lib.mkOption {
                type = lib.types.str;
                default = "0.0.0.0";
                description = "Host address for API Rust service to bind to";
                example = "127.0.0.1";
              };
              port = lib.mkOption {
                type = lib.types.port;
                default = 13335;
                description = "Port for API Rust service";
                example = 9815;
              };
              openFirewall = mkEnableOption "Open firewall port for API Rust service" // {
                default = false;
              };
              user = lib.mkOption {
                type = lib.types.str;
                default = "zigduck";
                description = "User to run API Rust service as";
              };
              group = lib.mkOption {
                type = lib.types.str;
                default = "zigduck";
                description = "Group to run API Rust service as";
              };
              dataDir = lib.mkOption {
                type = lib.types.str;
                default = "/var/lib/api-rs";
                description = "Data directory for API Rust service";
              };
              stateDir = lib.mkOption {
                type = lib.types.str;
                default = "/var/lib/api-rs/state";
                description = "State directory for API Rust service";
              };
              logLevel = lib.mkOption {
                type = lib.types.enum ["error" "warn" "info" "debug" "trace"];
                default = "info";
                description = "Log level for API Rust service";
              };
              environmentFile = lib.mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Environment file for API Rust service";
              };
              extraConfig = lib.mkOption {
                type = lib.types.attrs;
                default = {};
                description = "Extra configuration options for API Rust service";
              };
              ssl = lib.mkOption {
                type = types.nullOr (types.submodule {
                  options = {
                    enable = mkEnableOption "Enable SSL/TLS for API Rust service";
                    certFile = mkOption {
                      type = types.path;
                      description = "Path to SSL certificate file";
                    };
                    keyFile = mkOption {
                      type = types.path;
                      description = "Path to SSL private key file";
                    };
                    caCertFile = mkOption {
                      type = types.nullOr types.path;
                      default = null;
                      description = "Path to CA certificate file for client verification";
                    };
                  };
                });
                default = null;
                description = "SSL/TLS configuration for API Rust service";
              };
            };
      
            duckdash = {
              enable = lib.mkEnableOption "Enable the DuckDash web dashboard" // {
                default = false;
              };
              host = lib.mkOption {
                type = lib.types.str;
                default = "0.0.0.0";
                description = "Host address for DuckDash to bind to";
                example = "0.0.0.0";
              };
              port = lib.mkOption {
                type = lib.types.port;
                default = 13337;
                description = "Port for DuckDash web dashboard";
                example = 8082;
              };
              openFirewall = mkEnableOption "Open firewall port for DuckDash service" // {
                default = false;
              };
              user = lib.mkOption {
                type = lib.types.str;
                default = "duckdash";
                description = "User to run DuckDash service as";
              };
              group = lib.mkOption {
                type = lib.types.str;
                default = "duckdash";
                description = "Group to run DuckDash service as";
              };
              dataDir = lib.mkOption {
                type = lib.types.str;
                default = "/var/lib/duckdash";
                description = "Data directory for DuckDash service";
              };
              stateDir = lib.mkOption {
                type = lib.types.str;
                default = "/var/lib/duckdash/state";
                description = "State directory for DuckDash service";
              };
              logLevel = lib.mkOption {
                type = lib.types.enum ["error" "warn" "info" "debug" "trace"];
                default = "info";
                description = "Log level for DuckDash service";
              };
              environmentFile = lib.mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Environment file for DuckDash service";
              };
              extraConfig = lib.mkOption {
                type = lib.types.attrs;
                default = {};
                description = "Extra configuration options for DuckDash service";
              };
              # 🦆 says ⮞ SSL configuration specifically for DuckDash
              ssl = lib.mkOption {
                type = types.nullOr (types.submodule {
                  options = {
                    enable = mkEnableOption "Enable SSL/TLS for DuckDash service";
                    certFile = mkOption {
                      type = types.path;
                      description = "Path to SSL certificate file";
                    };
                    keyFile = mkOption {
                      type = types.path;
                      description = "Path to SSL private key file";
                    };
                    caCertFile = mkOption {
                      type = types.nullOr types.path;
                      default = null;
                      description = "Path to CA certificate file for client verification";
                    };
                    redirectHttp = mkOption {
                      type = types.bool;
                      default = true;
                      description = "Redirect HTTP to HTTPS";
                    };
                    httpPort = mkOption {
                      type = types.port;
                      default = 80;
                      description = "HTTP port for redirection (if redirectHttp is enabled)";
                    };
                  };
                });
                default = null;
                description = "SSL/TLS configuration for DuckDash service";
              };
            };
          };
        };
        default = {};
        description = "House service configurations for Zigduck Rust Automation System, Rust REST API Endpoints, DuckDash Generates HTML/JS/CSS from Nix house configuration";
      };
      
      
      # 🦆 duck say ⮞ set our esp device info
      tv = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "Enable this Android TVOS device";
            room = lib.mkOption {
              type = lib.types.strMatching (lib.concatStringsSep "|" (lib.attrNames config.house.rooms));
              description = "Room where TV is located";
            };
            ip = lib.mkOption {
              type = lib.types.str;
              description = "TV's static IP address";
            };

            apps = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = {};
              description = "App package names and activities for this TV device";
              example = {
                telenor = "se.telenor.stream/.MainActivity";
                tv4 = "se.tv4.tv4playtab/se.tv4.tv4play.ui.mobile.main.BottomNavigationActivity";
              };
            };
            
            # 🦆 duck say ⮞ TV channel definitions
            channels = lib.mkOption {
              type = lib.types.attrsOf (lib.types.submodule {
                options = {
                  name = lib.mkOption {
                    type = lib.types.str;
                    description = "Channel display name";
                  };
                  icon = lib.mkOption {
                    type = types.nullOr types.path;
                    description = "Optional file path for channel icon used for the generated TV-guide web frontend";
                    default = null;
                  };                  
                  id = lib.mkOption {
                    type = lib.types.nullOr lib.types.int;
                    default = null;
                    description = "Channel ID number, when set will send defined value as ADB channel command.";
                  };
                  cmd = lib.mkOption {
                    type = lib.types.str;
                    description = "Sequence of ADB commands to launch channel. Seperated with && (Overrides ID)";
                    default = "";
                  };     
                  stream_url = lib.mkOption {
                    type = lib.types.str;
                    description = "Stream URL to send to device. (Overrides ID)";
                    default = "";
                  };
                  scrape_url = lib.mkOption {
                    type = lib.types.str;
                    description = "Scrape URL for TV-Guide";
                    default = "";
                  };      
                };
              });
              description = "TV channel options";
            };
          };
        });
        default = {};
      };
      
      # 🦆 says ⮞ set our esp device info
      esp = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
          options = {
            enable = lib.mkEnableOption "Enable this ESP device";
            type = lib.mkOption {
              type = lib.types.enum (lib.attrNames supportedBoards);
              default = "esp32s3box";
              description = "Device hardware type";
            };
            ip = lib.mkOption {
              type = lib.types.str;
              description = "Static IP address for the device";
            };
            mac = lib.mkOption {
              type = lib.types.str;
              description = "MAC address for DHCP reservation";
            };
            serialPort = lib.mkOption {
              type = lib.types.str;
              default = "/dev/ttyACM0";
              description = "Default serial port for flashing";
            };
            description = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Human-readable device description";
            };
        
            # 🦆 duck say ⮞ internal  
            board = lib.mkOption {
              type = lib.types.str;
              internal = true;
              readOnly = true;
            };
            sketch = lib.mkOption {
              type = lib.types.str;
              internal = true;
              readOnly = true;
            };
          };
      
          config = let
            type = config.type or "esp32s3box";
            boardInfo = supportedBoards.${type};
          in {
            board = boardInfo.board;
            sketch = boardInfo.sketch;
          };
        }));
        default = {};
        description = "Configuration for ESP devices";
      };

      zigbee = {
      
        enable = lib.mkEnableOption "zigbee2mqtt service";

        #package = lib.mkPackageOption pkgs "zigbee2mqtt" { };

        dataDir = lib.mkOption {
          description = "Zigbee2mqtt data directory";
          default = "/var/lib/zigbee";
          type = lib.types.path;
        };

        settings = lib.mkOption {
          type = format.type;
          default = { };
          example = lib.literalExpression ''
            {
              homeassistant.enabled = config.services.home-assistant.enable;
              permit_join = true;
              serial = {
                port = "/dev/ttyACM1";
              };
            }
          '';
          description = ''
            Your {file}`configuration.yaml` as a Nix attribute set.
            Check the [documentation](https://www.zigbee2mqtt.io/information/configuration.html)
            for possible options.
          '';
        };

      
      
        networkKeyFile = mkOption {
          type = types.path;
          description = "Path to the Zigbee network key file.";
        };
      };

      zigbee.mosquitto = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            host = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "IP address of the host running Mosquitto";
              example = "192.168.1.211";
            };  
            username = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "MQTT username for authentication";
            };  
            passwordFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Path to file containing MQTT password";
            };
            # 🦆 says ⮞ SSL/TLS options for secure MQTT connections
            ssl = {
              enable = mkEnableOption "Enable SSL/TLS for MQTT connection";    
              caCertFile = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Path to CA certificate file";
              };    
              clientCertFile = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Path to client certificate file";
              };    
              clientKeyFile = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Path to client private key file";
              };
            };
          };
        });
      };

      
      zigbee.coordinator = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            vendorId = mkOption {
              type = types.str;
              description = "USB vendor ID (hex format)";
            };
            productId = mkOption {
              type = types.str;
              description = "USB product ID (hex format)";
            };
            symlink = mkOption {
              type = types.str;
              description = "Symlink name to create in /dev";
            };
            adapter = mkOption {
              type = types.str;
              description = "Adapter type for the coordinator, required for Zigbee2MQTT version 2.x and above. If you don't kknow leave blank for default.";
              default = "zstack";
            };
          };
        });
        default = {};
        description = "Serial port device mapping by USB IDs";
      };

      # 🦆 says ⮞ Philips Hue Play HDMI Sync Box (winz price for longest product name?)
      # 🦆 says ⮞ syncing lights to TV
      zigbee.hueSyncBox = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            enable = mkEnableOption "Enable Philips Hue Bridge & Sync Box integration";      
            # 🦆 says ⮞ Hue Bridge configuration (sadly must have for sync - i block it's internet access)
            bridge = {
              ip = mkOption {
                type = types.str;
                description = "IP address of the Philips Hue Bridge";
              };
              passwordFile = mkOption {
                type = types.path;
                description = "File containing the Hue Bridge API key (username)";
              };
            };      
            # 🦆 says ⮞ Hue Sync Box configuration
            syncBox = {
              ip = mkOption {
                type = types.str;
                description = "IP address of the Philips Hue Sync Box";
              };
              passwordFile = mkOption {
                type = types.path;
                description = "File containing the Hue Sync Box API key";
              };
              tv = mkOption {
                type = types.str;
                description = "What TV should syncBox syncronize the lights to. Available TVs: ${lib.concatStringsSep ", " (lib.attrNames config.house.tv)}";
                default = "";
                example = "shield";
                apply = tvName:
                  if tvName == "" then tvName
                  else if builtins.hasAttr tvName config.house.tv then tvName
                  else throw "TV '${tvName}' is not defined in house.tv. Available: ${lib.concatStringsSep ", " (lib.attrNames config.house.tv)}";
              };
            };      
            insecure = mkOption {
              type = types.bool;
              default = false;
              description = "Allow insecure HTTP for Bridge (use with caution!)";
            };
            skipCertCheck = mkOption {
              type = types.bool;
              default = true;
              description = "Skip SSL certificate verification for Sync Box (self-signed cert)";
            };
          };
        });
        default = null;
        description = "Philips Hue Bridge & Sync Box configuration for TV to lights syncing";
      };

      # 🦆 says ⮞ dimmer coniguration      
      zigbee.dimmer = lib.mkOption {
        type = types.submodule {
          options = {
            # 🦆 says ⮞ which MQTT field contains the action
            message = lib.mkOption {
              type = lib.types.str;
              default = "action";
              description = "MQTT field name containing dimmer action";
            };
            # 🦆 says ⮞ action mappings
            actions = {
              onPress = lib.mkOption {
                type = lib.types.str;
                default = "on_press_release";
                description = "Action for single press of ON button";
              };
              onHold = lib.mkOption {
                type = lib.types.str;
                default = "on_hold_release";
                description = "Action for holding ON button";
              };
              offPress = lib.mkOption {
                type = lib.types.str;
                default = "off_press_release";
                description = "Action for single press of OFF button";
              };
              offHold = lib.mkOption {
                type = lib.types.str;
                default = "off_hold_release";
                description = "Action for holding OFF button";
              };
              upPress = lib.mkOption {
                type = lib.types.str;
                default = "up_press_release";
                description = "Action for single press of UP button";
              };
              upHold = lib.mkOption {
                type = lib.types.str;
                default = "up_hold_release";
                description = "Action for holding UP button";
              };
              downPress = lib.mkOption {
                type = lib.types.str;
                default = "down_press_release";
                description = "Action for single press of DOWN button";
              };
              downHold = lib.mkOption {
                type = lib.types.str;
                default = "down_hold_release";
                description = "Action for holding DOWN button";
              };
            };
          };  
        };    
        default = {
          message = "action";
          actions = {
            onPress = "on_press_release";
            onHold = "on_hold_release";
            offPress = "off_press_release";
            offHold = "off_hold_release";
            upPress = "up_press_release";
            upHold = "up_hold_release";
            downPress = "down_press_release";
            downHold = "down_hold_release";
          };
        };
        description = "Configuration for dimmer switches. Default configuration is for the Philips Hue Dimmer Switch. You can check the message for your specific dimmer at zigbee2MQTT documentation.";
      };


      # 🦆 say ⮞ lights don't help blind ducks but guests might like
      zigbee.devices = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            friendly_name = mkOption {
              type = types.str;
              description = "A human-readable device name.";
              example = "Kitchen Dimmer";
            };
            room = lib.mkOption { 
              type = lib.types.strMatching (lib.concatStringsSep "|" (lib.attrNames config.house.rooms));
              description = "The room this device belongs to.";
              example = "kitchen";
            };
            type = lib.mkOption { 
              type = lib.types.enum [ "light" "hue_light" "dimmer" "sensor" "motion" "outlet" "remote" "pusher" "blind" ];
              description = "The type of device (e.g., light, dimmer, sensor, motion, outlet, remote, pusher, blind, hue_light).";
              example = "light";
            };
            icon = lib.mkOption { 
              type = lib.types.str;
              description = "Material Design icon name representing this device.";
              default = "mdi:monitor-shimmer";
              example = "mdi:cancel";
            };
            
            batteryType = mkOption {
              type = types.nullOr (types.enum ["CR2032" "CR2450" "CR02" "AAA" "AA"]);
              default = null;
              description = "Optional type of battery the device uses, if applicable.";
              example = "CR2032";
            };
            
            supports_color = mkOption {
              type = types.bool;
              default = false;
              description = "Whether the light device supports setting color.";
              example = true;
            };
            
            supports_temperature = mkOption {
              type = types.bool;
              default = false;
              description = "Whether the light device supports setting temperature.";
              example = true;
            };
            
            endpoint = lib.mkOption { 
              type = lib.types.int;
              description = "The Zigbee endpoint to control this device.";
              example = 11;
            };
            
            hue_id = lib.mkOption { 
              type = types.nullOr types.int;
              description = "The light_id for the device. Integrates Philips Hue paired devices. Configuring this option will NOT insert the device into the Zigbee2MQTT configuration file.";
              example = 11;
              default = null;
            };            
          };
        });
        default = {};
          description = "Zigbee device definitions keyed by device ID.";
          example = {
            "0x0017880103ca6e95" = {
              friendly_name = "Kitchen Dimmer";
              room = "kitchen";
              type = "dimmer";
              icon = "mdi-toggle-switch";
              endpoint = 1;
              batteryType = "CR3032";
              supports_color = false;
            };
          };    
        };
        
        zigbee.scenes = lib.mkOption {
          type = lib.types.attrsOf (lib.types.attrsOf (lib.types.attrs));
          default = {};
          description = "Scenes for Zigbee devices";
        };
            
        zigbee.darkTime = lib.mkOption {
          type = lib.types.submodule {
            options = { # 🦆 duck say ⮞ used with Zigduck Bash
              enable = mkEnableOption "Enable dark time automations" // {
                default = true;
              };              
              start = lib.mkOption {
                type = lib.types.str;
                default = "18:00";
                description = "Start time of dark time range (in HH:MM)";
              };
              end = lib.mkOption {
                type = lib.types.str;
                default = "08:30";
                description = "End time of dark time range (in HH:MM)";
              }; # 🦆 duck say ⮞ used in Zigduck Rust
              after = lib.mkOption {
                type = lib.types.str;
                default = "16";
                description = "Start time of dark time range (HH)";
              };
              before = lib.mkOption {
                type = lib.types.str;
                default = "9";
                description = "End time of dark time range (HH format)";
              }; 
              duration = lib.mkOption {
                type = lib.types.str;
                default = "900"; # 🦆 duck say ⮞ 15 minutes
                description = "Number of seconds to wait before turning the lights off after motion is detected in dark time";
              };              
            };
          };
          default = {};
          description = "Time range when it's considered dark (HH:MM format)";
        };
    
        # 🦆 says ⮞ automations configuration
        zigbee.automations = mkOption {
          type = types.submodule {
            options = {        
           
              # 🦆 says ⮞ MQTT triggered automations
              mqtt_triggered = mkOption {
                type = types.attrsOf (types.submodule {
                  options = {
                    enable = mkEnableOption "Enable this MQTT-triggered automation";
                    description = mkOption {
                      type = types.str;
                      description = "Description of what this automation does";
                    };
                    topic = mkOption {
                      type = types.str;
                      description = "MQTT topic to subscribe to";
                      example = "zigbee2mqtt/button/action";
                    };
                    message = mkOption {
                      type = types.nullOr types.str;
                      default = null;
                      description = "Specific message value to match (if any)";
                      example = "single";
                    };
                    conditions = mkOption {
                      type = types.listOf (types.submodule {
                        options = {
                          type = mkOption {
                            type = types.enum ["dark_time" "someone_home" "room_occupied"];
                            description = "Condition type";
                          };
                          room = mkOption {
                            type = types.nullOr types.str;
                            default = null;
                            description = "Room for room-specific conditions";
                          };
                          value = mkOption {
                            type = types.nullOr types.bool;
                            default = null;
                            description = "Expected condition value";
                          };
                        };
                      });
                      default = [];
                      description = "Conditions that must be met";
                    };
                    actions = mkOption {
                      type = types.listOf automationActionType;
                      default = [];
                      description = "Actions to perform when MQTT message is received";
                    };
                  };
                });
                default = {};
                description = "MQTT-triggered automations";
                example = {
                  button_single_press = {
                    enable = true;
                    description = "Toggle living room lights on button single press";
                    topic = "zigbee2mqtt/living_room_button/action";
                    message = "single";
                    actions = [
                      {
                        type = "mqtt";
                        topic = "zigbee2mqtt/living_room_lights/set";
                        message = ''{"state":"TOGGLE"}'';
                      }
                    ];
                  };
                  motion_alert = {
                    enable = true;
                    description = "Send notification on motion detected";
                    topic = "zigbee2mqtt/outdoor_motion/occupancy";
                    message = "true";
                    actions = [
                      "echo 'Motion detected outside!' | wall"
                      {
                        type = "shell";
                        command = "${pkgs.libnotify}/bin/notify-send 'Security' 'Motion detected outside'";
                      }
                    ];
                  };
                };
              };
                       
              # 🦆 says ⮞ time based automations
              time_based = mkOption {
                type = types.attrsOf (types.submodule {
                  options = {
                    enable = mkEnableOption "Enable this time-based automation";
                    description = mkOption {
                      type = types.str;
                      description = "Description of what this automation does";
                    };
                    schedule = mkOption {
                      type = types.oneOf [
                        (types.submodule {
                          options = {
                            start = mkOption {
                              type = types.nullOr types.str;
                              default = null;
                              description = "Start time (HH:MM)";
                            };
                            end = mkOption {
                              type = types.nullOr types.str;
                              default = null;
                              description = "End time (HH:MM)";
                            };
                            days = mkOption {
                              type = types.listOf (types.enum ["mon" "tue" "wed" "thu" "fri" "sat" "sun"]);
                              default = ["mon" "tue" "wed" "thu" "fri" "sat" "sun"];
                              description = "Days of week to run";
                            };
                          };
                        })
                      ];
                      description = "Schedule configuration";
                    };
                    conditions = mkOption {
                      type = types.listOf (types.submodule {
                        options = {
                          type = mkOption {
                            type = types.enum ["dark_time" "someone_home" "room_occupied"];
                            description = "Condition type";
                          };
                          room = mkOption {
                            type = types.nullOr types.str;
                            default = null;
                            description = "Room for room-specific conditions";
                          };
                          value = mkOption {
                            type = types.nullOr types.bool;
                            default = null;
                            description = "Expected condition value";
                          };
                        };
                      });
                      default = [];
                      description = "Conditions that must be met";
                    };
                    actions = mkOption {
                      type = types.listOf automationActionType;
                      default = [];
                      description = "Actions to perform";
                    };
                  };
                });
                default = {};
                description = "Time-based automations";
                example = {
                  morning_wakeup = {
                    enable = true;
                    description = "Gentle morning lights";
                    schedule = {
                      start = "06:30";
                      end = "07:00";
                      days = ["mon" "tue" "wed" "thu" "fri"];
                    };
                    conditions = [
                      { type = "someone_home"; value = true; }
                    ];
                    actions = [
                      {
                        type = "scene";
                        scene = "morning";
                      }
                      "echo 'Good morning!'"
                    ];
                  };
                  bedtime = {
                    enable = true;
                    description = "Prepare for bed";
                    schedule = "0 22 * * *";
                    actions = [
                      {
                        type = "scene";
                        scene = "night";
                      }
                    ];
                  };
                };
              };
        
              # 🦆 says ⮞ presence based automations
              presence_based = mkOption {
                type = types.attrsOf (types.submodule {
                  options = {
                    enable = mkEnableOption "Enable this presence-based automation";
                    description = mkOption {
                      type = types.str;
                      description = "Description of what this automation does";
                    };
                    motion_sensors = mkOption {
                      type = types.listOf types.str;
                      description = "List of motion sensor friendly names to monitor";
                      example = ["Hallway Motion" "Living Room Motion"];
                    };
                    no_motion_duration = mkOption {
                      type = types.int;
                      default = 300;
                      description = "Seconds without motion before triggering";
                    };
        
                    conditions = mkOption {
                      type = types.listOf (types.submodule {
                        options = {
                          type = mkOption {
                            type = types.enum ["dark_time" "room_occupied" "lights_on"];
                            description = "Condition type";
                          };
                          room = mkOption {
                            type = types.nullOr types.str;
                            default = null;
                            description = "Room for room-specific conditions";
                          };
                          value = mkOption {
                            type = types.nullOr types.bool;
                            default = null;
                            description = "Expected condition value";
                          };
                        };
                      });
                      default = [];
                      description = "Conditions that must be met";
                    };
                    actions = mkOption {
                      type = types.listOf automationActionType;
                      default = [];
                      description = "Actions to perform when no motion is detected";
                    };
                    motion_restored_actions = mkOption {
                      type = types.listOf automationActionType;
                      default = [];
                      description = "Actions to perform when motion is detected again";
                    };
                  };
                });
                default = {};
                description = "Presence/motion-based automations";
              };
  
              # 🦆 says ⮞ Welcome Home Automation
              greeting = mkOption {
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "Enable greeting automation";
                    greeting = mkOption {
                      type = types.str;
                      default = "Welcome home, good to see you again sir!";
                      description = "Greeting message to say";
                    };
                    awayDuration = mkOption {
                      type = types.str;
                      default = "7200";
                      description = "Time in seconds to be concidered away from home (default 7200)";
                    };                    
                    delay = mkOption {
                      type = types.str;
                      default = "10";
                      description = "Delay in seconds before triggering greeting";
                    };
                    sayOnHost = mkOption {
                      type = types.str;
                      default = "";
                      example = "HostWithSpeakers";
                      description = "Specify on which host the greeting should be played onDelay in seconds before triggering greeting";
                    };
                    action = mkOption {
                      type = automationActionType;
                      default = "echo 'Welcome home!'";
                      description = "Action to perform for greeting";
                    };
                  };
                };
                default = {};
                description = "Greeting automation configuration";
              };
            
              # 🦆 says ⮞ Per-room dimmer switch actions
              dimmer_actions = mkOption {
                type = types.attrsOf (types.submodule {
                  options = {
                    on_press_release = mkOption {
                      type = types.nullOr dimmerActionType;
                      default = null;
                      description = "Action for on button press and release";
                    };
                    on_hold_release = mkOption {
                      type = types.nullOr dimmerActionType;
                      default = null;
                      description = "Action for on button hold and release";
                    };
                    off_press_release = mkOption {
                      type = types.nullOr dimmerActionType;
                      default = null;
                      description = "Action for off button press and release";
                    };
                    off_hold_release = mkOption {
                      type = types.nullOr dimmerActionType;
                      default = null;
                      description = "Action for off button hold and release";
                    };
                    up_press_release = mkOption {
                      type = types.nullOr dimmerActionType;
                      default = null;
                      description = "Action for up button press and release";
                    };
                    up_hold_release = mkOption {
                      type = types.nullOr dimmerActionType;
                      default = null;
                      description = "Action for up button hold and release";
                    };
                    down_press_release = mkOption {
                      type = types.nullOr dimmerActionType;
                      default = null;
                      description = "Action for down button press and release";
                    };
                    down_hold_release = mkOption {
                      type = types.nullOr dimmerActionType;
                      default = null;
                      description = "Action for down button hold and release";
                    };
                  };
                });
                default = {};
                description = "Per-room configuration for dimmer switch actions";
                example = {
                  kitchen = {
                    on_press_release = {
                      enable = true;
                      description = "Turn on kitchen lights and fan";
                      extra_actions = [
                        {
                          type = "mqtt";
                          topic = "zigbee2mqtt/Fläkt/set";
                          message = ''{"state":"ON"}'';
                        }
                      ];
                    };
                    off_press_release = {
                      enable = true;
                      description = "Turn off kitchen lights only";
                    };
                  };
                  _default = {
                    on_press_release = {
                      enable = true;
                      description = "Default: turn on room lights";
                    };
                    on_hold_release = {
                      enable = true;
                      description = "Default: turn on all lights at maximum brightness";
                    };
                    up_press_release = {
                      enable = true;
                      description = "Default: dim up room lights";
                    };
                    up_hold_release = {
                      enable = true;
                      description = "Default: no default actions";
                    };
                    down_press_release = {
                      enable = true;
                      description = "Default: dim down room lights";
                    };
                    down_hold_release = {
                      enable = true;
                      description = "Default: no default actions";
                    };   
                    off_press_release = {
                      enable = true;
                      description = "Default: turn off room lights";
                    };                      
                    off_hold_release = {
                      enable = true;
                      description = "Default: turn off all lights";
                    };                    
                  };
                };
              };
        
              # 🦆 says ⮞ Room-specific automations
              room_actions = mkOption {
                type = types.attrsOf (types.attrsOf (types.listOf automationActionType));
                default = {};
                description = "Room-specific automation actions";
                example = {
                  kitchen = {
                    motion_detected = [
                      "echo 'Motion in kitchen'"
                      {
                        type = "mqtt";
                        topic = "zigbee2mqtt/Fläkt/set";
                        message = ''{"state":"ON"}'';
                      }
                    ];
                    lights_turned_on = [
                      "echo 'Kitchen lights activated'"
                    ];
                  };
                };
              };

              # 🦆 says ⮞ Global automations
              global_actions = mkOption {
                type = types.attrsOf (types.listOf automationActionType);
                default = {};
                description = "Global automation actions not tied to specific rooms";
                example = {
                  all_lights_on = [
                    "echo 'All lights turned on'"
                    {
                      type = "scene";
                      scene = "max";
                    }
                  ];
                  security_armed = [
                    "echo 'Security system armed'"
                    {
                      type = "mqtt";
                      topic = "zigbee2mqtt/security/state";
                      message = ''{"armed":true}'';
                    }
                  ];
                };
              };
            };
          };
          default = {};
          description = "Modular automation configurations";
        };
      };
  

    # 🔧 🦆 says ⮞  User Configuration
    config = lib.mkMerge [
      {
        assertions = sceneValidations ++ deviceValidations ++ 
                     duplicateFriendlyNameValidation ++ motionSensorValidations ++
                     mqttValidations ++ mqttTriggeredValidations ++
                     [syncBoxTvValidation];
      }
      {
        environment.etc."dark-time.conf".text = ''
          DARK_TIME_ENABLED="${if config.house.zigbee.darkTime.enable then "1" else "0"}"
          DARK_TIME_START="${config.house.zigbee.darkTime.start}"
          DARK_TIME_END="${config.house.zigbee.darkTime.end}"
        '';    
      }
        
      (lib.mkIf (config.house.media.root != null) (let
        defaults = defaultPaths config.house.media.root;
      in {
        house.media = {
          movies = lib.mkIf (!(lib.hasAttr "movies" config.house.media)) (lib.mkDefault defaults.movies);
          tv = lib.mkIf (!(lib.hasAttr "tv" config.house.media)) (lib.mkDefault defaults.tv);
          music = lib.mkIf (!(lib.hasAttr "music" config.house.media)) (lib.mkDefault defaults.music);
          musicVideos = lib.mkIf (!(lib.hasAttr "musicVideos" config.house.media)) (lib.mkDefault defaults.musicVideos);
          otherVideos = lib.mkIf (!(lib.hasAttr "otherVideos" config.house.media)) (lib.mkDefault defaults.otherVideos);
          podcasts = lib.mkIf (!(lib.hasAttr "podcasts" config.house.media)) (lib.mkDefault defaults.podcasts);
        };
      }))
        
      {
        environment.systemPackages = [
          pkgs.clang
          # 🦆 says ⮞ Dependencies 
          pkgs.mosquitto
          pkgs.zigbee2mqtt # 🦆 says ⮞ wat? dat's all?
          
          # 🦆 says ⮞ scene fireworks  
          (pkgs.writeScriptBin "scene-roll" ''
            ${cmdHelpers}
            ${lib.concatStringsSep "\n" (lib.flatten (lib.mapAttrsToList (_: cmds: lib.mapAttrsToList (_: cmd: cmd) cmds) sceneCommands))}
          '')
          
          # 🦆 says ⮞ activate a scene yo
          (pkgs.writeScriptBin "scene" ''
            ${cmdHelpers}
            MQTT_BROKER="${config.house.zigbee.mosquitto.host}"
            MQTT_USER="${config.house.zigbee.mosquitto.username}"
            MQTT_PASSWORD=$(cat "${config.house.zigbee.mosquitto.passwordFile}") # ⮜ 🦆 says password file
            SCENE="$1"      
            # 🦆 says ⮞ convert to lowercase
            SCENE_LOWER=$(echo "$SCENE" | tr '[:upper:]' '[:lower:]')
      
            # 🦆 says ⮞ no scene == random scene
            if [ -z "$SCENE" ]; then
              SCENE=$(shuf -n 1 -e ${lib.concatStringsSep " " (lib.map (name: "\"${name}\"") (lib.attrNames sceneCommands))})
              SCENE_LOWER=$(echo "$SCENE" | tr '[:upper:]' '[:lower:]')
            fi
      
            # 🦆 says ⮞ create lowercase scene names
            case "$SCENE_LOWER" in
            ${
              lib.concatStringsSep "\n" (
                lib.mapAttrsToList (sceneName: cmds:
                  let
                    commandLines = lib.concatStringsSep "\n    " (
                      lib.mapAttrsToList (_: cmd: cmd) cmds
                    );
                    lowercaseName = lib.toLower sceneName;
                  in
                    "\"${lowercaseName}\")\n    ${commandLines}\n    ;;"
                ) sceneCommands
              )
            }
            *)
              say_duck "fuck ❌"
              exit 1
              ;;
            esac
          '')  
          
          # 🦆 says ⮞ helper function 4 controlling zingle device
          (pkgs.writeScriptBin "zig" ''
            ${cmdHelpers}
            set -euo pipefail
            # 🦆 says ⮞ create case insensitive map of device friendly_name
            declare -A device_map=(
              ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "['${lib.toLower k}']='${v}'") normalizedDeviceMap)}
            )
            available_devices=(
              ${toString deviceList}
            )    
            DEVICE="$1" # 🦆 says ⮞ device to control      
            STATE="''${2:-}" # 🦆 says ⮞ state change        
            BRIGHTNESS="''${3:-100}"
            COLOR="''${4:-}"
            TEMP="''${5:-}"
            ZIGBEE_DEVICES='${deviceMeta}'
            MQTT_BROKER="${config.house.zigbee.mosquitto.host}"

            MQTT_USER="${config.house.zigbee.mosquitto.username}"
            MQTT_PASSWORD=$(cat "${config.house.zigbee.mosquitto.passwordFile}") # ⮜ 🦆 says password file
            # 🦆 says ⮞ Zigbee coordinator backup
            if [[ "$DEVICE" == "backup" ]]; then
              mqtt_pub -t "zigbee2mqtt/backup/request" -m '{"action":"backup"}'
              say_duck "Zigbee coordinator backup requested! - processing on server..."
              exit 0
            fi         
            # 🦆 says ⮞ validate device
            input_lower=$(echo "$DEVICE" | tr '[:upper:]' '[:lower:]')
            exact_name=''${device_map["$input_lower"]}
            if [[ -z "$exact_name" ]]; then
              say_duck "fuck ❌ device not found: $DEVICE" >&2
              say_duck "Available devices: ${toString (builtins.attrNames zigbeeDevices)}" >&2
              exit 1
            fi
            # 🦆 says ⮞ if COLOR da lamp prob want hex yo
            if [[ -n "$COLOR" ]]; then
              COLOR=$(color2hex "$COLOR") || {
                say_duck "fuck ❌ Invalid color: $COLOR" >&2
                exit 1
              }
            fi
            # 🦆 says ⮞ turn off the device
            if [[ "$STATE" == "off" ]]; then
              mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m '{"state":"OFF"}'
              say_duck " turned off $DEVICE"
              exit 0
            fi    
            # 🦆 says ⮞ turn down the device brightness
            if [[ "$STATE" == "down" ]]; then
              say_duck "🔻 Decreasing $light_id in $clean_room"
              mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m '{"brightness_step":-50,"transition":3.5}'
              exit 0
            fi      
            # 🦆 says ⮞ turn up the device brightness
            if [[ "$STATE" == "up" ]]; then
              say_duck "🔺 Increasing brightness on $light_id in $clean_room"
              mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m '{"brightness_step":50,"transition":3.5}'
              exit 0
            fi      
                        
            # 🦆 says ⮞ construct payload
            PAYLOAD="{\"state\":\"ON\""
            [[ -n "$BRIGHTNESS" ]] && PAYLOAD+=", \"brightness\":$BRIGHTNESS"
            [[ -n "$COLOR" ]] && PAYLOAD+=", \"color\":{\"hex\":\"$COLOR\"}"
            PAYLOAD+="}"
            # 🦆 says ⮞ publish payload
            mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m "$PAYLOAD"
            say_duck "$PAYLOAD" 
     
     
     
            # 🦆TODO⮞ BRIDGED PAYLOAD 
            PAYLOAD="{\"state\":\"true\""
            [[ -n "$BRIGHTNESS" ]] && PAYLOAD+=", \"bri\":$BRIGHTNESS"
            [[ -n "$COLOR" ]] && PAYLOAD+=", \"color\":{\"hex\":\"$COLOR\"}"
            PAYLOAD+="}"
            # 🦆 says ⮞ publish payload
            mqtt_pub -t "zigbee2mqtt/$exact_name/set" -m "$PAYLOAD"
            say_duck "$PAYLOAD" 
            
               
     
     
     
            
            
          '')
          
          # 🦆 says ⮞ Philips Hue Sync Box control
          ( pkgs.writeScriptBin "hue" ''
            ${cmdHelpers}
            # set -euo pipefail
          
            # 🦆 says ⮞ configuration loaded at build time
            if [ "${if config.house.zigbee.hueSyncBox != null && config.house.zigbee.hueSyncBox.enable then "1" else "0"}" = "1" ]; then
              HUE_BRIDGE_IP="${config.house.zigbee.hueSyncBox.bridge.ip}"
              HUE_BRIDGE_API_KEY="$(cat "${config.house.zigbee.hueSyncBox.bridge.passwordFile}" 2>/dev/null || echo "")"
              HUE_SYNC_BOX_IP="${config.house.zigbee.hueSyncBox.syncBox.ip}"
              HUE_SYNC_BOX_API_KEY="$(cat "${config.house.zigbee.hueSyncBox.syncBox.passwordFile}" 2>/dev/null || echo "")"
              HUE_INSECURE="${toString config.house.zigbee.hueSyncBox.insecure}"
              HUE_SKIP_CERT_CHECK="${toString config.house.zigbee.hueSyncBox.skipCertCheck}"
              
              # 🦆 says ⮞ build-time device mapping (keyed by friendly_name)
              HUE_DEVICE_MAP='${builtins.toJSON (
                let
                  zigbeeConfig = config.house.zigbee;
                  # 🦆 says ⮞ get all devices with hue_id
                  hueDevices = lib.attrsets.filterAttrs (name: device: device.hue_id != null) zigbeeConfig.devices;
                  # 🦆 says ⮞ create mapping from friendly_name to hue_id
                  hueDeviceMapping = builtins.listToAttrs (
                    builtins.filter (x: x != null) (
                      builtins.map (device:
                        let
                          deviceInfo = builtins.getAttr device hueDevices;
                        in
                          if deviceInfo.hue_id != null then
                            {
                              name = deviceInfo.friendly_name;
                              value = {
                                hue_id = deviceInfo.hue_id;
                                zigbee_key = device;
                                room = deviceInfo.room;
                                type = deviceInfo.type;
                              };
                            }
                          else null
                      ) (builtins.attrNames hueDevices)
                    )
                  );
                in
                  hueDeviceMapping
              )}'
              
              
              # 🦆 says ⮞ Nix scenes
              HUE_NIX_SCENES='${builtins.toJSON config.house.zigbee.scenes}'
            else
              HUE_BRIDGE_IP=""
              HUE_BRIDGE_API_KEY=""
              HUE_SYNC_BOX_IP=""
              HUE_SYNC_BOX_API_KEY=""
              HUE_INSECURE="false"
              HUE_SKIP_CERT_CHECK="false"
              HUE_DEVICE_MAP='{}'
              HUE_NIX_SCENES='{}'
            fi
          
            # 🦆 says ⮞ fetch hue states and update global state.json
            update_state_file() {
              STATE_FILE="/var/lib/zigduck/state.json"
              HUE_JSON="$(hue bridge lights)"
              NOW_ISO="$(date --iso-8601=seconds)"
              NOW_EPOCH="$(date +%s)"
              
              jq \
                --argjson hue "$HUE_JSON" \
                --arg now_iso "$NOW_ISO" \
                --arg now_epoch "$NOW_EPOCH" '
                reduce ($hue | keys[]) as $id (
                  .;
                  (
                    $hue[$id] as $l
                    | $l.name as $name
                    | .[$name] = (
                        (.[$name] // {})
                        + {
                            state: (if $l.state.on then "ON" else "OFF" end),
                            brightness: ($l.state.bri | tostring),
                            color: (
                              if ($l.state.xy | length) == 2
                              then "{\"x\":" + ($l.state.xy[0]|tostring)
                                   + ",\"y\":" + ($l.state.xy[1]|tostring) + "}"
                              else .[$name].color
                              end
                            ),
                            last_seen: $now_iso,
                            last_updated: $now_epoch
                          }
                      )
                  )
                )
              ' "$STATE_FILE" > "''${STATE_FILE}.tmp"      
              mv "''${STATE_FILE}.tmp" "$STATE_FILE" 
            }

            # 🦆 says ⮞ helpers
            load_device_map() {
              echo "$HUE_DEVICE_MAP" | ${pkgs.jq}/bin/jq '.'
            }
            
          
            load_nix_scenes() {
              echo "$HUE_NIX_SCENES" | ${pkgs.jq}/bin/jq '.'
            }
          
            get_hue_id() {
              local friendly_name="$1"
              local device_map
              device_map=$(load_device_map)
              echo "$device_map" | ${pkgs.jq}/bin/jq -r --arg name "$friendly_name" '
                if .[$name] then .[$name].hue_id else null end
              '
            }
          
            get_device_info() {
              local friendly_name="$1"
              local device_map
              device_map=$(load_device_map)
              echo "$device_map" | ${pkgs.jq}/bin/jq -r --arg name "$friendly_name" '
                if .[$name] then .[$name] else null end
              '
            }
          
            list_hue_devices() {
              local device_map
              device_map=$(load_device_map)
              echo "$device_map" | ${pkgs.jq}/bin/jq -r '
                to_entries[] | 
                "\(.key) (hue_id: \(.value.hue_id), room: \(.value.room), type: \(.value.type))"
              '
            }
          
            list_nix_scenes() {
              local nix_scenes
              nix_scenes=$(load_nix_scenes)
              echo "$nix_scenes" | ${pkgs.jq}/bin/jq -r '
                to_entries[] | 
                .key
              '
            }
          
            get_nix_scene_info() {
              local scene_name="$1"
              local nix_scenes
              nix_scenes=$(load_nix_scenes)
              echo "$nix_scenes" | ${pkgs.jq}/bin/jq -r --arg scene "$scene_name" '
                if .[$scene] then .[$scene] else null end
              '
            }
          
            hue_api() {
              local target="$1" method="$2" endpoint="$3" data="$4"
              local ip key base curl_opts=""  
              case "$target" in
                bridge)
                  ip="$HUE_BRIDGE_IP"
                  key="$HUE_BRIDGE_API_KEY"
                  base="http://$ip/api/$key"
                  [ "$HUE_INSECURE" = "true" ] && curl_opts="-k"
                  ;;
                sync)
                  ip="$HUE_SYNC_BOX_IP"
                  key="$HUE_SYNC_BOX_API_KEY"
                  base="https://$ip/api/v1/$key"
                  [ "$HUE_SKIP_CERT_CHECK" = "true" ] && curl_opts="-k"
                  ;;
                *)
                  say_duck "fuck ❌ Invalid target: $target"
                  say_duck "Use: \"bridge\" or \"sync\""
                  exit 1
                  ;;
              esac      
              [[ -z "$ip" || -z "$key" ]] && {
                say_duck "fuck ❌ $target not configured or API key missing"
                exit 1
              }
              if [[ -n "$data" ]]; then
                curl $curl_opts -X "$method" "$base$endpoint" \
                  -H "Content-Type: application/json" \
                  -d "$data" 2>/dev/null || { say_duck "fuck ❌ $target API call failed"; exit 1; }
              else
                curl $curl_opts -X "$method" "$base$endpoint" 2>/dev/null || { say_duck "$target API call failed"; exit 1; }
              fi
            }
          
            # 🦆 says ⮞ ACTIVATE NIX SCENE ON HUE DEVICES
            apply_nix_scene() {
              local scene_name="$1"
              local nix_scenes
              nix_scenes=$(load_nix_scenes)
              local scene_def
              scene_def=$(echo "$nix_scenes" | ${pkgs.jq}/bin/jq -r --arg scene "$scene_name" '.[$scene]')
              
              if [ -z "$scene_def" ] || [ "$scene_def" = "null" ]; then
                say_duck "fuck ❌ No Nix scene found: $scene_name"
                say_duck "Available Nix scenes:"
                list_nix_scenes | sed 's/^/  /'
                exit 1
              fi
              
              say_duck "Applying Nix scene: $scene_name"
              local applied_count=0
              local skipped_count=0
              
              local device_names
              device_names=$(echo "$scene_def" | ${pkgs.jq}/bin/jq -r 'keys[]')
              
              while IFS= read -r friendly_name; do
                local hue_id
                hue_id=$(get_hue_id "$friendly_name")
                
                if [ -z "$hue_id" ] || [ "$hue_id" = "null" ]; then
                  say_duck "⚠️ Skipping $friendly_name: no hue_id"
                  skipped_count=$((skipped_count + 1))
                  continue
                fi
                
                local device_state
                device_state=$(echo "$scene_def" | ${pkgs.jq}/bin/jq -c --arg name "$friendly_name" '.[$name]')
                
                # 🦆says⮞ STATE BUILD
                local state
                state=$(echo "$device_state" | ${pkgs.jq}/bin/jq -r '.state // "ON"')
                
                local update_json="{\"on\":"
                if [ "$state" = "ON" ]; then
                  update_json="''${update_json}true"
  
                  # 🦆says⮞ brightness
                  if [ "$brightness" != "null" ] && [ "$brightness" != "" ]; then
                    update_json="''${update_json}, \"bri\":$brightness"
                  fi
  
                  # 🦆says⮞  color (supports all Hue formats)
                  local xy_json hue_val sat_val ct_val
                  xy_json=$(echo "$device_state" | ${pkgs.jq}/bin/jq -r '.color.xy')
                  hue_val=$(echo "$device_state" | ${pkgs.jq}/bin/jq -r '.color.hue')
                  sat_val=$(echo "$device_state" | ${pkgs.jq}/bin/jq -r '.color.saturation')
                  ct_val=$(echo "$device_state" | ${pkgs.jq}/bin/jq -r '.color.ct // .color.temp')
  
                  if [ "$xy_json" != "null" ] && [ "$xy_json" != "" ]; then
                    # 🦆says⮞  xy color
                    update_json="''${update_json}, \"xy\":$xy_json"
                  elif [ "$hue_val" != "null" ] && [ "$sat_val" != "null" ] && [ "$hue_val" != "" ] && [ "$sat_val" != "" ]; then
                    # 🦆says⮞  hue/sat
                    update_json="''${update_json}, \"hue\":$hue_val, \"sat\":$sat_val"
                  elif [ "$ct_val" != "null" ] && [ "$ct_val" != "" ]; then
                    # 🦆says⮞ color temp
                    update_json="''${update_json}, \"ct\":$ct_val"
                  else
                    # 🦆says⮞ fallback2hex
                    hex_value=$(echo "$device_state" | ${pkgs.jq}/bin/jq -r '.color.hex // .color')
                    if [ "$hex_value" != "null" ] && [ "$hex_value" != "" ]; then
                      local xy_coords
                      xy_coords=$(hex_to_xy "$hex_value") || {
                        say_duck "⚠️ Skipping color for $friendly_name: invalid hex '$hex_value'"
                      }
                      if [ -n "$xy_coords" ]; then
                        local x y
                        x=$(echo "$xy_coords" | cut -d' ' -f1)
                        y=$(echo "$xy_coords" | cut -d' ' -f2)
                        update_json="''${update_json}, \"xy\":[$x,$y]"
                      fi
                    fi
                  fi
  
                  # 🦆says⮞ effect
                  local effect_val
                  effect_val=$(echo "$device_state" | ${pkgs.jq}/bin/jq -r '.effect')
                  if [ "$effect_val" != "null" ] && [ "$effect_val" != "" ] && [ "$effect_val" != "none" ]; then
                    update_json="''${update_json}, \"effect\":\"$effect_val\""
                  fi
  
                  # 🦆says⮞ alert
                  local alert_val
                  alert_val=$(echo "$device_state" | ${pkgs.jq}/bin/jq -r '.alert')
                  if [ "$alert_val" != "null" ] && [ "$alert_val" != "" ] && [ "$alert_val" != "none" ]; then
                    update_json="''${update_json}, \"alert\":\"$alert_val\""
                  fi
                else
                  update_json="''${update_json}false"
                fi
                
                update_json="''${update_json}}"
                
                hue_api bridge PUT "/lights/$hue_id/state" "$update_json" > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                  say_duck "$friendly_name (hue_id: $hue_id): $state"
                  applied_count=$((applied_count + 1))
                else
                  say_duck "fuck  ❌ Failed to update $friendly_name"
                fi
                
                # 🦆says⮞tiny delay - safety first!
                sleep 0.1
              done <<< "$device_names"
              
              say_duck "Scene '$scene_name' applied! ($applied_count hue devices, $skipped_count non-hue devices skipped)"
              update_state_file
            }
          
            # 🦆 says ⮞ routing
            case "$1" in
              # 🦆 says ⮞ bridge
              bridge)
                case "$2" in
                  devices|list)
                    echo "Hue devices configured in zigbee:"
                    list_hue_devices
                    ;;
                  scenes)
                    echo "Bridge scenes from Hue:"
                    hue_api bridge GET "/scenes" "" | ${pkgs.jq}/bin/jq '.'
                    ;;
                  nix-scenes)
                    echo "Available Nix scenes:"
                    list_nix_scenes
                    ;;
                  nix-scene-info)
                    scene_name="$3"
                    echo "Nix scene info for: $scene_name"
                    get_nix_scene_info "$scene_name" | ${pkgs.jq}/bin/jq '.'
                    ;;
                  groups)
                    hue_api bridge GET "/groups" "" | ${pkgs.jq}/bin/jq '.'
                    ;;
                  sync-state)
                    update_state_file
                    ;;
                  lights)
                    hue_api bridge GET "/lights" "" | ${pkgs.jq}/bin/jq '.'
                    ;;
                  light)
                    friendly_name="$3"
                    action="$4"
                    value="''${5:-}"
                    
                    # 🦆 says ⮞ get hue_id from friendly_name
                    hue_id=$(get_hue_id "$friendly_name")
                    if [ -z "$hue_id" ] || [ "$hue_id" = "null" ]; then
                      say_duck "fuck ❌ No hue_id found for device: $friendly_name"
                      say_duck "Available devices:"
                      list_hue_devices | sed 's/^/  /'
                      exit 1
                    fi
                    
                    case "$action" in
                      on)
                        hue_api bridge PUT "/lights/$hue_id/state" '{"on":true}'
                        say_duck "Turned on $friendly_name (hue_id: $hue_id)"
                        ;;
                      off)
                        hue_api bridge PUT "/lights/$hue_id/state" '{"on":false}'
                        say_duck "Turned off $friendly_name (hue_id: $hue_id)"
                        ;;
                      toggle)
                        current_state=$(hue_api bridge GET "/lights/$hue_id" "")
                        is_on=$(echo "$current_state" | ${pkgs.jq}/bin/jq -r '.state.on')
                        new_state=$([ "$is_on" = "true" ] && echo "false" || echo "true")
                        hue_api bridge PUT "/lights/$hue_id/state" "{\"on\":$new_state}"
                        say_duck "Toggled $friendly_name (hue_id: $hue_id) → $([ "$new_state" = "true" ] && echo "ON" || echo "OFF")"
                        ;;
                      brightness|bri)
                        [[ "$value" =~ ^[0-9]+$ && "$value" -ge 0 && "$value" -le 254 ]] || {
                          say_duck "fuck ❌ Brightness must be 0-254"
                          exit 1
                        }
                        hue_api bridge PUT "/lights/$hue_id/state" "{\"bri\":$value}"
                        say_duck "Set $friendly_name brightness to $value"
                        ;;
                      color)
                        xy_json=$(color2xy "$value") || {
                          say_duck "fuck ❌ Invalid color: $value"
                          exit 1
                        }
                        hue_api bridge PUT "/lights/$hue_id/state" "{\"xy\":$xy_json}"
                        say_duck "Set $friendly_name color to $value (xy: $xy_json)"
                        ;;
                      state)
                        # 🦆 says ⮞ advanced! set multiple properties
                        if [[ -n "$value" ]]; then
                          if echo "$value" | ${pkgs.jq}/bin/jq . >/dev/null 2>&1; then
                            hue_api bridge PUT "/lights/$hue_id/state" "$value"
                            say_duck "Updated $friendly_name state"
                          else
                            say_duck "fuck ❌ Invalid JSON in state payload"
                            exit 1
                          fi
                        else
                          say_duck "fuck ❌ State requires JSON payload"
                          say_duck "Example: hue bridge light \"TV Play Strip\" state '{\"on\":true, \"bri\":200, \"xy\":[0.1709,0.3693]}'"
                          exit 1
                        fi
                        ;;
                      info|status)
                        echo "Device info for $friendly_name:"
                        get_device_info "$friendly_name" | ${pkgs.jq}/bin/jq '.'
                        echo "Current state from bridge:"
                        hue_api bridge GET "/lights/$hue_id" "" | ${pkgs.jq}/bin/jq '.'
                        ;;
                      *)
                        say_duck "fuck ❌ Unknown light action: $action"
                        say_duck "Available actions: on, off, toggle, brightness, color, state, info"
                        exit 1
                        ;;
                    esac
                    ;;
                  scene)
                    # 🦆 says ⮞ activate Hue scenes (by id)
                    scene_id="$3"
                    hue_api bridge PUT "/groups/0/action" "{\"scene\":\"$scene_id\"}"
                    say_duck "Activated bridge scene: $scene_id"
                    ;;
                  apply-scene|nix-scene)
                    # 🦆 says ⮞ Nix configured scenes
                    scene_name="$3"
                    apply_nix_scene "$scene_name"
                    ;;
                  group)
                    group_id="$3"
                    action="$4"
                    case "$action" in
                      on)
                        hue_api bridge PUT "/groups/$group_id/action" '{"on":true}'
                        ;;
                      off)
                        hue_api bridge PUT "/groups/$group_id/action" '{"on":false}'
                        ;;
                      brightness|bri)
                        value="$5"
                        [[ "$value" =~ ^[0-9]+$ && "$value" -ge 0 && "$value" -le 254 ]] || {
                          say_duck "fuck ❌ Brightness must be 0-254"
                          exit 1
                        }
                        hue_api bridge PUT "/groups/$group_id/action" "{\"bri\":$value}"
                        ;;
                      *)
                        say_duck "fuck ❌ Unknown group action: $action"
                        exit 1
                        ;;
                    esac
                    ;;
                  help)
                    cat <<EOF
          🦆 Hue Bridge Commands:
            devices, list         List configured hue devices
            scenes                List scenes from Hue bridge
            nix-scenes            List available Nix scenes
            nix-scene-info <name> Show details of a Nix scene
            groups                List all groups from bridge
            light <name> <action> Control a light by friendly name
                Actions: on, off, toggle, brightness <0-254>, color <name/hex>, state <json>, info
            scene <id>            Activate a bridge scene (by ID only)
            apply-scene <name>    Apply a Nix-defined scene to hue devices
            group <id> <action>   Control a group
                Actions: on, off, brightness <0-254>
          
          Examples:
            hue bridge devices
            hue bridge nix-scenes
            hue bridge apply-scene backlit
            hue bridge apply-scene dark
            hue bridge light "TV Play 1" on
            hue bridge light "TV Play Strip" brightness 150
            hue bridge nix-scene-info backlit
            hue bridge light "TV Play Strip" state '{"on":true, "bri":200, "xy":[0.1709,0.3693]}'
          EOF
                    ;;
                  *)
                    say_duck "fuck ❌ Unknown bridge command: $2"
                    say_duck "Use: help, devices, scenes, nix-scenes, groups, light, scene, apply-scene, group"
                    exit 1
                    ;;
                esac
                ;;            
              
              # 🦆 says ⮞ syncBox
              sync)
                case "$2" in
                  on)
                    hue_api sync PUT "/sync" '{"syncActive":true}'
                    ;;
                  off)
                    hue_api sync PUT "/sync" '{"syncActive":false}'
                    ;;
                  toggle)
                    status=$(hue_api sync GET "" "")
                    is_active=$(echo "$status" | ${pkgs.jq}/bin/jq -r '.execution.syncActive')
                    new_state=$([ "$is_active" = "true" ] && echo "false" || echo "true")
                    hue_api sync PUT "/sync" "{\"syncActive\":$new_state}"
                    ;;
                  status)
                    hue_api sync GET "" "" | ${pkgs.jq}/bin/jq '.'
                    ;;
                  mode)
                    mode="$3"
                    case "$mode" in
                      video|music|game)
                        hue_api sync PUT "/sync" "{\"mode\":\"$mode\"}"
                        ;;
                      *)
                        say_duck "fuck ❌ Invalid mode: $mode"
                        exit 1
                        ;;
                    esac
                    ;;
                  intensity)
                    intensity="$3"
                    case "$intensity" in
                      subtle|moderate|high|intense)
                        hue_api sync PUT "/sync" "{\"intensity\":\"$intensity\"}"
                        ;;
                      *)
                        say_duck "fuck ❌ Invalid intensity: $intensity"
                        exit 1
                        ;;
                    esac
                    ;;
                  entertainment-area)
                    area_id="$3"
                    hue_api sync PUT "/sync" "{\"entertainmentConfiguration\":\"$area_id\"}"
                    ;;
                  hdmi-input)
                    input="$3"
                    [[ "$input" =~ ^[1-4]$ ]] || {
                      say_duck "fuck ❌ Invalid HDMI input: $input"
                      exit 1
                    }
                    hue_api sync PUT "/sync" "{\"hdmiSource\":\"input$input\"}"
                    ;;
                  help)
                    cat <<EOF
          🦆 Hue Sync Box Commands:
            on                    Turn sync on
            off                   Turn sync off
            toggle                Toggle sync state
            status                Get sync box status
            mode <mode>           Set sync mode (video|music|game)
            intensity <level>     Set intensity (subtle|moderate|high|intense)
            entertainment-area <id> Set entertainment area
            hdmi-input <1-4>      Set HDMI input source
          EOF
                    ;;
                  *)
                    say_duck "fuck ❌ Unknown sync command: $2"
                    say_duck "Use: help, on, off, toggle, status, mode, intensity, entertainment-area, hdmi-input"
                    exit 1
                    ;;
                esac
                ;;
              
              # 🦆 says ⮞ help
              help|--help|-h)
                cat <<EOF
          🦆 Philips Hue Control Script
          
          Usage:
            hue bridge <command> [args...]    Control Hue Bridge
            hue sync <command> [args...]      Control Hue Sync Box
            hue help                         Show this help
          
          Quick Examples:
            hue bridge nix-scenes             # List all Nix scenes
            hue bridge apply-scene backlit    # Apply Nix "backlit" scene to hue devices
            hue bridge apply-scene dark       # Apply Nix "dark" scene to hue devices
            hue bridge devices                # List all hue devices
            hue bridge light "TV Play 1" on  # Turn on a light by name
            hue sync on                       # Turn on sync box
            hue sync mode video              # Set sync mode to video
          
          Use 'hue bridge help' or 'hue sync help' for more detailed help.
          EOF
                ;;         
              *)
                say_duck "fuck ❌ Unknown command: $1"
                say_duck "Use: \"bridge\", \"sync\", or \"help\""
                exit 1
                ;;
            esac
          '')
        ];        
      }
            
      {
        services.udev.extraRules = let
          port = config.house.zigbee.coordinator;
        in
          ''
            SUBSYSTEM=="tty", ATTRS{idVendor}=="${port.vendorId}", ATTRS{idProduct}=="${port.productId}", SYMLINK+="${port.symlink}"
          '';
      }
      
      {
          users.users.zigbee2mqtt = {
            isSystemUser = true;
            group = "zigbee2mqtt";
            home = "/var/lib/zigbee";
            createHome = true;
          }; 
          users.groups.zigbee2mqtt = {};
      }    

    ];}
