# dotfiles/bin/default.nix
{ 
    self,
    config,
    lib,
    pkgs,
    ...
} : let # 🦆 duck say ⮞ this file just sets simple helpers and auto imports all scripts
  inherit (lib) types mkOption mkEnableOption mkMerge;
  importModulesRecursive = dir:
    let
      entries = builtins.readDir dir;
      modules = lib.attrsets.mapAttrsToList (name: type:
        let path = dir + "/${name}";
        in if type == "directory" then
          importModulesRecursive path
        else if lib.hasSuffix ".nix" name then
          [ path ]
        else
          []
      ) entries;
    in lib.flatten modules;

  sysHosts = lib.attrNames self.nixosConfigurations;
  sysDevShells = lib.attrNames self.devShells; 
  
  # 🦆 duck say ⮞ Create helper functions for yo scripts
  cmdHelpers = ''
    parse_flags() {
      VERBOSE=0
      DRY_RUN=false
      HOST=""
      for arg in "$@"; do
        case "$arg" in
          '?') ((VERBOSE++)) ;;
          '!') DRY_RUN=true ;;
          *) HOST="$arg" ;;
        esac
      done
      FLAGS=()
      (( VERBOSE > 0 )) && FLAGS+=(--show-trace "-v''${VERBOSE/#0/}")
    }     

    # 🦆 duck say ⮞ outputs hex from plain text color names
    color2hex() {
      local color="$1"
      declare -A color_ranges=(
        ["red"]="255,0,0:165,0,0"
        ["green"]="0,255,0:0,100,0"
        ["blue"]="0,0,255:0,0,165"
        ["yellow"]="255,255,0:200,200,0"
        ["orange"]="255,165,0:205,100,0"
        ["purple"]="128,0,128:80,0,80"
        ["pink"]="255,192,203:220,150,160"
        ["white"]="255,255,255:240,240,240"
        ["black"]="10,10,10:0,0,0"
        ["gray"]="160,160,160:80,80,80"
        ["brown"]="165,42,42:120,30,30"
        ["cyan"]="0,255,255:0,200,200"
        ["magenta"]="255,0,255:180,0,180"
      )
      if [[ -z "''${color_ranges[$color]}" ]]; then
        echo "Unknown color: $color" >&2
        return 1
      fi
      IFS=':' read -r min_range max_range <<< "''${color_ranges[$color]}"
      IFS=',' read -r min_r min_g min_b <<< "$min_range"
      IFS=',' read -r max_r max_g max_b <<< "$max_range"
      local r=$(( min_r + RANDOM % (max_r - min_r + 1) ))
      local g=$(( min_g + RANDOM % (max_g - min_g + 1) ))
      local b=$(( min_b + RANDOM % (max_b - min_b + 1) ))
      printf "%02x%02x%02x\n" "$r" "$g" "$b"
    }


    # 🦆 duck say ⮞ check development enviorment exist yo!
    validate_devShell() {
      if [[ ! " ${lib.escapeShellArg (toString sysDevShells)} " =~ " $devShell " ]]; then
        echo -e "\033[1;31m❌ $1\033[0m Unknown devShell: $devShell" >&2
        echo "Available devShells: ${toString sysDevShells}" >&2
        exit 1
      fi
    }

    # 🦆 duck say ⮞ run commands safely, yo!
    run_cmd() {
      if $DRY_RUN; then
        echo "[DRY RUN] Would execute:"
        echo "  ''${@}"
        "''${@}"
      else
        if (( VERBOSE > 0 )); then
          echo "Executing: ''${@}"
        fi
        "''${@}"
      fi
    }

    # 🦆 duck say ⮞ diis need explaination? 
    say_duck() {
      echo -e "\e[3m\e[38;2;0;150;150m🦆 duck say \e[1m\e[38;2;255;255;0m⮞\e[0m\e[3m\e[38;2;0;150;150m $1\e[0m"
    }

    # 🦆 duck say ⮞ remember to set appropriate mode in script 
    debug() {
     if [ "$DEBUG_MODE" = true ]; then echo "$*"; fi
    }      

    # 🦆 duck say ⮞ fail? i usually don't, yo!
    type fail >/dev/null 2>&1 || fail() { 
      echo -e "$1" >&2
      exit 1
    }
    
    # 🦆 duck say ⮞ validate command flags, yo!
    validate_flags() {
      verbosity_level=$(grep -o '?' <<< "$@" | wc -l)
      DRY_RUN=$(grep -q '!' <<< "$@" && echo true || echo false)
    }

    # 🦆 duck say ⮞ plays failing sound
    play_fail() {
      aplay "${config.this.user.me.dotfilesDir}/modules/themes/sounds/fail.wav" >/dev/null 2>&1
    }

    # 🦆 duck say ⮞ validate json input before process
    is_valid_json() {
      echo "$1" | jq -e . >/dev/null 2>&1
    }
    # 🦆 duck say ⮞ plays winning sound
    play_win() {
      aplay "${config.this.user.me.dotfilesDir}/modules/themes/sounds/win.wav" >/dev/null 2>&1
    }
    # 🦆 duck say ⮞ Prompt for input by voice
    mic_input() {
      yo-mic | jq -r '.transcription // empty'
    } 
    # 🦆 duck say ⮞ validate host, yo!
    validate_host() {
      if [[ ! " ${lib.escapeShellArg (toString sysHosts)} " =~ " $host " ]]; then
        echo -e "\033[1;31m❌ $1\033[0m Unknown host: $host" >&2
        echo "Available hosts: ${toString sysHosts}" >&2
        exit 1
      fi
    }
    # 🦆 says ⮞ resets timer set for motion triggering lights off
    reset_room_timer() { 
      local room="$1"
      local timer_file="''$TIMER_DIR/''${room// /_}"
      if [ -f "$timer_file" ]; then
        kill $(cat "$timer_file") 2>/dev/null
        rm -f "$timer_file"
      fi  
      ( # 🦆 says ⮞ Time til' lights turn off after motion trigger activation
        sleep 300 # 🦆 says ⮞ in seconds
        room_lights_off "$room"
        rm -f "$timer_file"
      ) & 
      echo $! > "$timer_file"
      debug "Reset 5m timer for $room (PID: $!)"
    }
    # 🦆 says ⮞ Time windom of day that allow motion triggering lights on
    is_dark_time() { 
      local current_hour=$((10#$(date +%H)))
      [[ ($current_hour -ge 0 && $current_hour -lt 8) || # 🦆 says ⮞ from 00,00 to 08.00
         ($current_hour -ge 16 && $current_hour -le 23) ]] # 🦆 says ⮞ & from 16,00 to 23.00
    }
    mqtt_pub() { # 🦆 says ⮞ publish Mosquitto
      mosquitto_pub -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" "$@"
    }
    mqtt_sub() { # 🦆 says ⮞ subscribe Mosquitto
      mosquitto_sub -F '%t|%p' -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t "$@"
    }      
    # 🦆 says ⮞ parser
    device_check() { 
      occupancy=$(echo "$line" | jq -r '.occupancy') && debug "occupancy: $occupancy"
      action=$(echo "$line" | jq -r '.action') && debug "action: $action"
      device_name="''${topic#zigbee2mqtt/}" && debug "device_name: $device_name"
      dev_room=$(jq ".\"$device_name\".room" $STATE_DIR/zigbee_devices.json) && debug "dev_room: $dev_room"
      dev_type=$(jq ".\"$device_name\".type" $STATE_DIR/zigbee_devices.json) && debug "dev_type: $dev_type"     
      dev_id=$(jq ".\"$device_name\".id" $STATE_DIR/zigbee_devices.json) && debug "dev_id: $dev_id"  
      room="''${dev_room//\"/}"
    }
    # 🦆 says ⮞ turn on specified room
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
    # 🦆 says ⮞ turn off specified room
    room_lights_off() { 
      local clean_room=$(echo "$1" | sed 's/"//g')
      jq -r --arg room "$clean_room" 'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' $STATE_DIR/zigbee_devices.json |
        while read -r light_id; do
          debug "🚫 $light_id OFF in $clean_room"
          mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"state":"OFF"}'
        done    
      say_duck "🚫 Lights OFF in $clean_room"  
    }
  '';
in { # 🦆 duck say ⮞ import everythang in defined directories
    imports = builtins.map (file: import file {
        inherit self config lib cmdHelpers pkgs sysHosts;
    }) (
        importModulesRecursive ./config ++# 🦆 duck say ⮞ plus
        importModulesRecursive ./system ++# 🦆 duck say ⮞ plus
        importModulesRecursive ./security ++ # 🦆 duck say ⮞ plus plus plus lots of luck?
        importModulesRecursive ./maintenance ++
        importModulesRecursive ./productivity ++
        importModulesRecursive ./network ++
        importModulesRecursive ./misc # 🦆 duck say ⮞ last one i swear
        
    );} # 🦆 duck say ⮞ bye
