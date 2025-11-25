# dotfiles/modules/house.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ here we define options that help us control our house yo 
  self,
  config,
  lib,
  pkgs,
  ...
} : let
  inherit (lib) types mkOption mkEnableOption mkMerge;  

  cmdHelpers = ''
    say_duck() { # 🦆 duck say ⮞ diis need explaination? 
      echo -e "\e[3m\e[38;2;0;150;150m🦆 duck say \e[1m\e[38;2;255;255;0m⮞\e[0m\e[3m\e[38;2;0;150;150m $1\e[0m"
    }  
    mqtt_pub() { # 🦆 says ⮞ publish Mosquitto
      ${pkgs.mosquitto}/bin/mosquitto_pub -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" "$@"
    }
    color2hex() { # 🦆 duck say ⮞ outputs random hex within color range from plain text color names
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
      if [[ -z "$color" || "$color" == "random" || -z "''${color_ranges[$color]}" ]]; then
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

  # 🦆 says ⮞ 
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
      override_actions = mkOption {  # 🦆 NEW
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
    brightness >= 0 && brightness <= 255;

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
          message = "🦆 duck say ⮞ fuck ❌ Scene '${sceneName}' device '${deviceName}' has invalid brightness ${toString settings.brightness} (must be 0-255)";
        }
        {
          assertion = settings ? color -> settings.color ? hex -> isValidHexColor settings.color.hex;
          message = "🦆 duck say ⮞ fuck ❌ Scene '${sceneName}' device '${deviceName}' has invalid color hex '${settings.color.hex}'";
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

  # 🦆 says ⮞ Add validation for MQTT configuration
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

  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = lib.findSingle (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) null null sysHosts;    
  mqttHostip = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or (
      let
        resolved = builtins.readFile (pkgs.runCommand "resolve-host" {} ''
          ${pkgs.dnsutils}/bin/host -t A ${mqttHost} > $out
        '');
      in
        lib.lists.head (lib.strings.splitString " " (lib.lists.elemAt (lib.strings.splitString "\n" resolved) 0))
    )
    else (throw "No Mosquitto host found in configuration");
  mqttAuth = "-u mqtt -P $(cat ${config.house.zigbee.mosquitto.passwordFile})";

  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = config.house.zigbee.devices;
  
  # 🦆 says ⮞ case-insensitive device matching
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ device validation list
  deviceList = builtins.attrNames normalizedDeviceMap;

  # 🦆 says ⮞ scene simplifier? or not
  sceneLight = {state, brightness ? 200, hex ? null, temp ? null}:
    let
      colorValue = if hex != null then { inherit hex; } else null;
    in
    {
      inherit state brightness;
    } // (if colorValue != null then { color = colorValue; } else {})
      // (if temp != null then { color_temp = temp; } else {});

  # 🎨 Scenes  🦆 YELLS ⮞ SCENES!!!!!!!!!!!!!!!11
  scenes = config.house.zigbee.scenes; # 🦆 says ⮞ Declare light states, quack dat's a scene yo!   

  # 🦆 says ⮞ Generate scene commands    
  makeCommand = device: settings:
    let
      json = builtins.toJSON settings;
    in
      ''
      mqtt_pub -t "zigbee2mqtt/${device}/set" -m '${json}'
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
      # 🦆 says ⮞ fallback values
      defaultValue = mkOption { type = str; default = "--"; };
      defaultDetails = mkOption { type = str; default = "Waiting for data"; };   
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
      # 🦆 says ⮞ dashboard configuraiton
      dashboard = {
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
      
      # 🦆 duck say ⮞ set our esp device info
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
        networkKeyFile = mkOption {
          type = types.path;
          description = "Path to the Zigbee network key file.";
        };
      };

      zigbee.mosquitto = mkOption {
        type = types.nullOr (types.submodule {
          options = {
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
          };
        });
        default = {};
        description = "Serial port device mapping by USB IDs";
      };


      # 🦆 duck say ⮞ lights don't help blind ducks but guests might like
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
              type = lib.types.enum [ "light" "dimmer" "sensor" "motion" "outlet" "remote" "pusher" "blind" ];
              description = "The type of device (e.g., light, dimmer, sensor, motion, outlet, remote, pusher, blind).";
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
                     mqttValidations ++ mqttTriggeredValidations;
      }
      {
        environment.etc."dark-time.conf".text = ''
          DARK_TIME_ENABLED="${if config.house.zigbee.darkTime.enable then "1" else "0"}"
          DARK_TIME_START="${config.house.zigbee.darkTime.start}"
          DARK_TIME_END="${config.house.zigbee.darkTime.end}"
        '';    
      }
        
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
            MQTT_BROKER="${mqttHostip}"
            if [ "$MQTT_BROKER" = "{config.this.host.ip}" ]; then
              MQTT_BROKER="localhost"
            fi
            MQTT_USER="${config.house.zigbee.mosquitto.username}"
            MQTT_PASSWORD=$(cat "${config.house.zigbee.mosquitto.passwordFile}") # ⮜ 🦆 says password file
            SCENE="$1"      
            # 🦆 says ⮞ no scene == random scene
            if [ -z "$SCENE" ]; then
              SCENE=$(shuf -n 1 -e ${lib.concatStringsSep " " (lib.map (name: "\"${name}\"") (lib.attrNames sceneCommands))})
            fi      
            case "$SCENE" in
            ${
              lib.concatStringsSep "\n" (
                lib.mapAttrsToList (sceneName: cmds:
                  let
                    commandLines = lib.concatStringsSep "\n    " (
                      lib.mapAttrsToList (_: cmd: cmd) cmds
                    );
                  in
                    "\"${sceneName}\")\n    ${commandLines}\n    ;;"
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
            MQTT_BROKER="${mqttHostip}"
            if [ "$MQTT_BROKER" = "{config.this.host.ip}" ]; then
              MQTT_BROKER="localhost"
            fi
            #MQTT_USER=$(nix eval "${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.scripts.zigduck.parameters" --json | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "user") | .default')
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

        
    ];}
