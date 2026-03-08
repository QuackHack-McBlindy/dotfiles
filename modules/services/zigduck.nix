# dotfiles/modules/services/zigduck.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞ enables zigduck service 
  config,
  lib,
  pkgs,
  self,
  ...
} : let
  # 🦆 says ⮞ icon map
  icons = {
    light = {
      ceiling         = "mdi:ceiling-light";
      strip           = "mdi:light-strip";
      spotlight       = "mdi:spotlight";
      bulb            = "mdi:lightbulb";
      bulb_color      = "mdi:lightbulb-multiple";
      desk            = "mdi:desk-lamp";
      floor           = "mdi:floor-lamp";
      wall            = "mdi:wall-sconce-round";
      chandelier      = "mdi:chandelier";
      pendant         = "mdi:vanity-light";
      nightlight      = "mdi:lightbulb-night";
      strip_rgb       = "mdi:led-strip-variant";
      reading         = "mdi:book-open-variant";
      candle          = "mdi:candle";
      ambient         = "mdi:weather-night";
    };
    sensor = {
      motion          = "mdi:motion-sensor";
      smoke           = "mdi:smoke-detector";
      water           = "mdi:water";
      contact         = "mdi:door";
      temperature     = "mdi:thermometer";
      humidity        = "mdi:water-percent";
    };
    remote            = "mdi:remote";
    outlet            = "mdi:power-socket-eu";
    dimmer            = "mdi:toggle-switch";
    pusher            = "mdi:gesture-tap-button";
    blinds            = "mdi:blinds";
  };


in {
  config = lib.mkMerge [
    (lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) {
      environment.systemPackages = [ self.packages.x86_64-linux.zigduck-rs ];
      services.zigduck = {
        enable = true;
        broker = "192.168.1.211";
        extraEnv.PATH = 
          "/run/current-system/sw/bin:"
          + "/run/wrappers/bin:"
          + "/nix/var/nix/profiles/default/bin:"
          + "/nix/var/nix/profiles/default/sbin:"
          + "/run/current-system/sw/sbin";
      };              
          
    })

    {
      services.zigduck.cli.broker = "192.168.1.211";
    }
   
  ];}
