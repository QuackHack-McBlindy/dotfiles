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
              type = lib.types.str;
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
              type = types.nullOr (types.enum ["CR2032" "CR2450" "AAA" "AA"]);
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
            options = {
              start = lib.mkOption {
                type = lib.types.str;
                default = "18:00";
                description = "Start time of dark time range (in HH:MM)";
              };

              end = lib.mkOption {
                type = lib.types.str;
                default = "08:30";
                description = "End time of dark time range (in HH:MM)";
              };
            };
          };
          default = {};
          description = "Time range when it's considered dark (HH:MM format)";
        };
      
        dash.cards = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              enable = lib.mkEnableOption "Enable this dashboard card";
              title = lib.mkOption {
                type = lib.types.str;
                description = "Title for the card";
              };
              icon = lib.mkOption {
                type = lib.types.str;
                description = "Icon class for the card";
              };
              color = lib.mkOption {
                type = lib.types.str;
                description = "Color for the card icon";
              };
              mqttTopic = lib.mkOption {
                type = lib.types.str;
                description = "MQTT topic to subscribe to for this card's data";
              };
              valueParser = lib.mkOption {
                type = lib.types.str;
                default = "payload => payload";
                description = "JavaScript function to parse MQTT payload";
              };
              valueCount = lib.mkOption {
                type = lib.types.int;
                default = 1;
                description = "Number of value fields to display (1 or 2)";
              };
              details = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Static details text for the card";
              };
            };
          });
          default = {};
          description = "Dashboard card configurations";
        };      
      
        timeAutomations = mkOption {
            type = types.attrsOf (types.submodule {
                options = {
                    time = mkOption {
                        type = types.str;
                        example = "07:00";
                        description = ''
                            Time of day to trigger the automation. Can be a fixed time like "07:00" or a keyword like "sunrise".
                        '';
                    };
                    everyMin = mkOption {
                      type = types.nullOr types.int;
                      example = 30;
                      default = null;
                      description = ''
                        Interval in minutes to run this automation repeatedly.
                        If set, overrides 'time' and 'days'.
                      '';
                    };
                    days = mkOption {
                        type = types.listOf types.str;
                        example = [ "Mon" "Tue" "Wed" "Thu" "Fri" ];
                        description = ''
                            Days of the week to apply this automation. Use "*" for every day.
                        '';
                    };
                    action = mkOption {
                        type = types.str;
                        example = "scene morning";
                        description = "Shell command or script to run.";
                    };
                    # 🦆 says ⮞ TODO 🌞🌙 sunrise/sunset handling with sunwait
                    
                };
            });
            default = {};
            description = "Define time-based home automations.";
        };
    # 🦆 says ⮞ ❓ TODO moar house options        
    };
  
    # 🔧 🦆 says ⮞  User Configuration
    config = lib.mkMerge [
      {
        environment.etc."dark-time.conf".text = ''
          DARK_TIME_START="${config.house.zigbee.darkTime.start}"
          DARK_TIME_END="${config.house.zigbee.darkTime.end}"
        '';    
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
      { 
        systemd.timers = lib.mapAttrs' (name: cfg:
          let
            timerConfig = if cfg.everyMin != null then {
              OnBootSec = "1m";                       # Initial delay after boot
              OnUnitActiveSec = "${toString cfg.everyMin}min";  # Repeat interval
              Persistent = true;
            } else let
              daysStr = if cfg.days == [ "*" ] then "*" else lib.concatStringsSep "," cfg.days;
              onCalendar = "${daysStr} ${cfg.time}";
            in {
              OnCalendar = onCalendar;
              Persistent = true;
            };
          in
          lib.nameValuePair "house-automation-${name}" {
            enable = true;
            wantedBy = [ "timers.target" ];
            timerConfig = timerConfig;
          }
        ) config.house.timeAutomations;
        
        systemd.services = lib.mapAttrs' (name: cfg:
          lib.nameValuePair "house-automation-${name}" {
            serviceConfig = {
              Type = "oneshot";
              ExecStart = pkgs.writeShellScript "automation-${name}" ''
                set -euo pipefail
                ${cfg.action}
              '';
            };
          }
        ) config.house.timeAutomations;
      }
     
        
      
#      {  # 🦆 says ⮞ ⏰ Configures systemd timers & voilá - time based automations 
#        # 🦆 says ⮞ use `systemctl list-timers --all` to list all timers
#        systemd.timers = lib.mapAttrs' (name: cfg:
#            let
#                daysStr = if cfg.days == [ "*" ]
#                    then "*"
#                    else lib.concatStringsSep "," cfg.days;
#                onCalendar = "${daysStr} ${cfg.time}";
#            in
#            lib.nameValuePair "house-automation-${name}" {
#                enable = true;
#                wantedBy = [ "timers.target" ];
#                timerConfig = {
#                    OnCalendar = onCalendar;
#                    Persistent = true;
#                };
#            }
#        ) config.house.timeAutomations;
#      }
 
#      {  # 🦆 says ⮞ ⏰ Creates the service for da timer 
#        systemd.services = lib.mapAttrs' (name: cfg:
#            lib.nameValuePair "house-automation-${name}" {
#                serviceConfig = {
#                    Type = "oneshot";
#                    ExecStart = pkgs.writeShellScript "automation-${name}" ''
#                        set -euo pipefail
#                        ${cfg.action}
#                    '';
#                };
#            }
#        ) config.house.timeAutomations;
#      }        
#      {
        # 🦆 says ⮞ ⏰ Time triggered automations
#        house.timeAutomations = {
#            good_morning = {
#                time = "07:00";
#                days = [ "Mon" "Tue" "Wed" "Thu" "Fri" ];
#                action = ''
#                  echo "Turning on morning lights..."
#                  echo "action 2"
#                '';
#            };
#        };
#      }  
    ];}
