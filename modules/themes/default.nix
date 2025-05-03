# modules/themes/default.nix
{ 
  lib,
  config,
  pkgs,
  ...
} : with lib;
let
  cfg = config.this.theme;
  themePath = ./css + "/${cfg.name}";
in {
  options.this.theme = {
    name = mkOption {
      type = types.str;
      default = "crazy.css";
      description = "Active theme file name";
      apply = v:
        if ! builtins.pathExists (./css + "/${v}") 
        then throw "Theme ${v} not found in ${toString ./css}"
        else v;
    };

    styles = mkOption {
      type = types.path;
      readOnly = true;
      default = themePath;
      description = "Resolved path to theme CSS file";
    };

    # Fixed submodule definitions
    iconTheme = mkOption {
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            default = "Adwaita";
            description = "Icon theme name";
          };
          package = mkOption {
            type = types.package;
            default = pkgs.adwaita-icon-theme;
            description = "Package providing the icon theme";
          };
        };
      };
      default = {};
    };

    cursorTheme = mkOption {
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            default = "Adwaita";
            description = "Cursor theme name";
          };
          package = mkOption {
            type = types.package;
            default = pkgs.adwaita-icon-theme;
            description = "Package providing the cursor theme";
          };
          size = mkOption {
            type = types.int;
            default = 24;
            description = "Cursor size in pixels";
          };
        };
      };
      default = {};
    };

    # Add fonts submodule
    fonts = mkOption {
      type = types.submodule {
        options = {
          system = mkOption {
            type = types.str;
            default = "DejaVu Sans";
            description = "System UI font family";
          };
          monospace = mkOption {
            type = types.str;
            default = "DejaVu Sans Mono";
            description = "Monospace font family";
          };
          packages = mkOption {
            type = types.listOf types.package;
            default = [];
            description = "Font packages to install";
          };
        };
      };
      default = {};
    };
  };

  
  config = mkMerge [
    {
      # Font configuration (always applied)
      fonts = {
        packages = mkIf (cfg.fonts.packages != []) cfg.fonts.packages;
        fontconfig = {
          enable = true;
          defaultFonts = {
            sansSerif = [ cfg.fonts.system ];
            monospace = [ cfg.fonts.monospace ];
          };
        };
      };

      # Required for dconf theming
      programs.dconf.enable = true;
    }
    
    (mkIf (cfg.iconTheme != {}) {
      # Icon theme configuration
      environment.systemPackages = [ cfg.iconTheme.package ];
      programs.dconf.profiles.user.databases = [{
        settings = {
          "org/gnome/desktop/interface" = {
            icon-theme = cfg.iconTheme.name;
          };
        };
      }];
    })
    
    (mkIf (cfg.cursorTheme != {}) {
      # Cursor theme configuration
      environment.systemPackages = [ cfg.cursorTheme.package ];
      environment.sessionVariables = {
        XCURSOR_THEME = cfg.cursorTheme.name;
        XCURSOR_SIZE = toString cfg.cursorTheme.size;
      };
      programs.dconf.profiles.user.databases = [{
        settings = {
          "org/gnome/desktop/interface" = {
            cursor-theme = cfg.cursorTheme.name;
          };
        };
      }];
    })
  ];
}
