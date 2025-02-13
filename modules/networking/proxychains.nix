# EMPTY NIX OS MODULE
# import into flake.
{ config, pkgs, ... }:

{
  
  programs.proxychains = {
    enable = true;

    
    package = pkgs.proxychains-ng;

    
    chain = {
      type = "random";
      length = 3; # Only applicable if type is "random"
    };

    proxyDNS = true;
    quietMode = false;
    remoteDNSSubnet = 224;
    tcpReadTimeOut = 15000;
    tcpConnectTimeOut = 8000;
    localnet = "127.0.0.0/255.0.0.0";

    proxies = {
      myproxy = {
        type = "socks5";
        host = "127.0.0.1";
        port = 1080;
      };
      anotherproxy = {
        type = "http";
        host = "proxy.example.com";
        port = 8080;
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
