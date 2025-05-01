# modules/system/gtk.nix
{ 
  config,
  lib,
  pkgs,
  ...
} : let
  cfg = config.this.theme;
  username = config.this.user.me.name;
  userHome = config.users.users.${username}.home;
  
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
              # Create GTK config directories
              mkdir -p "${userHome}/.config/gtk-3.0"
              mkdir -p "${userHome}/.config/gtk-4.0"

              # Generate settings.ini files
              ${lib.concatStrings (lib.mapAttrsToList (k: v: ''
                echo "Writing ${k} to GTK config"
                echo -e "[Settings]\n${k}=${v}" | tee \
                "${userHome}/.config/gtk-3.0/settings.ini" \
                "${userHome}/.config/gtk-4.0/settings.ini" >/dev/null
              '') cfg.gtkSettings)}

              # Symlink theme CSS
              ln -sf "${cfg.styles}" "${userHome}/.config/gtk-3.0/gtk.css"
              ln -sf "${cfg.styles}" "${userHome}/.config/gtk-4.0/gtk.css"

              # Set permissions
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

