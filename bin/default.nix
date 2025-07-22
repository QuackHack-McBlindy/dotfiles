# dotfiles/bin/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ dis file just sets simple helpers and auto imports all scripts
    self,
    config,
    lib,
    pkgs,
    ...
} : let # 🦆 duck say ⮞ grabbin' some of dat sweet sweet nix option for fancy fancy configz
  inherit (lib) types mkOption mkEnableOption mkMerge;
  # 🦆 duck say ⮞ recursive nix importer — let'z waddle throu' them dirz through the reeds
  importModulesRecursive = dir: 
    let
      entries = builtins.readDir dir;# 🦆 duck say ⮞ read all files & subfolders in dir i say no duck left behind
      modules = lib.attrsets.mapAttrsToList (name: type: # 🦆 duck say ⮞ map over entries, check if directory or nix file
        let path = dir + "/${name}"; # 🦆 duck say ⮞ build path quackfully
        in if type == "directory" then
          importModulesRecursive path # 🦆 duck say ⮞ dive down the directory pond recursively
        else if lib.hasSuffix ".nix" name then
          [ path ] # 🦆 duck say ⮞ found nix file! add it to da list, quack yees
        else
          [] # 🦆 duck say ⮞ no nix file? no worries move along little ducky
      ) entries;
    in lib.flatten modules; # 🦆 duck say ⮞ flatten list of lists go single list - no nested duck nestz here

  # 🦆 duck say ⮞ list all hostz — all ducks in the pond
  sysHosts = lib.attrNames self.nixosConfigurations;
  # 🦆 duck say ⮞ list all devShells — ducklingz ready to hatch dem dev env
  sysDevShells = lib.attrNames self.devShells; 
  
  # 🦆 duck say ⮞ stash house for massive amounts of helper functions for yo scripts
  cmdHelpers = ''
    elapsed_since_start() {
      local now=$(date +%s.%N)
      local elapsed=$(echo "$now - $start" | bc)
      printf "%.3f" "$elapsed"
    }
    # 🦆 duck say ⮞ colors & stykez yo
    BOLD="\033[1m"
    BLINK="\033[5m"
    YELLOW="\033[33m"
    BLUE="\033[34m"
    GREEN="\033[0;32m"
    ALERT='\033[1;5;31m'
    RED='\033[1;31m'
    NC='\033[0m'
    RESET='\033[0m'
    GRAY="\033[38;5;244m"
    # 🦆 says ⮞ duck say stylez 
    DSAY="\033[3m\033[38;2;0;150;150m"   
    bold() { # 🦆 says ⮞ function to make input text bold   
      echo -e "\033[1m$1\033[0m"
    }  
    # 🦆 says ⮞ DUCK TRACE YO
    # 🦆 says ⮞ convert string levels to numbers
    declare -A DT_LEVEL_MAP=( [DEBUG]=0 [INFO]=1 [WARNING]=2 [ERROR]=3 [CRITICAL]=4 )
    # 🦆 says ⮞ auto convert DT_LOG_LEVEL if set as string
    if [[ -n "$DT_LOG_LEVEL" && ! "$DT_LOG_LEVEL" =~ ^[0-9]+$ ]]; then
      export DT_LOG_LEVEL_NUM="''${DT_LEVEL_MAP[''${DT_LOG_LEVEL^^}]:-1}"
    else
      : ''${DT_LOG_LEVEL_NUM:=1}
    fi

    # 🦆 says ⮞ map log levels
    declare -A DT_LEVEL_MAP=( [DEBUG]=0 [INFO]=1 [WARNING]=2 [ERROR]=3 [CRITICAL]=4 )
    _dt_log() {
      local level="$1"
      local symbol="$2"
      local color="$3"
      local message="$4"
      local blink="$5"
      local timestamp
      timestamp=$(date +"%H:%M:%S")
      local blink_code=""
      [[ "$blink" == "true" ]] && blink_code="$BLINK"
      local level_num="''${DT_LEVEL_MAP[$level]:-0}"
      (( level_num < DT_LOG_LEVEL_NUM )) && return      
      local max_size=1048576 # 1MB     
      # 🦆 says ⮞ rorate logs
      if [[ -f "$log_path" && $(stat -c%s "$log_path") -gt $max_size ]]; then mv "$log_path" "$log_path.old"; fi
      # 🦆 says ⮞ format output
      local output="''${color}''${BOLD}''${blink_code}[🦆📜] [''${timestamp}] ''${symbol}''${level}''${symbol} ⮞ ''${message}''${RESET}"
      echo -e "$output" 
      # 🦆 says ⮞ append to log file
      echo "[''${timestamp}] ''${level} - ''${message}" >> "''${DT_LOG_PATH%/}/''${DT_LOG_FILE}"
    }
    # 🦆 says ⮞ log levels (in order of most critical)
    dt_debug() {
      local elapsed_time=$(elapsed_since_start)
      local elapsed_text=""
      if (( $(echo "$elapsed_time < 10000" | bc -l) )); then
        elapsed_text="+$elapsed_time s "
      fi
      _dt_log "DEBUG" "⁉️" "$BLUE" "''${elapsed_text}$1" >&2
    }
    dt_info() {
      _dt_log "INFO" "✅" "$GREEN" "$1" >&2
    }
    dt_warning() {
      _dt_log "WARNING" "⚠️" "$YELLOW" "$1" >&2
    }
    dt_error() {
      _dt_log "ERROR" "❌" "$RED" "$1" true >&2
    }
    dt_critical() {
      _dt_log "CRITICAL" "🚨" "$RED" "$1" true >&2
    }
    # 🦆 says ⮞ END OF DUCK TRACE ='( 
    parse_flags() { # 🦆 says ⮞ quite self explained  
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
    color2hex() { # 🦆 duck say ⮞ outputs random hex within color range from plain text color names
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

      local r g b

      if [[ -z "$color" || "$color" == "random" || -z "''${color_ranges[$color]}" ]]; then
        # Empty, 'random', or unknown color name: full random fallback
        r=$(( RANDOM % 256 ))
        g=$(( RANDOM % 256 ))
        b=$(( RANDOM % 256 ))
      else
        IFS=':' read -r min_range max_range <<< "''${color_ranges[$color]}"
        IFS=',' read -r min_r min_g min_b <<< "$min_range"
        IFS=',' read -r max_r max_g max_b <<< "$max_range"
        r=$(( min_r + RANDOM % (max_r - min_r + 1) ))
        g=$(( min_g + RANDOM % (max_g - min_g + 1) ))
        b=$(( min_b + RANDOM % (max_b - min_b + 1) ))
      fi
      printf "%02x%02x%02x\n" "$r" "$g" "$b"
    }
    validate_devShell() {  # 🦆 duck say ⮞ check development enviorment exist yo!
      if [[ ! " ${lib.escapeShellArg (toString sysDevShells)} " =~ " $devShell " ]]; then
        echo -e "\033[1;31m❌ $1\033[0m Unknown devShell: $devShell" >&2
        echo "Available devShells: ${toString sysDevShells}" >&2
        exit 1
      fi
    }
    run_cmd() { # 🦆 duck say ⮞ run commands safely, yo!
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
    say_duck() { # 🦆 duck say ⮞ diis need explaination? 
      echo -e "\e[3m\e[38;2;0;150;150m🦆 duck say \e[1m\e[38;2;255;255;0m⮞\e[0m\e[3m\e[38;2;0;150;150m $1\e[0m"
    }
    type fail >/dev/null 2>&1 || fail() { # 🦆 duck say ⮞ fail? duck's usually don't yo?
      echo -e "$1" >&2
      exit 1
    }
    validate_flags() { # 🦆 duck say ⮞ validate command flags, yo!
      verbosity_level=$(grep -o '?' <<< "$@" | wc -l)
      DRY_RUN=$(grep -q '!' <<< "$@" && echo true || echo false)
    }
  
    # 🦆 duck say ⮞ plays failing sound
    play_fail() {
      aplay "${config.this.user.me.dotfilesDir}/modules/themes/sounds/fail.wav" >/dev/null 2>&1
    }
    # 🦆 duck say ⮞ validate json input before process
    is_valid_json() {
      echo "$1" | ${pkgs.jq}/bin/jq -e . >/dev/null 2>&1
    }    
    play_win() { # 🦆 duck say ⮞ plays winning sound
      aplay "${config.this.user.me.dotfilesDir}/modules/themes/sounds/win.wav" >/dev/null 2>&1
    }
    mic_input() { # 🦆 duck say ⮞ Prompt for input by voice
      yo-mic | ${pkgs.jq}/bin/jq -r '.transcription // empty'
    } 
    validate_host() { # 🦆 duck say ⮞ validate host, yo!
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
        sleep 900 # 🦆 says ⮞ in seconds
        room_lights_off "$room"
        rm -f "$timer_file"
      ) & 
      echo $! > "$timer_file"
      dt_debug "Reset 5m timer for $room (PID: $!)"
    }
    # 🦆 says ⮞ Time window of day that allow motion triggering lights on
#    is_dark_time() { 
#      local current_hour=$((10#$(date +%H)))
#      [[ ($current_hour -ge 0 && $current_hour -lt 8) || # 🦆 says ⮞ from 00,00 to 08.00
#         ($current_hour -ge 16 && $current_hour -le 23) ]] # 🦆 says ⮞ & from 16,00 to 23.00
#    }
    is_dark_time() {
      source /etc/dark-time.conf
      local now_hour now_min now total_now
      IFS=: read -r now_hour now_min <<< "$(date +%H:%M)"
      total_now=$((10#$now_hour * 60 + 10#$now_min))
      IFS=: read -r start_hour start_min <<< "$DARK_TIME_START"
      local start_total=$((10#$start_hour * 60 + 10#$start_min))
      IFS=: read -r end_hour end_min <<< "$DARK_TIME_END"
      local end_total=$((10#$end_hour * 60 + 10#$end_min))
      if (( start_total <= end_total )); then
        (( total_now >= start_total && total_now < end_total ))
      else
        (( total_now >= start_total || total_now < end_total ))
      fi
    }
    mqtt_pub() { # 🦆 says ⮞ publish Mosquitto
      ${pkgs.mosquitto}/bin/mosquitto_pub -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" "$@"
    }
    mqtt_sub() { # 🦆 says ⮞ subscribe Mosquitto
      ${pkgs.mosquitto}/bin/mosquitto_sub -F '%t|%p' -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t "$@"
    }
    # 🦆 says ⮞ device parser for zigduck
    device_check() { 
      occupancy=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.occupancy // empty') && dt_debug "occupancy: $occupancy"
      action=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.action // empty') && dt_debug "action: $action"
      contact=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.contact // empty') && dt_debug "contact: $contact"
      position=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.position // empty') && dt_debug "position: $position"
      state=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.state // empty') && dt_debug "state: $state"
      brightness=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.brightness // empty') && dt_debug "brightness: $brightness"
      color=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.color // empty') && dt_debug "color: $color"
      water_leak=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.water_leak // empty') && dt_debug "water_leak: $water_leak"
      waterleak=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.waterleak // empty') && dt_debug "waterleak: $waterleak"
      temperature=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.temperature // empty') && dt_debug "temperature: $temperature" # 🆙 Fixed typo
      battery=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.battery // empty') && dt_debug "battery: $battery"
              
      device_name="''${topic#zigbee2mqtt/}" && dt_debug "device_name: $device_name"
      dev_room=$(${pkgs.jq}/bin/jq ".\"$device_name\".room" $STATE_DIR/zigbee_devices.json) && dt_debug "dev_room: $dev_room"
      dev_type=$(${pkgs.jq}/bin/jq ".\"$device_name\".type" $STATE_DIR/zigbee_devices.json) && dt_debug "dev_type: $dev_type"     
      dev_id=$(${pkgs.jq}/bin/jq ".\"$device_name\".id" $STATE_DIR/zigbee_devices.json) && dt_debug "dev_id: $dev_id"  
      room="''${dev_room//\"/}"
      should_update() {
        case "$device_name" in
          */set|*/availability)
            return 1
          ;;
          *)
            return 0  
          ;;
        esac
      }

      if should_update; then
        [ -n "$battery" ] && update_device_state "$device_name" "battery" "$battery"
        [ -n "$temperature" ] && update_device_state "$device_name" "temperature" "$temperature"
        [ -n "$state" ] && update_device_state "$device_name" "state" "$state"
        [ -n "$brightness" ] && update_device_state "$device_name" "brightness" "$brightness"
        [ -n "$color" ] && update_device_state "$device_name" "color" "$color"        
        [ -n "$position" ] && update_device_state "$device_name" "position" "$position"
        [ -n "$contact" ] && update_device_state "$device_name" "contact" "$contact"
       fi
     }   

    # 🦆 says ⮞ turn on specified room
    room_lights_on() { 
      local clean_room=$(echo "$1" | sed 's/"//g')
      ${pkgs.jq}/bin/jq -r --arg room "$clean_room" \
        'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' \
        $STATE_DIR/zigbee_devices.json |
        while read -r light_id; do
          mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"state":"ON"}'
        done      
    }
    # 🦆 says ⮞ turn off specified room
    room_lights_off() { 
      local clean_room=$(echo "$1" | sed 's/"//g')
      ${pkgs.jq}/bin/jq -r --arg room "$clean_room" 'to_entries | map(select(.value.room == $room and .value.type == "light")) | .[].value.id' $STATE_DIR/zigbee_devices.json |
        while read -r light_id; do
          mqtt_pub -t "zigbee2mqtt/$light_id/set" -m '{"state":"OFF"}'
        done    
    }
    
    trigram_similarity() {
      local str1="$1"
      local str2="$2"
      declare -a tri1 tri2
      for ((i=0; i<''${#str1}-2; i++)); do
        tri1+=( "''${str1:i:3}" )
      done
      for ((i=0; i<''${#str2}-2; i++)); do
        tri2+=( "''${str2:i:3}" )
      done
      local matches=0
      for t in "''${tri1[@]}"; do
        [[ " ''${tri2[*]} " == *" $t "* ]] && ((matches++))
      done
      local total=$(( ''${#tri1[@]} + ''${#tri2[@]} ))
      (( total == 0 )) && echo 0 && return
      echo $(( 100 * 2 * matches / total ))
    }       
     
    levenshtein_similarity() {
      local a="$1" b="$2"
      local len_a=''${#a} len_b=''${#b}
      local max_len=$(( len_a > len_b ? len_a : len_b ))   
      (( max_len == 0 )) && echo 100 && return     
      local dist=$(levenshtein "$a" "$b")
      local score=$(( 100 - (dist * 100 / max_len) ))         
      [[ "''${a:0:1}" == "''${b:0:1}" ]] && score=$(( score + 10 ))
      echo $(( score > 100 ? 100 : score ))
    }
    
    levenshtein() {
      local a="$1" b="$2"
      local len_a=''${#a} len_b=''${#b}
      [ "$len_a" -eq 0 ] && echo "$len_b" && return
      [ "$len_b" -eq 0 ] && echo "$len_a" && return
      local i j cost
      local -a d  
      for ((i=0; i<=len_a; i++)); do
          d[i*len_b+0]=$i
      done
      for ((j=0; j<=len_b; j++)); do
          d[0*len_b+j]=$j
      done
      for ((i=1; i<=len_a; i++)); do
          for ((j=1; j<=len_b; j++)); do
              [ "''${a:i-1:1}" = "''${b:j-1:1}" ] && cost=0 || cost=1
              del=$(( d[(i-1)*len_b+j] + 1 ))
              ins=$(( d[i*len_b+j-1] + 1 ))
              alt=$(( d[(i-1)*len_b+j-1] + cost ))
              
              min=$del
              [ $ins -lt $min ] && min=$ins
              [ $alt -lt $min ] && min=$alt
              d[i*len_b+j]=$min
          done
      done
      echo ''${d[len_a*len_b+len_b]}
    }
    normalize_string() {
      echo "$1" | 
        iconv -f utf-8 -t ascii//TRANSLIT | 
        tr '[:upper:]' '[:lower:]' |         
        tr -d '[:punct:]' |          
        sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' |  # Trim spaces
        sed -e 's/[[:space:]]+/ /g'          # Normalize spaces
    }    
    
    # 🦆 says ⮞ pure fuzz – Nixified Bash Levenshtein
#    levenshtein() {
#      local str1="$1"
#      local str2="$2"
#      local len1="''${#str1}"
#      local len2="''${#str2}"
#      local i j cost 
#      declare -A matrix  ## ⮜ associative array says 🦆 
      # 🦆 says ⮞ init matrix
#      for ((i=0; i<=len1; i++)); do
#        matrix["''$i,0"]=$i
#      done
#      for ((j=0; j<=len2; j++)); do
#        matrix["0,$j"]=$j
#      done
#      # 🦆 says ⮞ compute distances
#      for ((i=1; i<=len1; i++)); do
#        for ((j=1; j<=len2; j++)); do
#          [[ "''${str1:i-1:1}" == "''${str2:j-1:1}" ]] && cost=0 || cost=1
#          local del=''$((matrix["$((i-1)),$j"] + 1))
#          local ins=$((matrix["$i,$((j-1))"] + 1))
#          local sub=$((matrix["$((i-1)),$((j-1))"] + cost))
#          matrix["$i,$j"]=$(min3 "$del" "$ins" "$sub")
#        done
#      done
#      echo "''${matrix["''$len1,''$len2"]}"
#    }
    min3() {
      printf "%s\n" "$@" | sort -n | head -n1
    }
    # 🦆 duck say ⮞ true bash fuzz
#    levenshtein_similarity() {
#      local a="$1"
#      local b="$2"
#      local dist=$(levenshtein "$a" "$b")
#      local max_len=$(( ''${#a} > ''${#b} ? ''${#a} : ''${#b} ))
#      if [[ ''$max_len -eq 0 ]]; then
#        echo "100"  # Both strings empty
#      else
#        echo $(( 100 - (dist * 100 / max_len) ))
#      fi
#    }
    # 🦆 duck say ⮞ TTS function for when no intent is matched to sentence
    say_no_match() { # 🦆 duck say ⮞ very mature sentences incomin' yo!
      local responses=(
        "Kompis du pratar japanska jag fattar ingenting"
        "Det låter som att du har en köttee bulle i käften. Ät klart middagen och försök sedan igen."
        "eeyyy bruscch öppna käften innan du pratar ja fattar nada ju"
        "men håll käften cp!"
        "noll koll . Golf boll."
        "Ursäkta?"
      )
      # 🦆 duck say ⮞ Pick a random amd text to speech dat shit yo
      local index=$((RANDOM % ''${#responses[@]}))
      say "''${responses[$index]}"
      say_duck "''${responses[$index]}"
      
    }
    tts() {    
      yo-say --text "$1"
    }
    if_voice_say() { 
      if [ "$VOICE_MODE" = "1" ]; then yo-say "$1"; fi
    }    
    confirm() {
      local question="$1"
      yo-say "$question Säg: ja eller nej."
      read -r ask
      ask=$(yo-mic)
      if [[ "$ask" == "ja" ]]; then
        return 0
      elif [[ "$ask" == "nej" ]]; then
        exit 1
      else
        yo-say "Ogiltigt svar brosh. Försök igen."
        confirm "$question"
      fi
    } 
    urlencode() {
        local string="$1"
        local strlen=''${#string}
        local encoded=""
        local pos c o    
        for (( pos=0; pos<strlen; pos++ )); do
            c=''${string:$pos:1}
            case "$c" in
                [-_.~a-zA-Z0-9]) o="$c" ;;
                *) printf -v o '%%%02X' "'$c" ;;
            esac
            encoded+="''${o}"
        done
        echo "$encoded"
    }
    log_failed_input() {
      local sentence="$1"
      local config_dir="/home/${config.this.user.me.name}/.config"
      local wordfile="$config_dir/failed_word_freq.txt"
      local sentencefile="$config_dir/failed_sentence_freq.txt"
      mkdir -p "$config_dir"
      touch "$sentencefile" "$wordfile"  # Ensure files exist
      # 🦆 says ⮞ if failed sentence in sentence file
      if grep -qF -- "$sentence" "$sentencefile" 2>/dev/null; then
        awk -v s="$sentence" -F '\t' 'BEGIN {OFS=FS} 
          $1 == s {$2 += 1} {print}
          ENDFILE {if (!found) print s, 1}' "$sentencefile" > "$sentencefile.tmp" 
        mv "$sentencefile.tmp" "$sentencefile"
      else
        echo -e "$sentence\t1" >> "$sentencefile"
      fi
      # 🦆 says ⮞ normalize & split sentence into wordz
      echo "$sentence" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]' | grep -o '\w\+' |
      while IFS= read -r word; do
        if grep -qF -- "$word" "$wordfile" 2>/dev/null; then
          awk -v w="$word" -F '\t' 'BEGIN {OFS=FS} 
              $1 == w {$2 += 1} {print}' "$wordfile" > "$wordfile.tmp"
          mv "$wordfile.tmp" "$wordfile"
        else
          echo -e "$word\t1" >> "$wordfile"
        fi
      done
    }    
  '';
in { # 🦆 duck say ⮞ import everythang in defined directories
    imports = builtins.map (file: import file {
        inherit self config lib cmdHelpers pkgs sysHosts;
    }) (
        importModulesRecursive ./config ++   # 🦆 duck say ⮞ ++
        importModulesRecursive ./system ++    # 🦆 duck say ⮞ ++
        importModulesRecursive ./security ++   # 🦆 duck say ⮞ ++
        importModulesRecursive ./maintenance ++ # 🦆 duck say ⮞ +++++ plus plus plus rots of duck's give lot'z of luck
        importModulesRecursive ./productivity ++
        importModulesRecursive ./network ++
        importModulesRecursive ./media ++        
        importModulesRecursive ./misc # 🦆 duck say ⮞ enuff enuff dis iz last you have ducks word on dat        
    );} # 🦆 duck say ⮞ bye!
