# dotfiles/bin/network/zugbee.nix
{ self, lib, config, pkgs, cmdHelpers, ... } : let
# 🦆 says > Welcome to my quacky hacky home of fun! 💫  
# 🦆 says > If u somewhat alike quack hack the mcblind duck - and like cool stuff n shit, do remember⭐
# 🦆 says > SmartHome 🥈 sure qwacks,but Free Home🏆🥇 & Safe Home💫wow🚀but plz duckwised be - you are🔑for your home🔏
# 🦆 says > why don't u let 🦆 plz in? > @nixhome dropin lol come in

  # 🦆 says > While true, easy to debug i say
  DEBUG_MODE = true;

  # 🦆 says > dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = lib.findSingle (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) null null sysHosts;    
  mqttHostip = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or "127.0.0.1"
    else "127.0.0.1";
  mqttAuth = "-u mqtt -P $(cat ${config.sops.secrets.mosquitto.path})";
   
  # 🦆 says > define Zigbee devices here yo 
  zigbeeDevices = { # 🦆 says > inb4 long annoying list  
    # Kitchen   🦆 says > oh crap
    "0x0017880103ca6e95" = {# 🦆 says > scroll
      friendly_name = "Dimmer Switch Kök";# 🦆 says > scroll sad duck, scroll ='(
      room = "kitchen"; # 🦆 says > i'll tell u when to stop ='(
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
      type = "motion";
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
      type = "motion";
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
      type = "motion";
      endpoint = 1;
    };
    "0x0017880103f44b5f" = {
      friendly_name = "Dörr";
      room = "bedroom";
      type = "light";
      endpoint = 11;
    };
    "0x00178801001ecdaa" = {  # 🦆 says > THATS TOO FAST!!
      friendly_name = "Bloom";
      room = "bedroom";
      type = "light";
      endpoint = 11; # 🦆 says > SLOW DOWN DUCKIE!!
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
      endpoint = 1; # 🦆 says > that's way too many devices huh
    };    
  };

  # 🎨 Scenes  🦆 YELLS > SCENES!!!!!!!!!!!!!!!1
  scenes = { # 🦆 says > Declare light states, quack dat's a scene yo!
    # 🦆 says > Scene name
    "Duck Scene" = {
      # 🦆 says > Device friendly_name
      "PC" = { # 🦆 says > Device state
        state = "ON";
        brightness = 200;
        color = { hex = "#00FF00"; };
      };
    };
    # 🦆 says > Scene 2    
    "Chill Scene" = {
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
    "max" = { # 🦆 says > max brightness, all lights ? yo ?
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
  };

  # 🦆 says > Generate scene commands    
  makeCommand = device: settings:
    let
      json = builtins.toJSON settings;
    in
      ''
      mosquitto_pub -h "${mqttHostip}" -t "zigbee2mqtt/${device}/set" -m '${json}'
      '';
  sceneCommands = lib.mapAttrs
    (sceneName: sceneDevices:
      lib.mapAttrs (device: settings: makeCommand device settings) sceneDevices
    ) scenes;  
    
  # 🦆 says > Filter devices by rooms
  byRoom = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.room} = (acc.${dev.room} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # 🦆 says > Filter by device type
  byType = lib.foldlAttrs (acc: id: dev:
    lib.recursiveUpdate acc {
      ${dev.type} = (acc.${dev.type} or []) ++ [ id ];
    }) {} zigbeeDevices;

  # 🦆 says > dis creates groups yi
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

  # 🦆 says > Create Zigbee device configuration
  deviceConfig = lib.mapAttrs (id: dev: {
    friendly_name = dev.friendly_name;
  }) zigbeeDevices;

  # 🦆 says > Put actions on all light dimmers based on room
  dimmerHandlers = lib.concatStringsSep "\n\n" (lib.mapAttrsToList (id: dev: let
    roomLights = lib.filterAttrs (_: d: 
      d.room == dev.room && d.type == "light"
    ) zigbeeDevices;
    lightArray = lib.concatMapStringsSep " " (name: ''"${name}"'') 
      (lib.attrNames roomLights);
  in ''
    # ${dev.friendly_name} in ${dev.room}
    lights=(${lightArray})
    
    mosquitto_sub -h "$MQTT_BROKER" -t "zigbee2mqtt/${dev.friendly_name}" | while read -r line; do
      payload=$(echo "$line" | cut -d ' ' -f 2-)
      action=$(echo "$payload" | jq -r '.action // empty')      
      if ''${DEBUG_MODE}; then
        echo "$line"
      fi
  
    # Button 1 Press
      if [ "$action" == "on_press_release" ]; then
        echo "$action"
      fi
    # Button 1 Hold
      if [ "$action" == "on_hold_release" ]; then
        echo "$action"
      fi
    # Button 2 Press      
      if [ "$action" == "up_press_release" ]; then
        echo "$action"
      fi
    # Button 2 Hold      
      if [ "$action" == "up_hold_release" ]; then
        echo "$action"
      fi
    # Button 3 Press      
      if [ "$action" == "down_press_release" ]; then
        echo "$action"
      fi
    # Button 3 Hold      
      if [ "$action" == "down_hold_release" ]; then
        echo "$action"
      fi
      # Button 4 Press - Turn off all room lights sequentially
      # Button 4 Hold - Turn off all lights sequentially
      if [ "$action" == "on_hold_release" ]; then
        mosquitto_pub -h "192.168.1.211" -t "zigbee2mqtt/PC/set" -m '{"state": "ON"}'
        echo "💡 Turning OFF all lights in ${dev.room}"
        for light in "''${lights[@]}"; do
          mosquitto_pub -h "$MQTT_BROKER" -t "zigbee2mqtt/$light/set" -m '{"state": "OFF"}'
          sleep 0.3 # Short delay between lights
        done
      fi
    done &
  '') (lib.filterAttrs (id: d: d.type == "dimmer") zigbeeDevices));


  blindHandlers = lib.concatStringsSep "\n\n" (lib.mapAttrsToList (id: dev: ''
    # ${dev.friendly_name}
    mosquitto_sub -h "$MQTT_BROKER" -t "zigbee2mqtt/${dev.friendly_name}" | while read -r line; do
      echo "$line"  
      if [ "$type" == "blind" ]; then
        echo "🪟 Blind state: $state"
      fi
    done &
  '') (lib.filterAttrs (id: d: d.type == "blind") zigbeeDevices));
   
  # 🕵️ Motion & Sensors       
  motionHandlers = lib.concatStringsSep "\n\n" (lib.mapAttrsToList (id: dev: ''
    # ${dev.friendly_name}
    mosquitto_sub -h "$MQTT_BROKER" -t "zigbee2mqtt/${dev.friendly_name}" | while read -r line; do
      echo "$line"  
      if [[ "$presence" == "true" ]]; then
        echo "👣 Motion detected in $room" 
      fi
    done &
  '') (lib.filterAttrs (id: d: d.type == "motion") zigbeeDevices));

  # 🦆 says > not to be confused with facebook - this is not even duckbook
  deviceMeta = builtins.toJSON (lib.listToAttrs (lib.mapAttrsToList (id: dev: {
    name = dev.friendly_name;
    value = {
      room = dev.room;
      type = dev.type;
      id = id;
      endpoint = dev.endpoint;
    };
  }) zigbeeDevices));

in { # 🦆 says > finally here, quack! 
  yo.scripts.nixhome = { # 🦆 says > dis is where my home at
    description = "Home Automations at its best! Bash & Nix cool as dat. Runs on single process";
    category = "🌐 Networking"; # 🦆 says > thnx for following me home
    aliases = [ "zigbee" "home" ]; # 🦆 says > and not laughing at me
    helpFooter = '' 
      # TODO TUI/GUI Group Control within help command  # 🦆 says < dis coold be cool?!
    '';
#    parameters = [
#      { name = "user"; description = "Media to search"; default = "mqtt"; optional = false; }
#      { name = "pwfile"; description = "Passwordfile for user"; default = config.sops; optional = faöse; }
#    ]; # 🦆 says > Script entrypoint yo
    code = ''
      ${cmdHelpers}         
      ZIGBEE_DEVICES='${deviceMeta}'
      MQTT_BROKER="${mqttHostip}"
      MQTT_PORT=1883
      start_listening() {
        trap 'echo "🛑 Stopping..."; pkill -P $$; exit' INT TERM
        echo "$ZIGBEE_DEVICES" > /tmp/zigbee_devices.json
        echo "📡 Listening to all Zigbee events..."
        echo "📡 Connected to MQTT broker at $MQTT_BROKER"
        mosquitto_sub -h "$MQTT_BROKER" -p "$MQTT_PORT" -t "zigbee2mqtt/#" | while read -r line; do
          # Extract topic and payload
          topic_full=$(echo "$line" | cut -d ' ' -f 1)
          topic="''${topic_full#zigbee2mqtt/}"
          payload=$(echo "$line" | cut -d ' ' -f 2-)
          [ -z "$topic" ] && continue

          # Look up device
          dev=$(jq -r --arg name "$topic" '.[$name] // empty' /tmp/zigbee_devices.json)
          [ -z "$dev" ] || [ "$dev" = "null" ] && continue

          # Parse device attributes
          type=$(echo "$dev" | jq -r '.type')
          room=$(echo "$dev" | jq -r '.room')
          id=$(echo "$dev" | jq -r '.id')
        
          # Parse payload fields
          action=$(echo "$payload" | jq -r '.action // empty')
          state=$(echo "$payload" | jq -r '.state // empty')
          presence=$(echo "$payload" | jq -r '.occupancy // empty')
          smoke=$(echo "$payload" | jq -r '.smoke // empty')
          echo "🔔 $topic [$type/$room] → action=$action, state=$state, presence=$presence, smoke=$smoke"
          say_duck "$action"
          say_duck "$type"
        done
      }        
     # 🌀 Motors & Shaders 
      # 🕒 Time based automations

      echo " Ready for liftoff?"    
      echo "🚀 Starting nixhome automation system"      
      start_listening             
    '';
  };  
  
  # 🦆 says > Create device symlink for declarative serial port mapping
  services.udev.extraRules = ''SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="zigbee"'';
  
  # 🦆 says > Mosquitto configuration
  # 🦆 says > we only need server configuration on one host - so set nixhome at config.this.host.module services
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

  # 🦆 says > Z2MQTT configurations
  services.zigbee2mqtt = lib.mkIf (lib.elem "nixhome" config.this.host.modules.services) { # 🦆 says > once again - dis is server configuration
    enable = true;
    dataDir = "/var/lib/zigbee";
    settings = {
        experimental.output = "json";
        homeassistant = true;
        mqtt = {
          server = "mqtt://localhost:1883";
          user = "mqtt";
          password =  config.sops.secrets.mosquitto.path; 
          base_topic = "zigbee2mqtt";
        };
        serial = {
#          port = "/dev/zigbee"; # 🦆 says > all hosts, same serial port yo!
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
          devices = deviceConfig; # 🦆 says > inject zigbee D!
          groups = groupConfig // { # 🦆 says > inject zigbee G, yo!
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

  # 🦆 says > Prebuild scene activation
  environment.systemPackages = [
    (pkgs.writeScriptBin "activate-scene" ''
      ${lib.concatStringsSep "\n" (lib.flatten (lib.mapAttrsToList (_: cmds: lib.mapAttrsToList (_: cmd: cmd) cmds) sceneCommands))}
    '')
  ];  
    
  # 🦆 says > pls ensure my quacky hacky home start at boot - YO
  systemd.services.nixhome = {
    wantedBy = ["multi-user.target"];
    after = ["zigbee2mqtt.service"];
    serviceConfig = {
      ExecStart = "${config.pkgs.yo}/bin/yo-nixhome";
      Restart = "on-failure";
     # LogRateLimitIntervalSec = 30;
     # LogRateLimitBurst = 1000;
    };
  };} # 🦆 says > Bye bye, catch u later home duck G dawg! 💕 💕 💫
    
