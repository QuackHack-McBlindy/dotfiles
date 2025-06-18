# dotfiles/modules/house.nix
# 🦆 duck say ⮞ here we define options that help us control our house yo
{ 
    config,
    lib,
    pkgs,
    ...
} : let
  inherit (lib) types mkOption mkEnableOption mkMerge;
in { # 🦆 says ⮞ Options for da house
    options.house = {
        zigbee.devices = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
                options = {
                    friendly_name = mkOption {
                        type = types.str;
                        description = "A human-readable device name.";
                        example = "Kitchen Dimmer";
                    };
                    room = lib.mkOption { 
                        type = lib.types.str;
                        description = "The room this device belongs to.";
                        example = "kitchen";
                    };
                    type = lib.mkOption { 
                        type = lib.types.str;
                        description = "The type of device (e.g., light, dimmer, motion, etc).";
                        example = "light";
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
                };
            };    
        };
        zigbee.scenes = lib.mkOption {
            type = lib.types.attrsOf (lib.types.attrsOf (lib.types.attrs));
            default = {};
            description = "Scenes for Zigbee devices";
        };
    };
    # 🦆 says ⮞ ❓ TODO moar house options
    
    
    # 🦆 says ⮞  User Configuration
    config = {
        # 🦆 says ⮞ 💡 User defined Zigbee devices
        house.zigbee.devices = { 
            # 🦆 says ⮞ Kitchen   
            "0x0017880103ca6e95" = { # 🦆 says ⮞ 64bit IEEE adress (this is the unique device ID)  
                friendly_name = "Dimmer Switch Kök"; # 🦆 says ⮞ simple human readable friendly name
                room = "kitchen"; # 🦆 says ⮞ bind to group
                type = "dimmer"; # 🦆 says ⮞ set a custom device type
                endpoint = 1; # 🦆 says ⮞ endpoint to call the device on
            }; 
           "0x0017880102f0848a" = { # 🦆 says ⮞ inb4 long annoying list  
                friendly_name = "Spotlight kök 1"; # 🦆 says > oh crap
                room = "kitchen"; # 🦆 says ⮞ scroll
                type = "light"; # 🦆 says ⮞ scroll sad duck, scroll ='(
                endpoint = 11; # 🦆 says ⮞ i'll tell u when to stop ='(
            };
            "0x0017880102f08526" = { friendly_name = "Spotlight Kök 2"; room = "kitchen"; type = "light"; endpoint = 11; };
            "0x0017880103a0d280" = { friendly_name = "Uppe"; room = "kitchen"; type = "light"; endpoint = 11; };
            "0x0017880103e0add1" = { friendly_name = "Golvet"; room = "kitchen"; type = "light"; endpoint = 11; };
            "0xa4c13873044cb7ea" = { friendly_name = "Kök Bänk Slinga"; room = "kitchen"; type = "light"; endpoint = 11; };
            "0x70ac08fffe9fa3d1" = { friendly_name = "Motion Sensor Kök"; room = "kitchen"; type = "motion"; endpoint = 1; };
            "0xa4c1380afa9f7f3e" = { friendly_name = "Smoke Alarm Kitchen"; room = "kitchen"; type = "sensor"; endpoint = 1; };
            "0x0c4314fffe179b05" = { friendly_name = "Fläkt"; room = "kitchen"; type = "power plug"; endpoint = 1; };    
            # 🦆 says ⮞ LIVING ROOM
            "0x0017880104f78065" = { friendly_name = "Dimmer Switch Vardagsrum"; room = "livingroom"; type = "dimmer"; endpoint = 1; };
            "0x54ef4410003e58e2" = { friendly_name = "Roller Shade"; room = "livingroom"; type = "blind"; endpoint = 1; };
            "0x0017880104540411" = { friendly_name = "PC"; room = "livingroom"; type = "light"; endpoint = 11; };
            "0x0017880102de8570" = { friendly_name = "Rustning"; room = "livingroom"; type = "light"; endpoint = 11; };
            "0x540f57fffe85c9c3" = { friendly_name = "Water Sensor"; room = "livingroom"; type = "sensor"; endpoint = 1; };    
            # 🦆 says ⮞ HALLWAY
            "0x00178801021311c4" = { friendly_name = "Motion Sensor Hall"; room = "hallway"; type = "motion"; endpoint = 1; };
            "0x0017880103eafdd6" = { friendly_name = "Tak Hall";  room = "hallway"; type = "light"; endpoint = 11; };
            "0x000b57fffe0e2a04" = { friendly_name = "Vägg"; room = "hallway"; type = "light"; endpoint = 1; };
            # 🦆 says ⮞ WC
            "0x001788010361b842" = { friendly_name = "WC 1"; room = "wc"; type = "light"; endpoint = 11; };
            "0x0017880103406f41" = { friendly_name = "WC 2"; room = "wc"; type = "light"; endpoint = 11; };
            # 🦆 says ⮞ BEDROOM
            "0x0017880104f77d61" = { friendly_name = "Dimmer Switch Sovrum"; room = "bedroom"; type = "dimmer"; endpoint = 1; };
            "0x0017880106156cb0" = { friendly_name = "Taket Sovrum 1"; room = "bedroom"; type = "light"; endpoint = 11; };
            "0x0017880103c7467d" = { friendly_name = "Taket Sovrum 2"; room = "bedroom"; type = "light"; endpoint = 11; };
            "0x0017880109ac14f3" = { friendly_name = "Sänglampa"; room = "bedroom"; type = "light"; endpoint = 11; };
            "0x0017880104051a86" = { friendly_name = "Sänggavel"; room = "bedroom"; type = "light"; endpoint = 11; };
            "0xf4b3b1fffeaccb27" = { friendly_name = "Motion Sensor Sovrum"; room = "bedroom"; type = "motion"; endpoint = 1; };
            "0x0017880103f44b5f" = { friendly_name = "Dörr"; room = "bedroom"; type = "light"; endpoint = 11; }; # 🦆 says ⮞ THATS TOO FAST!!
            "0x00178801001ecdaa" = { friendly_name = "Bloom"; room = "bedroom"; type = "light"; endpoint = 11; }; # 🦆 says ⮞ SLOW DOWN DUCKIE!!
            # 🦆 says ⮞ MISCELLANEOUS
            "0x000b57fffe0f0807" = { friendly_name = "IKEA 5 Dimmer"; room = "other"; type = "remote"; endpoint = 1; };
            "0x70ac08fffe6497be" = { friendly_name = "On/Off Switch 1"; room = "other"; type = "remote"; endpoint = 1; };
            "0x70ac08fffe65211e" = { friendly_name = "On/Off Switch 2"; room = "other"; type = "remote"; endpoint = 1; };
            "0x0017880103c73f85" = { friendly_name = "Unknown 1"; room = "other"; type = "misc"; endpoint = 1; };  
            "0x0017880103f94041" = { friendly_name = "Unknown 2"; room = "other"; type = "misc"; endpoint = 1; };      
            "0x0017880103c753b8" = { friendly_name = "Unknown 3"; room = "other"; type = "misc"; endpoint = 1; };      
            "0x00178801037e754e" = { friendly_name = "Unknown 5"; room = "other"; type = "misc"; endpoint = 1; };    
        }; # 🦆 says ⮞ that's way too many devices huh
        # 🦆 says ⮞ that's actually not too bad when they on single line each

        # 🎨 Scenes  🦆 says ⮞ user defined scenes
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
            };     
        };
    };}
