{ 
  config,
  lib,
  pkgs,
  ... 
} : {
    config = lib.mkIf (lib.elem "zigbee2mqtt" config.this.host.modules.services) {
      services.zigbee2mqtt = lib.mkIf (!config.this.installer) {
        enable = true;
        dataDir = "/var/lib/zigbee";
        settings = {
          homeassistant = true;
          mqtt = {
            server = "mqtt://localhost:1883";
            user = "mqtt";
            password =  config.sops.secrets.mosquitto.path;
            base_topic = "zigbee2mqtt";
          };
          serial = {
            port = "/dev/serial/by-id/usb-Silicon_Labs_Sonoff_Zigbee_3.0_USB_Dongle_Plus_0001-if00-port0";
          };
          frontend = {
            enabled = true;
            port = 8099;
          };
          advanced = {
            homeassistant_legacy_entity_attributes = false;
            legacy_api = false;
            legacy_availability_payload = false;
            log_syslog = {
              app_name = "Zigbee2MQTT";
              eol = "/n";
              host = "localhost";
              localhost = "localhost";
              path = "/dev/log";
              pid = "process.pid";
              port = 123;
              protocol = "tcp4";
              type = "5424";
            };
            transmit_power = 9;
            channel = 15;
            last_seen = "ISO_8601_local";
            network_key = [
              86 208 29 190 33 225 60 93
              199 70 36 29 123 129 73 40
            ];
            pan_id = 60410;
          };
          device_options = {
            legacy = false;
          };
          availability = true;
          permit_join = false;
          devices = {
            "0x0017880104540411" = {
              friendly_name = "PC";
            };
            "0x001788010361b842" = {
              friendly_name = "WC 1";
            };
            "0x0017880102de8570" = {
              friendly_name = "Rustning";
            };
            "0x0017880103406f41" = {
              friendly_name = "WC 2";
            };
            "0x0017880103eafdd6" = {
              friendly_name = "Tak Hall";
            };
            "0x0c4314fffe179b05" = {
              friendly_name = "Fläkt";
            };
            "0x000b57fffe0e2a04" = {
              friendly_name = "Vägg";
            };
            "0x000b57fffe0f0807" = {
              friendly_name = "IKEA 5 Dimmer";
            };
            "0x00178801021311c4" = {
              friendly_name = "Motion Sensor Hall";
            };
            "0x70ac08fffe9fa3d1" = {
              friendly_name = "Motion Sensor Kök";
            };
            "0xf4b3b1fffeaccb27" = {
              friendly_name = "Motion Sensor Sovrum";
            };
            "0x00178801001ecdaa" = {
              friendly_name = "Bloom";
            };
            "0x70ac08fffe6497be" = {
              friendly_name = "On/Off Switch 1";
            };
            "0x70ac08fffe65211e" = {
              friendly_name = "On/Off Switch 2";
            };
            "0x0017880102f0848a" = {
              friendly_name = "Spotlight kök 1";
            };
            "0x0017880102f08526" = {
              friendly_name = "Spotlight Kök 2";
            };
            "0x0017880103e0add1" = {
              friendly_name = "Golvet";
            };
            "0x0017880103a0d280" = {
              friendly_name = "Uppe";
            };
            "0x0017880103ca6e95" = {
              friendly_name = "Dimmer Switch Kök";
            };
            "0x0017880104f77d61" = {
              friendly_name = "Dimmer Switch Sovrum";
            };
            "0x0017880106156cb0" = {
              friendly_name = "Taket Sovrum 1";
            };
            "0x0017880103c7467d" = {
              friendly_name = "Taket Sovrum 2";
            };
            "0x0017880103f44b5f" = {
              friendly_name = "Dörr";
            };
            "0x0017880109ac14f3" = {
              friendly_name = "Sänglampa";
            };
            "0x0017880104051a86" = {
              friendly_name = "Sänggavel";
            };
            "0x0017880104f78065" = {
              friendly_name = "Dimmer Switch Vardagsrum";
            };
            "0x54ef4410003e58e2" = {
              friendly_name = "Roller Shade";
            };
            "0xa4c1380afa9f7f3e" = {
              friendly_name = "Smoke Alarm Kitchen";
            };
            "0xa4c13873044cb7ea" = {
              friendly_name = "Kök Bänk Slinga";
            };
            "0x0017880103c73f85" = {
              friendly_name = "0x0017880103c73f85";
            };
            "0x0017880103f94041" = {
              friendly_name = "0x0017880103f94041";
            };
            "0x0017880103c753b8" = {
              friendly_name = "0x0017880103c753b8";
            };
            "0x540f57fffe85c9c3" = {
              friendly_name = "0x540f57fffe85c9c3";
            };
            "0x00178801037e754e" = {
              friendly_name = "0x00178801037e754e";
            };
          };
          groups = {
            "1" = {
              friendly_name = "uppe_o_nere";
              devices = [
                "0x0017880103a0d280/11"
                "0x0017880103e0add1/11"
              ];
            };
            "2" = {
              friendly_name = "all_kitchen_lights";
              devices = [
                "0x0017880103e0add1/11"
                "0x0017880103a0d280/11"
                "0x0017880102f0848a/11"
                "0x0017880102f08526/11"
              ];
            };
            "3" = {
              friendly_name = "all_bedroom_lights";
              devices = [
                "0x00178801001ecdaa/11"
                "0x0017880103f44b5f/11"
                "0x0017880104051a86/11"
                "0x0017880109ac14f3/11"
                "0x0017880106156cb0/11"
                "0x0017880103c7467d/11"
              ];
            };
            "4" = {
              friendly_name = "all_wc_lights";
              devices = [
                "0x001788010361b842/11"
                "0x0017880103406f41/11"
              ];
            };
            "5" = {
              friendly_name = "all_hallway_lights";
              devices = [
                "0x000b57fffe0e2a04/1"
                "0x0017880103eafdd6/11"
              ];
            };
            "6" = {
              friendly_name = "kitchen_spotlight_group";
            };
            "7" = {
              friendly_name = "kitchen_spotlights";
            };
          };
        };
      };
    };}   
