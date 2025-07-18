# dotfiles/modules/virtualisation/arr.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ Declarative docker services for media handling.
  config,
  lib,
  pkgs,
  ...
} : let # 🦆 duck say ⮞ create dotenv yo
    pythonEnv = pkgs.python3.withPackages (ps: [ ps.requests ps.python-dotenv ]);
    env = pkgs.writeText ".env" ''
        TZ="Europe/Berlin"
        PUID="2000"
        PGID="2000"
        USER="@TRANS@"
        PASS="@TRANS@"
        SHADOWPASS="@SHADOWPASS@"
    '';

    # 🦆 duck say ⮞ Requestrr Settings
    requestrrSettingsScript = pkgs.writeShellScriptBin "generate-requestrr-settings" ''
        #!/bin/sh
        source /docker/apiKeys.env
        mkdir -p /docker/requestrr/config
        cat > /docker/requestrr/config/settings.json <<EOF
        {
          "Authentication": {
            "Username": "admin",
            "Password": "$(cat ${config.sops.secrets.requestrrPassword.path})",
            "PrivateKey": "$(cat ${config.sops.secrets.requestrrPrivateKey.path})"
          },
          "ChatClients": {
            "Discord": {
              "BotToken": "$(cat ${config.sops.secrets.discordToken.path})",
              "ClientId": "1059139110054412349",
              "StatusMessage": "/help",
              "EnableRequestsThroughDirectMessages": false,
              "AutomaticallyNotifyRequesters": true,
              "NotificationMode": "PrivateMessages",
              "AutomaticallyPurgeCommandMessages": true
            },
            "Language": "english"
          },
          "DownloadClients": {
            "Lidarr": {
              "Hostname": "localhost",
              "Port": 8686,
              "ApiKey": "$LIDARR_API_KEY"
            },
            "Ombi": {
              "Hostname": "",
              "Port": 3579,
              "ApiKey": ""
            },
            "Overseerr": {
              "Hostname": "",
              "Port": 5055,
              "ApiKey": ""
            },
            "Radarr": {
              "Hostname": "localhost",
              "Port": 7878,
              "ApiKey": "$RADARR_API_KEY"
            },
            "Sonarr": {
              "Hostname": "localhost",
              "Port": 8989,
              "ApiKey": "$SONARR_API_KEY"
            }
          },
          "BotClient": {
            "Client": ""
          },
          "Movies": {
            "Client": "Enabled"
          },
          "Music": {
            "Client": "Enabled"
          },
          "TvShows": {
            "Client": "Enabled",
            "Restrictions": "None"
          },
          "Port": 4545,
          "BaseUrl": "",
          "DisableAuthentication": false,
          "Version": "2.1.3"
        }
        EOF
    '';

    pyRestore = pkgs.writeText "restore-apps.py" ''
      #!${pythonEnv}/bin/python
      import os
      import requests
      import glob
      import logging
      from pathlib import Path
      logging.basicConfig(filename='/docker/arr-restore.log', level=logging.INFO)

      HOST = "192.168.1.28"
      SERVICES = [
          {"name": "Prowlarr", "port": 9696, "api": "v1"},
          {"name": "Radarr", "port": 7878, "api": "v3"},
          {"name": "Sonarr", "port": 8989, "api": "v3"},
          {"name": "Lidarr", "port": 8686, "api": "v1"},
          {"name": "Readarr", "port": 8787, "api": "v1"}
      ]
      BACKUP_DIR = "/backup/arr"
      def restore_service(service):
          backup_pattern = f"{BACKUP_DIR}/{service['name']}_*.zip"
          backups = sorted(glob.glob(backup_pattern), key=os.path.getmtime, reverse=True)
          if not backups:
              return False
          latest_backup = backups[0]
          api_key = os.getenv(f"{service['name'].upper()}_API_KEY")
          url = f"http://{HOST}:{service['port']}/api/{service['api']}/system/backup/restore/upload"
          try:
              with open(latest_backup, 'rb') as f:
                  response = requests.post(
                      url,
                      headers={"X-Api-Key": api_key},
                      files={"file": f}
                  )
              response.raise_for_status()
              logging.info(f"Restored {service['name']} from {latest_backup}")
              return True
          except Exception as e:
              logging.error(f"Failed to restore {service['name']}: {str(e)}")
              return False

      if __name__ == "__main__":
          for service in SERVICES:
              restore_service(service)
    '';

    bashBackup = pkgs.writeScriptBin "backup-apps" ''
        #!/bin/sh
        export PATH="${pkgs.lib.makeBinPath [ pkgs.curl pkgs.jq pkgs.coreutils pkgs.gnugrep ]}"
        mkdir -p /docker/backups
        BACKUP_NAME=$(curl -s "http://192.168.1.28:8989/api/v3/system/backup" \
            -H "X-Api-Key: $(grep SONARR_API_KEY /docker/apiKeys.env | cut -d= -f2)" | jq -r '.[0].name')
        SONARR_BACKUP_PATH="/docker/sonarr/config/Backups/scheduled/$BACKUP_NAME"
        cp "$SONARR_BACKUP_PATH" /docker/backups/sonarr.zip

        BACKUP_NAME=$(curl -s "http://192.168.1.28:7878/api/v3/system/backup" \
            -H "X-Api-Key: $(grep RADARR_API_KEY /docker/apiKeys.env | cut -d= -f2)" | jq -r '.[0].name')
        RADARR_BACKUP_PATH="/docker/radarr/config/Backups/scheduled/$BACKUP_NAME"
        cp "$RADARR_BACKUP_PATH" /docker/backups/radarr.zip

        BACKUP_NAME=$(curl -s "http://192.168.1.28:8686/api/v1/system/backup" \
            -H "X-Api-Key: $(grep LIDARR_API_KEY /docker/apiKeys.env | cut -d= -f2)" | jq -r '.[0].name')
        LIDARR_BACKUP_PATH="/docker/lidarr/config/Backups/scheduled/$BACKUP_NAME"
        cp "$LIDARR_BACKUP_PATH" /docker/backups/lidarr.zip

        BACKUP_NAME=$(curl -s "http://192.168.1.28:9696/api/v1/system/backup" \
            -H "X-Api-Key: $(grep PROWLARR_API_KEY /docker/apiKeys.env | cut -d= -f2)" | jq -r '.[0].name')
        PROWLARR_BACKUP_PATH="/docker/prowlarr/config/Backups/scheduled/$BACKUP_NAME"
        cp "$PROWLARR_BACKUP_PATH" /docker/backups/prowlarr.zip

        BACKUP_NAME=$(curl -s "http://192.168.1.28:8787/api/v1/system/backup" \
            -H "X-Api-Key: $(grep READARR_API_KEY /docker/apiKeys.env | cut -d= -f2)" | jq -r '.[0].name')
        READARR_BACKUP_PATH="/docker/readarr/config/Backups/scheduled/$BACKUP_NAME"
        cp "$READARR_BACKUP_PATH" /docker/backups/readarr.zip
        cp /docker/requestrr/config/settings.json /docker/backups/requestrr_settings.json
        cp /docker/transmission/config/settings.json /docker/backups/transmission_settings.json
        echo "Finished backing up Arr applications!"
    '';

    # 🦆 duck say ⮞ script to set up environment and run da Python script yo
    configureApplications = pkgs.writeScriptBin "configure-apps" ''
        #!/bin/sh
        RADARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' /docker/radarr/config/config.xml)
        export RADARR_API_KEY
        if grep -q "^RADARR_API_KEY=" /docker/apiKeys.env; then
            sed -i "s|^RADARR_API_KEY=.*|RADARR_API_KEY=$RADARR_API_KEY|" /docker/apiKeys.env
        else
            echo "RADARR_API_KEY=$RADARR_API_KEY" >> /docker/apiKeys.env
        fi

        SONARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' /docker/sonarr/config/config.xml)
        export SONARR_API_KEY
        if grep -q "^SONARR_API_KEY=" /docker/apiKeys.env; then
            sed -i "s|^SONARR_API_KEY=.*|SONARR_API_KEY=$SONARR_API_KEY|" /docker/apiKeys.env
        else
            echo "SONARR_API_KEY=$SONARR_API_KEY" >> /docker/apiKeys.env
        fi

        LIDARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' /docker/lidarr/config/config.xml)
        export LIDARR_API_KEY
        if grep -q "^LIDARR_API_KEY=" /docker/apiKeys.env; then
            sed -i "s|^LIDARR_API_KEY=.*|LIDARR_API_KEY=$LIDARR_API_KEY|" /docker/apiKeys.env
        else
            echo "LIDARR_API_KEY=$LIDARR_API_KEY" >> /docker/apiKeys.env
        fi

        READARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' /docker/readarr/config/config.xml)
        export READARR_API_KEY
        if grep -q "^READARR_API_KEY=" /docker/apiKeys.env; then
            sed -i "s|^READARR_API_KEY=.*|READARR_API_KEY=$READARR_API_KEY|" /docker/apiKeys.env
        else
            echo "READARR_API_KEY=$READARR_API_KEY" >> /docker/apiKeys.env
        fi

        PROWLARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' /docker/prowlarr/config/config.xml)
        export PROWLARR_API_KEY
        if grep -q "^PROWLARR_API_KEY=" /docker/apiKeys.env; then
            sed -i "s|^PROWLARR_API_KEY=.*|PROWLARR_API_KEY=$PROWLARR_API_KEY|" /docker/apiKeys.env
        else
            echo "PROWLARR_API_KEY=$PROWLARR_API_KEY" >> /docker/apiKeys.env
        fi

        export TRANSMISSION_USERNAME=""
        export TRANSMISSION_PASSWORD=""
  '';
in {
    config = lib.mkIf (lib.elem "arr" config.this.host.modules.virtualisation) {
        # 🦆 duck say ⮞ sets variables needed for the containers
        systemd.services.arr-conf = lib.mkIf (!config.this.installer) {
            wantedBy = [ "multi-user.target" ];
            preStart = ''
                touch /docker/arr.env
                touch /docker/apiKeys.env
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
            };                                                                                    };

        # 🦆 duck say ⮞ configure the applicationz!
        systemd.services.configure-arr = lib.mkIf (!config.this.installer) {
            description = "Configure ARR services and generate .env file";
            wantedBy = [ "multi-user.target" ];
            after = [ "docker-radarr.service" "docker-sonarr.service" "docker-lidarr.service" ];
            requires = [ "docker-radarr.service" "docker-sonarr.service" "docker-lidarr.service" ];

            serviceConfig = {
                ExecStart = "${configureApplications}/bin/configure-apps";                                Restart = "on-failure";
                RestartSec = "5s";                                                                        RuntimeDirectory = [ "dockeruser" ];
                User = "dockeruser";
            };
        };

        # 🦆 duck say ⮞ Container Configurationz!
        virtualisation.oci-containers = lib.mkIf (!config.this.installer) {
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
                    user = "0:0";
                    dependsOn = [ "gluetun" ];
                    capabilities = { NET_ADMIN = true; };
                    extraOptions = [ "--network=container:gluetun" ];
                    autoStart = true;
                    volumes = [
                        "/docker/flaresolverr:/.local/share/selenium"
                    ];
                    environment = {
                        CAPTCHA_SOLVER = "hcaptcha";
                        PORT = "8191";
                        HEADLESS = "true";
                        USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
                    };

                };

                podgrab = {                                                                                   image = "akhilrex/podgrab";
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

        # 🦆 duck say ⮞ i can secret keepin' dont worriez trust duck
        sops.secrets = lib.mkIf (!config.this.installer) {
            transmission = {
                sopsFile = ./../../secrets/transmission.yaml;
                owner = "dockeruser";
                owner = "dockeruser";
                mode = "0440";
            };
            discordToken = {
                sopsFile = ./../../secrets/discordToken.yaml;
                owner = "dockeruser";
                owner = "dockeruser";
                mode = "0440";
            };
            requestrrPassword = {
                sopsFile = ./../../secrets/requestrrPassword.yaml;
                owner = "dockeruser";
                owner = "dockeruser";
                mode = "0440";
            };
            requestrrPrivateKey = {
                sopsFile = ./../../secrets/requestrrPrivateKey.yaml;
                owner = "dockeruser";
                owner = "dockeruser";
                mode = "0440";
            };
        };

        # 🦆 duck say ⮞ iz diz automatic backup yo?
        systemd.services.arr-backup = lib.mkIf (!config.this.installer) {
            serviceConfig = {
                Type = "oneshot";
                User = "dockeruser";
                ExecStart = "${bashBackup}/bin/backup-apps";
            };
        };
        systemd.timers.arr-backup = lib.mkIf (!config.this.installer) {
            wantedBy = ["timers.target"];
            timerConfig = {
                OnCalendar = "daily";
                Persistent = true;
            };
        };

        # 🦆 duck say ⮞ iz diz automatic restorationz yo?
        systemd.services.arr-restore = lib.mkIf (!config.this.installer) {
            wantedBy = ["multi-user.target"];
            after = ["docker-radarr.service" "docker-sonarr.service" "docker-lidarr.service" "docker-readarr.service" "docker-prowlarr.service"];
            requires = ["docker-radarr.service" "docker-sonarr.service" "docker-lidarr.service" "docker-readarr.service" "docker-prowlarr.service"];
            script = ''
                if [ ! -f /docker/.restored ]; then
                    ${pythonEnv}/bin/python ${pyRestore}                                                      touch /docker/.restored
                fi                                                                                    '';
            serviceConfig = {
                Type = "oneshot";
                User = "dockeruser";
            };
        };

        # 🦆 duck say ⮞ set da /Docker ownersihp and don't forget da permissionz yo!
        system.activationScripts.dockerPermissions = lib.mkIf (!config.this.installer) {
            text = ''
                echo "Setting permissions and ownership for /docker directories..."
                mkdir -p /docker
                touch /docker/apiKeys.env
                chown -R dockeruser:dockeruser /docker
                chmod -R 700 /docker
            '';
        };
        
    };}
    
    
    
    
    
    

