{ config, lib, pkgs, ... }:

let
  inherit (lib) types;

  # 1. Configuration types
  mediaType = types.submodule {
    options = {
      path = lib.mkOption {
        type = types.str;
        description = "Base directory for this media type";
      };
      extensions = lib.mkOption {
        type = types.listOf types.str;
        default = [];
        description = "File extensions to include";
      };
      randomize = lib.mkOption {
        type = types.bool;
        default = false;
        description = "Whether to shuffle results";
      };
    };
  };

  # 2. Core script generation
  makeDeviceScript = device: ip: pkgs.writeShellScriptBin device ''
    set -euo pipefail

    media_type="''${1:-}"
    query="''${2:-}"
    
    # Load Nix-managed config
    MEDIA_TYPES='${builtins.toJSON config.services.media-search.mediaTypes}'
    CORRECTIONS='${builtins.toJSON config.services.media-search.corrections}'
    WEBSERVER="${config.services.media-search.webServer}"
    PLAYLIST_PATH="${config.services.media-search.playlistPath}"
    INTRO_URL="${config.services.media-search.introUrl}"
    MAX_ITEMS=${toString config.services.media-search.maxPlaylistItems}

    connect() {
      adb connect ${ip} >/dev/null 2>&1
      adb -s ${ip} wait-for-device
    }

    correct_query() {
      local query="$1"
      jq --arg q "$query" -r '
        to_entries | 
        map(select(.key | ascii_downcase == ($q | ascii_downcase))) | 
        if length > 0 then first.value else $q end
      ' <<< "$CORRECTIONS"
    }

    handle_media() {
      local media_config=$(jq -r ".$media_type" <<< "$MEDIA_TYPES")
      local search_dir=$(jq -r '.path' <<< "$media_config")
      local folder_name=$(basename "$search_dir")
      local exts=($(jq -r '.extensions[]' <<< "$media_config"))
      local randomize=$(jq -r '.randomize' <<< "$media_config")
    
      # Clear existing playlist and add intro URL
      rm -f "$PLAYLIST_PATH"
      echo "$INTRO_URL" > "$PLAYLIST_PATH"
    
      # Build find command with proper escaping
      local find_cmd="find -L \"$search_dir\" -type f \( -false"
      for ext in "''${exts[@]}"; do
        find_cmd+=" -o -iname \"*$ext\""
      done
      find_cmd+=" \) -print0"
    
      # Add randomization/selection and limit
      if [ "$randomize" = "true" ]; then
        find_cmd+=" | shuf -z -n $((MAX_ITEMS - 1))"
      else
        find_cmd+=" | fzf --filter=\"$(correct_query "$query")\" --read0 --print0"
      fi
    
      eval "$find_cmd" | while IFS= read -r -d ''' filepath; do
        # Convert local path to web URL
        relative_path="''${filepath#''$search_dir/}"
        url_encoded_path=$(printf '%s' "$relative_path" | sed 's/ /%20/g; s/&/%26/g; s/?/%3F/g')
        echo "$WEBSERVER/$folder_name/$url_encoded_path"
      done | head -n "$((MAX_ITEMS - 1))" >> "$PLAYLIST_PATH"
    
      # Send to device
      connect
      adb -s ${ip} shell "am start -a android.intent.action.VIEW \
        -d $WEBSERVER/playlist.m3u -t audio/x-mpegurl"
    }


    case "$media_type" in
      jukebox)
        media_type="music"
        query="*"
        handle_media
        ;;
      music|movie|tv)
        handle_media
        ;;
      on)
        connect
        adb -s ${ip} shell input keyevent KEYCODE_WAKEUP
        ;;
      off)
        adb -s ${ip} shell input keyevent KEYCODE_SLEEP
        ;;
      up)
        adb -s ${ip} shell input keyevent KEYCODE_VOLUME_UP
        ;;
      down)
        adb -s ${ip} shell input keyevent KEYCODE_VOLUME_DOWN
        ;;
      next)
        adb -s ${ip} shell input keyevent KEYCODE_MEDIA_NEXT
        ;;
      previous)
        adb -s ${ip} shell input keyevent KEYCODE_MEDIA_PREVIOUS
        ;;
      *)
        echo "Usage: ${device} [music|movie|tv|jukebox|on|off|up|down|next|previous] [query]"
        exit 1
        ;;
    esac
  '';

  deviceScripts = lib.mapAttrsToList makeDeviceScript 
    config.services.media-search.deviceMap;

in {
  options.services.media-search = {
    webServer = lib.mkOption {
      type = types.str;
      description = "Base URL for media server";
    };

    maxPlaylistItems = lib.mkOption {
      type = types.int;
      default = 200;
      description = "Maximum number of items in generated playlists";
    };

    introUrl = lib.mkOption {
      type = types.str;
      description = "Intro video URL";
    };

    playlistPath = lib.mkOption {
      type = types.str;
      default = "/tmp/playlist.m3u";
      description = "Local path to save generated playlists";
    };

    mediaTypes = lib.mkOption {
      type = types.attrsOf mediaType;
      default = {};
      description = "Media type configurations";
    };

    deviceMap = lib.mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Mapping of device names to IP addresses";
    };

    corrections = lib.mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Query correction mappings";
    };
  };

  config = {
    environment.systemPackages = deviceScripts ++ [
      pkgs.fzf
      pkgs.jq
      pkgs.android-tools
    ];

    services.media-search = {
      maxPlaylistItems = 200;
      webServer = "https://example.domain.org";
      introUrl = "https://example.domain.org/intro.mp4";
      playlistPath = "/home/pungkula/playlist.m3u";

      mediaTypes = {
        music = {
          path = "/Pool/Music";
          extensions = [".mp3" ".flac"];
          randomize = false;
        };

        movie = {
          path = "/Pool/Movies";
          extensions = [ ".mkv" ".mp4" ".avi" ];
        };

        tv = {
          path = "/Pool/TV";
          extensions = [ ".mkv" ".mp4" ".avi" ];
          randomize = false;
        };

        jukebox = {
          path = "/Pool/Music";
          extensions = [".mp3" ".flac"];
          randomize = true;
        };
      };

      deviceMap = {
        shield = "192.168.1.223";
        arris = "192.168.1.152";
      };

      corrections = {
        "2,5 men" = "two and a half men";
        "haus" = "House";
        "bajskorv" = "House";
      };
    };
  };
}
