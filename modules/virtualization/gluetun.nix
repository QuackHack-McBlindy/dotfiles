{ config, lib, pkgs, ... }:

{    
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {  
      gluetun = {
        image = "qmcgaw/gluetun";
        hostname = "gluetun";
        privileged = true;
#        cmd = [ "sh -c 'logread -f | awk '/port forwarded is/ {print \$NF > \'/tmp/gluetun/forwarded_port_custom\"}"'" ];
        capabilities = {
          NET_ADMIN = true;
        };

        extraOptions = [
          "--device=/dev/net/tun:/dev/net/tun"
        ];
     
        ports = [
          "8888:8888" # gluetun
          "8388:8388" # shadowsocks
          "8001:8000" # http proxy?
          "51413:51413" # vpn forwarding
        #  "8118:8118" # browserVPN
          "7878:7878"  # Radarr
          "8989:8989" # Sonarr:
          "8686:8686" # Lidarr:
          "8787:8787" # Readarr:
          "6767:6767" # Bazarr: 
          "4533:4533" # Navidrome: 
          "5055:5055" # Jellyseer:
          "4545:4545" # Requestrr:
          "8191:8191"   # Flaresolverr  
        
        ]; 
        volumes = [
          "/docker/gluetun/config:/gluetun"
          "/docker/gluetun/forwardedports.txt:/tmp/gluetun/forwarded_port"
        ];  
        environmentFiles = [ "/docker/gluetun.env" ];
      };	   
    };
  };
}  

