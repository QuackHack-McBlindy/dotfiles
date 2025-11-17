# dotfiles/modules/system/gtk.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says⮞ GTK configuration
  config,
  lib,
  pkgs,
  ...
} : let 
  cfg = config.this.theme;
  username = config.this.user.me.name;
  userHome = config.users.users.${username}.home;

  # 𝑸𝓾𝒂𝒄𝒌𝑯𝒂𝒄𝒌-𝑴𝒄𝑩𝒍𝒊𝒏𝒅𝒚
  bookmarks = ''
    file:///home/${username}/dotfiles ❄️ ⮞ 𝘿𝙤𝙩𝙛𝙞𝙡𝙚𝙨
    file:///home/${username} 👤 ⮞ 𝒑𝒖𝒏𝒈𝒌𝒖𝒍𝒂
    file:///home/${username}/.config 🛠️ ⮞ .𝘾𝙤𝙣𝙛𝙞𝙜
    file:///home/${username}/projects 💡 ⮞ 𝙋𝙧𝙤𝙟𝙚𝙘𝙩𝙨
    file:///home/${username}/Downloads 📥 ⮞ 𝘿𝙤𝙬𝙣𝙡𝙤𝙖𝙙𝙨
    file:///home/${username}/Public 📤 ⮞ 𝙋𝙪𝙗𝙡𝙞𝙘
    file:///home/${username}/blog 📝 ⮞ 𝗕𝗹𝗼𝗴    
    file:///Pool 💾 ⮞ 𝙋𝙤𝙤𝙡
    file:///Files 🛡️ ⮞ 𝙁𝙞𝙡𝙚 𝙑𝙖𝙪𝙡𝙩

  '';
 
in {  
  options.this.theme = {
    enable = lib.mkEnableOption "GTK theme configuration";
    gtkSettings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        "gtk-application-prefer-dark-theme" = "1";
        "gtk-cursor-theme-name" = "Bibata-Modern-Classic";
        "gtk-icon-theme-name" = "elementary-xfce-icon-theme";
      };
      description = "GTK settings attributes";
    };
  };


  config = lib.mkMerge [
    (lib.mkIf (lib.elem "gtk" config.this.host.modules.system) {

      systemd.services.gtk-theme-setup = {
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = let
            script = pkgs.writeShellScriptBin "gtk-theme-init" ''
              # 🦆 says⮞ create GTK config directories
              mkdir -p "${userHome}/.config/gtk-3.0"
              mkdir -p "${userHome}/.config/gtk-4.0"

              # 🦆 says⮞create bookmarks
              echo "${bookmarks}" | tee \
                "${userHome}/.config/gtk-3.0/bookmarks" \
                "${userHome}/.config/gtk-4.0/bookmarks" >/dev/null

              # 🦆 says⮞generate settings.ini files
              ${lib.concatStrings (lib.mapAttrsToList (k: v: ''
                echo "Writing ${k} to GTK config"
                echo -e "[Settings]\n${k}=${v}" | tee \
                "${userHome}/.config/gtk-3.0/settings.ini" \
                "${userHome}/.config/gtk-4.0/settings.ini" >/dev/null
              '') cfg.gtkSettings)}

              # 🦆 says⮞symlink theme CSS
              ln -sf "${cfg.styles}" "${userHome}/.config/gtk-3.0/gtk.css"
              ln -sf "${cfg.styles}" "${userHome}/.config/gtk-4.0/gtk.css"

              # 🦆 says⮞set permissions
              chown -R ${username}:users "${userHome}/.config/gtk-*"
              chmod 700 "${userHome}/.config/gtk-3.0" "${userHome}/.config/gtk-4.0"
            '';
          in "${script}/bin/gtk-theme-init";
        };
      };

      environment.systemPackages = with pkgs; [
        bibata-cursors
        elementary-xfce-icon-theme
      ];
    })
    
  ];}
