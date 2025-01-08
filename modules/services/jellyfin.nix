# EMPTY NIX OS MODULE
# import into flake.
{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    package = pkgs.jellyfin;
    user = "ducky";
    group = "jellyfin";
    dataDir = "/srv/jellyfin/data";
    configDir = "/srv/jellyfin/config";
    cacheDir = "/srv/jellyfin/cache";
    logDir = "/srv/jellyfin/logs";
    openFirewall = true;
  };

  # Other configurations...
}
}
