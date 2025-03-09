
{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.proxychains-ng ];
  
  services.tor = {
    enable = true;
    client = {
      enable = true;
    };
  };
  
  programs.proxychains = {
    enable = true;
    package = pkgs.proxychains-ng;
    chain = {
      type = "random";
    #  length = 3; # Only applicable if type is "random"
    };

    proxyDNS = true;
    quietMode = false;
    remoteDNSSubnet = 224;
    tcpReadTimeOut = 15000;
    tcpConnectTimeOut = 8000;
    localnet = "127.0.0.0/255.0.0.0";

    # Define a list of proxies
    proxies = {
    # 5 Shadowsocks proxies
      shadow1 = {
        type = "socks5"; 
        host = "127.0.0.1"; # FIXME IP
        port = 1080;
      };
      shadow2 = {
        type = "socks5"; 
        host = "127.0.0.1"; # FIXME IP
        port = 1080;
      };
      shadow3 = {
        type = "socks5"; 
        host = "127.0.0.1"; # FIXME IP
        port = 1080;
      };
      shadow4 = {
        type = "socks5"; 
        host = "127.0.0.1"; # FIXME IP
        port = 1080;
      };
      shadow5 = {
        type = "socks5"; 
        host = "127.0.0.1"; # FIXME IP
        port = 1080;
      };
        
      # HTTP Proxy
      #http-proxy = {
      #  type = "http";
      #  host = "proxy.example.com";
      #  port = 8080;
      #};
    };
  };

}
