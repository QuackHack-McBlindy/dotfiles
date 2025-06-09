# dotfiles/bin/network/zugbee.nix
{ self, lib, config, pkgs, cmdHelpers, ... } : let
# 🦆 says > Welcome to my quacky hacky home of fun! 💫  
# 🦆 says > If u somewhat alike quack hack the mcblind duck - and like cool stuff n shit, do remember⭐
# 🦆 says > SmartHome 🥈 sure qwacks,but Free Home🏆🥇 & Safe Home💫wow🚀but plz duckwised be - you are🔑for your home🔏
# 🦆 says > why don't u let 🦆 plz in? > @nixhome dropin lol come in

  # Fetch host info for Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = lib.findSingle (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) null null sysHosts;    
  mqttHostip = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or "127.0.0.1"
    else "127.0.0.1";
   
  # Declaratively define Zigbee devices 
  zigbeeDevices = {
    # Kitchen
    "0x0017880103ca6e95" = {
      friendly_name = "Dimmer Switch Kök";
      room = "kitchen";
      type = "dimmer";
      endpoint = 1;
    };
    "0x0017880102f0848a" = {
      friendly_name = "Spotlight kök 1";
      room = "kitchen";
      type = "light";
      endpoint = 11;
    };
    "0x0017880102f08526" = {
      friendly_name = "Spotlight Kök 2";
      room = "kitchen";
      type = "light";
      endpoint = 11;
    };
    "0x0017880103a0d280" = {
      friendly_name = "Uppe";
      room = "kitchen";
      type = "light";
      endpoint = 11;
    };
    "0x0017880103e0add1" = {
      friendly_name = "Golvet";
      room = "kitchen";
      type = "light";
      endpoint = 11;
    };
    "0xa4c13873044cb7ea" = {
      friendly_name = "Kök Bänk Slinga";
      room = "kitchen";
      type = "light";
      endpoint = 11;
    };
    "0x70ac08fffe9fa3d1" = {
      friendly_name = "Motion Sensor Kök";
      room = "kitchen";
      type = "sensor";
      endpoint = 1;
    };
    "0xa4c1380afa9f7f3e" = {
      friendly_name = "Smoke Alarm Kitchen";
      room = "kitchen";
      type = "sensor";
      endpoint = 1;
    };
    "0x0c4314fffe179b05" = {
      friendly_name = "Fläkt";
      room = "kitchen";
      type = "power plug";
      endpoint = 1;
    };

    # LIVINGROOM
    "0x0017880104f78065" = {
      friendly_name = "Dimmer Switch Vardagsrum";
      room = "livingroom";
      type = "dimmer";
      endpoint = 1;
    };
    "0x54ef4410003e58e2" = {
      friendly_name = "Roller Shade";
      room = "livingroom";
      type = "blind";
      endpoint = 1;
    };
    "0x0017880104540411" = {
      friendly_name = "PC";
      room = "livingroom";
      type = "light";
      endpoint = 11;
    };
    "0x0017880102de8570" = {
      friendly_name = "Rustning";
      room = "livingroom";
      type = "light";
      endpoint = 11;
    };

    # HALLWAY
    "0x00178801021311c4" = {
      friendly_name = "Motion Sensor Hall";
      room = "hallway";
      type = "sensor";
      endpoint = 1;
    };
    "0x0017880103eafdd6" = {
      friendly_name = "Tak Hall";
      room = "hallway";
      type = "light";
      endpoint = 11;
    };
    "0x000b57fffe0e2a04" = {
      friendly_name = "Vägg";
      room = "hallway";
      type = "light";
      endpoint = 1;
    };

    # WC
    "0x001788010361b842" = {
      friendly_name = "WC 1";
      room = "wc";
      type = "light";
      endpoint = 11;
    };
    "0x0017880103406f41" = {
      friendly_name = "WC 2";
      room = "wc";
      type = "light";
      endpoint = 11;
    };

    # BEDROOM
    "0x0017880104f77d61" = {
      friendly_name = "Dimmer Switch Sovrum";
      room = "bedroom";
      type = "dimmer";
      endpoint = 1;
    };
    "0x0017880106156cb0" = {
      friendly_name = "Taket Sovrum 1";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };
    "0x0017880103c7467d" = {
      friendly_name = "Taket Sovrum 2";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };
    "0x0017880109ac14f3" = {
      friendly_name = "Sänglampa";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };
    "0x0017880104051a86" = {
      friendly_name = "Sänggavel";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };
    "0xf4b3b1fffeaccb27" = {
      friendly_name = "Motion Sensor Sovrum";
      room = "bedroom";
      type = "sensor";
      endpoint = 1;
    };
    "0x0017880103f44b5f" = {
      friendly_name = "Dörr";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };
    "0x00178801001ecdaa" = {
      friendly_name = "Bloom";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };

    # MISC
    "0x000b57fffe0f0807" = {
      friendly_name = "IKEA 5 Dimmer";
      room = "other";
      type = "remote";
      endpoint = 1;
    };
    "0x70ac08fffe6497be" = {
      friendly_name = "On/Off Switch 1";
      room = "other";
      type = "remote";
      endpoint = 1;
    };
    "0x70ac08fffe65211e" = {
      friendly_name = "On/Off Switch 2";
      room = "other";
      type = "remote";
      endpoint = 1;
    };
    "0x0017880103c73f85" = {
      friendly_name = "Unknown 1";
      room = "other";
      type = "misc";
      endpoint = 1;
    };  
    "0x0017880103f94041" = {
      friendly_name = "Unknown 2";
      room = "other";
      type = "misc";
      endpoint = 1;
    };      
    "0x0017880103c753b8" = {
      friendly_name = "Unknown 3";
      room = "other";
      type = "misc";
      endpoint = 1;
    };      
    "0x540f57fffe85c9c3" = {
      friendly_name = "Unknown 4";
      room = "other";
      type = "misc";
      endpoint = 1;
    };    
    "0x00178801037e754e" = {
      friendly_name = "Unknown 5";
      room = "other";
      type = "misc";
      endpoint = 1;
    };    
  };

  # Filter by rooms
  byRoom = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.room} = (acc.${dev.room} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # Filter by device type
  byType = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.type} = (acc.${dev.type} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # Create groups
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

  # Create Zigbee device configuration
  deviceConfig = lib.mapAttrs (id: dev: {
    friendly_name = dev.friendly_name;
  }) zigbeeDevices;

  # Put actions on all light dimmers based on room
  dimmerHandlers = lib.concatStringsSep "\n\n" (lib.mapAttrsToList (id: dev: ''
    # ${dev.friendly_name}
    mosquitto_sub -h "$MQTT_BROKER" -t "zigbee2mqtt/${dev.friendly_name}" | while read -r line; do
      action=$(echo "$line" | jq -r '.action')
      hold_time=$(echo "$line" | jq -r '.hold_time // 0')
      echo "Device: ${dev.friendly_name}, Action: $action, Hold: $hold_time"
    
      case "$action" in
        # Button 1 (Top)
        "on")
          if [ "$hold_time" -eq 0 ]; then
            # Press: Turn on room + kitchen fläkt
            mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/${dev.room}/set" -m '{"state": "ON"}'
            ${lib.optionalString (dev.room == "kitchen") ''
              mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/Fläkt/set" -m '{"state": "ON"}'
            ''}
          else
            # Hold: Scene cycling
            mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/${dev.room}/set" -m '{"scene_next": ""}'
          fi
          ;;
      
        # Button 2 (Up)
        "brightness_step_up")
          if [ "$hold_time" -eq 0 ]; then
            # Press: +5% brightness
            mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/${dev.room}/set" -m '{"brightness_step": 5}'
          else
            # Hold: Max brightness + white
            mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/all_lights/set" -m '{"brightness": 255, "color": {"x": 0.3127, "y": 0.3290}}'
          fi
          ;;
      
        # Button 3 (Down)
        "brightness_step_down")
          if [ "$hold_time" -eq 0 ]; then
            # Press: -5% brightness
            mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/${dev.room}/set" -m '{"brightness_step": -5}'
          else
            # Hold: Turn off all + fläkt
            mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/all_lights/set" -m '{"state": "OFF"}'
             mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/Fläkt/set" -m '{"state": "OFF"}'
          fi
          ;;
      
        # Button 4 (Bottom)
        "off")
          if [ "$hold_time" -eq 0 ]; then
            # Press: Turn off room
            mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/${dev.room}/set" -m '{"state": "OFF"}'
          else
            # Hold: Voice command trigger
            mosquitto_pub -h "$MQTT_BROKER" -t "voice_assistant/trigger" -m '{"device": "${dev.friendly_name}"}'
          fi
        ;;
      
        *)
          echo "Unhandled action: $action"
          ;;
      esac
    done &
  '') (lib.filterAttrs (id: d: d.type == "dimmer") zigbeeDevices));
  
  deviceMeta = builtins.toJSON (lib.listToAttrs (lib.mapAttrsToList (id: dev: {
    name = dev.friendly_name;
    value = {
      room = dev.room;
      type = dev.type;
      id = id;
      endpoint = dev.endpoint;
    };
  }) zigbeeDevices));

in { # We're here. This is it. 
  # The Boss script that runs your home.
  yo.scripts.nixhome = {
    description = "nixhome, a simple yet powerful automation system for Smart Home devices. Runs on single process";
    category = "🌐 Networking";
    aliases = [ "zigbee" "home" ];
    helpFooter = ''
    
    '';
#    parameters = [
#      { name = "mqttuser"; description = "Media to search"; default = "mqtt"; optional = false; }
#      { name = "pwfile"; description = "Passwordfile for user"; default = config.sops; optional = faöse; }

#    ]; # Entrypoints
    code = ''
      ${cmdHelpers}       
      export ZIGBEE_DEVICES='${deviceMeta}'
      MQTT_BROKER="$mqttHostip"

      start_listening() {
        trap 'echo "🛑 duckduckduckduckduckduck.... off"; exit' INT TERM
        echo "$ZIGBEE_DEVICES" > /tmp/zigbee_devices.json 																																																																																																         echo "📡 Listening to all Zigbee events..."
        if ! command -v jq &> /dev/null; then
          echo "❌ 'jq' is required but not installed. Please install jq."
          exit 1
        fi
        if ! mosquitto_sub -h "$MQTT_BROKER" -t "\$SYS/broker/version" -C 1 -W 2 &> /dev/null; then
          echo "❌ Cannot connect to MQTT broker at $MQTT_BROKER"
          exit 1
        fi     

        mosquitto_sub -h "$MQTT_BROKER" -t "zigbee2mqtt/#" | while read -r line; do
          topic=$(echo "$line" | jq -r '.topic // empty')
          [ -z "$topic" ] && topic=$(echo "$line" | grep -oP '^zigbee2mqtt/\K[^ ]+')
          [ -z "$topic" ] && continue

          dev=$(jq -r --arg name "$topic" '.[$name] // empty' /tmp/zigbee_devices.json)
          [ "$dev" == "null" ] && continue

          type=$(echo "$dev" | jq -r '.type')
          room=$(echo "$dev" | jq -r '.room')
          id=$(echo "$dev" | jq -r '.id')
          action=$(echo "$line" | jq -r '.action // empty')
          state=$(echo "$line" | jq -r '.state // empty')
          hold_time=$(echo "$line" | jq -r '.hold_time // 0')
          presence=$(echo "$line" | jq -r '.occupancy // empty')
          smoke=$(echo "$line" | jq -r '.smoke // empty')
          echo "🔔 $topic [$type/$room] → action=$action, state=$state, presence=$presence, smoke=$smoke"
          case "$type" in
          
# ---> DEVICES <---- #      
      # 🎚 Dimmer Switches
            "dimmer")
              case "$action" in
                
                # Button 1 - On
                "on")
                  if [[ "$hold_time" -eq 0 ]]; then
                    mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"state": "ON"}'
                    [[ "$room" == "kitchen" ]] && \
                      mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/Fläkt/set" -m '{"state": "ON"}'
                  else
                    mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"scene_next": ""}'
                  fi
                  ;;
                  
                # Button 2 - Increase brightness  
                "brightness_step_up")
                  if [[ "$hold_time" -eq 0 ]]; then
                    mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"brightness_step": 5}'
                  else
                    mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/all_lights/set" -m '{"brightness": 255, "color": {"x": 0.3127, "y": 0.3290}}'
                  fi
                  ;;
                  
                # Button 3 - Decrease brightness
                "brightness_step_down")
                  if [[ "$hold_time" -eq 0 ]]; then
                    mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"brightness_step": -5}'
                  else
                    mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/all_lights/set" -m '{"state": "OFF"}'
                    mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/Fläkt/set" -m '{"state": "OFF"}'
                  fi
                  ;;
                
                # Button 4 - Off 
                "off")
                  if [[ "$hold_time" -eq 0 ]]; then
                    mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"state": "OFF"}'
                  else
                    mosquitto_pub -h "$MQTT_BROKER" -t "voice_assistant/trigger" -m "{\"device\": \"$topic\"}"
                  fi
                  ;;
              esac
              ;;

      # 🕵️ Motion & Sensors        
            "sensor")
              if [[ "$presence" == "true" ]]; then
                echo "👣 Motion detected in $room"
                mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"state": "ON"}'
              fi

              if [[ "$smoke" == "true" ]]; then
                echo "🔥 Smoke detected by $topic in $room!"
                quackalot "warning warning Smoke detected by $topic in $room!"
                say "ELD ELD ELD anka gillar ej ELD ELD ELD ELD!"   
                mosquitto_pub -h "$MQTT_BROKER" -t "notification/emergency" -m "{\"type\": \"smoke\", \"location\": \"$room\"}"
              fi
              ;;

      # ⚡ Power & Energy Plugs
            "power plug")
              echo "🔌 Power plug state: $state"
              ;;

      # 💡 Lights
            "light")
              echo "💡 Light state changed: $state"
              ;;

      # 🌀 Motors & Shaders
            "blind")
              echo "🪟 Blind state: $state"
              ;;

      # 🎚 Remotes & Buttons
            "remote")
              echo "🎮 Remote control: $action"
              ;;

      # 🎚 Misc & Unknown
            *)
              echo "⚠️ Unhandled device type: $type"
              ;;
          esac
        done
      
        echo "📡 Connected to MQTT broker at $MQTT_BROKER"
      }   
     
      # 🎨 Scenes
      # 📢 Notification system (smoke alarms, cameras, low battery notifications)
         
      # ---> AUTOMATIONS <---- #      
      # 🕒 Time based automations

      echo " Ready for liftoff?"    
      echo "🚀 Starting nixhome automation system"
      
      ${dimmerHandlers}
      start_listening      
         
    '';
  };  
  
  # Create device symlink for declarative serial port mapping
  services.udev.extraRules = ''SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="zigbee"'';
  
  services.mosquitto = lib.mkIf (lib.elem "nixhome" config.this.host.modules.services) {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
        users.mqtt.password = config.sops.secrets.mosquitto.path;
      }
    ];
  };
  networking.firewall = lib.mkIf (lib.elem "nixhome" config.this.host.modules.services) {
    enable = true; 
    allowedTCPPorts = [ 1883 ];
  };

  services.zigbee2mqtt = lib.mkIf (lib.elem "nixhome" config.this.host.modules.services) {
    enable = true;
    dataDir = "/var/lib/zigbee";
    settings = {
        experimental.output = "json";
        homeassistant = true;
        mqtt = {
          server = "mqtt://localhost:1883";
          user = "mqtt";
          password =  config.sops.secrets.mosquitto.path; # use a strong password outside /nix/store
          base_topic = "zigbee2mqtt";
        };
        serial = {
         # port = "/dev/zigbee"; # all hosts same path  
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
          devices = deviceConfig;
          groups = groupConfig // {
            all_lights = {
              friendly_name = "all";
              devices = lib.concatMap (id: 
                let dev = zigbeeDevices.${id};
                in if dev.type == "light" then ["${id}/${toString dev.endpoint}"] else []
              ) (lib.attrNames zigbeeDevices);
            };
          };
        };
      }; 
    }    
#    systemd.services.nixhome = {
#      wantedBy = ["multi-user.target"];
#      after = ["zigbee2mqtt.service"];
#      serviceConfig = {
#        ExecStart = "${config.yo.pkgs}/bin/yo-nixhome";
#        Restart = "on-failure";
#      };
      
#  };}
