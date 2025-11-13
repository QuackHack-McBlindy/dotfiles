# dotfiles/modules/house.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ here we define options that help us control our house yo 
  config,
  lib,
  pkgs,
  ...
} : let
  inherit (lib) types mkOption mkEnableOption mkMerge;  

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

in { # 🦆 says ⮞ Options for da house
    options.house = {
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
              description = "Whether the device supports setting color.";
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
                        (types.str)
                        (types.submodule {
                          options = {
                            cron = mkOption {
                              type = types.str;
                              description = "Cron expression (0 7 * * *)";
                            };
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
                     duplicateFriendlyNameValidation ++ motionSensorValidations;
      }
      {
        environment.etc."dark-time.conf".text = ''
          DARK_TIME_ENABLED="${if config.house.zigbee.darkTime.enable then "1" else "0"}"
          DARK_TIME_START="${config.house.zigbee.darkTime.start}"
          DARK_TIME_END="${config.house.zigbee.darkTime.end}"
        '';    
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
