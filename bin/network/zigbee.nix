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
      echo "Device: ${dev.friendly_name}, Action: $action"
      echo "Room:  ${dev.room}"
      # Button 1   
      if [[ "$action" == "on_press" ]]; then
        echo "$action"
        mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/''${dev.room}/set" -m '{"state": "ON"}'
      fi   
      if [[ "$action" == "on_press_release" ]]; then
        echo "$action"
      fi
      if [[ "$action" == "on_hold" ]]; then
        echo "$action"
      fi   
      if [[ "$action" == "on_hold_release" ]]; then
        echo "$action"
      fi    
      # Button 2
      if [[ "$action" == "up_press" ]]; then
        echo "$action"
        mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/${dev.room}/set" -m '{"state": "ON"}'
      fi   
      if [[ "$action" == "up_press_release" ]]; then
        echo "$action"
        mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/''${dev.room}/set" -m '{"brightness_step": 5}'
      fi
      if [[ "$action" == "up_hold" ]]; then
        echo "$action"
      fi   
      if [[ "$action" == "up_hold_release" ]]; then
        echo "$action"
        mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/all_lights/set" -m '{"brightness": 255, "color": {"x": 0.3127, "y": 0.3290}}'
      fi    
      # Button 3
      if [[ "$action" == "down_press" ]]; then
        echo "$action"
        mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"state": "ON"}'
      fi   
      if [[ "$action" == "down_press_release" ]]; then
        echo "$action"
        mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room}/set" -m '{"brightness_step": -5}'
      fi
      if [[ "$action" == "down_hold" ]]; then
        echo "$action"
      fi   
      if [[ "$action" == "down_hold_release" ]]; then
        echo "$action"
      fi    
      # Button 4
      if [[ "$action" == "off_press" ]]; then
        echo "$action"
        mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"state": "OFF"}'
      fi   
      if [[ "$action" == "off_press_release" ]]; then
        echo "$action"
        mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"state": "OFF"}'
      fi
      if [[ "$action" == "off_hold" ]]; then
        echo "$action"
      fi   
      if [[ "$action" == "off_hold_release" ]]; then
        echo "$action"
        mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"state": "ON"}'
        mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/all_lights/set" -m '{"state": "OFF"}'
        mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/Fläkt/set" -m '{"state": "OFF"}'
      fi    
      case "$action" in                
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
    description = "Home Automations at its best! Bash & Nix cool as dat. Runs on single process";
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
      ${dimmerHandlers}
      echo "Mosquitto host: ${mqttHost}"    
      echo "Mosquitto IP: ${mqttHostip}"
      ZIGBEE_DEVICES='${deviceMeta}'
      MQTT_BROKER="${mqttHostip}"
      MQTT_PORT=1883
      start_listening() {
        trap 'echo "🛑 Stopping..."; pkill -P $$; exit' INT TERM
        echo "$ZIGBEE_DEVICES" > /tmp/zigbee_devices.json
        echo "📡 Listening to all Zigbee events..."
        echo "📡 Connected to MQTT broker at $MQTT_BROKER" 
        mosquitto_sub -h "$MQTT_BROKER" -p "$MQTT_PORT" -t "zigbee2mqtt" | while read -r line; do
          # Extract topic and payload
          topic_full=$(echo "$line" | cut -d ' ' -f 1)
          topic="''${topic_full#zigbee2mqtt/}"
          payload=$(echo "$line" | cut -d ' ' -f 2-)
          [ -z "$topic" ] && continue


          dev=$(jq -r --arg name "$topic" '.[$name] // empty' /tmp/zigbee_devices.json)
          [ -z "$dev" ] || [ "$dev" = "null" ] && continue
          room=$(echo "$dev" | jq -r '.room')
          type=$(echo "$dev" | jq -r '.type')
          room=$(echo "$dev" | jq -r '.room')  # Get room at runtime
          id=$(echo "$dev" | jq -r '.id')
      
        
          # Parse payload fields
          action=$(echo "$payload" | jq -r '.action // empty')
          state=$(echo "$payload" | jq -r '.state // empty')
          presence=$(echo "$payload" | jq -r '.occupancy // empty')
          smoke=$(echo "$payload" | jq -r '.smoke // empty')
          echo "🔔 $topic [$type/$room] → action=$action, state=$state, presence=$presence, smoke=$smoke"
          echo "type: $type"
          
# ---> DEVICES <---- #       
          # 🎚 Dimmer Switches
          if [[ "$type" == "dimmer" ]]; then
              if [[ "$action" == "on_press_release" ]]; then
                  mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"state": "ON"}'
                  mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/Fläkt/set" -m '{"state": "ON"}'
              elif [[ "$action" == "up_press_release" ]]; then
                  mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"brightness_step": 5}'
              elif [[ "$action" == "up_hold_release" ]]; then
                  mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/all_lights/set" -m '{"brightness": 255, "color": {"x": 0.3127, "y": 0.3290}}'
              elif [[ "$action" == "down_press_release" ]]; then
                  mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"brightness_step": -5}'
              elif [[ "$action" == "down_hold_release" ]]; then
                  mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"brightness_step": -5}'
              elif [[ "$action" == "off_press_release" ]]; then
                  mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"state": "OFF"}'
              elif [[ "$action" == "off_hold_release" ]]; then
                  mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$room/set" -m '{"state": "ON"}'
                  mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/all_lights/set" -m '{"state": "OFF"}'
                  mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/Fläkt/set" -m '{"state": "OFF"}'
              fi
          fi
          
          # 🕵️ Motion & Sensors
          if [[ "$type" == "sensor" ]]; then
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
          fi
          
          # ⚡ Power & Energy Plugs   
          if [[ "$type" == "power plug" ]]; then
              echo "🔌 Power plug state: $state"
          fi 
          
          # 💡 Lights
          if [[ "$type" == "lights" ]]; then
              echo "💡 Light state changed: $state"
          fi
          
          # 🌀 Motors & Shaders
          if [[ "$type" == "blind" ]]; then
              echo "🪟 Blind state: $state"
          fi
          
          # 🎚 Remotes & Buttons
          if [[ "$type" == "remote" ]]; then
              echo "🎮 Remote control: $action"
          fi
          
          # 🎚 Misc & Unknown
          if [[ "$type" == "unknown" ]]; then
              echo "UNKNOWN TYPE!"
          fi
        done  
      }   
     
      # 🎨 Scenes
      # 📢 Notification system (smoke alarms, cameras, low battery notifications)
         
      # ---> AUTOMATIONS <---- #      
      # 🕒 Time based automations

      echo " Ready for liftoff?"    
      echo "🚀 Starting nixhome automation system"
      
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
