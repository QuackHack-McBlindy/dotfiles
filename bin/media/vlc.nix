# dotfiles/bin/media/vlc.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ playlist management 
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

in {   
   
  yo.scripts.vlc = {
    description = "Playlist management for the local machine";
    category = "🎧 Media Management";
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "add"; type = "path"; description = "Append file path to playlist"; optional = true; }
      { name = "addDir"; type = "path"; description = "Append directory path to playlist"; optional = true; }
      { name = "remove"; type = "bool"; description = "Boolean, true removes file path from playlist"; optional = true; }
      { name = "list"; type = "bool"; description = "List all current items in the playlist"; optional = true; }
      { name = "shuffle"; type = "bool"; description = "Shuffle the playlist"; optional = true; }
      { name = "clear"; type = "bool"; description = "Clears the playlist"; optional = true; }
      { name = "playlist"; type = "string"; description = "Path to the playlist file"; default = "/Pool/playlist.m3u"; optional = false; }
    ];
    code = ''
      ${cmdHelpers}
      dt_debug "Add: $add     Add Folder: $addDir"
      playlist="$playlist"
      
      # 🦆 says ⮞ --clear? clear the entire playlist
      if [ "$clear" = "true" ]; then
        dt_debug "Clearing playlist"
        > "$playlist"
        dt_info "Playlist cleared"
        exit 0
      fi
      touch "$playlist"
      
      # 🦆 says ⮞ --list? return json playlist      
      if [ "$list" = "true" ]; then
        # 🦆 says ⮞ read lines and filter em'
        playlist_items=$(grep -vE '^\s*#' "$playlist" | grep -vE '^\s*$')
        echo "{"
        echo '  "playlist": ['
        first=true
        while IFS= read -r line; do
          if [ "$first" = true ]; then
            first=false
          else
            echo ","
          fi
          # 🦆 says ⮞ escape quotes
          esc_line=$(printf '%s' "$line" | sed 's/"/\\"/g')
          echo "    \"$esc_line\""
        done <<< "$playlist_items"
        echo "  ]"
        echo "}"
        exit 0
      fi

      # 🦆 says ⮞ --remove? remove specified path
      if [ "$remove" = "true" ] && [ -n "$add" ]; then
        dt_debug "Removing: $add"

        target_path=$(realpath -s "$add" 2>/dev/null || echo "$add")

        temp_file=$(mktemp -p "$(dirname "$playlist")")
        grep -vF "$target_path" "$playlist" > "$temp_file"
        mv "$temp_file" "$playlist"
        dt_info "Removed '$target_path' from playlist"
        exit 0
      fi
      
      # 🦆 says ⮞ --add? add file to playlist
      if [ -n "$add" ]; then
        if [ ! -e "$add" ]; then
          dt_error "File '$add' does not exist"
          exit 1
        fi

        real_path=$(realpath -s "$add" 2>/dev/null || echo "$add")
        dt_debug "Adding file: $real_path"
        echo "$real_path" >> "$playlist"
        dt_info "Added '$real_path' to playlist"
      fi
      
      # 🦆 says ⮞ --addDir? add directory contents to playlist
      if [ -n "$addDir" ]; then
        if [ ! -d "$addDir" ]; then
          dt_error "Directory '$addDir' does not exist"
          exit 1
        fi
        real_dir=$(realpath -s "$addDir" 2>/dev/null || echo "$addDir")
        dt_debug "Adding directory: $real_dir"
        
        while IFS= read -r -d "" file; do
          file_path=$(realpath -s "$file" 2>/dev/null || echo "$file")
          echo "$file_path" >> "$playlist"
          dt_debug "Added '$file_path' to playlist"
        done < <(find "$real_dir" -type f \( \
          -name "*.mp3" -o \
          -name "*.flac" -o \
          -name "*.wav" -o \
          -name "*.m4a" -o \
          -name "*.ogg" -o \
          -name "*.mp4" -o \
          -name "*.avi" -o \
          -name "*.mkv" -o \
          -name "*.mov" -o \
          -name "*.wmv" \) -print0 2>/dev/null || true)
        
        dt_info "Added media files from '$real_dir' to playlist"
      fi
      
      # 🦆 says ⮞ --shuffle? shuffle the playlist
      if [ "$shuffle" = "true" ]; then
        dt_debug "Shuffling playlist"
        if [ ! -s "$playlist" ]; then
          dt_warn "Playlist is empty, nothing to shuffle"
          exit 0
        fi
        
        playlist_content=$(grep -vE '^\s*#' "$playlist" | grep -vE '^\s*$')
        
        if [ -n "$playlist_content" ]; then
          if command -v shuf >/dev/null 2>&1; then
            shuffled_content=$(echo "$playlist_content" | shuf)
          else
            shuffled_content=$(echo "$playlist_content" | sort -R)
          fi
          
          temp_file=$(mktemp -p "$(dirname "$playlist")")
          echo "$shuffled_content" > "$temp_file"
          mv "$temp_file" "$playlist"
          dt_info "Playlist shuffled"
        else
          dt_warn "Playlist is empty, nothing to shuffle"
        fi
      fi
    '';
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
