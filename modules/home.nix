# dotfiles/modules/home.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ if u expect home man - you are out of duck
  config,
  lib,
  pkgs,
  ... # 🦆 duck say ⮞ create a file like diz:  file = { ".config/myfile.txt" = "hello world"; };     
} : with lib;
let # 🦆 duck say ⮞ big ducks build their own home

  # 🦆 duck say ⮞ Create a file, yo!
  homeBase = config.this.user.me.dotfilesDir + "/home";
  sanitize = path: 
    replaceStrings ["/"] ["-"] (removePrefix "/" (removePrefix "./" path));
  
  # 🦆 duck say ⮞ Create a home, yo!
  mkUserLinks = user: baseDir: let
    userHome = config.users.users.${user}.home;
    storePath = builtins.path {
      path = baseDir;
      name = "home-manifest";
    };
  in ''
    echo "🦆 duck say ⮞ Mirroring home directory for ${user}"
    find ${storePath} -type f -print0 | while IFS= read -r -d $'\0' src; do
      rel_path="''${src#${storePath}/}"
      target="${userHome}/''${rel_path}"
    
      # 🦆 duck say ⮞ Skip if symlink already correct
      # if [[ -L "$target" && "$(readlink -f "$target")" == "$src" ]]; then
      #  continue
      # fi
    
      echo "🦆 duck say ⮞ Linking: $rel_path"
      mkdir -vp "$(dirname "$target")"
      
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

  options = {
    file = mkOption {
      type = types.attrsOf types.lines;
      default = {};
      description = "Files to create directly under ${homeBase}";
    };
    this.home = mkOption {
      type = types.path;
      description = "Directory to mirror to home directory";
    };
  };

  config = mkMerge [
    # 🦆 duck say ⮞ Create the file, yo!
    {
      system.activationScripts.simpleFiles = let
        files = config.file;

      in {
        text = concatStringsSep "\n" (mapAttrsToList (path: content:
          let
            storeName = "file-${sanitize path}";
            storePath = pkgs.writeText storeName content;
            fullPath = "${homeBase}/${path}";
            dir = dirOf fullPath;
            username = config.this.user.me.name;
          in ''
            mkdir -p "${dir}"
            cp -f "${storePath}" "${fullPath}"
            chown "${username}:users" "${fullPath}"
            chmod 600 "${fullPath}"
            echo "🦆 duck say ⮞ Created file: ${fullPath}"
          '') files);
        deps = [];  
      };
    }
    
    {
      file."README.md" = ''
        # 🦆🧑‍🦯 **QuackHack-McBLindy'z ⮞ home directory yay** 🦆🧑‍🦯

        > [!CAUTION]
        > **THIS IS NOT HOME-MANAGER!**  
        > **Ducks don't use home-manager.** 🦆

        **Why?** I don't like it.  
        
        **🦆 duck say ⮞ quack - diz iz my directory**
        **🦆 duck say ⮞ i handle filez**  
        
        ```nix
          file."ducks.md" = "🦆 duck say ⮞ like diz yay";
          
        ```
        
      '';
    }
    
    # 🦆 duck say ⮞ symlink the home, yo!
    (mkIf (config.this.home != null) {
      system.activationScripts.home-mirror = {
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          ${mkUserLinks config.this.user.me.name config.this.home}
        '';
        deps = [ "users" ];
      };

      # 🦆 duck say ⮞ Set user variiables quack
      environment.variables = {
        BROWSER = "firefox";
        EDITOR = "nano";
        TERMINAL = "ghostty";
        QT_QPA_PLATFORMTHEME = "gtk3";
        QT_SCALE_FACTOR = "1";
        MOZ_ENABLE_WAYLAND = "1";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        CLUTTER_BACKEND = "wayland";
        XDG_CURRENT_DESKTOP = "gnome";
        XDG_SESSION_DESKTOP = "gnome";
        XDG_SESSION_TYPE = "wayland";
        GTK_USE_PORTAL = "1";
        XDG_CACHE_HOME = "\${HOME}/.cache";
        XDG_CONFIG_HOME = "\${HOME}/.config";
        XDG_BIN_HOME = "\${HOME}/dotfiles/home/bin";
        XDG_DATA_HOME = "\${HOME}/.local/share";
        NIX_PATH = lib.mkForce "nixpkgs=flake:nixpkgs";
      };
    })
  ];}
