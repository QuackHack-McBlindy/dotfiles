{ 
  config,
  lib,
  pkgs,
  ...
} : let
  inherit (lib) mkOption types mkIf;

  mkUserLinks = user: baseDir: let
    userHome = config.users.users.${user}.home;
    storePath = builtins.path {
      path = baseDir;
      name = "home";
    };
  in ''
    echo "Mirroring home directory for ${user}"
    find ${storePath} -type f -print0 | while IFS= read -r -d $'\0' src; do
      rel_path="''${src#${storePath}/}"
      target="${userHome}/''${rel_path}"
      echo "Linking: $rel_path"
      mkdir -vp "$(dirname "$target")"
      if [[ -e "$target" && ! -L "$target" ]]; then
        echo "Backing up existing file at $target"
        mv -f "$target" "$target.backup"
      fi
      ln -vsfn "$src" "$target"
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
