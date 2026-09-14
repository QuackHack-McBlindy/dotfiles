# dotfiles/modules/programs/hyprland.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkIf (lib.elem "hypr" config.this.host.modules.programs) {
      environment.systemPackages = with pkgs; [ hyprland ];
      programs.hyprland.enable = true;
      services.xserver.windowManager.hypr.enable = true;

      services.xserver.displayManager.session = [
        {
          manage = "desktop";
          name = "hyprland";
          start = "Hyprland";
        }
      ];


    };}
