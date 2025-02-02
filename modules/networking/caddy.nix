{ pkgs, config, ... }:

#let
#  caddyFlake = import ./caddy/flake.nix;
#  caddy-duckdns = caddyFlake; 
#in

{

#  environment.systemPackages = with pkgs; [ caddy-duckdns ];   
  
  networking.firewall.allowedTCPPorts = [ 80 443 ];

#  services.caddyProxy = {
#    enable = true;
  #  package = caddy-duckdns;
  #  email = "example@example.com";
  #  config = ''
  #    desktop.local {
  ##      log /var/log/caddy.log
   #     file_server
   #   }  
   # '';
    virtualHosts = {
      "quackpass.local".extraConfig = ''
        reverse proxy http://192.168.1.28:5001

      '';
    };
  services.caddyProxy = {
    enable = true;

  };
  
  sops.secrets = {
    duckdns = {
      sopsFile = "/var/lib/sops-nix/secrets/duckdns.yaml"; 
      owner = config.users.users.secretservice.name;
      group = config.users.groups.secretservice.name;
      mode = "0440"; # Read-only for owner and group
    };
  };

  
}





