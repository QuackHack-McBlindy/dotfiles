{
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  homeBase = config.this.user.me.dotfilesDir + "/home";
  sanitize = path:
    replaceStrings ["/"] ["-"] (removePrefix "/" (removePrefix "./" path));

  mkUserLinks = user: baseDir: let
    userHome  = config.users.users.${user}.home;
    storePath = builtins.path {
      path = baseDir;
      name = "home-manifest";
    };
  in ''
    echo "🦆 duck say ⮞ Mirroring home directory for ${user}"

    find ${storePath} -type f -print0 | while IFS= read -r -d $'\0' src; do
      rel_path="''${src#${storePath}/}"
      target="${userHome}/''${rel_path}"
      dir="$(dirname "$target")"

      mkdir -vp "$dir"

      [[ -e "$target" && ! -L "$target" ]] && mv -f "$target" "$target.backup"
      ln -vsfn "$src" "$target"
      chown -h ${user}:users "$target"

      echo "🦆 duck say ⮞ Linked: $rel_path"
    done
  '';

in {

  options = {
    file = mkOption {
      type = types.attrsOf (types.either types.lines types.path);
      default = {};
      description = "Files to create directly under ${homeBase} (string content or a store path to copy).";
    };

    copy = mkOption {
      type = types.attrsOf (types.either types.lines types.path);
      default = {};
      description = "Files to create under ${homeBase} that are COPIED (not symlinked) into the user's home when mirroring. Use for git-tracked dirs pushed to remotes that can't read /nix/store.";
    };

    link = mkOption {
      type = types.attrsOf types.path;
      default = {};
      description = "Files/directories to symlink under ${homeBase} (paths or store paths)";
    };

    git.subRepo = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          url = mkOption { type = types.str; };
          rev = mkOption { type = types.str; };
          submodules = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to init/update submodules recursively";
          };
        };
      });
      default = {};
      description = "${pkgs.git}/bin/git repositories with submodules to clone into home directory";
    };

    this.home = mkOption {
      type = types.path;
      description = "Directory to mirror to home directory";
    };
  };

  config = mkMerge [

    {
      system.activationScripts.simpleFiles = {
        text = concatStringsSep "\n" (mapAttrsToList (path: content:
          let
            fullPath = "${homeBase}/${path}";
            dir      = dirOf fullPath;
            username = config.this.user.me.name;

            isStore = builtins.isPath content || builtins.getContext content != {};
            src     = if isStore
                      then toString content
                      else toString (pkgs.writeText "file-${sanitize path}" content);
            mode    = if isStore then "644" else "600";
          in ''
            mkdir -p "${dir}"
            rm -f "${fullPath}"
            cp -f "${src}" "${fullPath}"
            chown "${username}:users" "${fullPath}"
            chmod ${mode} "${fullPath}"
            echo "🦆 duck say ⮞ Created file: ${fullPath}"
          ''
        ) config.file);
        deps = [];
      };


      system.activationScripts.simpleLinks = let
        username = config.this.user.me.name;
        mkLink = path: source:
          let
            fullPath = "${homeBase}/${path}";
            dir = dirOf fullPath;
          in ''
            mkdir -p "${dir}"
            if [[ -e "${fullPath}" && ! -L "${fullPath}" ]]; then
              mv -f "${fullPath}" "${fullPath}.backup"
            fi
            ln -vsfn "${toString source}" "${fullPath}"
            chown -h "${username}:users" "${fullPath}"
            echo "🦆 duck say ⮞ Linked: ${fullPath} → ${toString source}"
          '';
      in {
        text = concatStringsSep "\n" (mapAttrsToList mkLink config.link);
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
        **🦆 duck say ⮞ quack - my home my rulez**
        **🦆 duck say ⮞ i create filez**

        ```nix
          file."ducks.md" = "🦆 duck say ⮞ like diz yay";
        ```

        **🦆 duck say ⮞ i symlink pathz**

        ```nix
          link".config/myapp" = pkgs.somePackage;
        ```


        ## 🦆 ⭐ 🦆 ⭐ 🦆 ⭐

        [![Star History](total-stars.svg)](https://github.com/QuackHack-McBlindy/)

      '';
    }

    (mkIf (config.this.home != null) {
      system.activationScripts.home-mirror = {
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          ${mkUserLinks config.this.user.me.name config.this.home}
        '';
        deps = [ "users" ];
      };

      system.activationScripts.copyFiles = {
        text = concatStringsSep "\n" (mapAttrsToList (path: content:
          let
            fullPath = "${config.users.users.${config.this.user.me.name}.home}/${path}";
            dir      = dirOf fullPath;
            username = config.this.user.me.name;

            isStore = builtins.isPath content || builtins.getContext content != {};
            src     = if isStore
                      then toString content
                      else toString (pkgs.writeText "copy-${sanitize path}" content);
            mode    = if isStore then "644" else "600";
          in ''
            mkdir -p "${dir}"
            rm -f "${fullPath}"
            cp -fL "${src}" "${fullPath}"
            chown "${username}:users" "${fullPath}"
            chmod ${mode} "${fullPath}"
            echo "🦆 duck say ⮞ Copied directly to home: ${fullPath}"
          ''
        ) config.copy);
        deps = [ "users" ];
      };

      environment.systemPackages = with pkgs; [ git openssh ];

      system.activationScripts.submodule-mirror = {
        deps = [ "home-mirror" ];
        text = let
          userName = config.this.user.me.name;
          userHome = config.users.users.${userName}.home;
          gitBin = "${pkgs.git}/bin";
          sshBin = "${pkgs.openssh}/bin";
          mkRepoScript = name: spec: ''
            echo "🦆 Managing submodule repo: ${name} -> ${spec.url}"
            target="${userHome}/${name}"

            # 🦆 Run as user with proper PATH and SSH command
            ${pkgs.sudo}/bin/sudo -u ${userName} ${pkgs.bash}/bin/bash -c "\
              export PATH=${gitBin}:${sshBin}:\$PATH
              export GIT_SSH_COMMAND=${sshBin}/ssh
              set -e
              target='$target'
              if [[ ! -d \"\$target/.git\" ]]; then
                echo 'Cloning ${spec.url} (with submodules)...'
                ${gitBin}/git clone --recursive '${spec.url}' \"\$target\"
              else
                echo 'Updating ${spec.url}...'
                (cd \"\$target\" && ${gitBin}/git fetch --all)
              fi
              (cd \"\$target\" && ${gitBin}/git checkout -f '${spec.rev}')
              if [[ '${boolToString spec.submodules}' == 'true' ]]; then
                (cd \"\$target\" && ${gitBin}/git submodule update --init --recursive --force)
              fi
            "
          '';
        in concatStringsSep "\n" (mapAttrsToList mkRepoScript config.git.subRepo);
      };

      # 🦆 say ⮞ Set user variiables quack
      environment.variables = {
        BROWSER = "firefox-esr";
        EDITOR = "nano";
        TERMINAL = "ghostty";
        QT_QPA_PLATFORMTHEME = "gtk3";
        QT_SCALE_FACTOR = "1";
        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland";
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
