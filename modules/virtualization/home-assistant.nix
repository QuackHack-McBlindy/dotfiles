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
            zigbee2mqtt = {
                image = "koenkk/zigbee2mqtt";
                hostname = "zigbee2mqtt";
            #   dependsOn = [ "db" ]; # FIXME database
                autoStart = true;
                ports = [ "8099:8080" ];
                volumes = [
                    "/docker/zigbee2mqtt/data:/data"
                    "/etc/localtime:/etc/localtime:ro"
                  #  "run/udev:/run/udev:ro"
                ];
                devices = [
                    "/dev/serial/by-id/usb-Silicon_Labs_Sonoff_Zigbee_3.0_USB_Dongle_Plus_0001-if00-port0:/dev/ttyACM0"
                ];
               # environmentFiles = [
               #     /docker/env/transmission/.env
            #    ];
            };
        };
    };
}    
        
