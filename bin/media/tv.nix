# dotfiles/bin/media/tv.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Android TVOS Controller 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ yo    
in {   
  house.tv = {
    shield = { room = "livingroom"; ip = "192.168.1.223"; };
    arris = { room = "bedroom"; ip = "192.168.1.152"; };
  };  
  yo.bitch = { 
    intents = {
      tv = {  # 🦆 says ⮞ high priority for fast script executionz
        priority = 1;
        data = [{
          sentences = [
            # 🦆 says ⮞ devices control sentences
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
          ];    
          lists = {
            typ.values = [
              { "in" = "[serie|serien|tvserien|tv-serien]"; out = "tv"; }
              { "in" = "[pod|podd|podcost|poddan|podden|podcast]"; out = "podcast"; }
              { "in" = "[slump|slumpa|random|musik|mix|shuffle]"; out = "jukebox"; }
              { "in" = "[artist|artisten|band|bandet|grupp|gruppen]"; out = "music"; }
              { "in" = "[låt|låten|sång|sången|biten]"; out = "song"; }
              { "in" = "[film|filmen]"; out = "movie"; }
              { "in" = "[ljudbok|ljudboken]"; out = "audiobook"; }
              { "in" = "video"; out = "othervideo"; }
              { "in" = "[musicvideo|musikvideo]"; out = "musicvideo"; }
              { "in" = "[spellista|spellistan|spel lista|spel listan]"; out = "favorites"; }
              { "in" = "[kanal|kanalen|kannal]"; out = "livetv"; }
              { "in" = "[youtube|you-tube|you|yt|yotub|yotube|yotub|tuben|juden]"; out = "youtube"; }
              { "in" = "[paus|pause|pausa|tyst|tysta|mute|stop]"; out = "pause"; }
              { "in" = "[play|fortsätt|okej]"; out = "play"; }
              { "in" = "[öj|höj|höjj|öka|hej]"; out = "up"; }
              { "in" = "[sänk|sänkt|ner|ned]"; out = "down"; }
              { "in" = "[näst|nästa|nästan|next|fram|framåt]"; out = "next"; }
              { "in" = "[förr|förra|föregående|backa|bakåt]"; out = "previous"; }
#              { "in" = "[spara|add|adda|addera|lägg till]"; out = "add"; }
              { "in" = "[favorit|favoriter|bästa]"; out = "add"; }
              { "in" = "[news|nyhet|nyheter|nyheterna|senaste nytt]"; out = "news"; }   
              { "in" = "[fjärren|fjärrkontroll|fjärrkontrollen]"; out = "call"; }   
              { "in" = "[av|stäng av]"; out = "off"; }            
              { "in" = "på"; out = "on"; }        
            ];
            search.wildcard = true;
            device.values = [
              { "in" = "[sovrum|sovrummet|bedroom]"; out = "192.168.1.152"; }
              { "in" = "[vardagsrum|vardagsrummet|livingroom]"; out = "192.168.1.223"; }              
            ];  
          };
        }];
      };
    };
  };
   
  yo.scripts.tv = {
    description = "Android TV Controller. Fuzzy search all media types and creates playlist and serves over webserver for casting. Fully conttrollable.";
    category = "🎧 Media Management";
    aliases = [ "remote" ];
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "typ"; description = "Specify the type of command or the media type to search for. Supported commands: on, off, up, down, call, favorites, add. Media Types: tv, movie, livetv, podcast, news, music, song, musicvideo, jukebox (random music), othervideo, youtube"; default = "tv"; optional = true; }
      { name = "search"; description = "Media to search"; optional = true; }
      { name = "device"; description = "Device IP to play on"; default = "192.168.1.223"; }      
      { name = "shuffle"; description = "Shuffle Toggle, true or false"; default = "true"; }   
      { name = "tvshowsDir"; description = "TV shows directory"; default = "/Pool/TV"; }
      { name = "moviesDir"; description = "Movies directory"; default = "/Pool/Movies"; }
      { name = "musicDir"; description = "Music directory"; default = "/Pool/Music"; }
      { name = "musicvideoDir"; description = "Music videos directory"; default = "/Pool/Music_Videos"; }      
      { name = "videosDir"; description = "Other videos directory"; default = "/Pool/Other_Videos"; }
      { name = "podcastDir"; description = "Podcasts directory"; default = "/Pool/Podcasts"; }
      { name = "audiobookDir"; description = "Audiobooks directory"; default = "/Pool/Audiobooks"; }
      { name = "youtubeAPIkeyFile"; description = "File containing YouTube API key"; default = config.sops.secrets.youtube_api_key.path; }
      { name = "webserver"; description = "File containing webserver URL that stores media"; default = config.sops.secrets.webserver.path; }     
      { name = "defaultPlaylist"; description = "Default playlist path"; default = "/Pool/playlist.m3u"; }
      { name = "favoritesPlaylist"; description = "File path for Favouyrites tagged entries"; default = "/Pool/favorites.m3u"; }      
      { name = "max_items"; description = "Set a maximum number of items in playlist"; default = "200"; }         
    ];
    code = ''    
      ${cmdHelpers}
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
        )
        if [[ "$action" == "find_remote" ]]; then
          adb -s "$device_ip" shell am start -a android.intent.action.VIEW -n com.nvidia.remotelocator/.ShieldRemoteLocatorActivity
          return
        fi
        local key_event="''${key_events[$action]}"
        if [[ -z "$key_event" ]]; then
          echo "Unknown action: $action"
          echo "Available actions: ''${!key_events[@]} find_remote"
          return 1
        fi

        adb -s "$device_ip" shell input keyevent "$key_event"
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
          
      # 🦆 says ⮞ handle different media types
      matched_media=""
      case "$media_type" in
        # 🦆 says ⮞ directory based searchez
        tv|podcast|movie|audiobook|musicvideo|music)
          case "$media_type" in
            tv)        search_dir="$TVDIR" ;;
            podcast)   search_dir="$PODCASTDIR" ;;
            movie)     search_dir="$MOVIEDIR" ;;
            audiobook) search_dir="$AUDIOBOOKDIR" ;;
            musicvideo) search_dir="$MUSICVIDEODIR" ;;
            music) search_dir="$MUSICDIR" ;;
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
          else
            dt_error "YouTube search failed"
          fi
          exit 0
          ;; 
        livetv) # 🦆 says ⮞ TODO handle live tv channels properly
          matched_media="$media_type"
          yo say "Aktiverar $media_type"
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

      if [[ -n "''${SEARCH_FOLDERS[$media_type]}" ]]; then
          BASE_PATH="''${SEARCH_FOLDERS[$media_type]}"
          dt_debug "BASEL_PATH is: $BASE_PATH"
          FULL_PATH="$BASE_PATH/$matched_media"
          dt_debug "FULL_PATH is: $FULL_PATH"
          generate_playlist "$FULL_PATH" "$media_type"
          start_playlist "$DEVICE"
      else
          dt_error "Unknown media type: $media_type"
      fi
    '';
    voice = {
        priority = 1;
        sentences = [
          # 🦆 says ⮞ devices control sentences
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
        ];    
        lists = {
          typ.values = [
            { "in" = "[serie|serien|tvserien|tv-serien]"; out = "tv"; }
            { "in" = "[pod|podd|podcost|poddan|podden|podcast]"; out = "podcast"; }
            { "in" = "[slump|slumpa|random|musik|mix|shuffle]"; out = "jukebox"; }
            { "in" = "[artist|artisten|band|bandet|grupp|gruppen]"; out = "music"; }
            { "in" = "[låt|låten|sång|sången|biten]"; out = "song"; }
            { "in" = "[film|filmen]"; out = "movie"; }
            { "in" = "[ljudbok|ljudboken]"; out = "audiobook"; }
            { "in" = "video"; out = "othervideo"; }
            { "in" = "[musicvideo|musikvideo]"; out = "musicvideo"; }
            { "in" = "[spellista|spellistan|spel lista|spel listan]"; out = "favorites"; }
            { "in" = "[kanal|kanalen|kannal]"; out = "livetv"; }
            { "in" = "[youtube|you-tube|you|yt|yotub|yotube|yotub|tuben|juden]"; out = "youtube"; }
            { "in" = "[paus|pause|pausa|tyst|tysta|mute|stop]"; out = "pause"; }
            { "in" = "[play|fortsätt|okej]"; out = "play"; }
            { "in" = "[öj|höj|höjj|öka|hej]"; out = "up"; }
            { "in" = "[sänk|sänkt|ner|ned]"; out = "down"; }
            { "in" = "[näst|nästa|nästan|next|fram|framåt]"; out = "next"; }
            { "in" = "[förr|förra|föregående|backa|bakåt]"; out = "previous"; }
            { "in" = "[spara|add|adda|addera|lägg till]"; out = "add"; }
            { "in" = "[favorit|favoriter|bästa]"; out = "add"; }
            { "in" = "[news|nyhet|nyheter|nyheterna|senaste nytt]"; out = "news"; }   
            { "in" = "[fjärren|fjärrkontroll|fjärrkontrollen]"; out = "call"; }   
            { "in" = "[av|stäng av]"; out = "off"; }            
            { "in" = "på"; out = "on"; }        
          ];
          search.wildcard = true;
          device.values = [
            { "in" = "[sovrum|sovrummet|bedroom]"; out = "192.168.1.152"; }
            { "in" = "[vardagsrum|vardagsrummet|livingroom]"; out = "192.168.1.223"; }              
          ];  
        };
    };
  };
    
  sops.secrets = {
    webserver = { 
      sopsFile = ../../secrets/webserver.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
    youtube_api_key = { 
      sopsFile = ../../secrets/youtube.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
  };}
