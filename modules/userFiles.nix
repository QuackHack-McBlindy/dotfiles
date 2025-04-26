{ config, lib, pkgs, ... }:

let
  cfg = config.my.userFiles;
  inherit (lib) mkOption types;

  fileType = types.submodule ({ name, ... }: {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable this file";
      };
      
      source = mkOption {
        type = types.path;
        description = "Source path of the file";
      };
      
      target = mkOption {
        type = types.str;
        description = "Target path relative to home directory";
      };
      
      recursive = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to link directories recursively";
      };
    };
  });

in {
  options.my.userFiles = mkOption {
    type = types.attrsOf fileType;
    default = {};
    description = "User files to manage with backup protection";
  };

  config = let
    enabledFiles = lib.filterAttrs (n: v: v.enable) cfg;
    
    fileCommands = lib.mapAttrsToList (name: file:
      let
        source = file.source;
        target = "\${HOME}/${file.target}";
        backup = "${target}.bak";
      in ''
        # Create parent directory
        mkdir -p "$(dirname "${target}")"
        
        # Handle existing files
        if [[ -e "${target}" && ! -L "${target}" ]]; then
          if [[ ! -e "${backup}" ]]; then
            echo "Backing up existing file: ${target} -> ${backup}"
            mv "${target}" "${backup}"
          else
            echo "Backup already exists: ${backup}"
          fi
        fi
        
        # Create symlink
        if [[ ! -e "${target}" ]] || [[ -L "${target}" ]]; then
          ln -sfT "${source}" "${target}"
        fi
      ''
    ) enabledFiles;

  in {
    system.activationScripts.userFiles = lib.strings.concatStringsSep "\n" [
      (lib.strings.concatMapStrings (text: text) fileCommands)
    ];
  };
}
