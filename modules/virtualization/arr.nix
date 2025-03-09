{ 
  config,
  lib,
  pkgs,
  ...
} : 


{
  imports = [ ./gluetun.nix ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      prowlarr = {
        image = "lscr.io/linuxserver/prowlarr:latest";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/prowlarr/config:/config"
        ];
      };
      
      radarr = {
        image = "lscr.io/linuxserver/radarr:latest";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/radarr/config:/config"
          "/Pool/Movies:/movies" #optional
          "/Pool/Downloads:/downloads" #optional
        ];
      };
      lidarr = {
        image = "lscr.io/linuxserver/lidarr:latest";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/lidarr/config:/config"
          "/Pool/Music:/music" #optional
          "/Pool/Downloads:/downloads" #optional
        ];
      };
      sonarr = {
        image = "lscr.io/linuxserver/sonarr:latest";
        extraOptions = [ "--network=container:gluetun" ];
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/sonarr/config:/config"
          "/Pool/TV:/tv" #optional
          "/Pool/Downloads:/downloads" #optional
        ];
      };
      
      readarr = {
        image = "lscr.io/linuxserver/readarr:develop";
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
#      jellyseerr = {
#        image = "";
        #hostname = "jellyseerr";
#        extraOptions = [ "--network=container:gluetun" ];
#        dependsOn = [ "gluetun" ];
#        autoStart = true;
#        volumes = [
#          "/docker/jellyserr/config:/app/config"
         #    - /mnt/data/supervisor/addons/local/jellyserr/duck2.svg:/app/public/logo_full.svg
         #       - /mnt/data/supervisor/addons/local/jellyserr/duck2.png:/app/public/logo_full.png
         #       - /mnt/data/supervisor/addons/local/jellyserr/logo_stacked.svg:/app/public/logo_stacked.svg
         #       - /mnt/data/supervisor/addons/local/jellyserr/duck2.png:/app/public/os_logo_square.png
#        ];
  #      environmentFiles = [
    #      /docker/env/jellyseerr/.env
   #       /docker/env/jellyseerr/.env.secret
   #     ];
#      };
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
  #      environmentFiles = [
  #        /docker/env/navidrome/.env
 #         /docker/env/navidrome/.env.secret
#        ];
#      };
    };
  };


}
