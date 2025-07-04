# dotfiles/bin/network/zigduck.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Welcome to QuackHack-McBLindy'z Quacky Hacky Home of Fun! 💫  
  self, 
  lib, # 🦆 says ⮞ 📌 FEATURES:
  config,     # 🦆 says ⮞ ⭐Autoconfigures: Lights, Zigbee Coordinator+encrypted backup, Dimmers, Scenes, Automations, Power Switches, Motion+Sensors, Blinds, etc.. 
  pkgs,       # 🦆 says ⮞ ⭐ Display Battery Dashboard in Markdown within `--help` command in CLI
  cmdHelpers, # 🦆 says ⮞ ⭐  etc, etc, etc... 
  ... # 🦆 says ⮞ duck don't write automations - duck write infra with junkie comments on each line.... quack
} : let # yo follow 🦆 home – ⬇⬇ 🦆 says diz way plz? quack quackz

  # 🦆 says ⮞ Directpry  for this configuration 
  zigduckDir = "/home/" + config.this.user.me.name + "/.config/zigduck";
  # 🦆 says ⮞ Verbose logging 
  DEBUG = false;
  # 🦆 says ⮞ don't stick it to the duck - encrypted Zigbee USB coordinator backup filepath
  backupEncryptedFile = "${config.this.user.me.dotfilesDir}/secrets/zigbee_coordinator_backup.json";

  # 🦆 says ⮞ ⏰ Automations based upon time
  house.timeAutomations = {
    good_morning = {
      time = "07:00";
      days = [ "Mon" "Tue" "Wed" "Thu" "Fri" ];
      action = "echo 'Turning on morning lights...'";
    };
  };  

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

in { # 🦆 says ⮞ finally here, quack! 
  yo.scripts.zigduck = { # 🦆 says ⮞ dis is where my home at
    description = "Home Automations at its best! Bash & Nix cool as dat. Runs on single process";
    category = "🛖 Home Automation"; # 🦆 says ⮞ thnx for following me home
    autoStart = config.this.host.hostname == "homie"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
    aliases = [ "zigbee" "hem" ]; # 🦆 says ⮞ and not laughing at me
    # 🦆 says ⮞ run `yo zigduck --help` to display your battery states!
    helpFooter = '' 
      # 🦆 says ⮞ TODO - TUI/GUI Group Control within help command  # 🦆 says ⮜ dis coold be cool yeah?!
      STATE_DIR=/var/lib/zigbee
      STATE_FILE="state.json"
      WIDTH=100
      cat <<EOF | ${pkgs.glow}/bin/glow --width $WIDTH -
## ──────⋆⋅☆⋅⋆────── ##
## 🔋 Battery Status
$(${pkgs.jq}/bin/jq -r --slurpfile mapping ${mappingFile} '
  to_entries[] |
  select(.value.battery != null) |
  .key as $ieee |
  .value.battery as $battery |
  ($mapping[0] | .[$ieee] // $ieee) as $display_name |
  "### 🖥️ Device: `\($display_name)`\n**Battery:** \($battery)% " +
  (
    if $battery >= 75 then "🔋"
    elif $battery >= 30 then "🟡"
    else "🪫"
    end
  ) + "\n"
' $STATE_DIR/$STATE_FILE)
## ──────⋆⋅☆⋅⋆────── ##
EOF
    '';
    logLevel = "INFO";
    parameters = [ # 🦆 says ⮞ set your mosquitto user & password
      { name = "user"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "pwfile"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
    ]; # 🦆 says ⮞ Script entrypoint yo
    code = ''
      ${cmdHelpers} # 🦆 says ⮞ load default helper functions 
      export PATH="$PATH:/run/current-system/sw/bin" # 🦆 says ⮞ annoying but easy
      DEBUG_MODE=DEBUG # 🦆 says ⮞ if true, duck logs flood
      ZIGBEE_DEVICES='${deviceMeta}'
      MQTT_BROKER="${mqttHostip}" && debug "$MQTT_BROKER"
      MQTT_USER="$user" && debug "$MQTT_USER"
      MQTT_PASSWORD=$(cat "$pwfile")
      STATE_DIR="${zigduckDir}"
      TIMER_DIR="$STATE_DIR/timers" 
      mkdir -p "$STATE_DIR" && mkdir -p "$TIMER_DIR"     
      BACKUP_ID=""
      BACKUP_TMP_FILE=""
      # 🦆 says ⮞ zigbee coordinator backup function
      perform_zigbee_backup() {
        BACKUP_ID="zigbee_backup_$(date +%Y%m%d_%H%M%S)"
        BACKUP_TMP_FILE="$(mktemp)"
        say_duck "Triggering Zigbee coordinator backup: $BACKUP_ID"
        mqtt_pub -t "zigbee2mqtt/bridge/request/backup" -m "{\"id\": \"$BACKUP_ID\"}"
      }
      # 🦆 says ⮞ handle backup response function
      handle_backup_response() {
        local line="$1"
        local backup_id=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.id')        
        if [ "$backup_id" != "$BACKUP_ID" ]; then
          debug "🦆 ignoring backup response for ID: $backup_id (waiting for $BACKUP_ID)"
          return
        fi      
        local status=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.status')
        if [ "$status" = "ok" ]; then
          echo "$line" | ${pkgs.jq}/bin/jq -r '.data.backup' > "$BACKUP_TMP_FILE"
          debug "Encrypting Zigbee coordinator backup with sops..."   
          if "''${config.pkgs.yo}/bin/yo-sops" "$BACKUP_TMP_FILE" > "${backupEncryptedFile}"; then
            say_duck "✅ Backup saved to: ${backupEncryptedFile}"
          else
            say_duck "fuck ❌ Encryption failed for zigbee coordinator backup!"
          fi
          rm -f "$BACKUP_TMP_FILE"
        else
          local error_msg=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.error')
          say_duck "❌ Backup failed: $error_msg"
        fi    
        # 🦆 says ⮞ reset states
        BACKUP_ID=""
        BACKUP_TMP_FILE=""
      }
      # 🦆 says ⮞ main loop - ducks can't listen but mosquitto's can apparently    
      start_listening() {
        echo "$ZIGBEE_DEVICES" | ${pkgs.jq}/bin/jq 'map({(.id): .}) | add' > $STATE_DIR/zigbee_devices.json
        ${pkgs.jq}/bin/jq 'map(select(.friendly_name != null) | {(.friendly_name): .}) | add' $STATE_DIR/zigbee_devices.json \
          > $STATE_DIR/zigbee_devices_by_friendly_name.json
        # 🦆 says ⮞ last echo
        echo "🦆🏡 Welcome Home" 
        
        # 🦆 says ⮞ Subscribe and split topic and payload
        mqtt_sub "zigbee2mqtt/#" | while IFS='|' read -r topic line; do
          debug "Topic: $topic" && debug "Payload: $line"         
          # 🦆 says ⮞ backup handling
          if [ "$topic" = "zigbee2mqtt/bridge/response/backup" ]; then handle_backup_response "$line"; fi          
          # 🦆 says ⮞ trigger backup from MQTT
          if [ "$topic" = "zigbee2mqtt/backup/request" ]; then perform_zigbee_backup; fi
 
          # 🦆 says ⮞ 🕵️ quick quack motion detect
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("occupancy")' > /dev/null; then
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
          if echo "$line" | ${pkgs.jq}/bin/jq -e 'has("action")' > /dev/null; then
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
                ${pkgs.jq}/bin/jq -r --arg room "$clean_room" 'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' $STATE_DIR/zigbee_devices.json |
                  while read -r light_id; do
                    say_duck "🔺 Increasing brightness on $light_id in $clean_room"
                    mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"brightness_step":50,"transition":3.5}'
                  done
            fi
            if [ "$action" == "up_hold_release" ]; then debug "$action"; fi
            if [ "$action" == "down_press_release" ]; then
              clean_room=$(echo "$dev_room" | sed 's/"//g')
              ${pkgs.jq}/bin/jq -r --arg room "$clean_room" 'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' $STATE_DIR/zigbee_devices.json |
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
      # 🦆 says ⮞ ran dis thang
      echo " Ready for liftoff?"    
      echo "🚀 Starting zigduck automation system"  
      say_duck "🚀 quack to the moon yo!"
      echo "📡 Listening to all Zigbee events..."
      start_listening             
    '';
  };

  # 🦆 says ⮞ how does ducks say ssschh?
  sops.secrets = {
    mosquitto = { # 🦆 says ⮞ quack, stupid!
      sopsFile = ./../../secrets/mosquitto.yaml; 
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    }; # 🦆 says ⮞ Z2MQTT encryption key - if changed needs re-pairing devices
    z2m_network_key = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) { 
      sopsFile = ./../../secrets/z2m_network_key.yaml; 
      owner = "zigbee2mqtt";
      group = "zigbee2mqtt";
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    };
    z2m_mosquitto = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) { 
      sopsFile = ./../../secrets/z2m_mosquitto.yaml; 
      owner = "zigbee2mqtt";
      group = "zigbee2mqtt";
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    };
  };
  # 🦆 says ⮞ Mosquitto configuration
  # 🦆 says ⮞ we only need server configuration on one host - so set zigduck at config.this.host.module services in your host config
  services.mosquitto = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) {
    enable = true;
    listeners = [{
        acl = [ "pattern readwrite #" ];
        port = 1883;
        omitPasswordAuth = false; # 🦆 says ⮞ safety first!
        users.mqtt.passwordFile = config.sops.secrets.mosquitto.path;
        settings.allow_anonymous = true; # 🦆 says ⮞ never forget, never forgive right?
#        settings.require_certificate = true; # 🦆 says ⮞ T to the L to the S spells wat? DUCK! 
#        settings.use_identity_as_username = true;
    }];
  };
  
  # 🦆 says ⮞ open firewall 4 Z2MQTT & Mosquitto on the server host
  networking.firewall = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) { allowedTCPPorts = [ 1883 8099 ]; };

  # 🦆 says ⮞ Create device symlink for declarative serial port mapping
  services.udev.extraRules = ''SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="zigbee"'';
  
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
          password =  config.sops.secrets.mosquitto.path; # 🦆 says ⮞ no support for passwordFile?! sneaky duckiie use dis as placeholder lol
          base_topic = "zigbee2mqtt";
        };
        # 🦆 says ⮞ physical port mapping
        serial = { # 🦆 says ⮞ either USB port (/dev/ttyUSB0), network Zigbee adapters (tcp://192.168.1.1:6638) or mDNS adapter (mdns://my-adapter).       
         port = "/dev/zigbee"; # 🦆 says ⮞ all hosts, same serial port yo!
         disable_led = true; # 🦆 says ⮞ save quack on electricity bill yo  
        };
        frontend = { # 🦆 says ⮞ who needs dis?
          enabled = true; # 🦆 says ⮞ 2duck4frontend yo
          host = "0.0.0.0";  # 🦆 says ⮞ duck means cool by the way - in case u did not realize 
          port = 8099; 
        };
        advanced = { # 🦆 says ⮞ dis is advanced? ='( duck tearz of sadness
          export_state = true;
          export_state_path = "${zigduckDir}/zigbee_devices.json";
          homeassistant_legacy_entity_attributes = false; # 🦆 says ⮞ wat the duck?! wat do u thiink?
          legacy_api = false;
          legacy_availability_payload = false;
          log_syslog = { # 🦆 says ⮞ log settings
            app_name = "Zigbee2MQTT";
            eol = "/n";
            host = "localhost";
            localhost = "localhost";
            path = "/dev/log";
            pid = "process.pid"; # 🦆 says ⮞ process id
            port = 123;
            protocol = "tcp4";# 🦆 says ⮞ TCP4pcplife
            type = "5424";
          };
          transmit_power = 9; # 🦆 says ⮞ to avoid brain damage, set low power
          channel = 15; # 🦆 says ⮞ channel 15 optimized for minimal interference from other 2.4Ghz devices, provides good stability  
          last_seen = "ISO_8601_local";
          # 🦆 says ⮞ zigbee encryption key.. quack? - better not expose it, decrypt and use da real deal down below yo
          network_key = [ # 🦆 says ⮞ placeholder net yo
              86 208 29 190 33 225 60 93
              199 70 36 29 123 129 73 40
            ];
            pan_id = 60410;
          };
          device_options = { legacy = false; };
          availability = true;
          permit_join = true; # 🦆 says ⮞ allow new devices, not suggested for thin wallets
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

  environment.systemPackages = [
    # 🦆 says ⮞ Dependencies 
    pkgs.mosquitto
    pkgs.zigbee2mqtt # 🦆 says ⮞ wat? dat's all?
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
    # 🦆 says ⮞ activate a scene yo
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
      MQTT_USER=$(nix eval "${config.this.user.me.dotfilesDir}#nixosConfigurations.${config.this.host.hostname}.config.yo.scripts.zigduck.parameters" --json | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "user") | .default')
      MQTT_PASSWORD=$(cat "${config.sops.secrets.mosquitto.path}") # ⮜ 🦆 says password file 
      # 🦆 says ⮞ Zigbee coordinator backup
      if [[ "$DEVICE" == "backup" ]]; then
        mqtt_pub -t "zigbee2mqtt/backup/request"
        say_duck "✅ Zigbee coordinator backup requested! - processing on server..."
        exit 0
      fi         
      # 🦆 says ⮞ validate device
      input_lower=$(echo "$DEVICE" | tr '[:upper:]' '[:lower:]')
      exact_name=''${device_map["$input_lower"]}
      if [[ -z "$exact_name" ]]; then
        say_duck "fuck ❌ Device not found: $DEVICE" >&2
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


  # 🦆 says ⮞ let's do some ducktastic decryption magic into yaml files before we boot services up duck duck yo
  systemd.services.zigbee2mqtt = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
#    environment.ZIGBEE2MQTT_DATA = "/var/lib/zigbee";
    preStart = '' 
      mkdir -p ${config.services.zigbee2mqtt.dataDir}    
      # 🦆 says ⮞ our real mosquitto password quack quack
      mosquitto_password=$(cat ${config.sops.secrets.z2m_mosquitto.path}) 
      sed -i "s|/run/secrets/mosquitto|$mosquitto_password|" ${config.services.zigbee2mqtt.dataDir}/configuration.yaml
      # 🦆 says ⮞ da real zigbee network key boom boom quack quack yo yo
#      TMPFILE="${config.services.zigbee2mqtt.dataDir}/tmp.yaml"
#      CFGFILE="${config.services.zigbee2mqtt.dataDir}/configuration.yaml"
#      ${pkgs.gawk}/bin/awk -v keyfile="${config.sops.secrets.z2m_network_key.path}" '
        # 🦆 says ⮞ match line starting with whitespace + network_key
#        /^[[:space:]]*network_key:[[:space:]]*$/ {
#          print
#          indent = substr($0, 1, match($0, /[^[:space:]]/) - 1)
#          while ((getline < keyfile) > 0) {
#            print indent "  " $0
#          }
#          close(keyfile)
#          skip = 1
#          next
#        }
        # 🦆 says ⮞ stop skipping when non indented key come by duck
#        skip && /^[^[:space:]]/ { skip = 0 }
#        # 🦆 says ⮞ while skipping, skip skip skip, oh man im so hiphop yo
#        skip { next }
#        { print }
#      ' "$CFGFILE" > "$TMPFILE"  
#      mv "$TMPFILE" "$CFGFILE"    
    ''; # 🦆 says ⮞ thnx fo quackin' along! 💫⭐
  };} # 🦆 says ⮞ sleep tight!
# 🦆 says ⮞ QuackHack-McBLindy out!
# ... 🛌🦆💤

