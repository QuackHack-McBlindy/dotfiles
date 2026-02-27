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
    (lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) {
      environment.systemPackages = [ self.packages.x86_64-linux.zigduck-rs ];
      services.zigduck.enable = true;           
    })
   
  ];}
