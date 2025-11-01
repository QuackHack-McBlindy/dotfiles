# dotfiles/modules/house.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ here we define options that help us control our house yo 
    config,
    lib,
    pkgs,
    ...
} : let
  inherit (lib) types mkOption mkEnableOption mkMerge;  
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
    (types.str) # Simple shell command
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

  # 🦆 says ⮞ Dimmer action configuration
  dimmerActionType = types.submodule {
    options = {
      enable = mkEnableOption "Enable this dimmer action";
      description = mkOption {
        type = types.str;
        description = "Human-readable description of this action";
      };
      extra_actions = mkOption {
        type = types.listOf automationActionType;
        default = [];
        description = "Additional actions to perform when this dimmer action triggers";
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
              description = "The type of device (e.g., light, dimmer, motion, etc).";
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
                default = "18";
                description = "Start time of dark time range (HH)";
              };
              before = lib.mkOption {
                type = lib.types.str;
                default = "6";
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
    
        # 🦆 says ⮞ Modular automations configuration
        zigbee.automations = mkOption {
          type = types.submodule {
            options = {
              # 🦆 says ⮞ Dimmer switch actions
              dimmer_actions = mkOption {
                type = types.attrsOf dimmerActionType;
                default = {};
                description = "Configuration for dimmer switch actions";
                example = {
                  on_press_release = {
                    enable = true;
                    description = "Turn on room lights";
                    extra_actions = [
                      "echo 'Room lights turned on'"
                      {
                        type = "mqtt";
                        topic = "zigbee2mqtt/Fläkt/set";
                        message = ''{"state":"ON"}'';
                      }
                    ];
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
        environment.etc."dark-time.conf".text = ''
          DARK_TIME_ENABLED="${if config.house.zigbee.darkTime.enable then "1" else "0"}"
          DARK_TIME_START="${config.house.zigbee.darkTime.start}"
          DARK_TIME_END="${config.house.zigbee.darkTime.end}"
        '';    
      }

      {
        # 🦆 says ⮞ Default dimmer actions (matching current behavior)
        house.zigbee.automations.dimmer_actions = {
          on_press_release = {
            enable = true;
            description = "Turns on all light devices in the dimmer device's room";
            extra_actions = [
              {
                type = "mqtt";
                topic = "zigbee2mqtt/Fläkt/set";
                message = ''{"state":"ON"}'';
              }
              {
                type = "shell";
                command = ''
                  echo "hello room lights"
                '';
              }
              
            ];
          };
          on_hold_release = {
            enable = true;
            description = "Turns on every light device configured.";
            extra_actions = [];
          };
          up_press_release = {
            enable = true;
            description = "Increase the brightness in the room";
            extra_actions = [];
          };
          down_press_release = {
            enable = true;
            description = "Decrease brightness in room";
            extra_actions = [];
          };
          off_press_release = {
            enable = true;
            description = "Turn off room lights";
            extra_actions = [
              {
                type = "mqtt";
                topic = "zigbee2mqtt/Fläkt/set";
                message = ''{"state":"OFF"}'';
              }
            ];
          };
          off_hold_release = {
            enable = true;
            description = "Turn off all lights";
            extra_actions = [];
          };
        };
  
        # 🦆 says ⮞ Default room-specific actions
        #house.zigbee.automations.room_actions = {

      }

      {  # 🎨 Scenes  🦆 says ⮞ user defined scenes
        house.zigbee.scenes = {
            # 🦆 says ⮞ Scene name
            "Duck Scene" = {
                # 🦆 says ⮞ Device friendly_name
                "PC" = { # 🦆 says ⮞ Device state
                    state = "ON";
                    brightness = 200;
                    color = { hex = "#00FF00"; };
                };
            };
            # 🦆 says ⮞ Scene 2    
            "Chill Scene" = {
                "PC" = { state = "ON"; brightness = 200; color = { hex = "#8A2BE2"; }; };               # 🦆 says ⮞ Blue Violet
                "Golvet" = { state = "ON"; brightness = 200; color = { hex = "#40E0D0"; }; };           # 🦆 says ⮞ Turquoise
                "Uppe" = { state = "ON"; brightness = 200; color = { hex = "#FF69B4"; }; };             # 🦆 says ⮞ Hot Pink
                "Spotlight Kök 1" = { state = "OFF"; brightness = 200; color = { hex = "#FFD700"; }; }; # 🦆 says ⮞ Gold
                "Spotlight Kök 2" = { state = "OFF"; brightness = 200; color = { hex = "#FF8C00"; }; }; # 🦆 says ⮞ Dark Orange
                "Taket Sovrum 1" = { state = "ON"; brightness = 200; color = { hex = "#00CED1"; }; };   # 🦆 says ⮞ Dark Turquoise
                "Taket Sovrum 2" = { state = "ON"; brightness = 200; color = { hex = "#9932CC"; }; };   # 🦆 says ⮞ Dark Orchid
                "Bloom" = { state = "ON"; brightness = 200; color = { hex = "#FFB6C1"; }; };            # 🦆 says ⮞ Light Pink
                "Sänggavel" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine
                "Takkrona 1" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
                "Takkrona 2" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
                "Takkrona 3" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
                "Takkrona 4" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
            }; 
            "Green D" = {
                "PC" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
                "Golvet" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
                "Uppe" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
                "Spotlight Kök 1" = { state = "OFF"; brightness = 200; color = { hex = "#00FF00"; }; };
                "Spotlight Kök 2" = { state = "OFF"; brightness = 200; color = { hex = "#00FF00"; }; };
                "Taket Sovrum 1" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
                "Taket Sovrum 2" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
                "Bloom" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
                "Sänggavel" = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
                "Takkrona 1" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
                "Takkrona 2" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
                "Takkrona 3" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
                "Takkrona 4" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };        # 🦆 says ⮞ Aquamarine   
            };  
            "dark" = { # 🦆 says ⮞ eat darkness... lol YO! You're as blind as me now! HA HA!  
                "Bloom" = { state = "OFF"; transition = 10; };
                "Dörr" = { state = "OFF"; transition = 10; };
                "Golvet" = { state = "OFF"; transition = 10; };
                "Kök Bänk Slinga" = { state = "OFF"; transition = 10; };
                "PC" = { state = "OFF"; transition = 10; };
                "Rustning" = { state = "OFF"; transition = 10; };
                "Spotlight Kök 2" = { state = "OFF"; transition = 10; };
                "Spotlight kök 1" = { state = "OFF"; transition = 10; };
                "Sänggavel" = { state = "OFF"; transition = 10; };
                "Sänglampa" = { state = "OFF"; transition = 10; };
                "Tak Hall" = { state = "OFF"; transition = 10; };
                "Taket Sovrum 1" = { state = "OFF"; transition = 10; };
                "Taket Sovrum 2" = { state = "OFF"; transition = 10; };
                "Uppe" = { state = "OFF"; transition = 10; };
                "Vägg" = { state = "OFF"; transition = 10; };
                "WC 1" = { state = "OFF"; transition = 10; };
                "WC 2" = { state = "OFF"; transition = 10; };
                "Takkrona 1" = { state = "OFF"; transition = 10; };   
                "Takkrona 2" = { state = "OFF"; transition = 10; };
                "Takkrona 3" = { state = "OFF"; transition = 10; };   
                "Takkrona 4" = { state = "OFF"; transition = 10; };   
            };  
            "dark-fast" = { # 🦆 says ⮞ eat darkness... NAO!  
                "Bloom" = { state = "OFF"; };
                "Dörr" = { state = "OFF"; };
                "Golvet" = { state = "OFF"; };
                "Kök Bänk Slinga" = { state = "OFF"; };
                "PC" = { state = "OFF"; };
                "Rustning" = { state = "OFF"; };
                "Spotlight Kök 2" = { state = "OFF"; };
                "Spotlight kök 1" = { state = "OFF"; };
                "Sänggavel" = { state = "OFF"; };
                "Sänglampa" = { state = "OFF"; };
                "Tak Hall" = { state = "OFF"; };
                "Taket Sovrum 1" = { state = "OFF"; };
                "Taket Sovrum 2" = { state = "OFF"; };
                "Uppe" = { state = "OFF"; };
                "Vägg" = { state = "OFF"; };
                "WC 1" = { state = "OFF"; };
                "WC 2" = { state = "OFF"; };
                "Takkrona 1" = { state = "OFF"; };   
                "Takkrona 2" = { state = "OFF"; };
                "Takkrona 3" = { state = "OFF"; };   
                "Takkrona 4" = { state = "OFF"; };   
            };  
            "max" = { # 🦆 says ⮞ let there be light
                "Bloom" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Dörr" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Golvet" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Kök Bänk Slinga" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "PC" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Rustning" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Spotlight Kök 2" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Spotlight kök 1" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Sänggavel" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Sänglampa" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Tak Hall" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Taket Sovrum 1" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Taket Sovrum 2" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Uppe" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Vägg" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "WC 1" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "WC 2" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Takkrona 1" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };   
                "Takkrona 2" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
                "Takkrona 3" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };   
                "Takkrona 4" = { state = "ON"; brightness = 255; color = { hex = "#FFFFFF"; }; };
            };     
        };
      }  
        
    ];}
