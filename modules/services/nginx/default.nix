{ config, pkgs, ... }:

{
  
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [  80 443 ];       
  networking.firewall.allowedTCPPorts = [ ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."desktop.lan" = {
    addSSL = true;
    enableACME = true;
    root = "/var/www/myhost.org";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "foo@bar.com";
  };
}
