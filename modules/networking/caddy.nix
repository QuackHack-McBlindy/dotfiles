{ pkgs, config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.caddy = {
    enable = true;
    email = "example@example.com";
    config = ''
      desktop.local {
        root /var/www/example
        log /var/log/caddy.log
        file_server
      }  
#      ha.local {
#        reverse proxy http://localhost:8123
#    '';
    virtualHosts = {
      "ha.local".extraConfig = ''
        reverse proxy http://localhost:8123
      '';
    };
    
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

      
 #       virtualHosts = {
            # DESKTOP.LOCAL
     #       "files.local".extraConfig = ''
     #           root * /var/www/files
     #           file_server
        #    '';
    #    };



