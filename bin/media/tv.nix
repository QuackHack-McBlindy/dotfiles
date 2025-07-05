# dotfiles/bin/media/tv.nix
{ 
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {  
  yo.bitch = { 
    intents = {
      tv = {
        priority = 1;
        data = [{
          sentences = [
            # devices control sentences
            "(spel|spela|kör|start|starta) [upp|igång] {typ} {search} i {device}"
            "jag vill se {typ} {search} i {device}"    
            "jag vill lyssna på {typ} i {device}"
            "jag vill höra {typ} {search} i {device}"
            "ring {typ}"
            "hitta {typ}"
            "{typ} (volym|volymen|avsnitt|avsnittet|låt|låten|skiten) i {device}"          
            # default player
            "(spel|spela|kör|start|starta) [upp|igång] {typ} {search}"
            "jag vill se {typ} {search}"    
            "jag vill lyssna på {typ}"
            "jag vill höra {typ}"
            "{typ} (volym|volymen|avsnitt|avsnittet|låt|låten|skiten)"       
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
              { "in" = "[spellista|spellistan|spel lista|spel listan]"; out = "playlist"; }
              { "in" = "[nyhet|nyheter|nyheten|nyheterna|senaste nytt]"; out = "news"; }
              { "in" = "[kanal|kanalen|kannal]"; out = "livetv"; }
              { "in" = "[youtube|you-tube|you|yt|yotub|yotube|yotub|tuben|juden]"; out = "youtube"; }
              { "in" = "[paus|pause|pausa|tyst|tysta|mute|stop]"; out = "pause"; }
              { "in" = "[play|fortsätt|okej]"; out = "play"; }
              { "in" = "[öj|höj|höjj|öka|hej]"; out = "up"; }
              { "in" = "[sänk|sänkt|ner|ned]"; out = "down"; }
              { "in" = "[näst|nästa|nästan|next|fram|framåt]"; out = "next"; }
              { "in" = "[förr|förra|föregående|backa|bakåt]"; out = "previous"; }
              { "in" = "[spara|add|adda|addera|lägg till]"; out = "add"; }
              { "in" = "[news|nyhet|nyheter|nyheterna|senaste nytt]"; out = "news"; }            
              { "in" = "[fjärren|fjärrkontroll|fjärrkontrollen]"; out = "find"; }              
            ];
            search.wildcard = true;
            device.values = [
              { "in" = "[sovrum|sovrummet|bedroom]"; out = "arris"; }
              { "in" = "[vardagsrum|vardagsrummet|livingroom]"; out = "shield"; }              
            ];  
          };
        }];
      };
    };
  };
   
  yo.scripts.tv = {
    description = "Android TV Controller";
    category = "🎧 Media Management";
    aliases = [ "remote" ];
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "typ"; description = "Media type"; default = "tv"; optional = true; }
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
      { name = "domainFile"; description = "File containing domain"; default = config.sops.secrets.domain.path; }     
      { name = "introURLFile"; description = "Secret file containing intro URL"; default = config.sops.secrets.intro_url.path; }
      { name = "defaultPlaylist"; description = "Default playlist path"; default = "/home/pungkula/playlisttm3u"; }
      { name = "max_items"; description = "Max number of items in playlist"; default = "200"; }         
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

      declare -A SEARCH_FOLDERS=([tv]="/Pool/TV")
      WEBSERVER=$(cat $domainFile)
      dt_debug "$WEBSERVER"
      PLAYLIST_SAVE_PATH="$playlist_file"
      dt_debug "$PLAYLIST_SAVE_PATH"
      INTRO_URL=$(cat $introURLFile)
      dt_debug "$INTRO_URL"

      template_directory_path() {
          local media_type=$1
          shift
          local directory_paths=("$@")
          local urls=()
          local base_path="''${SEARCH_FOLDERS[$media_type]}"
          local folder_name=$(basename "$base_path")  
          for path in "''${directory_paths[@]}"; do
              local relative_path="''${path#$base_path/}"
              relative_path="''${relative_path#$base_path}"  # Handle case without trailing slash     
              urls+=("''${WEBSERVER%/}/''${folder_name}/''${relative_path}")
          done        
          echo "''${urls[@]}"
      }
      
      save_media_content_urls() {
          local media_content_urls=("$@")     
          echo "$INTRO_URL" > "$PLAYLIST_SAVE_PATH"
          for url in "''${media_content_urls[@]}"; do
              echo "$url" >> "$PLAYLIST_SAVE_PATH"
          done   
          echo "Playlist saved to $PLAYLIST_SAVE_PATH"
      }
      template_single_path() {
          local path="$1"
          local media_type="$2"
          local base_path="''${SEARCH_FOLDERS[$media_type]}"
          local folder_name=$(basename "$base_path")
          local relative_path="''${path#$base_path}"
          relative_path="''${relative_path#/}"  # Remove leading slash
          local encoded_path=$(urlencode "$relative_path")    
          echo "''${WEBSERVER%/}/''${folder_name}/''${encoded_path}"
      }

      urlencode() {
          local string="$1"
          local strlen=''${#string}
          local encoded=""
          local pos c o

          for (( pos=0; pos<strlen; pos++ )); do
              c=${string:$pos:1}
              case "$c" in
                  [-_.~a-zA-Z0-9]) o="''${c}" ;;
                  *) printf -v o '%%%02x' "'$c" ;;
              esac
             encoded+="''${o}"
         done
         echo "''${encoded}"
      }
            
      find_best_fuzzy_match() {
        local input="$1"
        local best_score=0
        local best_match=""
        local normalized=$(echo "$input" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]')      
        local candidates
        mapfile -t candidates < <(jq -r '.[][] | "\(.script):\(.sentence)"' "$YO_FUZZY_INDEX")
        dt_debug "Found ''${#candidates[@]} candidates for fuzzy matching" >&2
        for candidate in "''${candidates[@]}"; do
          IFS=':' read -r script sentence <<< "$candidate"
          dt_debug "Checking candidate: $script - $sentence" >&2
          local tri_score=$(trigram_similarity "$normalized" "$sentence")
          (( tri_score < 30 )) && continue       
          local score=$(levenshtein_similarity "$normalized" "$sentence")  
          if (( score > best_score )); then
            best_score=$score
            best_match="$script:$sentence"
            dt_debug "New best match: $best_match ($score%)" >&2
          fi
        done
      
        if [[ -n "$best_match" ]]; then
          echo "$best_match|$best_score"
        else
          echo ""
        fi
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
    
      fuzzy_search_media() {
        local search_str="$1"
        local dir_path="$2"
        local best_score=0
        local best_match=""
        
        local list=()
        while IFS= read -r -d $'\0' item; do
            list+=( "$(basename "$item")" )
        done < <(find "$dir_path" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)    
        dt_debug "Fuzzy searching ''${#list[@]} items in $dir_path"
        [ ''${#list[@]} -eq 0 ] && return 1
        local normalized_search=$(echo "$search_str" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]')     
        for item in "''${list[@]}"; do
            normalized_show=$(normalize_string "$show")
            local tri_score=$(trigram_similarity "$normalized_search" "$normalized_item")
            (( tri_score < 30 )) && continue        
            local score=$(levenshtein_similarity "$normalized_search" "$normalized_item")          
            if (( score > best_score )); then
                best_score=$score
                best_match="$item"
                dt_debug "New best: $item ($score%)"
            fi
        done
        if (( best_score >= 60 )); then
            echo "$best_match"
            return 0
        else
            dt_debug "No match found (best score: $best_score%)"
            return 1
        fi
      }
    
      matched_media=""
      case "$media_type" in
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
              
              if (( combined_score > best_score )); then
                  best_score=$combined_score
                  best_match="$item"
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
              jukebox)  type_desc="mixen" ;;
              musicvideo) type_desc="musikvideon" ;;
              playlist) type_desc="spellistan" ;;
              *)        type_desc="$media_type" ;;
            esac
            tts "Spelar upp $type_desc ''${matched_media//./ }"
            
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

      song|othervideo)
          # File-based search (individual songs or videos)
          case "$media_type" in
            song)      
              search_dir="$MUSICDIR"
              extensions=("*.mp3" "*.flac" "*.m4a" "*.wav")
              ;;
            othervideo)
              search_dir="$VIDEOSDIR"
              extensions=("*.mp4" "*.mkv" "*.avi" "*.mov")
              ;;
          esac
          
          dt_debug "Searching files in $search_dir for $media_search"
          items=()
          find_cmd="find \"$search_dir\" -type f"
          for ext in "''${extensions[@]}"; do
              find_cmd+=" -iname \"$ext\" -o"
          done
          find_cmd=''${find_cmd% -o}  # Remove trailing -o
          find_cmd+=" -print0"
          
          while IFS= read -r -d $'\0' file; do
              filename=$(basename "$file")
              # Remove extension for matching
              base_name=''${filename%.*}
              items+=("$file:$base_name")
          done < <(eval "$find_cmd")
          
          best_score=0
          best_match=""
          normalized_search=$(normalize_string "$media_search")
          
          for item_pair in "''${items[@]}"; do
              IFS=':' read -r full_path item_name <<< "$item_pair"
              normalized_item=$(normalize_string "$item_name")
              [[ -z "$normalized_search" || -z "$normalized_item" ]] && continue
              
              tri_score=$(trigram_similarity "$normalized_search" "$normalized_item")
              lev_score=$(levenshtein_similarity "$normalized_search" "$normalized_item")
              combined_score=$(( (lev_score * 80 + tri_score * 20) / 100 ))
              
              if (( combined_score > best_score )); then
                  best_score=$combined_score
                  best_match="$full_path"
                  best_match_name="$item_name"
              fi
          done
          
          if (( best_score >= 30 )); then
              matched_media="$best_match"
              tts "Spelar upp ''${media_type} ''${best_match_name//./ }"
          else
              for item_pair in "''${items[@]}"; do
                  IFS=':' read -r full_path item_name <<< "$item_pair"
                  normalized_item=$(normalize_string "$item_name")
                  if [[ "$normalized_item" == *"$normalized_search"* ]]; then
                      matched_media="$full_path"
                      break
                  fi
              done
          fi
          ;;

        jukebox)
          matched_media="shuffle"
          tts "Spelar slumpad musik"
          ;;

        playlist)
          matched_media="playlist"
          tts "Spelar upp spellista"
          ;;
          
        pause|play|up|down|next|previous|add)
          matched_media="$media_type"
          tts "Utför kommando: $media_type"
          ;;
          
        news)
          dt_debug "Playing news"
          yo-news
          exit 0
          ;;
          
        youtube)
          dt_debug "Playing YouTube"
          tv "$DEVICE" "$media_search" "$media_type"
          exit 0
          ;;
          
        livetv|call)
          matched_media="$media_type"
          tts "Aktiverar $media_type"
          ;;
          
        *)
          dt_error "Okänt mediatyp: $media_type"
          exit 1
          ;;
      esac

      tv "$DEVICE" "$matched_media" "$media_type"

    '';
  };
    
  sops.secrets = {
    domain = { 
      sopsFile = ../../secrets/domain.yaml;
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
    intro_url = { 
      sopsFile = ../../secrets/intro.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };    
  };}
