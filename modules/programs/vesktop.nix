# dotfiles/modules/programs/vesktop.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ vesktop configuration
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  cfg = config.this.host.modules.programs;
  user = config.this.user.me.name;
  themeCSS = builtins.readFile config.this.theme.styles;  
  vesktopThemeDir = "/home/${config.this.user.me.name}/.config/vesktop/themes";  
in {
  config = lib.mkIf (lib.elem "vesktop" cfg) {
#    file.".config/vesktop/themes/globalTheme.css" = themeCSS:
  
    systemd.services.vesktop-profile = {
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = let
          script = pkgs.writeShellScriptBin "vesktop-init" ''
            mkdir -p "${vesktopThemeDir}"
            # 🦆says⮞ create globalTheme.css
            cat > "${vesktopThemeDir}/globalTheme.css" <<EOF
${themeCSS}
EOF
            chown -R ${user}:${user} "${vesktopThemeDir}"
            chmod -R 755 "${vesktopThemeDir}"
          '';
        in "${script}/bin/vesktop-init";
      };
    }; 
  
    environment.systemPackages = [
      pkgs.vesktop  
    ];

  };}
