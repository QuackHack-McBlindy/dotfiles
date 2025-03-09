{ 
  config,
  lib,
  pkgs,
  ...
} : 
let
  admin = "pungkula";
  transmission-pw = config.sops.secrets.transmission.path;
in
{    
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {      
      transmission = {
        image = "lscr.io/linuxserver/transmission:latest";
        #hostname = "transmission";
        dependsOn = [ "gluetun" ];
        extraOptions = [ "--network=container:gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/transmission/config:/config"
          "/Pool/Downloads:/downloads"
          "/Pool/Watch:/watch"
        ];
        environment = {
          USER = admin
          PASS = transmission-pw
          TZ = "Europe/Stockholm
        };
      };
      prowlarr = {
        image = "lscr.io/linuxserver/prowlarr:latest";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/prowlarr/config:/config"
        ];
     #   environmentFiles = [
     #     /docker/env/prowlarr/.env
    #      /docker/env/prowlarr/.env.secret     
    #    ];
      };
      radarr = {
        image = "lscr.io/linuxserver/radarr:latest";
        #hostname = "radarr";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/radarr/config:/config"
          "/Pool/Movies:/movies" #optional
          "/Pool/Downloads:/downloads" #optional
        ];
       # environmentFiles = [
     #     /docker/env/radarr/.env
    #      /docker/env/radarr/.env.secret     
  #      ];
      };
      lidarr = {
        image = "lscr.io/linuxserver/lidarr:latest";
        #hostname = "lidarr";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/lidarr/config:/config"
          "/Pool/Music:/music" #optional
          "/Pool/Downloads:/downloads" #optional
        ];
     #   environmentFiles = [
     #     /docker/env/lidarr/.env
     #     /docker/env/lidarr/.env.secret     
     #   ];
      };
      sonarr = {
        image = "lscr.io/linuxserver/sonarr:latest";
        #hostname = "sonarr";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/sonarr/config:/config"
          "/Pool/TV:/tv" #optional
          "/Pool/Downloads:/downloads" #optional
        ];
     #   environmentFiles = [
    #      /docker/env/sonarr/.env
   #       /docker/env/sonarr/.env.secret     
     #   ];
      };
      readarr = {
        image = "lscr.io/linuxserver/readarr:develop";
        #hostname = "readarr";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/readarr/config:/config"
          "/Pool/Books:/books" #optional
          "/Pool/Downloads:/downloads" #optional
        ];
     #   environmentFiles = [
    #      /docker/env/readarr/.env
    #      /docker/env/readarr/.env.secret     
    #    ];
      };
      requestrr = {
        image = "thomst08/requestrr:latest";
        #hostname = "requestrr";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/requestrr/config:/root/config"
        ];
     #   environmentFiles = [
      #    /docker/env/requestrr/.env
      #    /docker/env/requestrr/.env.secret     
      #  ];
      };
      flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr:latest";
        #hostname = "flaresolverr";
        dependsOn = [ "gluetun" ];
        extraOptions = [ "--network=container:gluetun" ];
        autoStart = true;
     #   environmentFiles = [
     #     /docker/env/flaresolverr/.env
    #      /docker/env/flaresolverr/.env.secret     
   #     ];
      };
      podgrab = {
        image = "akhilrex/podgrab";
        #hostname = "podgrab";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/podgrab/config:/config"
          "/Pool/Podcasts:/assets"
        ];
 #       environmentFiles = [
 #         /docker/env/podgrab/.env
#          /docker/env/podgrab/.env.secret     
  #      ];
      };
      bazarr = {
        image = "lscr.io/linuxserver/bazarr:latest";
        #hostname = "bazarr";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/bazarr/config:/config"
          "/Pool/Movies:/movies" #optional
          "/Pool/TV:/tv" #optional
        ];
     #   environmentFiles = [
    #      /docker/env/bazarr/.env
    #      /docker/env/bazarr/.env.secret     
  #     ];
      };
      jellyseerr = {
        image = "";
        #hostname = "jellyseerr";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/jellyserr/config:/app/config"
         #    - /mnt/data/supervisor/addons/local/jellyserr/duck2.svg:/app/public/logo_full.svg
         #       - /mnt/data/supervisor/addons/local/jellyserr/duck2.png:/app/public/logo_full.png
         #       - /mnt/data/supervisor/addons/local/jellyserr/logo_stacked.svg:/app/public/logo_stacked.svg
         #       - /mnt/data/supervisor/addons/local/jellyserr/duck2.png:/app/public/os_logo_square.png
        ];
  #      environmentFiles = [
    #      /docker/env/jellyseerr/.env
   #       /docker/env/jellyseerr/.env.secret     
   #     ];
      };
#      navidrome = {
#       image = "deluan/navidrome:latest";
        #hostname = "navidrome";
       # dependsOn = [ "gluetun" ];
  #      volumes = [
  #        "/docker/navidrome/config:/data"
 #         "/Pool/Music:/music:ro"     
 #       ];
  #      ports = [ 
  #        "4533:4533"
    #    ];
  #      environment = [
      #- C:\docker4\jellyseer\src:/app/src
      #- C:\docker4\jellyseer\public:/app/publc
      #- C:\docker4\jellyseer\server:/app/server
      #- C:\docker4\jellyseer\docs:/app/docs
########   JELLYSEER IMAGES BELOW    #########
#      - C:\docker4\jellyseer\logo_stacked.svg:/app/public/logo_stacked.svg
#      - C:\docker4\jellyseer\logo_stacked.svg:/jellyseerr/logo_stacked.svg
#      - C:\docker4\jellyseer\logo_full.svg:/app/overseerr/public/logo_full.svg
#      - C:\docker4\jellyseer\logo_full.svg:/app/public/logo_full.svg
#      - C:\docker4\jellyseer\logo_full.png:/app/public/logo_full.png
#      - C:\docker4\jellyseer\android-chrome-192x192.png:/app/public/android-chrome-192x192.png
#      - C:\docker4\jellyseer\android-chrome-512x512.png:/app/public/android-chrome-512x512.png
#      - C:\docker4\jellyseer\apple-touch-icon.png:/app/public/apple-touch-icon.png
#      - C:\docker4\jellyseer\badge-128x128.png:/app/public/badge-128x128.png
#      - C:\docker4\jellyseer\favicon-16x16.png:/app/public/favicon-16x16.png
##      - C:\docker4\jellyseer\favicon-32x32.png:/app/public/favicon-32x32.png
#      - C:\docker4\jellyseer\mstile-150x150.png:/app/public/mstile-150x150.png
#      - C:\docker4\jellyseer\os_logo_filled.png:/app/public/os_logo_filled.png
#      - C:\docker4\jellyseer\os_logo_square.png:/app/public/os_logo_square.png
#      - C:\docker4\jellyseer\images\overseerr_poster_not_found.png:/app/public/images/overseerr_poster_not_found.png
#overseerr_poster_not_found_logo_center.png
#      - C:\docker4\jellyseer\images\overseerr_poster_not_found_logo_top.png:/app/public/images/overseerr_poster_not_found_logo_top.png
#      - C:\docker4\jellyseer\apple-splash-640-1136.jpg:/app/public/apple-splash-640-1136.jpg
#      - C:\docker4\jellyseer\apple-splash-750-1334.jpg:/app/public/apple-splash-750-1334.jpg
#      - C:\docker4\jellyseer\apple-splash-1284-2778.jpg:/app/public/apple-splash-1284-2778.jpg
#      - C:\docker4\jellyseer\apple-splash-1242-2688.jpg:/app/public/apple-splash-1242-2688.jpg
#      - C:\docker4\jellyseer\apple-splash-1242-2208.jpg:/app/public/apple-splash-1242-2208.jpg
#      - C:\docker4\jellyseer\apple-splash-1170-2532.jpg:/app/public/apple-splash-1170-2532.jpg
#      - C:\docker4\jellyseer\apple-splash-1125-2436.jpg:/app/public/apple-splash-1125-2436.jpg
#      - C:\docker4\jellyseer\apple-splash-828-1792.jpg:/app/public/apple-splash-828-1792.jpg
#      - C:\docker4\jellyseer\apple-splash-1536-2048.jpg:/app/public/apple-splash-1536-2048.jpg
#      - C:\docker4\jellyseer\android-chrome-192x192_maskable.png:/app/public/android-chrome-192x192_maskable.png
#      - C:\docker4\jellyseer\android-chrome-512x512_maskable.png:/app/public/android-chrome-512x512_maskable.png
#      - C:\docker4\jellyseer\android-icon-192x192.png:/app/public/android-icon-192x192.png
#      - C:\docker4\jellyseer\android-icon-144x144.png:/app/public/android-icon-144x144.png
#      - C:\docker4\jellyseer\android-icon-48x48.png:/app/public/android-icon-48x48.png
#      - C:\docker4\jellyseer\android-icon-36x36.png:/app/public/android-icon-36x36.png
#      - C:\docker4\jellyseer\favicon.ico:/app/public/favicon.ico 
#        ];
#      };   
    };
  };
  sops.secrets = {
    transmission = {
      sopsFile = ./../../secrets/transmission.yaml";
      owner = "transmission";
      group = "transmission";
      mode = "0440"; # Read-only for owner and group
    };
  };
  users.users.transmission = {
    home = "/var/lib/transmission";
    createHome = true;
    isSystemUser = true;
    group = "transmission";
  };  
  users.groups.transmisison = {};

}
