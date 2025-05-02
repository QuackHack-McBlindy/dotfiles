# modules/home.nix
{ 
  config,
  lib,
  pkgs,
  ...
} : let
  inherit (lib) mkOption types mkIf;
  
  mkUserLinks = user: baseDir: let
    userHome = config.users.users.${user}.home;
    # Get store path with content hash
    storePath = builtins.path {
      path = baseDir;
      name = "home-manifest";
    };
  in ''
    echo "Mirroring home directory for ${user}"
    find ${storePath} -type f -print0 | while IFS= read -r -d $'\0' src; do
      rel_path="''${src#${storePath}/}"
      target="${userHome}/''${rel_path}"
    
      # Skip if symlink already correct
      if [[ -L "$target" && "$(readlink -f "$target")" == "$src" ]]; then
        continue
      fi
    
      echo "Linking: $rel_path"
      mkdir -vp "$(dirname "$target")"
      
      # Set ownership once per directory
      dir="$(dirname "$target")"
      if [[ ! -d "$dir" ]]; then
        chown ${user}:users "$dir"
      fi

      [[ -e "$target" && ! -L "$target" ]] && mv -f "$target" "$target.backup"
      ln -vsfn "$src" "$target"
      chown -h ${user}:users "$target"
    done
  '';

in {
  options.this.home = mkOption {
    type = types.path;
    description = "Directory to mirror to home directory";
  };

  config = mkIf (config.this.home != null) {
    system.activationScripts.home-mirror = {
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail
        ${mkUserLinks config.this.user.me.name config.this.home}
      '';
      deps = [ "users" ];
    };
  };
}
