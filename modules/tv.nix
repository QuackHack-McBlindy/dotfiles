# media-search.nix
{ config, lib, pkgs, ... }:

let
  inherit (lib) types;

  directoryOption = types.coercedTo
    types.str
    (path: { inherit path; searchType = "files"; })
    (types.submodule {
      options = {
        path = lib.mkOption {
          type = types.str;
          description = "Directory path to search";
        };
        searchType = lib.mkOption {
          type = types.enum [ "files" "directories" "both" ];
          default = "files";
          description = "Whether to search for files, directories, or both";
        };
      };
    });

  mediaType = types.submodule {
    options = {
      directories = lib.mkOption {
        type = types.listOf directoryOption;
        default = [];
        description = "List of directories and their search types";
      };
    };
  };

  script = pkgs.writeShellScriptBin "media-search" ''
    set -euo pipefail

    MEDIA_TYPE="''${1:-}"
    if [ -z "$MEDIA_TYPE" ]; then
      echo "Usage: media-search [media-type]"
      exit 1
    fi

    declare -a DIR_ENTRIES=()

    case "$MEDIA_TYPE" in
      documents)
        DIR_ENTRIES=(
          ${lib.concatMapStringsSep "\n          " (d: ''"${d.path}:${d.searchType}"'') config.services.media-search.documents.directories}
        )
        ;;
      images)
        DIR_ENTRIES=(
          ${lib.concatMapStringsSep "\n          " (d: ''"${d.path}:${d.searchType}"'') config.services.media-search.images.directories}
        )
        ;;
      videos)
        DIR_ENTRIES=(
          ${lib.concatMapStringsSep "\n          " (d: ''"${d.path}:${d.searchType}"'') config.services.media-search.videos.directories}
        )
        ;;
      music)
        DIR_ENTRIES=(
          ${lib.concatMapStringsSep "\n          " (d: ''"${d.path}:${d.searchType}"'') config.services.media-search.music.directories}
        )
        ;;
      *)
        echo "Unknown media type: $MEDIA_TYPE"
        echo "Available types: documents, images, videos, music"
        exit 1
        ;;
    esac

    if [ "''${#DIR_ENTRIES[@]}" -eq 0 ]; then
      echo "No directories configured for media type: $MEDIA_TYPE"
      exit 1
    fi

    QUERY="''${2:-}"

    # Find and select files/directories with fzf
    (
      for entry in "''${DIR_ENTRIES[@]}"; do
        dir="$(echo "$entry" | cut -d: -f1)"
        search_type="$(echo "$entry" | cut -d: -f2)"
        # Expand tilde in directory path
        eval dir="$dir"
        case "$search_type" in
          files)
            find "$dir" -type f 2>/dev/null
            ;;
          directories)
            find "$dir" -type d 2>/dev/null
            ;;
          both)
            find "$dir" 2>/dev/null
            ;;
          *)
            echo "Invalid search type: $search_type" >&2
            exit 1
            ;;
        esac
      done
    ) | ${pkgs.fzf}/bin/fzf --query "$QUERY" --preview '
      if [ -d {} ]; then
        ${pkgs.tree}/bin/tree -C {} | head -200
      else
        ${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || ${pkgs.file}/bin/file {}
      fi
    ' | xargs -r ${pkgs.xdg-utils}/bin/xdg-open
  '';
in {
  options.services.media-search = {
    documents = lib.mkOption {
      type = mediaType;
      default = {};
      description = "Configuration for document search";
    };

    images = lib.mkOption {
      type = mediaType;
      default = {};
      description = "Configuration for image search";
    };

    videos = lib.mkOption {
      type = mediaType;
      default = {};
      description = "Configuration for video search";
    };

    music = lib.mkOption {
      type = mediaType;
      default = {};
      description = "Configuration for music search";
    };
  };

  config = {
    environment.systemPackages = [ 
      script 
      pkgs.fzf 
      pkgs.bat 
      pkgs.tree 
      pkgs.file 
      pkgs.xdg-utils 
    ];

    # Example default configuration
    services.media-search = {
      documents.directories = [
        { path = "~/Documents"; searchType = "files"; }
        { path = "~/Projects"; searchType = "both"; }
      ];
      images.directories = [
        { path = "~/Pictures"; searchType = "files"; }
        { path = "~/Art"; searchType = "both"; }
      ];
      videos.directories = [
        { path = "~/Videos"; searchType = "files"; }
        { path = "~/Movie Projects"; searchType = "both"; }
      ];
      music.directories = [
        { path = "~/Music"; searchType = "files"; }
        { path = "~/Sound Libraries"; searchType = "both"; }
      ];
    };
  };
}
