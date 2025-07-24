{ 
  config, 
  lib, 
  pkgs, 
  ... 
} : let
in {
  environment.systemPackages = lib.mkIf (lib.elem "jelly" config.this.host.modules.services) [
    pkgs.jellyfin
    pkgs.jellyfin-web
  ];

  services.jellyfin = lib.mkIf (lib.elem "jelly" config.this.host.modules.services) {
    enable = true;
    dataDir = "/var/lib/jellyfin";
    package = pkgs.jellyfin;
    openFirewall = true;
  };}
