{ pkgs, config, lib, ... }:
let
  cfg = config.customization.gdm-logo;
in
{
  options.customization.gdm-logo = {
    enable = lib.mkEnableOption "GDM icon customization";
    logoPath = lib.mkOption {
      type = lib.types.path;
      default = ./artwork/logo-horizontal-white.png;
      description = "Path to the logo file";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.dconf.profiles.gdm.databases = [{
      settings."org/gnome/login-screen" = {
        logo = builtins.toString cfg.logoPath;
      };
    }];
  };
}
