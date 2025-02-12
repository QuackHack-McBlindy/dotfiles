{ pkgs, config, ... }:


{

  imports = [ ./caddyModule.nix ];
  
  disabledModules = [ "services/web-servers/caddy.nix" ];
#  environment.systemPackages = with pkgs; [ caddy-duckdns ];   
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.caddy-duckdns = {
    enable = true; 
    email = "example@example.com";
  #  virtualHosts = {
 #     "quackpass.local".extraConfig = ''
 #       reverse proxy http://192.168.1.28:5001
  #    '';
  };

#  sops.secrets = {
#    duckdns = {
#      sopsFile = "/var/lib/sops-nix/secrets/duckdns.yaml"; 
 #     owner = config.users.users.secretservice.name;
#      group = config.users.groups.secretservice.name;
#      mode = "0440"; # Read-only for owner and group
#    };
 # };
 
}





