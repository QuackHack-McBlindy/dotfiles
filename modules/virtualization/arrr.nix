{ 
  config,
  lib,
  pkgs,
  ...
} : let 
  
 #  dockerUID = config.users.users.dockeruser.uid;
#   dockerGID = config.users.groups.dockeruser.gid;
      
   env = pkgs.writeText ".env" ''
        TZ="Europe/Berlin"
        PUID="0"  
        PGID="0"
        USER="admin"
        PASS="admin" 
        SHADOWPASS="@SHADOWPASS@"
    '';
  
in {
    imports = [ ./gluetun.nix ];

    systemd.services.arr-conf = {
        wantedBy = [ "multi-user.target" ];
        preStart = ''
            touch /docker/arr.env
            sed -e "/@TRANS@/{
                s|@TRANS@|$(cat ${config.sops.secrets.transmission.path})|
            }" \
            -e "/@SHADOWPASS@/{
                s|@SHADOWPASS@|$(cat ${config.sops.secrets.SHADOWSOCKS_PASSWORD.path})|
            }" ${env} > /docker/arr.env                
        '';
    
        serviceConfig = {
            ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
            Restart = "on-failure";
            RestartSec = "2s";
      #      RuntimeDirectory = [ "dockeruser" ];
            User = "root";
        };
    };
    
    sops.secrets = {
        transmission = {
            sopsFile = ./../../secrets/transmission.yaml;
            owner = "pungkula";
            group = "pungkula";
            mode = "0440"; 
        };
    };


    virtualisation.oci-containers = {
        backend = "docker";
        containers = {
            transmission = {
                image = "lscr.io/linuxserver/transmission:latest";
                # user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/transmission/config:/config"
                    "/Pool/Downloads:/downloads"
                    "/Pool/Watch:/watch"
                ];
                environmentFiles = [ "/docker/arr.env" ];
            }; 
      
            prowlarr = {
                image = "lscr.io/linuxserver/prowlarr:latest";
                # user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/prowlarr/config:/config"
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            radarr = {
                image = "lscr.io/linuxserver/radarr:latest";
                # user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/radarr/config:/config"
                    "/Pool/Movies:/movies" #optional
                    "/Pool/Downloads:/downloads" #optional
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            lidarr = {
                image = "lscr.io/linuxserver/lidarr:latest";
                # user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/lidarr/config:/config"
                    "/Pool/Music:/music" 
                    "/Pool/Downloads:/downloads" 
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            sonarr = {
                image = "lscr.io/linuxserver/sonarr:latest";
                # user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/sonarr/config:/config"
                    "/Pool/TV:/tv" 
                   "/Pool/Downloads:/downloads"
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            readarr = {
                image = "lscr.io/linuxserver/readarr:develop";
                # user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/readarr/config:/config"
                    "/Pool/Books:/books"
                    "/Pool/Downloads:/downloads"
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            requestrr = {
                image = "thomst08/requestrr:latest";
                # user = "2000:2000"; 
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/requestrr/config:/root/config"
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            flaresolverr = {
                image = "ghcr.io/flaresolverr/flaresolverr:latest";
                # user = "2000:2000";
                dependsOn = [ "gluetun" ];
                extraOptions = [ "--network=container:gluetun" ];
                autoStart = true;
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            podgrab = {
                image = "akhilrex/podgrab";
                # user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/podgrab/config:/config"
                    "/Pool/Podcasts:/assets"
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            bazarr = {
                image = "lscr.io/linuxserver/bazarr:latest";
                # user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/bazarr/config:/config"
                    "/Pool/Movies:/movies"
                    "/Pool/TV:/tv" 
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
        };
    };}
    


    
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
#    };
#  };
#}
