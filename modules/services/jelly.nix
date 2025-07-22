{ 
  config, 
  lib, 
  pkgs, 
  ... 
} : { 
  services.jellyfin = lib.mkIf (lib.elem "jelly" config.this.host.modules.services) {
    enable = true;
    dataDir = "/var/lib/jellyfin";
    package = pkgs.jellyfin;
    openFirewall = true;
  };}


