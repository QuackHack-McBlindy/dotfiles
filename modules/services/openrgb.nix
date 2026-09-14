# dotfiles/modules/services/openrgb.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ rgb control
  config,
  lib,
  pkgs,
  self,
  ...
} : let

in {
    config = lib.mkIf (lib.elem "openrgb" config.this.host.modules.services) {
        environment.systemPackages = [ pkgs.openrgb ];

        #boot.kernelModules = [ "i2c-dev" ];

        hardware.i2c.enable = true;
        services.hardware.openrgb = {
            enable = true;
            #package = pkgs.openrgb-with-all-plugins;
            server.port = 6742;
            # he profile file to load from “/var/lib/OpenRGB” at startup.
            startupProfile = null;
            motherboard = "intel";
        };

    };}
