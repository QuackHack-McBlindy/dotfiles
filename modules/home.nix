{ config, lib, pkgs, ... }:

let
  cfg = config.my.userFiles;
  inherit (lib) mkOption types;

  forbiddenTargets = [ "" "." "./" ];

  fileType = types.submodule ({ name, ... }: {
    options = {
      enable = mkOption { type = types.bool; default = true; };
      source = mkOption { type = types.str; };
      target = mkOption {
        type = types.str;
        apply = target:
          if lib.elem target forbiddenTargets
          then throw "Invalid target path for '${name}': '${target}'"
          else target;
      };
      recursive = mkOption { type = types.bool; default = false; };
    };
  });

  enabledFiles = lib.filterAttrs (_: v: v.enable) cfg;

  script = pkgs.writeShellScript "link-user-files" ''
    set -euo pipefail
    DOTFILES_DIR="${config.this.user.me.dotfilesDir}"
    
    ${lib.concatMapStringsSep "\n" (file: ''
      # Resolve relative paths
      target="$HOME/${file.target}"
      source="$DOTFILES_DIR/${lib.removePrefix "/" file.source}"
      
      echo "Linking: $source → $target"
      mkdir -p "$(dirname "$target")"
      
      # Handle existing non-symlinks differently
      if [[ -e "$target" && ! -L "$target" ]]; then
        echo "Backing up existing file: $target"
        mv "$target" "$target.bak"
      fi
      
      ln -sf${if file.recursive then "T" else ""} "$source" "$target"
    '') (lib.attrValues enabledFiles)}
  '';

in {
  options.my.userFiles = mkOption {
    type = types.attrsOf fileType;
    default = {};
    description = "User-level file management with symlinks";
  };

  config = {
    systemd.user.services.link-user-files = {
      description = "Link user config files at login";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = script;
      };
    };
  };
}
