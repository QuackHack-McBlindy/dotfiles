{ pkgs, config, ... }:
{
    networking.firewall.allowedTCPPorts = [ 80 443 ];
   
    services.caddy = {
        enable = true;
    
        virtualHosts = {
            # DESKTOP.LOCAL
            "desktop.local".extraConfig = ''
                reverse_proxy http://localhost:7888
            '';
        };
    };
}
