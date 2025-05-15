# browser-in-browser.nix
{ config, pkgs, lib, ... }:
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
        environmentFiles = [ /docker/gluetun/.env ];
      };	   
      browserVPN = {
        image = "lscr.io/linuxserver/firefox:latest";
        hostname = "browserVPN";
        dependsOn = [ "gluetun" ];
      #  shm_size = [ "2gb" ];
        volumes = [
          "docker/saferBrowser/config:/config"
        ];  
        autoStart = true;
      };
    };
  };
}
