{ config, pkgs, ... }:
{    
    networking.firewall.allowedTCPPorts = [ 8123 ];
    virtualisation.oci-containers = {
        backend = "docker";
        containers = {
            home-assistant = {
                image = "ghcr.io/home-assistant/home-assistant:stable";
                hostname = "home-assistant";
            #   dependsOn = [ "db" ]; # FIXME database
                autoStart = true;
                ports = [
                  "8123:8123"
                ];
                volumes = [
                    "/etc/localtime:/etc/localtime:ro"
                    "/run/dbus:/run/dbus:ro"
                    "/docker/home-assistant/config:/config"
                ];
               # environmentFiles = [
               #     /docker/env/transmission/.env
            #    ];
            };
            
        };
    };
}    
        
