# dotfiles/modules/services/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  config,
  lib,
  pkgs,
  ...
} : let
  cfg = config.this.host.modules.services;
in {
    config = lib.mkIf (lib.elem "default" cfg) {
        services.atd.enable = true; 
    
    };}
