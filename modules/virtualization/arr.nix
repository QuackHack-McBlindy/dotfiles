{ config, pkgs, ... }:
{    
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {  
      gluetun = {
        image = "qmcgaw/gluetun";
        hostname = "gluetun";
        cmd = ["--cap-add=NET_ADMIN --device=/dev/net/tun:/dev/net/tun"];
        ports = [
          "8888:8888" # gluetun
          "8388:8388" # shadowsocks
          "8001:8000" # http proxy?
          "51413:51413" # vpn forwarding
          "8118:8118" # browserVPN
        ]; 
        volumes = [
          "/docker/gluetun/config:/gluetun"
          "/docker/gluetun/forwardedports.txt:/tmp/gluetun/forwardedport.txt"
        ];  
        environment = [
          SHADOWSOCKS=on
          SHADOWSOCKS_PASSWORD=config.sops.secrets.SHADOWSOCKS_PASSWORD.path;
          VPN_SERVICE_PROVIDER=protonvpn;
          OPENVPN_USER=config.sops.secrets.PROTON_OPENVPN_USER.path;
          OPENVPN_PASSWORD=config.sops.secrets.PROTON_OPENVPN_PASSWORD.path;
          VPN_PORT_FORWARDING=on;
          VPN_PORT_FORWARDING_PROVIDER=protonvpn;
          #PRIVATE_INTERNET_ACCESS_VPN_PORT_FORWARDING=on;
          #FIREWALL_OUTBOUND_SUBNETS=255.255.255.0/24;
          #HTTPPROXY=on;        
        ];
      };	       
      transmission = {
        image = "lscr.io/linuxserver/transmission:latest";
        hostname = "transmission";
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/transmission/config:/config"
          "/srv/mergerfs/Pool/Downloads:/downloads"
          "/srv/mergerfs/Pool/Watch:/watch"
        ];
        environmentFiles = [
          /docker/env/transmission/.env
          /docker/env/transmission/.env.secret
        ];
      };
      prowlarr = {
        image = "lscr.io/linuxserver/prowlarr:latest";
        hostname = "prowlarr";
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/prowlarr/config:/config"
        ];
        environmentFiles = [
          /docker/env/prowlarr/.env
          /docker/env/prowlarr/.env.secret     
        ];
      };
      radarr = {
        image = "lscr.io/linuxserver/radarr:latest";
        hostname = "radarr";
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/radarr/config:/config"
          "/srv/mergerfs/Pool/Movies:/movies" #optional
          "/srv/mergerfs/Pool/Downloads:/downloads" #optional
        ];
        environmentFiles = [
          /docker/env/radarr/.env
          /docker/env/radarr/.env.secret     
        ];
      };
      lidarr = {
        image = "lscr.io/linuxserver/lidarr:latest";
        hostname = "lidarr";
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/lidarr/config:/config"
          "/srv/mergerfs/Pool/Music:/music" #optional
          "/srv/mergerfs/Pool/Downloads:/downloads" #optional
        ];
        environmentFiles = [
          /docker/env/lidarr/.env
          /docker/env/lidarr/.env.secret     
        ];
      };
      sonarr = {
        image = "lscr.io/linuxserver/sonarr:latest";
        hostname = "sonarr";
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/sonarr/config:/config"
          "/srv/mergerfs/Pool/TV:/tv" #optional
          "/srv/mergerfs/Pool/Downloads:/downloads" #optional
        ];
        environmentFiles = [
          /docker/env/sonarr/.env
          /docker/env/sonarr/.env.secret     
        ];
      };
      readarr = {
        image = "lscr.io/linuxserver/readarr:develop";
        hostname = "readarr";
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/readarr/config:/config"
          "/srv/mergerfs/Pool/Books:/books" #optional
          "/srv/mergerfs/Pool/Downloads:/downloads" #optional
        ];
        environmentFiles = [
          /docker/env/readarr/.env
          /docker/env/readarr/.env.secret     
        ];
      };
      requestrr = {
        image = "thomst08/requestrr:latest";
        hostname = "requestrr";
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/requestrr/config:/root/config"
        ];
        environmentFiles = [
          /docker/env/requestrr/.env
          /docker/env/requestrr/.env.secret     
        ];
      };
      flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr:latest";
        hostname = "flaresolverr";
        dependsOn = [ "gluetun" ];
        autoStart = true;
        environmentFiles = [
          /docker/env/flaresolverr/.env
          /docker/env/flaresolverr/.env.secret     
        ];
      };
      podgrab = {
        image = "akhilrex/podgrab";
        hostname = "podgrab";
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/podgrab/config:/config"
          "/srv/mergerfs/Pool/Podcasts:/assets"
        ];
        environmentFiles = [
          /docker/env/podgrab/.env
          /docker/env/podgrab/.env.secret     
        ];
      };
      bazarr = {
        image = "lscr.io/linuxserver/bazarr:latest";
        hostname = "bazarr";
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/bazarr/config:/config"
          "/srv/mergerfs/Pool/Movies:/movies" #optional
          "/srv/mergerfs/Pool/TV:/tv" #optional
        ];
        environmentFiles = [
          /docker/env/bazarr/.env
          /docker/env/bazarr/.env.secret     
        ];
      };
      jellyseerr = {
        image = "";
        hostname = "jellyseerr";
        dependsOn = [ "gluetun" ];
        autoStart = true;
        volumes = [
          "/docker/jellyserr/config:/app/config"
         #    - /mnt/data/supervisor/addons/local/jellyserr/duck2.svg:/app/public/logo_full.svg
         #       - /mnt/data/supervisor/addons/local/jellyserr/duck2.png:/app/public/logo_full.png
         #       - /mnt/data/supervisor/addons/local/jellyserr/logo_stacked.svg:/app/public/logo_stacked.svg
         #       - /mnt/data/supervisor/addons/local/jellyserr/duck2.png:/app/public/os_logo_square.png
        ];
        environmentFiles = [
          /docker/env/jellyseerr/.env
          /docker/env/jellyseerr/.env.secret     
        ];
      };
      navidrome = {
        image = "deluan/navidrome:latest";
        hostname = "navidrome";
        dependsOn = [ "gluetun" ];
        volumes = [
          "/docker/navidrome/config:/data"
          "/srv/mergerfs/Pool/Music:/music:ro"     
        ];
     #   ports = [ 
     #     "4533:4533"
     #   ];
        environmentFiles = [
          /docker/env/navidrome/.env
          /docker/env/navidrome/.env.secret     
        ];
      };   
    };
  };
}
