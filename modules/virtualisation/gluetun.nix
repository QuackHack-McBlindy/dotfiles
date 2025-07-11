{ 
  config,
  lib,
  pkgs,
  ...
} : let

    env = pkgs.writeText ".env" ''
        VPN_SERVICE_PROVIDER="protonvpn"
        VPN_TYPE="openvpn"
        OPENVPN_USER="@VPNUSER@"
        OPENVPN_PASSWORD="@VPNPASS@"
        SERVER_COUNTRIES="Netherlands"
        BLOCK_SURVEILLANCE="on"
        BLOCK_MALICIOUS="on"
        BLOCK_ADS="on"
        HTTPPROXY="on"
        SHADOWSOCKS="on"
        SHADOWSOCKS_PASSWORD="@SHADOWPASS@"
        FIREWALL_OUTBOUND_SUBNETS="255.255.255.0/24"
        TZ="Europe/Berlin"
        PUID="2000"
        PGID="2000"
        VPN_PORT_FORWARDING="on"
        PORT_FORWARD_ONLY="on"  
        TRANS="@TRANS@"
    '';
    
in {
    config = lib.mkIf (lib.elem "arr" config.this.host.modules.virtualisation) {
        virtualisation.oci-containers = {
            backend = "docker";
            containers = {
                gluetun = {
                    image = "ghcr.io/qdm12/gluetun:latest";
                    user = "0:0";
                    hostname = "gluetun";
                    privileged = true;
                    capabilities = { NET_ADMIN = true; };
                    extraOptions = [ "--device=/dev/net/tun:/dev/net/tun" ];
                    ports = [
                        "8888:8888"       # Gluetun
                        "8388:8388"       # Shadowsocks
                        "8000:8000"       # HTTP Control API
                        "8118:8118"       # browserVPN
                        "7878:7878"       # Radarr
                        "8989:8989"       # Sonarr:
                        "8686:8686"       # Lidarr:
                        "8787:8787"       # Readarr:
                        "6767:6767"       # Bazarr:
#                        "4533:4533"       # Navidrome:
                        "5055:5055"       # Jellyseer:
                        "4545:4545"       # Requestrr:
                        "9696:9696"       # Prowlarr
                        "8191:8191"       # Flaresolverr
                        "9091:9091"       # Transmission
                        "51413:51413"     # Transmission
                        "51413:51413/udp" # Transmission
                    ];
                    volumes = [
                        "/docker/gluetun/config:/gluetun"
                        "/docker/gluetun/logs:/var/log/gluetun"
                    ];
                    environmentFiles = [ "/docker/gluetun/.env" ];
                    environment = {
                        VPN_PORT_FORWARDING_UP_COMMAND = ''
                            /bin/sh -c "
                                echo FORWARDED PORT: {{PORTS}};
                                FORWARDED={{PORTS}};
                                sleep 30;
                                SESSION_ID=\$(wget -qO- --user=admin --password=admin --server-response http://localhost:9091/transmission/rpc 2>&1 | grep -o 'X-Transmission-Session-Id: .*' | head -n1 | cut -d ' ' -f2);
                                sleep 5;
                                RESPONSE=\$(wget -qO- --user='\$TRANS' --password='\$TRANS' --header=\"X-Transmission-Session-Id: \$SESSION_ID\" \
                                    --header=\"Content-Type: application/json\" \
                                    --post-data='{\"method\": \"session-set\", \"arguments\": {\"peer-port\": '\$FORWARDED' }}' \                                                                                       http://localhost:9091/transmission/rpc);
                                echo \"Transmission RPC Response: \$RESPONSE\";
                                if echo \"\$RESPONSE\" | grep -q '\"result\":\"success\"'; then
                                    echo '✅ Port updated successfully!';
                                else                                                                                          echo '❌ Failed to update port!';
                                fi
                            "
                        '';                                                                                   };
                };
            };
        };

        systemd.services.glue-conf = {
            wantedBy = [ "multi-user.target" ];
            preStart = ''
                mkdir -p /docker/gluetun
                sed -e "/@VPNUSER@/{
                    s|@VPNUSER@|$(cat ${config.sops.secrets.PROTON_OPENVPN_USER.path})|
                }" \
                -e "/@VPNPASS@/{
                    s|@VPNPASS@|$(cat ${config.sops.secrets.PROTON_OPENVPN_PASSWORD.path})|
                }" \
                -e "/@TRANS@/{
                    s|@TRANS@|$(cat ${config.sops.secrets.transmission.path})|
                }" \
                -e "/@SHADOWPASS@/{
                    s|@SHADOWPASS@|$(cat ${config.sops.secrets.SHADOWSOCKS_PASSWORD.path})|
                }" ${env} > /docker/gluetun/.env
            '';

            serviceConfig = {
                ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
                Restart = "on-failure";
                RestartSec = "2s";
                RuntimeDirectory = [ "dockeruser" ];
                User = "dockeruser";
            };
        };

        sops.secrets = {
            PROTON_OPENVPN_USER = {
                sopsFile = ./../../secrets/PROTON_OPENVPN_USER.yaml;
                owner = "dockeruser";
                group = "dockeruser";
                mode = "0440";
            };
            PROTON_OPENVPN_PASSWORD = {
                sopsFile = ./../../secrets/PROTON_OPENVPN_PASSWORD.yaml;
                owner = "dockeruser";
                group = "dockeruser";
                mode = "0440";
            };
            SHADOWSOCKS_PASSWORD = {
                sopsFile = ./../../secrets/SHADOWSOCKS_PASSWORD.yaml;
                owner = "dockeruser";
                group = "dockeruser";
                mode = "0440";
            };
            transmission = {
                sopsFile = ./../../secrets/transmission.yaml;
                owner = "dockeruser";
                group = "dockeruser";
                mode = "0440";
            };
        };

        system.activationScripts.dockerPermissions = {
            text = ''
                while [ ! -d /docker/gluetun/config ]; do
                    sleep 1
                done
                echo "Setting permissions and ownership for /docker/gluetun directory..."
                chown -R 2000:2000 /docker/gluetun/config
                chown -R 2000:2000 /docker/gluetun/logs
                chmod -R 600 /docker/gluetun/config
                chmod -R 700 /docker/gluetun/logs
            '';
        };
        
    };}
