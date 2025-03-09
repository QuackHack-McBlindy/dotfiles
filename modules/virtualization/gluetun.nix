{ 
  config,
  lib,
  pkgs,
  ...
} : let
    capturePortScript = pkgs.writeShellScript "capture-gluetun-port" ''
        #!/bin/bash
        journalctl -u docker-gluetun.service --no-pager -f | grep --line-buffered "port forwarded" | \
        while read -r line; do
            line=$(journalctl -u docker-gluetun.service --no-pager | grep -i "port forwarded is" | tail -n 1)
            port=$(echo "$line" | sed -E 's/.*port forwarded is ([0-9]+).*/\1/')
            echo '{' > /home/pungkula/dotfiles/modules/virtualization/gluetun-port.nix
            echo '  port = "$port";' >> /home/pungkula/dotfiles/modules/virtualization/gluetun-port.nix
            echo '}' >> /home/pungkula/dotfiles/modules/virtualization/gluetun-port.nix
            ${pkgs.docker}/bin/docker run -d \
                --name transmission \
                --network container:gluetun \
                -v /docker/transmission/config:/config \
                -v /Pool/Downloads:/downloads \
                -v /Pool/Watch:/watch \
                -e PEERPORT=$port \
                --restart always \
                lscr.io/linuxserver/transmission:latest
        done
    '';
    forwarded = import ./gluetun-port.nix;
in {
    systemd.services.capture-gluetun-port = {
        description = "Capture Gluetun forwarded port";
        after = [ "docker-gluetun.service" ];
        serviceConfig.ExecStart = "${capturePortScript}";
        serviceConfig.Restart = "always";
        serviceConfig.User = "root";
        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers = {
        backend = "docker";
        containers = {
            gluetun = {
                image = "qmcgaw/gluetun";
                hostname = "gluetun";
                privileged = true;
                capabilities = { NET_ADMIN = true; };
                extraOptions = [ "--device=/dev/net/tun:/dev/net/tun" ];
                ports = [
                    "8888:8888" # Gluetun
                    "8388:8388" # Shadowsocks
                    "8001:8000" # HTTP Control API
                    "${forwarded.port}:${forwarded.port}"  # vpn forwarding
                    "8118:8118" # browserVPN
                    "7878:7878"  # Radarr
                    "8989:8989" # Sonarr:
                    "8686:8686" # Lidarr:
                    "8787:8787" # Readarr:
                    "6767:6767" # Bazarr:
                    "4533:4533" # Navidrome:
                    "5055:5055" # Jellyseer:
                    "4545:4545" # Requestrr:
                    "8191:8191" # Flaresolverr
                    "9091:9091" # Transmission
                    "51413:51413" # Transmission
                    "51413:51413/udp" # Transmission
                ];
                volumes = [
                    "/docker/gluetun/config:/gluetun"
                ];
                environmentFiles = [ "/docker/gluetun/.env" ];
                environment = { 
                    VPN_PORT_FORWARDING_UP_COMMAND = "${capture-gluetun-port}";
                };
            };
        };
    };}
