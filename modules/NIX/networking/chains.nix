{ config, pkgs, lib, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      gluetun1 = {
        image = "qmcgaw/gluetun";
        hostname = "gluetun1";
        cmd = ["--cap-add=NET_ADMIN --device=/dev/net/tun:/dev/net/tun"];
        ports = [ "1081:8388" ];
        volumes = [
          "/docker/gluetun1/config:/gluetun"
          "/docker/gluetun1/forwardedports.txt:/tmp/gluetun/forwardedport.txt"
        ];  
        environmentFiles = [
          "/docker/gluetun/.env"
        ];
      };

      gluetun2 = {
        image = "qmcgaw/gluetun";
        hostname = "gluetun2";
        cmd = ["--cap-add=NET_ADMIN --device=/dev/net/tun:/dev/net/tun"];
        ports = [ "1082:8388" ];
        volumes = [
          "/docker/gluetun2/config:/gluetun"
          "/docker/gluetun2/forwardedports.txt:/tmp/gluetun/forwardedport.txt"
        ];  
        environmentFiles = [
          "/docker/gluetun/.env"
        ];
      };
      gluetun3 = {
        image = "qmcgaw/gluetun";
        hostname = "gluetun3";
        cmd = ["--cap-add=NET_ADMIN --device=/dev/net/tun:/dev/net/tun"];
        ports = [ "1083:8388" ];
        volumes = [
          "/docker/gluetun3/config:/gluetun"
          "/docker/gluetun3/forwardedports.txt:/tmp/gluetun/forwardedport.txt"
        ];  
        environmentFiles = [
          "/docker/gluetun/.env"
        ];
      };

      gluetun4 = {
        image = "qmcgaw/gluetun";
        hostname = "gluetun4";
        cmd = ["--cap-add=NET_ADMIN --device=/dev/net/tun:/dev/net/tun"];
        ports = [ "1084:8388" ];
        volumes = [
          "/docker/gluetun4/config:/gluetun"
          "/docker/gluetun4/forwardedports.txt:/tmp/gluetun/forwardedport.txt"
        ];  
        environmentFiles = [
          "/docker/gluetun/.env"
        ];
      };

      gluetun5 = {
        image = "qmcgaw/gluetun";
        hostname = "gluetun5";
        cmd = ["--cap-add=NET_ADMIN --device=/dev/net/tun:/dev/net/tun"];
        ports = [ "1085:8388" ];
        volumes = [
          "/docker/gluetun5/config:/gluetun"
          "/docker/gluetun5/forwardedports.txt:/tmp/gluetun/forwardedport.txt"
        ];  
        environmentFiles = [
          "/docker/gluetun/.env"
        ];
      };
    };
  };

  programs.proxychains = {
    enable = true;
    package = pkgs.proxychains-ng;

 #  chain = {
 #     type = "random";
  #    length = 3; # Only applicable if type is "random"
 #   };

    proxyDNS = true;
    quietMode = false;
    remoteDNSSubnet = 224;
    tcpReadTimeOut = 15000;
    tcpConnectTimeOut = 8000;
    localnet = "127.0.0.0/255.0.0.0";

    proxies = {
      gluetun1 = {
        type = "socks5";
        host = "gluetun1";
        port = 1081;
      };
      gluetun2 = {
        type = "socks5";
        host = "gluetun2";
        port = 1082;
      };
      gluetun3 = {
        type = "socks5";
        host = "gluetun3";
        port = 1083;
      };
      gluetun4 = {
        type = "socks5";
        host = "gluetun4";
        port = 1084;
      };
      gluetun5 = {
        type = "socks5";
        host = "gluetun5";
        port = 1085;
      };
    };
  };

  services.tor = {
    enable = true;
    client = {
      enable = true;
    };
  };

  environment.systemPackages = [ pkgs.proxychains-ng ];
}

