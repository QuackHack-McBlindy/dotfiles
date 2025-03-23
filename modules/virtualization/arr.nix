{ 
  config,
  lib,
  pkgs,
  ...
} : let 
    radarrAPI = builtins.readFile (pkgs.runCommand "extract-api-key" {} ''
        grep -oP '(?<=<ApiKey>)[^<]+' /docker/radarr/config/config.xml > $out
    ''); 
    sonarrAPI = builtins.readFile (pkgs.runCommand "extract-api-key" {} ''
        grep -oP '(?<=<ApiKey>)[^<]+' /docker/sonarr/config/config.xml > $out
    '');    
    lidarrAPI = builtins.readFile (pkgs.runCommand "extract-api-key" {} ''
        grep -oP '(?<=<ApiKey>)[^<]+' /docker/lidarr/config/config.xml > $out
    '');    

    setupVar = pkgs.writeText "arrkeys.env" ''
        RADARR="@RADARR@"
        SONARR="@SONARR@"
        LIDARR="@LIDARR@"
    '';    
    # Script to generate the .env file
    envSetupScript = pkgs.writeScript "generate-env-file.sh" ''
        #!/bin/sh
        sed \
            -e "s|@RADARR@|$(cat ${radarrAPI})|" \
            -e "s|@SONARR@|$(cat ${sonarrAPI})|" \
            -e "s|@LIDARR@|$(cat ${lidarrAPI})|" \
            ${setupVar} > /docker/arrKeys.env
            echo "Collected API keys for ARR Services."
    '';
    
    env = pkgs.writeText ".env" ''
        TZ="Europe/Berlin"
        PUID="2000"  
        PGID="2000"
        USER=@TRANS@
        PASS=@TRANS@ 
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

    # Final script sending API calls to configure everything inside the applications while running
    configureApplications = pkgs.writeScript "configure-applications.sh" ''
        #!/bin/sh
        LOG_FILE="/docker/arr-setup.log"

        log() {
            echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
        }

        RADARR_HOST="localhost"
        RADARR_PORT="7878"
        RADARR_API_KEY="$(cat /docker/arrKeys.env | grep RADARR | cut -d '=' -f 2 | tr -d '"')"

        # Validate API key
        if [[ -z "$RADARR_API_KEY" ]]; then
            log "Error: Radarr API key is empty!"
            exit 1
        fi

        RADARR_API_URL="http://${RADARR_HOST}:${RADARR_PORT}/api/v3"

        # Hardcoded quality definitions based on Trash Guide recommendations
        # Format: "Quality Name|minSize|maxSize|preferredSize"
        QUALITY_DEFINITIONS=(
            "Bluray-1080p|0|2048|1024"
            "Bluray-720p|0|1024|512"
            "WEBRip-1080p|0|2048|1024"
            "WEBRip-720p|0|1024|512"
            "HDTV-1080p|0|1024|512"
            "HDTV-720p|0|512|256"
            "DVD|0|512|256"
            "SDTV|0|256|128"
        )

        # Function to update quality definitions
        update_quality_definitions() {
            echo "Fetching current quality definitions from Radarr..."
            QUALITY_RESPONSE=$(curl -s -H "X-Api-Key: ${RADARR_API_KEY}" "${RADARR_API_URL}/qualitydefinition")

            # Check if the response is valid
            if [[ -z "$QUALITY_RESPONSE" ]]; then
                echo "Failed to fetch quality definitions. Check your Radarr API key and connection."
                exit 1
            fi

            echo "Updating quality definitions..."
            for QUALITY_DEF in "${QUALITY_DEFINITIONS[@]}"; do
                IFS='|' read -r QUALITY_NAME MIN_SIZE MAX_SIZE PREFERRED_SIZE <<< "$QUALITY_DEF"

                # Find the quality definition ID by name                                                  QUALITY_ID=$(echo "$QUALITY_RESPONSE" | jq -r ".[] | select(.quality.name == \"${QUALITY_NAME}\") | .id")

                if [[ -z "$QUALITY_ID" ]]; then
                    echo "Quality '${QUALITY_NAME}' not found in Radarr. Skipping..."                         continue
                fi

                # Prepare JSON payload for the update
                JSON_PAYLOAD=$(jq -n \
                    --argjson id "$QUALITY_ID" \
                    --argjson minSize "$MIN_SIZE" \
                    --argjson maxSize "$MAX_SIZE" \
                    --argjson preferredSize "$PREFERRED_SIZE" \
                    '{                                                                                            id: $id,
                        minSize: $minSize,
                        maxSize: $maxSize,
                        preferredSize: $preferredSize,
                        quality: {
                            id: $id,
                            name: "'"${QUALITY_NAME}"'"
                        }
                    }')

                # Send the update request
                UPDATE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
                    -H "X-Api-Key: ${RADARR_API_KEY}" \
                    -H "Content-Type: application/json" \
                    -d "$JSON_PAYLOAD" \
                    "${RADARR_API_URL}/qualitydefinition/${QUALITY_ID}")

                if [[ "$UPDATE_RESPONSE" == "202" ]]; then
                    echo "Updated ${QUALITY_NAME}: minSize=${MIN_SIZE}, maxSize=${MAX_SIZE}, preferredSize=${PREFERRED_SIZE}"
                else
                    echo "Failed to update ${QUALITY_NAME}. HTTP status: ${UPDATE_RESPONSE}"
                fi
            done

            echo "Quality definitions update complete!"
        }

        # Run the update function
        update_quality_definitions

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
        
        preStart = ''
            ${envSetupScript}
        '';
        
        serviceConfig = {
            ExecStart = "${configureApplications}";
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
            touch /docker/transmission/config/settings.json
            echo "${transmissionSettings}" > /docker/transmission/config/settings.json
            echo "Setting permissions and ownership for /docker directories..."
            mkdir -p /docker
            chown -R dockeruser:dockeruser /docker
            chmod -R 700 /docker
        '';
    };}
    
