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
      browserVPN = {
        image = "lscr.io/linuxserver/firefox:latest";
        hostname = "browserVPN";
        dependsOn = [ "gluetun" ];
        shm_size = [ "2gb" ];
        volumes = [
          "docker/saferBrowser/config:/config"
        ];  
        autoStart = true;
      };
    };
  };
}
