# dotfiles/bin/network/zigduck.nix
{ self, lib, config, pkgs, cmdHelpers, ... } : let
# 🦆 says ⮞ Welcome to my quacky hacky home of fun! 💫  
# 🦆 says ⮞ Home Assistant? wat? just another Big Tech Co, quack dat! 
# 🦆 says ⮞ duck don't write home automation, duck write infra with junkie comments on each line 
# 🦆 says ⮞ quack quack quack quack 🦆 please follow along til' we home?

  # 🦆 says ⮞ Dorectpry  for this configuration 
  zigduckDir = "/home/" + config.this.user.me.name + "/.config/zigduck";
  # 🦆 says ⮞ Verbose logging 
  DEBUG = false;

  # 🦆 says ⮞ dis fetch what host has Mosquitto
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
  mqttAuth = "-u mqtt -P $(cat ${config.sops.secrets.mosquitto.path})";
   
  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = { # 🦆 says ⮞ inb4 long annoying list  
    # Kitchen   🦆 says > oh crap
    "0x0017880103ca6e95" = {# 🦆 says ⮞ scroll
      friendly_name = "Dimmer Switch Kök";# 🦆 says ⮞ scroll sad duck, scroll ='(
      room = "kitchen"; # 🦆 says ⮞ i'll tell u when to stop ='(
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
    # 🦆 says ⮞ LIVING ROOM
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

    # 🦆 says ⮞ HALLWAY
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

    # 🦆 says ⮞ WC
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

    # 🦆 says ⮞ BEDROOM
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
    "0x00178801001ecdaa" = {  # 🦆 says ⮞ THATS TOO FAST!!
      friendly_name = "Bloom";
      room = "bedroom";
      type = "light";
      endpoint = 11; # 🦆 says ⮞ SLOW DOWN DUCKIE!!
    };
    # 🦆 says ⮞ MISCELLANEOUS
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
  };# 🦆 says ⮞ that's way too many devices huh

  # 🦆 says ⮞ scene simplifier? or not
  sceneLight = {state, brightness ? 200, hex ? null, temp ? null}:
    let
      colorValue = if hex != null then { inherit hex; } else null;
    in
    {
      inherit state brightness;
    } // (if colorValue != null then { color = colorValue; } else {})
      // (if temp != null then { color_temp = temp; } else {});

  # 🎨 Scenes  🦆 YELLS > SCENES!!!!!!!!!!!!!!!11
  scenes = { # 🦆 says ⮞ Declare light states, quack dat's a scene yo!
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
      "PC" = { state = "ON"; brightness = 200; color = { hex = "#8A2BE2"; }; };         # Blue Violet
      "Golvet" = { state = "ON"; brightness = 200; color = { hex = "#40E0D0"; }; };     # Turquoise
      "Uppe" = { state = "ON"; brightness = 200; color = { hex = "#FF69B4"; }; };       # Hot Pink
      "Spotlight Kök 1" = { state = "OFF"; brightness = 200; color = { hex = "#FFD700"; }; }; # Gold
      "Spotlight Kök 2" = { state = "OFF"; brightness = 200; color = { hex = "#FF8C00"; }; }; # Dark Orange
      "Taket Sovrum 1" = { state = "ON"; brightness = 200; color = { hex = "#00CED1"; }; };   # Dark Turquoise
      "Taket Sovrum 2" = { state = "ON"; brightness = 200; color = { hex = "#9932CC"; }; };   # Dark Orchid
      "Bloom" = { state = "ON"; brightness = 200; color = { hex = "#FFB6C1"; }; };       # Light Pink
      "Sänggavel" = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };   # Aquamarine
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
      "Bloom" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Dörr" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Golvet" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Kök Bänk Slinga" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "PC" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Rustning" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Spotlight Kök 2" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Spotlight kök 1" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Sänggavel" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Sänglampa" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Tak Hall" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Taket Sovrum 1" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Taket Sovrum 2" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Uppe" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "Vägg" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "WC 1" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
      "WC 2" = { state = "OFF"; brightness = 255; color = { hex = "#FFFFFF"; }; };
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

  # 🦆 says ⮞ Generate scene commands    
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

  # 🦆 says ⮞ dis creates device configuration for Z2M yo
  deviceConfig = lib.mapAttrs (id: dev: {
    friendly_name = dev.friendly_name;
  }) zigbeeDevices;

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

in { # 🦆 says ⮞ finally here, quack! 
  yo.scripts.zigduck = { # 🦆 says ⮞ dis is where my home at
    description = "Home Automations at its best! Bash & Nix cool as dat. Runs on single process";
    category = "🌐 Networking"; # 🦆 says ⮞ thnx for following me home
    aliases = [ "zigbee" "hem" ]; # 🦆 says ⮞ and not laughing at me
    helpFooter = '' 
      # 🦆 says ⮞ TODO - TUI/GUI Group Control within help command  # 🦆 says ⮜ dis coold be cool yeah?!
    '';
    parameters = [# 🦆 says ⮞ set your mosquitto user & password
      { name = "user"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "pwfile"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
#      { name = "debig"; description = "Debug mode, true or false"; optional = false; default = false; }
    ]; # 🦆 says ⮞ Script entrypoint yo
    code = ''
      ${cmdHelpers}      
      DEBUG_MODE=DEBUG # 🦆 says ⮞ if true, duck logs flood
      ZIGBEE_DEVICES='${deviceMeta}'
      MQTT_BROKER="${mqttHostip}"
      MQTT_USER="$user"
      MQTT_PASSWORD=$(cat "$pwfile")
      STATE_DIR="${zigduckDir}"
      SCENE_STATE="$STATE_DIR/current_scene"
      SCENE_LIST=(${lib.concatStringsSep " " (lib.attrNames scenes)}) 
      TIMER_DIR="$STATE_DIR/timers" 
      mkdir -p "$STATE_DIR" && mkdir -p "$TIMER_DIR"
     
      reset_room_timer() {
        local room="$1"
        local timer_file="''$TIMER_DIR/''${room// /_}"
        if [ -f "$timer_file" ]; then
          kill $(cat "$timer_file") 2>/dev/null
          rm -f "$timer_file"
        fi  
        (
          sleep 300
          room_lights_off "$room"
          rm -f "$timer_file"
        ) & 
        echo $! > "$timer_file"
        debug "⏱ Reset 5m timer for $room (PID: $!)"
      }
      is_dark_time() {
        local current_hour=$((10#$(date +%H)))
        [[ ($current_hour -ge 0 && $current_hour -lt 8) || 
           ($current_hour -ge 14 && $current_hour -le 23) ]]
      }
#      mqtt_pub() {
#        mosquitto_pub -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" "$@"
#      }
#      mqtt_sub() {
#        mosquitto_sub -F '%t|%p' -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t "$@"
#      }      
      mqtt_pub() {
        mosquitto_pub -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" "$@"
      }
      mqtt_sub() {
        mosquitto_sub -F '%t|%p' -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" "$@"
      }

      device_check() {
        occupancy=$(echo "$line" | jq -r '.occupancy') && debug "occupancy: $occupancy"
        action=$(echo "$line" | jq -r '.action') && debug "action: $action"
        device_name="''${topic#zigbee2mqtt/}" && debug "device_name: $device_name"
        dev_room=$(jq ".\"$device_name\".room" $STATE_DIR/zigbee_devices.json) && debug "dev_room: $dev_room"
        dev_type=$(jq ".\"$device_name\".type" $STATE_DIR/zigbee_devices.json) && debug "dev_type: $dev_type"     
        dev_id=$(jq ".\"$device_name\".id" $STATE_DIR/zigbee_devices.json) && debug "dev_id: $dev_id"  
        room="''${dev_room//\"/}"
      }
      room_lights_on() {
        local clean_room=$(echo "$1" | sed 's/"//g')
        jq -r --arg room "$clean_room" \
          'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' \
          $STATE_DIR/zigbee_devices.json |
          while read -r light_id; do
            debug "💡 $light_id ON in $clean_room"
            mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"state":"ON"}'
          done      
        say_duck "💡 Lights ON in $clean_room"  
      }
      room_lights_off() {
        local clean_room=$(echo "$1" | sed 's/"//g')
        jq -r --arg room "$clean_room" 'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' $STATE_DIR/zigbee_devices.json |
          while read -r light_id; do
            debug "🚫 $light_id OFF in $clean_room"
            mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"state":"OFF"}'
          done    
        say_duck "🚫 Lights OFF in $clean_room"  
      }
      
      start_listening() {
        echo "$ZIGBEE_DEVICES" | jq 'map({(.id): .}) | add' > $STATE_DIR/zigbee_devices.json
        jq 'map(select(.friendly_name != null) | {(.friendly_name): .}) | add' $STATE_DIR/zigbee_devices.json \
          > $STATE_DIR/zigbee_devices_by_friendly_name.json

        echo "🦆🏡 Welcome Home" 
        
        # 🦆 says ⮞ Subscribe and split topic and payload
        mqtt_sub "zigbee2mqtt/#" | while IFS='|' read -r topic line; do
          debug "Topic: $topic" && debug "Payload: $line"
          
          # 🦆 says ⮞ 🕵️ quick quack motion detect
          if echo "$line" | jq -e 'has("occupancy")' > /dev/null; then
            device_check            
            if [ "$occupancy" = "true" ]; then
              say_duck "🕵️ Motion in $device_name $dev_room"
              # 🦆 says ⮞ If current time is within motion > light timeframe - turn on lights
              if is_dark_time; then
                room_lights_on "$room"
                reset_room_timer "$room"
                else
                  debug "❌ Daytime - no lights activated by motion."
              fi
            else
              debug "🛑 No more motion in $device_name $dev_room"            
            fi
          fi

          # 🦆 says ⮞ 🎚 Dimmer Switch actions
          if echo "$line" | jq -e 'has("action")' > /dev/null; then
            device_check       
            if [ "$action" == "on_press_release" ]; then
              # 🦆 says ⮞ turn on all lights in the room
              room_lights_on "$room"
            # 🦆 says ⮞ yo homie, turn the fan on when grillin'
            if [ "$clean_room" == "kitchen" ]; then mqtt_pub -t "zigbee2mqtt/Fläkt/set" -m '{"state":"ON"}'; fi
            fi
            if [ "$action" == "on_hold_release" ]; then scene "max" && say_duck "✅💡 MAX LIGHTS ON"; fi
            if [ "$action" == "up_press_release" ]; then
              clean_room=$(echo "$dev_room" | sed 's/"//g')
                jq -r --arg room "$clean_room" 'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' $STATE_DIR/zigbee_devices.json |
                  while read -r light_id; do
                    say_duck "🔺 Increasing brightness on $light_id in $clean_room"
                    mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"brightness_step":50,"transition":3.5}'
                  done
            fi
            if [ "$action" == "up_hold_release" ]; then debug "$action"; fi
            if [ "$action" == "down_press_release" ]; then
              clean_room=$(echo "$dev_room" | sed 's/"//g')
              jq -r --arg room "$clean_room" 'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' $STATE_DIR/zigbee_devices.json |
                while read -r light_id; do
                  say_duck "🔻 Decreasing $light_id in $clean_room"
                  mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"brightness_step":-50,"transition":3.5}'
                done
            fi
            if [ "$action" == "down_hold_release" ]; then debug "$action"; fi
            if [ "$action" == "off_press_release" ]; then room_lights_off "$room"; fi
            if [ "$action" == "off_hold_release" ]; then scene "dark" && say_duck "🚫 DARKNESS ON"; fi
          fi
        done
      }   

      echo " Ready for liftoff?"    
      echo "🚀 Starting zigduck automation system"  
      say_duck "🚀 quack to the moon yo!"
      echo "📡 Listening to all Zigbee events..."
      start_listening             
    '';
  };

  # 🦆 says ⮞ how does dycks say ssschh?
  sops.secrets = {
    mosquitto = {# 🦆 says ⮞ quack, stupid!
      sopsFile = ./../../secrets/mosquitto.yaml; 
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # Read-only for owner and group
    };
  };

  # 🦆 says ⮞ Create device symlink for declarative serial port mapping
  services.udev.extraRules = ''SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="zigbee"'';
  
  # 🦆 says ⮞ Mosquitto configuration
  # 🦆 says ⮞ we only need server configuration on one host - so set zigduck at config.this.host.module services in your host config
  services.mosquitto = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) {
    enable = true;
    listeners = [{
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = false;# 🦆 says ⮞ safety first!
        users.mqtt.password = config.sops.secrets.mosquitto.path;
        settings.allow_anonymous = true;# 🦆 says ⮞ never forget, never forgive right?
       # settings.require_certificate = true;# 🦆 says ⮞ T to the L to the S spells wat? DUCK! 
       # settings.use_identity_as_username = true;
    }];
  };
  networking.firewall = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) {
    enable = true; 
    allowedTCPPorts = [ 1883 ];
  };

  # 🦆 says ⮞ Z2MQTT configurations
  services.zigbee2mqtt = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) { # 🦆 says ⮞ once again - dis is server configuration
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
#          port = "/dev/zigbee"; # 🦆 says ⮞ all hosts, same serial port yo!
          port = "/dev/serial/by-id/usb-Silicon_Labs_Sonoff_Zigbee_3.0_USB_Dongle_Plus_0001-if00-port0";
        };
        frontend = {# 🦆 says ⮞ who needs dis?
          enabled = false;# 🦆 says ⮞ 2duck4frontend yo
          port = 8099;# 🦆 says ⮞ duck means cool yo
        };
        advanced = {# 🦆 says ⮞ dis is advanced? duck tearz
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
          transmit_power = 9;# 🦆 says ⮞ to avoid brain damage, set low power
          channel = 15;# 🦆 says ⮞ channel 15 optimized for minimal interference from other 2.4Ghz devices, provides good stability  
          last_seen = "ISO_8601_local";
          network_key = [# 🦆 says ⮞ safe to expose? how the quack should ii know?
              86 208 29 190 33 225 60 93
              199 70 36 29 123 129 73 40
            ];
            pan_id = 60410;
          };
          device_options = {
            legacy = false;
          };
          availability = true;
          permit_join = false;# 🦆 says ⮞ allow new devices, not suggested for thin wallets
          devices = deviceConfig; # 🦆 says ⮞ inject defined Zigbee D!
          groups = groupConfig // { # 🦆 says ⮞ inject defined Zigbee G, yo!
            all_lights = { # 🦆 says ⮞ + create a group containing all light devices
              friendly_name = "all";
              devices = lib.concatMap (id: 
                let dev = zigbeeDevices.${id};
                in if dev.type == "light" then ["${id}/${toString dev.endpoint}"] else []
              ) (lib.attrNames zigbeeDevices);
            };
          };
        };
      }; 

  # 🦆 says ⮞ Prebuild scene commands
  environment.systemPackages = [
    # 🦆 says ⮞ Dependencies 
    pkgs.mosquitto
    pkgs.zigbee2mqtt 
    # 🦆 says ⮞ scene fireworks  
    (pkgs.writeScriptBin "scene-roll" ''
      ${lib.concatStringsSep "\n" (lib.flatten (lib.mapAttrsToList (_: cmds: lib.mapAttrsToList (_: cmd: cmd) cmds) sceneCommands))}
    '')
    # 🦆 says ⮞ activate a scene yo
    (pkgs.writeScriptBin "scene" ''
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
  ];  

  # 🦆 says ⮞ always running process does not need to be voice activated, we set empty intent data to disable voice activation for this script
  yo.bitch.intents.zigduck = { data = [{ sentences = [ ]; lists = { }; }]; };    
    
  # 🦆 says ⮞ pls ensure my quacky hacky home start at boot - YO
  systemd.services.zigduck = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) { # 🦆 says ⮞ again -- server config on single host
    requires = ["mosquitto.service" "zigbee2mqtt.service"];
    after = ["zigbee2mqtt.service" "mosquitto.service" "network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {# 🦆 says ⮞ dis down below is dis script above
      User = config.this.user.me.name;
      Group = config.this.user.me.name;
      StateDirectory = baseNameOf zigduckDir;# 🦆 says ⮞ Creates /var/lib/zigduck
      RuntimeDirectory = baseNameOf zigduckDir;
      ExecStart = "${config.pkgs.yo}/bin/yo-zigduck";
      Restart = "on-failure";
      RestartSec = "5s";
      StartLimitIntervalSec = "60";
      StartLimitBurst = 5;
    };
  };} # 🦆 says ⮞ Bye bye, please come again yo! 💕 💕 💫   
