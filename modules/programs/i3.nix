# dotfiles/modules/programs/i3.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkIf (lib.elem "i3" config.this.host.modules.programs) {
      services.xserver.windowManager.i3 = {
        enable = true;
      };     
      
    };}

