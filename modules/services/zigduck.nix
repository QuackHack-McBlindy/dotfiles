# dotfiles/modules/services/zigduck.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞ enables zigduck service 
  config,
  lib,
  pkgs,
  self,
  ...
} : let

in {
  config = lib.mkMerge [   
    {      
      services.zigduck = {
        enable = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) true;
        cli.enable = true;
        dashboard.enable = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) true;
        dashboard.port = 13337;
        dashboard.openFirewall = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) true;
        dashboard.passwordFile = config.sops.secrets.api.path;
        dashboard.secure = false;                
        extraEnv.PATH = 
          "/run/current-system/sw/bin:"
          + "/run/wrappers/bin:"
          + "/nix/var/nix/profiles/default/bin:"
          + "/nix/var/nix/profiles/default/sbin:"
          + "/run/current-system/sw/sbin";
      };            
    }
   
  ];}
