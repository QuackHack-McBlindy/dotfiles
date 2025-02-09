{ config, pkgs, ... }:
{    
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
                    "/home/pungkula/dotfiles/home/.config/home-assistant/config:/config"
                ];
               # environmentFiles = [
               #     /docker/env/transmission/.env
            #    ];
            };
         # FIXME TODO db
      #    DATABASE = {
          #    image = "
           #   hostname = "prowlarr";
           #   dependsOn = [ "gluetun" ];
           #   autoStart = true;
           #   volumes = [
           #       "/docker/prowlarr/config:/config"
            #  ];
       #       ];
        #  };
        };
    };
}    
        
