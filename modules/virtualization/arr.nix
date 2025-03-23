{ 
  config,
  lib,
  pkgs,
  ...
} : let 
    
    env = pkgs.writeText ".env" ''
        TZ="Europe/Berlin"
        PUID="2000"  
        PGID="2000"
        USER="@TRANS@"
        PASS="@TRANS@" 
        SHADOWPASS="@SHADOWPASS@"
    '';
 
    # Transmission Settings
    transmissionSettings = pkgs.writeText "settings.json" ''
        {
            "alt-speed-down": 50,
            "alt-speed-enabled": false,
            "alt-speed-time-begin": 540,
            "alt-speed-time-day": 127,
            "alt-speed-time-enabled": false,
            "alt-speed-time-end": 1020,
            "alt-speed-up": 50,
            "announce-ip": "",
            "announce-ip-enabled": false,
            "anti-brute-force-enabled": false,
            "anti-brute-force-threshold": 100,
            "bind-address-ipv4": "0.0.0.0",
            "bind-address-ipv6": "::",
            "blocklist-enabled": false,
            "blocklist-url": "http://www.example.com/blocklist",
            "cache-size-mb": 4,
            "default-trackers": "",
            "dht-enabled": true,
            "download-dir": "/root/Downloads",
            "download-queue-enabled": true,
            "download-queue-size": 5,
            "encryption": 1,
            "idle-seeding-limit": 30,
            "idle-seeding-limit-enabled": false,
            "incomplete-dir": "/root/Downloads",
            "incomplete-dir-enabled": false,
            "lpd-enabled": true,
            "message-level": 4,
            "peer-congestion-algorithm": "",
            "peer-limit-global": 200,
            "peer-limit-per-torrent": 50,
            "peer-port": 51413,
            "peer-port-random-high": 65535,
            "peer-port-random-low": 49152,
            "peer-port-random-on-start": false,
            "peer-socket-tos": "le",
            "pex-enabled": true,
            "port-forwarding-enabled": true,
            "preallocation": 1,
            "prefetch-enabled": true,
            "queue-stalled-enabled": true,
            "queue-stalled-minutes": 30,
            "ratio-limit": 2,
            "ratio-limit-enabled": false,
            "rename-partial-files": false,
            "rpc-authentication-required": false,
            "rpc-bind-address": "0.0.0.0",
            "rpc-enabled": true,
            "rpc-host-whitelist": "",
            "rpc-host-whitelist-enabled": false,
            "rpc-password": "{064ddf1bfa75eb61a0a677a0b0ed6c3637d0d1d4Wr8BjVrr",
            "rpc-port": 9091,
            "rpc-socket-mode": "0750",
            "rpc-url": "/transmission/",
            "rpc-username": "",
            "rpc-whitelist": "127.0.0.1,::1",
            "rpc-whitelist-enabled": false,
            "scrape-paused-torrents-enabled": true,
            "script-torrent-added-enabled": false,
            "script-torrent-added-filename": "",
            "script-torrent-done-enabled": false,
            "script-torrent-done-filename": "",
            "script-torrent-done-seeding-enabled": false,
            "script-torrent-done-seeding-filename": "",
            "seed-queue-enabled": false,
            "seed-queue-size": 10,
            "speed-limit-down": 100,
            "speed-limit-down-enabled": false,
            "speed-limit-up": 100,
            "speed-limit-up-enabled": false,
            "start-added-torrents": true,
            "tcp-enabled": true,
            "torrent-added-verify-mode": "fast",
            "trash-original-torrent-files": false,
            "umask": "022",
            "upload-slots-per-torrent": 8,
            "utp-enabled": true
        }
    ''; 
    
    pythonEnv = pkgs.python3.withPackages (ps: [ ps.requests ]);
    py = pkgs.writeText "config-apps.py" ''
        #!${pythonEnv}/bin/python
        import requests
        import json
        import os
        import logging
        import re
        
        logging.basicConfig(filename='/docker/arr-setup.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

        HOST = "192.168.1.28"
        RADARR_PORT = "7878"
        RADARR_API_KEY = os.getenv("RADARR_API_KEY")
        RADARR_API_URL = f"http://{HOST}:{RADARR_PORT}/api/v3"

        SONARR_PORT = "8989"
        SONARR_API_KEY = os.getenv("SONARR_API_KEY")
        SONARR_API_URL = f"http://{HOST}:{SONARR_PORT}/api/v3"

        LIDARR_PORT = "8686"
        LIDARR_API_KEY = os.getenv("LIDARR_API_KEY")
        LIDARR_API_URL = f"http://{HOST}:{LIDARR_PORT}/api/v3"

        READARR_PORT = "8787"
        READARR_API_KEY = os.getenv("READARR_API_KEY")
        READARR_API_URL = f"http://{HOST}:{READARR_PORT}/api/v3"

        PROWLARR_PORT = "9696"
        PROWLARR_API_KEY = os.getenv("PROWLARR_API_KEY")
        PROWLARR_API_URL = f"http://{HOST}:{PROWLARR_PORT}/api/v3"

        TRANSMISSION_PORT = "9091"
        TRANSMISSION_URL = f"http://{HOST}:{TRANSMISSION_PORT}"
        
        FLARESOLVERR_PORT = "8191"
        FLARESOLVERR_URL = f"http://{HOST}:{FLARESOLVERR_PORT}"
        
        def fetch_trash_guide_quality_definitions():
            url = "https://trash-guides.info/Radarr/Radarr-Quality-Settings-File-Size/"
            try:
                response = requests.get(url)
                response.raise_for_status()
                html_content = response.text

                quality_definitions = []
                table_pattern = re.compile(r"<tr>\s*<td[^>]*>(.*?)</td>\s*<td[^>]*>(.*?)</td>\s*<td[^>]*>(.*?)</td>\s*<td[^>]*>(.*?)</td>", re.DOTALL)
                matches = table_pattern.findall(html_content)

                for match in matches:
                    quality_name = match[0].strip()
                    min_size = int(float(match[1].strip()) * 1024)  # Convert MB to KB
                    max_size = int(float(match[2].strip()) * 1024)  # Convert MB to KB
                    preferred_size = int(float(match[3].strip()) * 1024)  # Convert MB to KB

                    quality_definitions.append({
                        "name": quality_name,
                        "minSize": min_size,
                        "maxSize": max_size,
                        "preferredSize": preferred_size
                    })

                return quality_definitions
                logging.info(quality_definitions)
            except requests.exceptions.RequestException as e:
                logging.error(f"Failed to fetch quality definitions from Trash Guide: {e}")
                return []

        def update_radarr_quality_definitions(quality_definitions):  
            try:
                response = requests.get(f"{RADARR_API_URL}/qualitydefinition", headers={"X-Api-Key": RADARR_API_KEY})
                response.raise_for_status()
                current_definitions = response.json()

                for trash_quality in quality_definitions:
                    quality_name = trash_quality["name"]
                    min_size = trash_quality["minSize"]
                    max_size = trash_quality["maxSize"]
                    preferred_size = trash_quality["preferredSize"]

                    radarr_quality = next((q for q in current_definitions if q["quality"]["name"] == quality_name), None)
                    if not radarr_quality:
                        logging.warning(f"Quality '{quality_name}' not found in Radarr. Skipping...")
                        continue

                    # Prepare JSON payload for the update
                    payload = {
                        "id": radarr_quality["id"],
                        "minSize": min_size,
                        "maxSize": max_size,
                        "preferredSize": preferred_size,
                        "quality": {
                            "id": radarr_quality["quality"]["id"],
                            "name": quality_name
                        }
                    }

                    update_response = requests.put(
                        f"{RADARR_API_URL}/qualitydefinition/{radarr_quality['id']}",
                        headers={"X-Api-Key": RADARR_API_KEY, "Content-Type": "application/json"},
                        data=json.dumps(payload))
                    update_response.raise_for_status()

                    logging.info(f"Updated {quality_name}: minSize={min_size}, maxSize={max_size}, preferredSize={preferred_size}")

                logging.info("Quality definitions update complete!")
            except requests.exceptions.RequestException as e:
                logging.error(f"Failed to update Radarr quality definitions: {e}")

        # Main function
        def main():
            quality_definitions = fetch_trash_guide_quality_definitions()

            if not quality_definitions:
                logging.error("No quality definitions found. Exiting.")
                return

            update_radarr_quality_definitions(quality_definitions)

        if __name__ == "__main__":
            main()
    '';        
            
    
    # Script to set up environment and run Python script
    configureApplications = pkgs.writeScriptBin "configure-apps" ''
        #!/bin/sh
        RADARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' /docker/radarr/config/config.xml)
        export RADARR_API_KEY
        if grep -q "^RADARR_API_KEY=" apiKeys.env; then
            sed -i "s|^RADARR_API_KEY=.*|RADARR_API_KEY=$RADARR_API_KEY|" apiKeys.env
        else
            echo "RADARR_API_KEY=$RADARR_API_KEY" >> apiKeys.env
        fi

        SONARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' /docker/sonarr/config/config.xml)
        export SONARR_API_KEY        
        if grep -q "^SONARR_API_KEY=" apiKeys.env; then
            sed -i "s|^SONARR_API_KEY=.*|SONARR_API_KEY=$SONARR_API_KEY|" apiKeys.env
        else
            echo "SONARR_API_KEY=$SONARR_API_KEY" >> apiKeys.env
        fi
        
        LIDARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' /docker/lidarr/config/config.xml)
        export LIDARR_API_KEY   
        if grep -q "^LIDARR_API_KEY=" apiKeys.env; then
            sed -i "s|^LIDARR_API_KEY=.*|LIDARR_API_KEY=$LIDARR_API_KEY|" apiKeys.env
        else
            echo "LIDARR_API_KEY=$LIDARR_API_KEY" >> apiKeys.env
        fi
     
        READARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' /docker/readarr/config/config.xml)
        export READARR_API_KEY
        if grep -q "^READARR_API_KEY=" apiKeys.env; then
            sed -i "s|^READARR_API_KEY=.*|READARR_API_KEY=$READARR_API_KEY|" apiKeys.env
        else
            echo "READARR_API_KEY=$READARR_API_KEY" >> apiKeys.env
        fi
     
        PROWLARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' /docker/prowlarr/config/config.xml)
        export PROWLARR_API_KEY
        if grep -q "^PROWLARR_API_KEY=" apiKeys.env; then
            sed -i "s|^PROWLARR_API_KEY=.*|PROWLARR_API_KEY=$PROWLARR_API_KEY|" apiKeys.env
        else
            echo "PROWLARR_API_KEY=$PROWLARR_API_KEY" >> apiKeys.env
        fi
        
        ${pythonEnv}/bin/python ${py}
  '';
in {
    # Creates VPN Network & Open port for Transmission
    imports = [ ./gluetun.nix ];

    # Sets variables needed for the containers
    systemd.services.arr-conf = {
        wantedBy = [ "multi-user.target" ];
        preStart = ''
            touch /docker/arr.env
            sed -e "/@TRANS@/{
                s|@TRANS@|$(cat ${config.sops.secrets.transmission.path})|
            }" \
            -e "/@SHADOWPASS@/{
                s|@SHADOWPASS@|$(cat ${config.sops.secrets.SHADOWSOCKS_PASSWORD.path})|
            }" ${env} > /docker/arr.env    
        '';
        serviceConfig = {
            ExecStart = "${pkgs.bash}/bin/bash -c 'echo Enviorment ready, starting containers; sleep 200'";
            Restart = "on-failure";
            RestartSec = "2s";
            RuntimeDirectory = [ "dockeruser" ];
            User = "dockeruser";
        };
    };

    # Configure the applications
    systemd.services.configure-arr = {
        description = "Configure ARR services and generate .env file";
        wantedBy = [ "multi-user.target" ];
        after = [ "docker-radarr.service" "docker-sonarr.service" "docker-lidarr.service" ];
        requires = [ "docker-radarr.service" "docker-sonarr.service" "docker-lidarr.service" ];
        
        
        serviceConfig = {
            ExecStart = "${configureApplications}/bin/configure-apps";
            Restart = "on-failure";
            RestartSec = "5s";
            RuntimeDirectory = [ "dockeruser" ];
            User = "dockeruser";
        };
    };    

    # Container Configuration
    virtualisation.oci-containers = {
        backend = "docker";
        containers = {
            transmission = {
                image = "lscr.io/linuxserver/transmission:latest";
                user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/transmission/config:/config"
                    "/Pool/Downloads:/downloads"
                    "/Pool/Watch:/watch"
                ];
                environmentFiles = [ "/docker/arr.env" ];
                environment = { 
                    USER = "";
                    PASS = "";
                    PUID = "2000" ; 
                    PGID = "2000";
                };
            }; 
      
            prowlarr = {
                image = "lscr.io/linuxserver/prowlarr:latest";
                user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/prowlarr/config:/config"
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            radarr = {
                image = "lscr.io/linuxserver/radarr:latest";
                user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/radarr/config:/config"
                    "/Pool/Movies:/movies" 
                    "/Pool/Downloads:/downloads" 
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            lidarr = {
                image = "lscr.io/linuxserver/lidarr:latest";
                user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/lidarr/config:/config"
                    "/Pool/Music:/music" 
                    "/Pool/Downloads:/downloads" 
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            sonarr = {
                image = "lscr.io/linuxserver/sonarr:latest";
                user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/sonarr/config:/config"
                    "/Pool/TV:/tv" 
                   "/Pool/Downloads:/downloads"
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            readarr = {
                image = "lscr.io/linuxserver/readarr:develop";
                user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/readarr/config:/config"
                    "/Pool/Books:/books"
                    "/Pool/Downloads:/downloads"
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            requestrr = {
                image = "thomst08/requestrr:latest";
                user = "2000:2000"; 
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/requestrr/config:/root/config"
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            flaresolverr = {
                image = "ghcr.io/flaresolverr/flaresolverr:latest";
                user = "2000:2000";
                dependsOn = [ "gluetun" ];
                extraOptions = [ "--network=container:gluetun" ];
                autoStart = true;
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            podgrab = {
                image = "akhilrex/podgrab";
                user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/podgrab/config:/config"
                    "/Pool/Podcasts:/assets"
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
      
            bazarr = {
                image = "lscr.io/linuxserver/bazarr:latest";
                user = "2000:2000";
                extraOptions = [ "--network=container:gluetun" ];
                dependsOn = [ "gluetun" ];
                autoStart = true;
                volumes = [
                    "/docker/bazarr/config:/config"
                    "/Pool/Movies:/movies"
                    "/Pool/TV:/tv" 
                ];
                environmentFiles = [ "/docker/arr.env" ];
            };
        };    
    };
    
    sops.secrets = {
        transmission = {
            sopsFile = ./../../secrets/transmission.yaml;
            owner = "dockeruser";
            group = "dockeruser";
            mode = "0440"; 
        };
    };

    # Set /Docker Ownersihp and Permissions 
    system.activationScripts.dockerPermissions = {
        text = ''
            echo "Setting permissions and ownership for /docker directories..."
            mkdir -p /docker
            chown -R dockeruser:dockeruser /docker
            chmod -R 700 /docker
        '';
    };}
    
