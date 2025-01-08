# EMPTY NIX OS MODULE
# import into flake.
{ config, pkgs, ... }:

{
    # Enable the proxychains service
  programs.proxychains = {
    enable = true;

    # Specify the proxychains package to use
    package = pkgs.proxychains-ng;

    # Define the chain type and length
    chain = {
      type = "random";
      length = 3; # Only applicable if type is "random"
    };

    # Other configuration options
    proxyDNS = true;
    quietMode = false;
    remoteDNSSubnet = 224;
    tcpReadTimeOut = 15000;
    tcpConnectTimeOut = 8000;
    localnet = "127.0.0.0/255.0.0.0";

    # Define a list of proxies
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

  # Example of enabling Tor and configuring it as a proxy
  services.tor = {
    enable = true;
    client = {
      enable = true;
    };
  };

  # Ensure the `proxychains` package is installed
  environment.systemPackages = [ pkgs.proxychains-ng ];
}
