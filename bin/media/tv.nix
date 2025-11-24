# dotfiles/bin/media/tv.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Android TVOS Controller 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ yo    
  # 🦆 says ⮞ gen json from `config.house.tv`  
  channelsJson = pkgs.writeText "channels.json" (builtins.toJSON (
    lib.mapAttrs (deviceName: deviceConfig: deviceConfig.channels) config.house.tv
  ));  
  tvDevicesJson = pkgs.writeText "tv-devices.json" (builtins.toJSON config.house.tv);

  # 🦆 says ⮞ mqtt is used for tracking channel states on devices
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

  # 🦆 says ⮞ used for season entity lists
  nums = [
    [ "1"  "ett" ]
    [ "2"  "två" ]
    [ "3"  "tre" ]
    [ "4"  "fyra" ]
    [ "5"  "fem" ]
    [ "6"  "sex" ]
    [ "7"  "sju" ]
    [ "8"  "åtta" ]
    [ "9"  "nio" ]
    [ "10" "tio" ]
    [ "11" "elva" ]
    [ "12" "tolv" ]
    [ "13" "tretton" ]
    [ "14" "fjorton" ]
    [ "15" "femton" ]
    [ "16" "sexton" ]
    [ "17" "sjutton" ]
    [ "18" "arton" ]
    [ "19" "nitton" ]
    [ "20" "tjugo" ]
    [ "21" "tjugoett" ]
    [ "22" "tjugotvå" ]
    [ "23" "tjugotre" ]
    [ "24" "tjugofyra" ]
    [ "25" "tjugofem" ]
    [ "26" "tjugosex" ]
    [ "27" "tjugosju" ]
    [ "28" "tjugoåtta" ]
    [ "29" "tjugonio" ]
    [ "30" "trettio" ]
  ];

in {   
   
  yo.scripts.tv = {
    description = "Android TV Controller. Fuzzy search all media types and creates playlist and serves over webserver for casting. Fully conttrollable.";
    category = "🎧 Media Management";
    aliases = [ "remote" ];
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "typ"; description = "Specify the type of command or the media type to search for. Supported commands: on, off, up, down, call, favorites, add. Media Types: tv, movie, livetv, podcast, news, music, song, musicvideo, jukebox (random music), othervideo, youtube, nav_up, nav_down, nav_left, nav_right, nav_select, nav_menu, nav_back"; default = "tv"; optional = true; values = [ "on" "off" "up" "down" "next" "prev" "call" "favorites" "add" "tv" "movie" "livetv" "podcast" "news" "music" "song" "musicvideo" "jukebox" "othervideo" "youtube" "nav_up" "nav_down" "nav_left" "nav_right" "nav_select" "nav_menu" "nav_back" "channel_up" "channel_down" ]; }
      { name = "search"; type = "string"; description = "Media to search"; optional = true; }
      { name = "device"; description = "Device IP to play on"; default = "192.168.1.223"; }
      { name = "season"; type = "string"; description = "Specific season to play"; optional = true; }
      { name = "shuffle"; type = "bool"; description = "Shuffle Toggle, true or false"; default = true; }
      { name = "tvshowsDir"; type = "path"; description = "TV shows directory"; default = "/Pool/TV"; }
      { name = "moviesDir"; type = "path"; description = "Movies directory"; default = "/Pool/Movies"; }
      { name = "musicDir"; type = "path"; description = "Music directory"; default = "/Pool/Music"; }
      { name = "musicvideoDir"; type = "path"; description = "Music videos directory"; default = "/Pool/Music_Videos"; }      
      { name = "videosDir"; type = "path"; description = "Other videos directory"; default = "/Pool/Other_Videos"; }
      { name = "podcastDir"; type = "path"; description = "Podcasts directory"; default = "/Pool/Podcasts"; }
      { name = "audiobookDir"; type = "path"; description = "Audiobooks directory"; default = "/Pool/Audiobooks"; }
      { name = "youtubeAPIkeyFile"; type = "path"; description = "File containing YouTube API key"; default = config.sops.secrets.youtube_api_key.path; }
      { name = "webserver"; type = "path"; description = "File containing webserver URL that stores media"; default = config.sops.secrets.webserver.path; }     
      { name = "defaultPlaylist"; description = "Default playlist path"; default = "/Pool/playlist.m3u"; }
      { name = "favoritesPlaylist"; description = "File path for Favouyrites tagged entries"; default = "/Pool/favorites.m3u"; }      
      { name = "max_items"; type = "int"; description = "Set a maximum number of items in playlist"; default = 200; }       
      { name = "mqttUser"; type = "string"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "mqttPWFile"; type = "path"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
    ];
    code = ''
      ${cmdHelpers}
      MQTT_BROKER="${mqttHostip}" && dt_debug "$MQTT_BROKER"
      MQTT_USER="$mqttUser" && dt_debug "$MQTT_USER"
      MQTT_PASSWORD=$(cat "$mqttPWFile")
      media_type="$typ"
      media_search="$search"
      DEVICE="$device"
      TVDIR="$tvshowsDir"
      MOVIEDIR="$moviesDir"
      MUSICDIR="$musicDir"
      MUSICVIDEODIR="$musicvideoDir"
      VIDEOSDIR="$videosDir"
      PODCASTDIR="$podcastDir"
      AUDIOBOOKDIR="$audiobookDir"
      SHUFFLE="$shuffle"
      MAX_ITEMS="$max_items"
      playlist_file="$defaultPlaylist"
      WEBSERVER=$(cat $webserver)
      PLAYLIST_SAVE_PATH="$playlist_file"
      FAVORITES_PATH="$favoritesPlaylist"
      FAVORITES="$WEBSERVER/favorites.m3u"
      INTRO_URL="$WEBSERVER/intro.mp4"
      # 🦆 says ⮞ load TV devices & channels
      CHANNELS_JSON="${channelsJson}"
      TV_DEVICES_JSON=${tvDevicesJson}
  
      declare -A SEARCH_FOLDERS=(
          [tv]="$TVDIR"
          [podcast]="$PODCASTDIR"
          [movie]="$MOVIEDIR"
          [audiobook]="$AUDIOBOOKDIR"
          [musicvideo]="$MUSICVIDEODIR"
          [music]="$MUSICDIR"
          [jukebox]="$MUSICDIR"
          [song]="$MUSICDIR"          
          [othervideo]="$VIDEOSDIR"
      )
      debug_navigation_step() {
         local step="$1"
         dt_debug "Navigation step: $step"
         local current_activity=$(get_current_activity)
         dt_debug "Current activity after '$step': $current_activity"
      }

      control_device() {
        local device_ip="$1"
        local action="$2"
        declare -A key_events=(
          [power_off]="KEYCODE_SLEEP"
          [power_on]="KEYCODE_WAKEUP"
          [play_pause]="KEYCODE_MEDIA_PLAY_PAUSE"
          [next]="KEYCODE_MEDIA_NEXT"
          [previous]="KEYCODE_MEDIA_PREVIOUS"
          [volume_up]="KEYCODE_VOLUME_UP"
          [volume_down]="KEYCODE_VOLUME_DOWN"
          [channel_up]="KEYCODE_CHANNEL_UP"
          [channel_down]="KEYCODE_CHANNEL_DOWN"
          # 🦆 says ⮞ navigation
          [nav_up]="KEYCODE_DPAD_UP"
          [nav_down]="KEYCODE_DPAD_DOWN"
          [nav_left]="KEYCODE_DPAD_LEFT"
          [nav_right]="KEYCODE_DPAD_RIGHT"
          [nav_select]="KEYCODE_DPAD_CENTER"
          [nav_back]="KEYCODE_BACK"
          [nav_home]="KEYCODE_HOME"
          [nav_menu]="KEYCODE_MENU"
          [nav_recents]="KEYCODE_APP_SWITCH"       
        )

        # 🦆 says ⮞ get current activity
        get_current_activity() {
          adb -s "$device_ip" shell "dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp' | grep -oP '[^/]+/[^ ]+' | head -1" 2>/dev/null || echo ""
        }

        # 🦆 says ⮞ dynamic app opener from Nix config
        open_app() {
          local app_key="$1"
          local current_activity=$(get_current_activity)
          local target_activity=$(get_device_app_activity "$device_ip" "$app_key")    
          if [[ -z "$target_activity" ]]; then
            dt_error "App '$app_key' not found in device configuration"
            return 1
          fi
          # 🦆 says ⮞ check if already running
          if [[ "$current_activity" == "$target_activity" ]]; then
            dt_debug "App $app_key is already the current activity: $current_activity"
            return 0
          fi

          dt_debug "Opening app $app_key: $target_activity (current: $current_activity)"
          adb -s "$device_ip" shell am start -n "$target_activity"
          return $?
        }

        # 🦆 says ⮞ get app activity from device config
        get_device_app_activity() {
          local device_ip="$1"
          local app_key="$2"
          ${pkgs.jq}/bin/jq -r --arg ip "$device_ip" --arg app "$app_key" '
            .[] | select(.ip == $ip) | .apps[$app] // empty
          ' "$TV_DEVICES_JSON"
        }

        case "$action" in
          find_remote)
            adb -s "$device_ip" shell am start -a android.intent.action.VIEW -n com.nvidia.remotelocator/.ShieldRemoteLocatorActivity
            ;;
          open_*)
            # 🦆 says ⮞ dynamic app opening - extract app key from action (open_tv4 -> tv4)
            local app_key="''${action#open_}"
            open_app "$app_key"
            ;;
          *)
            local key_event="''${key_events[$action]}"
            if [[ -z "$key_event" ]]; then
              echo "Unknown action: $action"
              echo "Available actions: ''${!key_events[@]} find_remote open_*"
              return 1
            fi
            adb -s "$device_ip" shell input keyevent "$key_event"
            ;;
        esac
      }

      generate_playlist() {
          local dir="$1"
          local media_type="$2"
          local base_dir="''${SEARCH_FOLDERS[$media_type]}"
          local folder_name="''${base_dir##*/}"
          local relative_path="''${dir#$base_dir/}"
          echo "#EXTM3U" > "$PLAYLIST_SAVE_PATH"
          echo "$INTRO_URL" >> "$PLAYLIST_SAVE_PATH"
    
          local temp_file=$(mktemp)
          find "''${dir}" -type f ! \
              \( -iname "*.nfo" -o \
                 -iname "*.png" -o \
                 -iname "*.gif" -o \
                 -iname "*.m3u" -o \
                 -iname "*.jpg" -o \
                 -iname "*.jpeg" \) > "$temp_file"
    
          if [[ "$SHUFFLE" == "true" ]]; then
              shuf "$temp_file" --output="$temp_file"
              dt_debug "Shuffled playlist contents"
          fi

          while IFS= read -r file; do
              local rel_file="''${file#$base_dir/}"
              echo "''${WEBSERVER}/''${folder_name}/''${rel_file// /%20}" >> "$PLAYLIST_SAVE_PATH"
          done < "$temp_file"
    
          rm "$temp_file"
          dt_info "Playlist generated: $PLAYLIST_SAVE_PATH (shuffle: $SHUFFLE)"
      }
      play_favorites() {
          local device_ip="$1"
          local playlist_url="$FAVORITES"
          control_device "$device_ip" power_on
          local command="am start -a android.intent.action.VIEW -d \"''${playlist_url}\" -t \"audio/x-mpegurl\""
          if adb -s "''${device_ip}" shell "''${command}" &> /dev/null; then
              dt_debug "Started playing favorites on device ''${device_ip}"
          else
              adb disconnect ''${device_ip}
              sleep 0.2
              adb connect ''${device_ip}
              sleep 0.1
              if (( retries < max_retries )); then
                dt_debug "Retrying start_playlist (''${retries}/''${max_retries})..."
                start_playlist "$device_ip" $((retries + 1))
              else
                dt_error "Max retries reached. Could not start playlist on ''${device_ip}"
              fi
          fi
      }
      start_playlist() {
          local device_ip="$1"
          local playlist_url="$WEBSERVER/playlist.m3u"
          control_device "$device_ip" power_on
          local retries="''${2:-0}"
#          local command="am start -a android.intent.action.VIEW -d \"''${playlist_url}\" -t \"audio/x-mpegurl\""
          local command="am start -a android.intent.action.VIEW -d \"''${playlist_url}\" \
            --ez \"extra_force_software\" true \
            -t \"audio/x-mpegurl\""

          if adb -s "''${device_ip}" shell "''${command}" &> /dev/null; then
              dt_debug "Playlist started successfully on device ''${device_ip}"
          else
              adb disconnect ''${device_ip}
              sleep 0.2
              adb connect ''${device_ip}
              sleep 0.1
              if (( retries < max_retries )); then
                dt_debug "Retrying start_playlist (''${retries}/''${max_retries})..."
                start_playlist "$device_ip" $((retries + 1))
              else
                dt_error "Max retries reached. Could not start playlist on ''${device_ip}"
              fi
          fi
      }
                  
      template_single_path() {
          local path="$1"
          local media_type="$2"
          local base_path="''${SEARCH_FOLDERS[$media_type]}" 
          base_path="''${base_path%/}"
          local folder_name=$(basename "$base_path")
          local relative_path="''${path#$base_path/}"
          relative_path="''${relative_path#$base_path}"
          relative_path="''${relative_path#/}"
          local encoded_path=""
          IFS='/' read -ra parts <<< "$relative_path"
          for part in "''${parts[@]}"; do
              encoded_path+="/$(urlencode "$part")"
          done
          encoded_path="''${encoded_path#/}"

          echo "''${WEBSERVER}/$folder_name/$encoded_path"
      }
    
      fuzzy_match_files() {
          local dir="$1"
          local search="$2"
          shift 2
          local exts=("$@")     
          local normalized_search
          normalized_search=$(normalize_string "$search")
          local -a results
          local find_cmd="find \"$dir\" -type f"
          if [ ''${#exts[@]} -gt 0 ]; then
              find_cmd+=" \("
              for ext in "''${exts[@]}"; do
                  find_cmd+=" -iname \"$ext\" -o"
              done
              find_cmd=''${find_cmd% -o}  # Remove last -o
              find_cmd+=" \)"
          fi
          find_cmd+=" -print0"

          # 🦆 says ⮞ process filez
          while IFS= read -r -d $'\0' file; do
              local filename=$(basename "$file")
              local base_name="''${filename%.*}"
              local normalized_item
              normalized_item=$(normalize_string "$base_name") 
              local tri_score lev_score combined_score
              tri_score=$(trigram_similarity "$normalized_search" "$normalized_item")
              lev_score=$(levenshtein_similarity "$normalized_search" "$normalized_item")
              combined_score=$(( (lev_score * 80 + tri_score * 20) / 100 ))
              results+=("$combined_score:$file:$base_name")
          done < <(eval "$find_cmd")
          # 🦆 says ⮞ sort by match % and select da top 3 yo
          IFS=$'\n' sorted=($(printf "%s\n" "''${results[@]}" | sort -t':' -k1 -nr | head -n 3))
          unset IFS  
          printf "%s\n" "''${sorted[@]}"
      }
      # 🦆 says ⮞ play youtube video yo
      play_youtube_video() {
          local device_ip="$1"
          local video_url="$2"
          if adb -s "$device_ip" shell "am start -a android.intent.action.VIEW -d \"$video_url\" com.google.android.youtube.tv" &> /dev/null; then
              dt_debug "Started YouTube successfully on device ''${device_ip}"
          else
              dt_error "Failed to start YouTube on device ''${device_ip}"
          fi          
      }
      
      # 🦆 says ⮞ search 4 youtube video yo
      search_youtube() {
          local query="$1"
          local api_key_file="$2"
          if [[ ! -f "$api_key_file" ]]; then
              dt_error "YouTube API key file not found: $api_key_file"
              return 1
          fi
          local api_key
          api_key=$(<"$api_key_file")
          local encoded_query
          encoded_query=$(urlencode "$query")
          local url="https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=5&q=$encoded_query&key=$api_key"
          local response
          response=$(curl -s -w "%{http_code}" "$url")
          local status_code="''${response: -3}"
          local content="''${response%???}" 
          if [[ "$status_code" != "200" ]]; then
              dt_error "YouTube API request failed. Status: $status_code"
              return 1
          fi  
          local video_id title
          video_id=$(echo "$content" | jq -r '.items[0].id.videoId // empty')
          title=$(echo "$content" | jq -r '.items[0].snippet.title // empty')
          if [[ -z "$video_id" ]]; then
              dt_error "No YouTube videos found for: $query"
              return 1
          fi
          echo "https://www.youtube.com/watch?v=$video_id"
          echo "$title"
          return 0
      }

      # 🦆 says ⮞ get channel info for a specific device
      get_channel_info() {
          local device_ip="$1"
          local channel_id="$2"
          ${pkgs.jq}/bin/jq -r --arg ip "$device_ip" --arg id "$channel_id" '
              .[] | select(.ip == $ip) | .channels[$id] // empty | 
              {id: $id, name: .name, cmd: (.cmd // ""), stream_url: (.stream_url // "")}
          ' "$TV_DEVICES_JSON"
      }

      # 🦆 says ⮞ get device channels 
      get_device_channels() {
        local device_ip="$1"
        ${pkgs.jq}/bin/jq -r --arg ip "$device_ip" '
          .[] | select(.ip == $ip) | .channels | keys[]?
        ' "$TV_DEVICES_JSON"
      }

      # 🦆 says ⮞ play live TV
      verify_channel_change() {
          local device_ip="$1"
          local expected_channel="$2"
          local max_wait=15
          local wait_time=0    
          dt_debug "Verifying channel change to $expected_channel..." 
          while (( wait_time < max_wait )); do
              # 🦆 says ⮞ method 1 check current TV input state
              local tv_state=$(adb -s "$device_ip" shell "dumpsys tv_input | grep -i 'current' 2>/dev/null" || true)
              if [[ -n "$tv_state" ]]; then
                  dt_debug "TV input state: $tv_state"
              fi   
              # 🦆 says ⮞ method 2 check media session for channel info
              local media_info=$(adb -s "$device_ip" shell "dumpsys media_session | grep -i -A5 -B5 'channel\|title' 2>/dev/null" | head -20 || true)
              if [[ -n "$media_info" ]] && echo "$media_info" | grep -q -i "channel.*$expected_channel\|$expected_channel"; then
                  dt_debug "Channel change verified via media session"
                  return 0
              fi      
              # 🦆 says ⮞ method 3 check for specific app activities
              local current_app=$(adb -s "$device_ip" shell "dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp' 2>/dev/null" || true)
              if [[ -n "$current_app" ]] && echo "$current_app" | grep -q -i "telenor\|tv4\|live.tv"; then
                  dt_debug "TV app is active: $current_app"
              fi        
              # 🦆 says ⮞ method 4 take screenshot and check for channel indicators
              if (( wait_time > 5 )); then
                  check_screenshot_for_channel "$device_ip" "$expected_channel" && return 0
              fi   
              sleep 2
              ((wait_time+=2))
          done   
          dt_debug "Channel verification timeout, proceeding anyway"
          return 0
      }

      check_screenshot_for_channel() {
          local device_ip="$1"
          local expected_channel="$2"
          return 0
          # 🦆 TODO ⮞ logic....
      }   

      get_current_channel() {
          local device_ip="$1"
          channel=$(ssh ${mqttHost} cat /var/lib/zigduck/state.json | jq -r ".\"tv_$device_ip\".current_channel // empty")
          echo "$channel"
      }

      get_channel_name() {
          local device_ip="$1"
          local channel_id="$2"
          get_channel_info "$device_ip" "$channel_id" | jq -r '.name // empty'
      }
    
      publish_channel_state() {
          local device_ip="$1"
          local channel_id="$2"
          local channel_name="$3"    
          local topic="zigbee2mqtt/tv/''${device_ip}/channel"
          local payload="{\"channel_id\":\"$channel_id\",\"channel_name\":\"$channel_name\",\"timestamp\":\"$(date -Iseconds)\"}"
          mqtt_pub -t "$topic" -m "$payload"
          dt_debug "Published channel state: $channel_name ($channel_id) on $device_ip"
      }

      # 🦆 says ⮞ smart channel navigation with state tracking
      smart_channel_navigate() {
          local device_ip="$1"
          local direction="$2" 
          # 🦆 says ⮞ step 1
          local current_channel=$(get_current_channel "$device_ip")
          local current_channel_name=$(get_channel_name "$device_ip" "$current_channel")    
          dt_debug "Current channel: $current_channel ($current_channel_name)"   
          if [[ -z "$current_channel" ]]; then
              dt_error "Could not determine current channel, using simple channel_$direction"
              control_device "$device_ip" "channel_$direction"
              return 0
          fi    
          # 🦆 says ⮞ step 2
          control_device "$device_ip" "channel_$direction"
          sleep 2 
          # 🦆 says ⮞ step 3
          local channel_list=$(get_device_channels "$device_ip" | sort -n)
          local channels=()
          while IFS= read -r channel; do
              [[ -n "$channel" ]] && channels+=("$channel")
          done <<< "$channel_list"
          if [[ ''${#channels[@]} -eq 0 ]]; then
              dt_error "No channels available for device $device_ip"
              return 0
          fi
          # 🦆 says ⮞ find current channel index
          local current_index=-1
          for i in "''${!channels[@]}"; do
              if [[ "''${channels[$i]}" == "$current_channel" ]]; then
                  current_index=$i
                  break
              fi
          done    
          if [[ $current_index -eq -1 ]]; then
              dt_debug "Current channel $current_channel not in channel list, using first channel"
              current_index=0
          fi    
          # 🦆 says ⮞ calculate new channel index
          local new_index
          if [[ "$direction" == "up" ]]; then
              new_index=$(( (current_index + 1) % ''${#channels[@]} ))
          else
              new_index=$(( (current_index - 1 + ''${#channels[@]}) % ''${#channels[@]} ))
          fi   
          local new_channel="''${channels[$new_index]}"
          local new_channel_info=$(get_channel_info "$device_ip" "$new_channel")
          local new_channel_name=$(echo "$new_channel_info" | jq -r '.name')  
          dt_debug "Channel $direction: $current_channel -> $new_channel ($new_channel_name)"  
          # 🦆 says ⮞ step 4
          publish_channel_state "$device_ip" "$new_channel" "$new_channel_name"
          # 🦆 says ⮞ announce the new channel
          yo say "Kanal $new_channel, $new_channel_name"
      }
  
      # 🦆 says ⮞ play live TV    
      start_channel() {
          local device_ip="$1"
          local channel_id="$2"
          dt_debug "Using start_channel function for channel $channel_id on $device_ip"
          # 🦆 says ⮞ ensure ADB connection
          adb connect "$device_ip" >/dev/null 2>&1
          sleep 0.5
          # 🦆 says ⮞ clear any existing input first
          adb -s "$device_ip" shell input keyevent KEYCODE_CLEAR
          sleep 0.3   
          # 🦆 says ⮞ type each digit separately with better timing
          for (( i=0; i<''${#channel_id}; i++ )); do
              digit="''${channel_id:$i:1}"
              dt_debug "Inputting digit: $digit"
              adb -s "$device_ip" shell "input text \"$digit\""
              sleep 0.3  # 🦆 says ⮞ increased delay for reliability
          done  
          sleep 1.5    
          # 🦆 says ⮞ send ENTER twice for redundancy
          adb -s "$device_ip" shell "input keyevent KEYCODE_ENTER"
          sleep 0.5
          # adb -s "$device_ip" shell "input keyevent KEYCODE_ENTER"   
          dt_debug "Channel $channel_id input completed"
      }

      play_livetv_channel() {
          local device_ip="$1"
          local channel_id="$2"
          local channel_info=$(get_channel_info "$device_ip" "$channel_id")
          local channel_name=$(echo "$channel_info" | jq -r '.name')
          local channel_cmd=$(echo "$channel_info" | jq -r '.cmd')
          local stream_url=$(echo "$channel_info" | jq -r '.stream_url')
          dt_debug "Playing channel $channel_id: $channel_name on $device_ip"
          dt_debug "Channel cmd: $channel_cmd, stream_url: $stream_url"
          yo say "Spelar kanal $channel_id, $channel_name"
          # 🦆 says ⮞ ensure device is on and connected
          control_device "$device_ip" power_on
          sleep 5
          # 🦆 says ⮞ get current activity once at the start
          get_current_activity() {
              adb -s "$device_ip" shell "dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp' | grep -oP '[^/]+/[^ ]+' | head -1" 2>/dev/null || echo ""
          }    
          local current_activity=$(get_current_activity)
          dt_debug "Current activity: $current_activity"
          # 🦆 says ⮞ check if app is already active
          is_app_active() {
              local app_key="$1"
              local target_activity=$(get_device_app_activity "$device_ip" "$app_key")
              if [[ -n "$target_activity" && "$current_activity" == "$target_activity" ]]; then
                  dt_debug "App $app_key is already active: $current_activity"
                  return 0
              fi
              return 1
          }

          # 🦆 says ⮞ custom command sequence if defined
          if [[ -n "$channel_cmd" && "$channel_cmd" != "null" ]]; then
              dt_debug "Using custom channel command: $channel_cmd"
              # 🦆 says ⮞ split command by && and execute each part
              IFS='&&' read -ra commands <<< "$channel_cmd"
              local skip_next_open=false        
              for cmd in "''${commands[@]}"; do
                  trimmed_cmd=$(echo "$cmd" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                  if [[ -n "$trimmed_cmd" ]]; then
                      # 🦆 says ⮞ check if we should skip this open command
                      if [[ "$skip_next_open" == true && "$trimmed_cmd" =~ ^open_ ]]; then
                          dt_debug "Skipping $trimmed_cmd - app already active"
                          skip_next_open=false
                          continue
                      fi          
                      # 🦆 says ⮞ if wait - plx be chillin' yo
                      if [[ "$trimmed_cmd" =~ ^wait[[:space:]]+([0-9]+)$ ]]; then
                          local wait_seconds="''${BASH_REMATCH[1]}"
                          dt_debug "Waiting $wait_seconds seconds"
                          sleep "$wait_seconds"     
                      # 🦆 says ⮞ handle start_channel_X commands
                      elif [[ "$trimmed_cmd" =~ ^start_channel_([0-9]+)$ ]]; then
                          local target_channel="''${BASH_REMATCH[1]}"
                          dt_debug "Starting channel $target_channel via start_channel function"    
                          # 🦆 says ⮞ extra wait before channel input for app readiness
                          sleep 3
                          start_channel "$device_ip" "$target_channel"
                          sleep 2       
                      # 🦆 says ⮞ handle open_* commands with activity check
                      elif [[ "$trimmed_cmd" =~ ^open_([a-zA-Z0-9_]+)$ ]]; then
                          local app_key="''${BASH_REMATCH[1]}"
                          if is_app_active "$app_key"; then
                              dt_debug "App $app_key already active, skipping open command"
                              skip_next_open=true
                          else
                              dt_debug "Executing: $trimmed_cmd"
                              debug_navigation_step "$trimmed_cmd"
                              control_device "$device_ip" "$trimmed_cmd"
                              sleep 2
                              current_activity=$(get_current_activity)
                          fi
                
                      else
                          # 🦆 says ⮞ use friendly command names dawg
                          dt_debug "Executing: $trimmed_cmd"
                          control_device "$device_ip" "$trimmed_cmd"
                          sleep 2
                          if [[ "$trimmed_cmd" =~ ^nav_ ]]; then
                              current_activity=$(get_current_activity)
                          fi
                      fi
                  fi
              done
    
          # 🦆 says ⮞ if set, use stream URL
          elif [[ -n "$stream_url" && "$stream_url" != "null" ]]; then
              dt_debug "Using stream URL: $stream_url"
              adb -s "$device_ip" shell "am start -a android.intent.action.VIEW -d \"$stream_url\""
    
          else
              # 🦆 says ⮞ default channel behavior - input channel number
              dt_debug "Using default channel behavior for $channel_id"
              # 🦆 says ⮞ type each digit separately for better reliability
              for (( i=0; i<''${#channel_id}; i++ )); do
                  digit="''${channel_id:$i:1}"
                  adb -s "$device_ip" shell "input text \"$digit\""
                  sleep 0.2
              done
              sleep 1
              adb -s "$device_ip" shell "input keyevent KEYCODE_ENTER"
          fi
    
          # verify_channel_change "$device_ip" "$channel_id"
          publish_channel_state "$device_ip" "$channel_id" "$channel_name"
      }
          
      # 🦆 says ⮞ handle different media types
      matched_media=""
      case "$media_type" in
              
        tv)
            search_dir="$TVDIR"
            if [[ -n "$season" ]]; then
                # 🦆 says ⮞ season provided - turn off shuffle
                SHUFFLE="false"
                dt_debug "Season specified: $season - shuffle disabled"
                
                # 🦆 says ⮞ search for season folders within the show
                items=()
                while IFS= read -r -d $'\0' item; do
                    items+=("$(basename "$item")")
                done < <(find "$search_dir" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)
                
                best_score=0
                best_match=""
                normalized_search=$(normalize_string "$media_search")
                
                for item in "''${items[@]}"; do
                    normalized_item=$(normalize_string "$item")
                    [[ -z "$normalized_search" || -z "$normalized_item" ]] && continue        
                    tri_score=$(trigram_similarity "$normalized_search" "$normalized_item")
                    lev_score=$(levenshtein_similarity "$normalized_search" "$normalized_item")
                    combined_score=$(( (lev_score * 80 + tri_score * 20) / 100 ))
                    
                    if (( combined_score > best_score )); then
                        best_score=$combined_score
                        best_match="$item"
                    fi
                done
                
                if (( best_score >= 30 )); then
                    matched_media="$best_match"
                    # 🦆 says ⮞ now search for season within the matched show
                    season_patterns=(
                        "Season $season"
                        "Season $(printf "%02d" "$season")"
                        "S$(printf "%02d" "$season")"
                        "s$(printf "%02d" "$season")"
                    )
                    
                    season_path=""
                    for pattern in "''${season_patterns[@]}"; do
                        candidate="$search_dir/$matched_media/$pattern"
                        if [[ -d "$candidate" ]]; then
                            season_path="$candidate"
                            dt_debug "Found season folder: $season_path"
                            break
                        fi
                    done
                    
                    if [[ -n "$season_path" ]]; then
                        FULL_PATH="$season_path"
                        yo say "Spelar säsong $season av $matched_media"
                        generate_playlist "$FULL_PATH" "$media_type"
                        start_playlist "$DEVICE"
                    else
                        dt_error "Season $season not found for $matched_media"
                        yo say "Kunde inte hitta säsong $season för $matched_media"
                        exit 1
                    fi
                else
                    dt_error "No TV show found matching: $media_search"
                    exit 1
                fi
            else
                # 🦆 says ⮞ existing behavior when no season specified
                items=()
                while IFS= read -r -d $'\0' item; do
                    items+=("$(basename "$item")")
                done < <(find "$search_dir" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)
                
                best_score=0
                best_match=""
                normalized_search=$(normalize_string "$media_search")
                
                for item in "''${items[@]}"; do
                    normalized_item=$(normalize_string "$item")
                    [[ -z "$normalized_search" || -z "$normalized_item" ]] && continue        
                    tri_score=$(trigram_similarity "$normalized_search" "$normalized_item")
                    lev_score=$(levenshtein_similarity "$normalized_search" "$normalized_item")
                    combined_score=$(( (lev_score * 80 + tri_score * 20) / 100 ))
                    
                    if (( combined_score > best_score )); then
                        best_score=$combined_score
                        best_match="$item"
                    fi
                done
                
                if (( best_score >= 30 )); then
                    matched_media="$best_match"
                    FULL_PATH="$search_dir/$matched_media"
                    yo say "Spelar TV-serien $matched_media"
                else
                    dt_error "No TV show found matching: $media_search"
                    exit 1
                fi
            fi
            ;;
             
        # 🦆 says ⮞ directory based searchez
        podcast|movie|audiobook|musicvideo|music)
          case "$media_type" in
            podcast)   search_dir="$PODCASTDIR" ;;
            movie)     search_dir="$MOVIEDIR" ;;
            audiobook) search_dir="$AUDIOBOOKDIR" ;;
            musicvideo) search_dir="$MUSICVIDEODIR" ;;
            music) search_dir="$MUSICDIR" ;;
            livetv) search_dir="$MUSICDIR" ;;            
          esac
          
          dt_debug "Searching in $search_dir for $media_search"
          items=()
          while IFS= read -r -d $'\0' item; do
              items+=("$(basename "$item")")
          done < <(find "$search_dir" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)
          
          best_score=0
          best_match=""
          normalized_search=$(normalize_string "$media_search")
          
          for item in "''${items[@]}"; do
              normalized_item=$(normalize_string "$item")
              [[ -z "$normalized_search" || -z "$normalized_item" ]] && continue        
              tri_score=$(trigram_similarity "$normalized_search" "$normalized_item")
              lev_score=$(levenshtein_similarity "$normalized_search" "$normalized_item")
              combined_score=$(( (lev_score * 80 + tri_score * 20) / 100 ))
              dt_debug "Fuzzy matching: $search > $item"
              if (( combined_score > best_score )); then
                  best_score=$combined_score
                  best_match="$item"
                  dt_debug "New best match: $best_match"
              fi
          done
          
          if (( best_score >= 30 )); then
              matched_media="$best_match"
              case "$media_type" in
              livetv)   type_desc="Live TV channels" ;;
              tv)       type_desc="TV-serien" ;;
              movie)    type_desc="filmen" ;;
              music)    type_desc="musik artisten" ;;
              song)     type_desc="musik låten" ;;
              podcast)  type_desc="podden" ;;
              audiobook) type_desc="ljudboken" ;;
              jukebox)  type_desc="Slumpad musik mix" ;;
              musicvideo) type_desc="musikvideon" ;;
              playlist) type_desc="spellistan" ;;
              *)        type_desc="$media_type" ;;
            esac
            yo say "Spelar upp $type_desc ''${matched_media//./ }"
            
          else
              for item in "''${items[@]}"; do
                  normalized_item=$(normalize_string "$item")
                  if [[ "$normalized_item" == *"$normalized_search"* ]]; then
                      matched_media="$item"
                      break
                  fi
              done
          fi
          ;;

      # 🦆 says ⮞ file based searchez - like song etc, yo!  
      song|othervideo)
          case "$media_type" in
            song) # 🦆 says ⮞ search 4 music song yo
              search_dir="$MUSICDIR"
              extensions=("*.mp3" "*.flac" "*.m4a" "*.wav")
              ;; 
            othervideo) # 🦆 says ⮞ other videos not categorized elsewhere
              search_dir="$VIDEOSDIR"
              extensions=("*.mp4" "*.mkv" "*.avi" "*.mov")
              ;;
          esac
      
          # 🦆 says ⮞ get matches yo
          matches=()
          while IFS= read -r line; do
              matches+=("$line")
          done < <(fuzzy_match_files "$search_dir" "$media_search" "''${extensions[@]}" 2>/dev/null)
      
          if (( ''${#matches[@]} > 0 )); then
              echo "#EXTM3U" > "$PLAYLIST_SAVE_PATH"
              echo "$INTRO_URL" >> "$PLAYLIST_SAVE_PATH"    
              # 🦆 says ⮞ add top matchez
              for match in "''${matches[@]}"; do
                  IFS=':' read -r _ full_path base_name <<< "$match"
                  url=$(template_single_path "$full_path" "$media_type")
                  echo "$url" >> "$PLAYLIST_SAVE_PATH"
              done
      
              yo say "Spelar upp de bästa matcherna för $media_search"
              start_playlist "$DEVICE"
              exit 0
          else
              dt_error "Inga filer hittades för $media_search"
              exit 1
          fi
          ;; 
        jukebox) # 🦆 says ⮞ shuffled randomized music
          matched_media="shuffle"
          yo say "Spelar slumpad musik"
          ;; 
        favorites) # 🦆 says ⮞ play favourite music playlist 
          play_favorites
          ;; 
        add) # 🦆 says ⮞ save track to favorites 
          current_track=$(adb -s $DEVICE:5555 shell dumpsys media_session | grep -oP 'description=\K[^,]+' | head -n 1)
          if grep -qF "$current_track" "$FAVORITES_PATH"; then
            yo say "Låten finns redan i dina favoriter"
          else 
            echo "$current_track" >> "$FAVORITES_PATH"
            dt_info "$current_track har lagts till i dina favoriter"
            yo say "$current_track har lagts till i dina favoriter"
            exit 0
          fi  
          ;;   
        next) # 🦆 says ⮞ next track   
          dt_debug "Next track .."
          control_device "$DEVICE" next
          exit 0
          ;;  
        previous) # 🦆 says ⮞ previous track    
          dt_debug "Previous track .."
          control_device "$DEVICE" previous
          exit 0
          ;;  
        pause|play) # 🦆 says ⮞ pause/play command
          dt_debug "Pause/Play .."
          control_device "$DEVICE" play_pause
          exit 0
          ;; 
        down) # 🦆 says ⮞ volume down     
          dt_debug "Lowering volume.."
          control_device "$DEVICE" volume_down && control_device "$DEVICE" volume_down && control_device "$DEVICE" volume_down
          exit 0
          ;;     
        up) # 🦆 says ⮞ volume up 
          dt_debug "Volume up.."
          control_device "$DEVICE" volume_up && control_device "$DEVICE" volume_up
          exit 0
          ;;
        channel_up) # 🦆 says ⮞ channel up     
          dt_debug "Smart channel up.."
          smart_channel_navigate "$DEVICE" "up"
          exit 0
          ;;     
        channel_down) # 🦆 says ⮞ channel down 
          dt_debug "Smart channel down.."
          smart_channel_navigate "$DEVICE" "down"
          exit 0
          ;; 
        news) # 🦆 says ⮞ newz, handled externally by yo news  
          dt_debug "Playing news"
          yo-news
          exit 0
          ;;     
        youtube) # 🦆 says ⮞ play youtube videoz yo      
          dt_debug "Playing YouTube"
          video_info=$(search_youtube "$media_search" "$youtubeAPIkeyFile")
          if [[ $? -eq 0 ]]; then
            video_url=$(echo "$video_info" | head -1)
            video_title=$(echo "$video_info" | tail -1)
            dt_info "Playing YouTube video: $video_title"
            play_youtube_video "$DEVICE" "$video_url"
            say "Spelar YouTube videon $video_title"
          else
            dt_error "YouTube search failed"
          fi
          exit 0
          ;; 
        livetv) 
            device_channels=$(get_device_channels "$DEVICE")
            channel_id=""
    
            if [[ -n "$media_search" ]]; then
                if [[ "$media_search" =~ ^[0-9]+$ ]] && echo "$device_channels" | grep -q "$media_search"; then
                    channel_id="$media_search"
                else
                    # 🦆 says ⮞ fuzzy search channel names available on this device
                    normalized_search=$(normalize_string "$media_search")
                    for id in $device_channels; do
                        channel_info=$(get_channel_info "$DEVICE" "$id")
                        channel_name=$(echo "$channel_info" | jq -r '.name')
                        normalized_name=$(normalize_string "$channel_name") 
                        if [[ "$normalized_name" == *"$normalized_search"* ]]; then
                            channel_id="$id"
                            break
                        fi
                    done
                fi

                if [ -n "$channel_id" ]; then
                    play_livetv_channel "$DEVICE" "$channel_id"
                    channel_info=$(get_channel_info "$DEVICE" "$channel_id")
                    channel_name=$(echo "$channel_info" | jq -r '.name')
                    # 🦆 says ⮞ show & tell what's playing on that channel
                    yo tv-guide --channel "$channel_id"
                else
                    dt_error "Kanal hittades inte eller är inte tillgänglig på denna TV: $media_search"
                    yo say "Kanalen $media_search kunde inte hittas på denna TV"
                fi
            else
                # 🦆 says ⮞ if no channel specified, show TV guide
                yo tv-guide
            fi
        ;; 
        nav_up) # 🦆 says ⮞ navigate up     
          dt_debug "Navigating up"
          control_device "$DEVICE" nav_up
          exit 0
          ;;
        nav_down) # 🦆 says ⮞ navigate down     
          dt_debug "Navigating down"
          control_device "$DEVICE" nav_down
          exit 0
          ;;
        nav_left) # 🦆 says ⮞ navigate left     
          dt_debug "Navigating left"
          control_device "$DEVICE" nav_left
          exit 0
          ;;
        nav_right) # 🦆 says ⮞ navigate right     
          dt_debug "Navigating right"
          control_device "$DEVICE" nav_right
          exit 0
          ;;
        nav_select) # 🦆 says ⮞ navigate select     
          dt_debug "Navigating select"
          control_device "$DEVICE" nav_select
          exit 0
          ;;
        nav_back) # 🦆 says ⮞ navigate back     
          dt_debug "Navigating back"
          control_device "$DEVICE" nav_back
          exit 0
          ;;
        nav_menu) # 🦆 says ⮞ navigate menu     
          dt_debug "Navigating menu"
          control_device "$DEVICE" nav_menu
          exit 0
          ;;  
        nav_home) # 🦆 says ⮞ navigate home     
          dt_debug "Navigating home"
          control_device "$DEVICE" nav_home
          exit 0
          ;;  
        call) # 🦆 says ⮞ find remote     
          dt_debug "Calling remote.."
          control_device "$DEVICE" find_remote
          exit 0
          ;; 
        on) # 🦆 says ⮞ power on device     
          dt_debug "Powering on $DEVICE .."
          control_device "$DEVICE" power_on
          exit 0
          ;;  
        off) # 🦆 says ⮞ power off device    
          dt_debug "Powering off $DEVICE .."
          control_device "$DEVICE" power_off
          exit 0
          ;; # 🦆 says ⮞ invalid type
        *)
          dt_error "Okänt mediatyp: $media_type"
          exit 1
          ;;
      esac

      dt_debug "Matched media: $matched_media"
      dt_debug "Media type: $media_type" 

      # 🦆 says ⮞ unless season specified - create da playlist 
      if [[ -z "$season" ]] && [[ -n "''${SEARCH_FOLDERS[$media_type]}" ]]; then
          BASE_PATH="''${SEARCH_FOLDERS[$media_type]}"
          dt_debug "BASEL_PATH is: $BASE_PATH"
          FULL_PATH="$BASE_PATH/$matched_media"
          dt_debug "FULL_PATH is: $FULL_PATH"
          generate_playlist "$FULL_PATH" "$media_type"
          start_playlist "$DEVICE"
      fi
      
    '';
    voice = { # 🦆 says ⮞ low priority = faser execution? wtf
        priority = 1; # 🦆 says ⮞ 1 to 5
        sentences = [
          # 🦆 says ⮞ season specific search
          "[jag] (spel|spela|kör|start|starta) [upp|igång] {typ} {search} (säsong|season) {season} i {device}"
          "jag vill se {typ} {search} (säsong|season) {season} i {device}" 
          "[jag] (spel|spela|kör|start|starta) [upp|igång] {typ} {search} (säsong|season) {season}"
          "jag vill se {typ} {search} (säsong|season) {season}"       
          # 🦆 says ⮞ non default device control
          "[jag] (spel|spela|kör|start|starta) [upp|igång] {typ} {search} i {device}"
          "jag vill se {typ} {search} i {device}"    
          "jag vill lyssna på {typ} i {device}"
          "jag vill höra {typ} {search} i {device}"
          "{typ} (volym|volymen|avsnitt|avsnittet|låt|låten|skiten) i {device}"          
          "tv {typ} i {device}"
          # 🦆 says ⮞ default player
          "[jag] (spel|spela|kör|start|starta) [upp|igång] {typ} {search}"
          "jag vill se {typ} {search}"    
          "jag vill lyssna på [mina] {typ}"
          "jag vill höra [mina] {typ}"
          "{typ} (volym|volymen|avsnitt|avsnittet|låt|låten|skiten)"       
          "tv {typ}"
          # 🦆 says ⮞ append to favorites playlist
          "spara i {typ}"
          "lägg till den här [låten] i {typ}"
          # 🦆 says ⮞ find remote
          "ring {typ}"
          "hitta {typ}"            
        ]; # 🦆 says ⮞ lists are in word > out word
        lists = { # swap 🦆 says ⮞ long list incomin' yo 
          typ.values = [          
          # 🦆 says ⮞ media 
            { "in" = "[serie|serien|tvserien|tv-serien]"; out = "tv"; }
            { "in" = "[pod|podd|podcost|poddan|podden|podcast]"; out = "podcast"; }
            { "in" = "[slump|slumpa|random|musik|mix|shuffle]"; out = "jukebox"; }
            { "in" = "[artist|artisten|band|bandet|grupp|gruppen]"; out = "music"; }
            { "in" = "[låt|låten|sång|sången|biten]"; out = "song"; }
            { "in" = "[film|filmen]"; out = "movie"; }
            { "in" = "[ljudbok|ljudboken]"; out = "audiobook"; }
            { "in" = "[video|videon]"; out = "othervideo"; }
            { "in" = "[musicvideo|musikvideo]"; out = "musicvideo"; }
            { "in" = "[kanal|kanalen|kannal]"; out = "livetv"; }
            { "in" = "[youtube|you-tube|you|yt|yotub|yotube|yotub|tuben|juden]"; out = "youtube"; }     
            { "in" = "[news|nyhet|nyheter|nyheterna|senaste nytt]"; out = "news"; }               
          # 🦆 says ⮞ heart currently playing            
            { "in" = "[spellista|spellistan|spel lista|spel listan]"; out = "favorites"; }
          # 🦆 says ⮞ playback            
            { "in" = "[paus|pause|pausa|tyst|tysta|mute|stop]"; out = "pause"; }
            { "in" = "[play|fortsätt|okej]"; out = "play"; }
            { "in" = "[öj|höj|höjj|öka|hej]"; out = "up"; }
            { "in" = "[sänk|sänkt|ner|ned]"; out = "down"; }
            { "in" = "[näst|nästa|nästan|next|fram|framåt]"; out = "next"; }
            { "in" = "[förr|förra|föregående|backa|bakåt]"; out = "previous"; }
          # 🦆 says ⮞ add to playlist                        
            { "in" = "[spara|add|adda|addera|lägg till]"; out = "add"; }
            { "in" = "[favorit|favoriter|bästa]"; out = "add"; }
          # 🦆 says ⮞ on/off           
            { "in" = "[av|stäng av]"; out = "off"; }            
            { "in" = "på"; out = "on"; }      
          # 🦆 says ⮞ calls remote                        
            { "in" = "[fjärren|fjärrkontroll|fjärrkontrollen]"; out = "call"; }               
          ]; # 🦆 says ⮞ search can be anything            
          search.wildcard = true;
          # 🦆 says ⮞ hardcoded device names
          device.values = [
            { "in" = "[sovrum|sovrummet|bedroom]"; out = "192.168.1.152"; }
            { "in" = "[vardagsrum|vardagsrummet|livingroom]"; out = "192.168.1.223"; }              
          ]; # 🦆 says ⮞ or use device name from Nix config          
          # device.values = let
          #   devices = lib.attrValues config.house.tv;
          # in map (device: {
          #   "in" = "[${device.room}|${lib.head (lib.splitString "." device.ip)}]"; 
          #   out = device.ip; 
          # }) devices;
          season.values = map (pair: {
            "in" = builtins.concatStringsSep "|" pair;
            out  = builtins.head pair;
          }) nums;
        };
    };
  };
    
  sops.secrets = {
    webserver = { # 🦆 says ⮞ https required
      sopsFile = ../../secrets/webserver.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    }; # 🦆 says ⮞ required for youtube
    youtube_api_key = { 
      sopsFile = ../../secrets/youtube.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
    
  };}
