{ pkgs, config, ... }:
{
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.caddy = {
    
        enable = true;
        virtualHosts = {
            # DESKTOP.LOCAL
            "files.local".extraConfig = ''
                root * /var/www/files
                file_server
            '';
        };
    };
}
