# dotfiles/modules/programs/thunar.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ thunar configuration
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkIf (lib.elem "thunar" config.this.host.modules.programs) {
        environment.systemPackages = with pkgs; [ xfce.thunar ];
        programs.xfconf.enable = true;
        programs.thunar.enable = true;
        services.gvfs.enable = true; # 🦆says⮞ mount, trash, etc.
        services.tumbler.enable = true; # 🦆says⮞ thumbnail support   
        programs.thunar.plugins = with pkgs.xfce; [
            thunar-archive-plugin
            thunar-volman
        ];
        
    };}

