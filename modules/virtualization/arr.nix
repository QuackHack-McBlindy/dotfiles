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
        DOWNLOAD_DIR="/downloads"
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
      
    pythonEnv = pkgs.python3.withPackages (ps: [ ps.requests ps.python-dotenv ]);
    pyTestSetup = pkgs.writeText "test-apps.py" ''
        #!${pythonEnv}/bin/python
        import os
        import requests
        import json

        import sys
        from datetime import datetime
        from urllib.parse import urljoin



        # Configuration
        HOST = "192.168.1.28"
        SERVICES = {
            "prowlarr": {"port": 9696, "path": "/api/v1/system/status"},
            "radarr": {"port": 7878, "path": "/api/v3/system/status"},
            "sonarr": {"port": 8989, "path": "/api/v3/system/status"},
            "lidarr": {"port": 8686, "path": "/api/v1/system/status"},
            "readarr": {"port": 8787, "path": "/api/v1/system/status"},
            "transmission": {"port": 9091, "path": "/transmission/"}
        }

        # Colors for output
        COLOR_OK = "\033[92m"
        COLOR_WARNING = "\033[93m"                                                                COLOR_FAIL = "\033[91m"                                                                   COLOR_END = "\033[0m"                                                                                                                                                               def load_env():                                                                               """Load environment variables from arr.env"""                                             env_path = "/docker/apiKeys.env"                                                       env_vars = {}                                                                             try:                                                                                          with open(env_path) as f:                                                                     for line in f:                                                                                line = line.strip()                                                                       if line and not line.startswith("#"):                                                         key, value = line.split("=", 1)                                                           env_vars[key] = value.strip('"')                                              return env_vars                                                                       except Exception as e:                                                                        print(f"{COLOR_FAIL}Error loading environment: {str(e)}{COLOR_END}")                      exit(1)                                                                                                                                                                     def test_service_health():                                                                    """Test basic connectivity to all services"""                                             print(f"\n{COLOR_OK}=== Service Health Checks ==={COLOR_END}")                            env_vars = load_env()                                                                                                                                                               for service, config in SERVICES.items():                                                      url = f"http://{HOST}:{config['port']}{config['path']}"                                   api_key = env_vars.get(f"{service.upper()}_API_KEY", "")                                                                                                                            try:                                                                                          headers = {"X-Api-Key": api_key} if api_key else {}                                       response = requests.get(url, headers=headers, timeout=10)                                                                                                                           status_icon = f"{COLOR_OK}✓" if response.status_code == 200 else f"{COLOR_FAIL}✗"                                                                                                   print(f"{status_icon} {service.ljust(12)}: HTTP {response.status_code}{COLOR_END}")

                except requests.exceptions.RequestException as e:
                    print(f"{COLOR_FAIL}✗ {service.ljust(12)}: Connection failed - {str(e)}{COLOR_END}")

        def test_prowlarr_config():
            """Verify Prowlarr application configuration and enablement"""                            print(f"\n{COLOR_OK}=== Prowlarr Configuration Tests ==={COLOR_END}")                     env_vars = load_env()                                                                     prowlarr_url = f"http://{HOST}:9696/api/v1/applications"                                                                                                                            try:                                                                                          response = requests.get(                                                                      prowlarr_url,                                                                             headers={"X-Api-Key": env_vars["PROWLARR_API_KEY"]},                                      timeout=10                                                                            )                                                                                         response.raise_for_status()                                                                                                                                                         apps = response.json()                                                                    expected_apps = ["Radarr", "Sonarr", "Lidarr", "Readarr"]                                 app_status = {app["name"]: app for app in apps}                                                                                                                                     for app_name in expected_apps:                                                                if app_name in app_status:                                                                    status = app_status[app_name]                                                             if status["enable"]:                                                                          print(f"{COLOR_OK}✓ {app_name.ljust(12)}: Configured & enabled{COLOR_END}")                                                                                                     else:                                                                                         print(f"{COLOR_WARNING}✗ {app_name.ljust(12)}: Configured but disabled{COLOR_END}")                                                                                         else:                                                                                         print(f"{COLOR_FAIL}✗ {app_name.ljust(12)}: Missing configuration{COLOR_END}")                                                                                                                                                                                    except Exception as e:                                                                        print(f"{COLOR_FAIL}Prowlarr config test failed: {str(e)}{COLOR_END}")                                                                                                                                                                                                                                                                                          def test_download_clients():                                                                  """Validate Transmission configuration using official *Arr API specs"""                   print(f"\n{COLOR_OK}=== Download Client Validation (API-Compliant) ==={COLOR_END}")                                                                                                 env_vars = load_env()                                                                                                                                                               # Define API endpoints according to official documentation
            apps = {                                                                                      "Radarr": {
                    "port": 7878,
                    "path": "/api/v3/downloadclient",
                    "client_type": "Transmission",
                    "protocol": "torrent"
                },                                                                                        "Sonarr": {                                                                                   "port": 8989,                                                                             "path": "/api/v3/downloadclient",                                                         "client_type": "Transmission",                                                            "protocol": "torrent"                                                                 },                                                                                        "Lidarr": {                                                                                   "port": 8686,                                                                             "path": "/api/v1/downloadclient",                                                         "client_type": "Transmission",                                                            "protocol": "torrent"                                                                 },                                                                                        "Readarr": {                                                                                  "port": 8787,                                                                             "path": "/api/v1/downloadclient",
                    "client_type": "Transmission",
                    "protocol": "torrent"
                }
            }
            for app_name, config in apps.items():
                base_url = f"http://{HOST}:{config['port']}"
                api_key = env_vars.get(f"{app_name.upper()}_API_KEY", "")
                if not api_key:
                    print(f"{COLOR_FAIL}✗ {app_name.ljust(12)}: Missing API key{COLOR_END}")
                    continue

                try:
                    # Get download clients with exact API endpoint and parameters
                    response = requests.get(
                        f"{base_url}{config['path']}",                                                            headers={"X-Api-Key": api_key},                                                           timeout=10                                                                            )                                                                                         response.raise_for_status()                                                               clients = response.json()                                                                                                                                                           # Find Transmission clients using exact type match                                        transmission_clients = [                                                                      c for c in clients                                                                        if c.get("implementation") == config["client_type"]                                       and c.get("protocol") == config["protocol"]                                               and c.get("enable", False)                                                            ]                                                                                                                                                                                   if not transmission_clients:                                                                  print(f"{COLOR_FAIL}✗ {app_name.ljust(12)}: No enabled Transmission clients{COLOR_END}")                                                                                            continue                                                                                                                                                                        # Validate each client configuration                                                      for client in transmission_clients:                                                           client_name = client.get("name", "Unnamed")                                               status_prefix = f"{COLOR_OK}✓ {app_name.ljust(12)}: Transmission '{client_name}'"                                                                                                                                                                                             # Extract configuration parameters according to API spec                                  config_fields = {f["name"]: f.get("value") for f in client.get("fields", [])}                                                                                                       host = config_fields.get("host")                                                          port = config_fields.get("port")                                                          username = config_fields.get("username")                                                  password = config_fields.get("password")                                                                                                                                            # Verify required parameters exist                                                        if not all([host, port]):                                                                     print(f"{COLOR_FAIL}✗ {app_name.ljust(12)}: Invalid configuration (missing host/port){COLOR_END}")                                                                                  continue                                                                                                                                                                        # Test Transmission connection using exact field parameters                               try:                                                                                          # Create Transmission RPC session                                                         session = requests.Session()                                                              session.auth = (username, password) if username else None
                                session_id = session_response.headers.get('X-Transmission-Session-Id')
                            else:
                                session_id = None

                            if not session_id:
                                print(f"{COLOR_FAIL}✗ {app_name.ljust(12)}: Failed to get session ID{COLOR_END}")                                                                                                   continue                                                                                                                                                                        # Test connection with session-stats call                                                 headers = {                                                                                   "X-Transmission-Session-Id": session_id,                                                  "Content-Type": "application/json"                                                    }                                                                                         payload = {                                                                                   "method": "session-stats",                                                                "tag": 1                                                                              }                                                                                                                                                                                   rpc_response = session.post(                                                                  rpc_url,                                                                                  headers=headers,                                                                          json=payload,                                                                             timeout=10                                                                            )                                                                                                                                                                                   if rpc_response.status_code == 200:                                                           stats = rpc_response.json().get("arguments", {})                                          print(f"{status_prefix}")                                                                 print(f"   Version: {stats.get('version', 'Unknown')}")                                   print(f"   Active Torrents: {stats.get('activeTorrentCount', 0)}")                        print(f"   Free Space: {stats.get('download-dir-free-bytes', 'N/A')} bytes{COLOR_END}")                                                                                         else:                                                                                         print(f"{COLOR_FAIL}✗ {app_name.ljust(12)}: RPC failed ({rpc_response.status_code}){COLOR_END}")                                                                                                                                                                      except requests.exceptions.RequestException as e:                                             print(f"{COLOR_FAIL}✗ {app_name.ljust(12)}: Connection error - {str(e)}{COLOR_END}")                                                                                                                                                                              except requests.exceptions.HTTPError as e:                                                    print(f"{COLOR_FAIL}✗ {app_name.ljust(12)}: API Error ({e.response.status_code}){COLOR_END}")                                                                                   except requests.exceptions.RequestException as e:                                             print(f"{COLOR_FAIL}✗ {app_name.ljust(12)}: Request failed - {str(e)}{COLOR_END}")                                                                                                                                                                                                                                                                          def test_transmission_connection():                                                           """Test Transmission connection
                # First request to get session ID
                url = f"http://{HOST}:9091/transmission/rpc"
                response = requests.get(
                    url,
                    auth=(username, password),
                    timeout=10
                )                                                                                                                                                                                   # Check for expected status codes                                                         if response.status_code not in [200, 401, 409]:                                               print(f"{COLOR_FAIL}✗ Transmission: Unexpected status {response.status_code}{COLOR_END}")                                                                                           return                                                                                                                                                                          # Handle 401 Unauthorized                                                                 if response.status_code == 401:                                                               print(f"{COLOR_FAIL}✗ Transmission: Authentication failed{COLOR_END}")                    return                                                                                                                                                                          # Extract session ID from headers                                                         session_id = response.headers.get('X-Transmission-Session-Id')                            if not session_id:                                                                            print(f"{COLOR_FAIL}✗ Transmission: Missing session ID{COLOR_END}")                       return                                                                                                                                                                          # Test RPC functionality                                                                  headers = {                                                                                   "X-Transmission-Session-Id": session_id,                                                  "Content-Type": "application/json"                                                    }                                                                                         payload = {                                                                                   "method": "session-get",                                                                  "arguments": {}                                                                       }                                                                                                                                                                                   response = requests.post(                                                                     url,                                                                                      auth=(username, password),                                                                headers=headers,                                                                          json=payload,                                                                             timeout=10                                                                            )                                                                                                                                                                                   if response.status_code == 200:                                                               data = response.json()                                                                    print(f"{COLOR_OK}✓ Transmission: Authenticated successfully")                            print(f"   RPC Version: {data.get('arguments', {}).get('rpc-version')}")                  print(f"   Version: {data.get('arguments', {}).get('version')}{COLOR_END}")           else:                                                                                         print(f"{COLOR_FAIL}✗ Transmission: RPC call failed ({response.status_code}){COLOR_END}")

            test_service_health()
            test_prowlarr_config()
            test_download_clients()
            test_transmission_connection()
            print(f"\n{COLOR_OK}=== Test Suite Completed ==={COLOR_END}")       
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
             
    pyBackup = pkgs.writeText "backup-apps.py" ''
        #!${pkgs.python3}/bin/python
        import os
        import requests
        from pathlib import Path

        HOST = "192.168.1.28"
        OUTPUT_DIR = Path("/docker")
        OUTPUT_DIR.mkdir(exist_ok=True)

        # Load API keys directly (no error handling)
        api_keys = {}
        with open("/docker/apiKeys.env") as f:
            for line in f:
                if "SONARR_API_KEY" in line and "=" in line:
                    api_keys["sonarr"] = line.split("=", 1)[1].strip().strip('"')

        # Fetch backup list
        backups = requests.get(
            f"http://{HOST}:8989/api/v3/system/backup",
            headers={"X-Api-Key": api_keys["sonarr"]}
        ).json()

        # Download first backup
        if backups:
            backup = backups[0]
            response = requests.get(
                f"http://{HOST}:8989/api/v3/system/backup/{backup['id']}",
                headers={"X-Api-Key": api_keys["sonarr"]}
            )
            with open(OUTPUT_DIR / backup["name"], "wb") as f:
                f.write(response.content)
    '';
       
    bashBackup = pkgs.writeScriptBin "backup-apps" ''
        #!/bin/sh
        export PATH="${pkgs.lib.makeBinPath [ pkgs.curl pkgs.jq pkgs.coreutils pkgs.gnugrep ]}"
        BACKUP_NAME=$(curl -s "http://192.168.1.28:8989/api/v3/system/backup" \
            -H "X-Api-Key: $(grep SONARR_API_KEY /docker/apiKeys.env | cut -d= -f2)" | jq -r '.[0].name')
        SONARR_BACKUP_PATH="/docker/sonarr/config/Backups/scheduled/$BACKUP_NAME"
        cp "$SONARR_BACKUP_PATH" /backup/arr/sonarr.zip

        BACKUP_NAME=$(curl -s "http://192.168.1.28:7878/api/v3/system/backup" \
            -H "X-Api-Key: $(grep RADARR_API_KEY /docker/apiKeys.env | cut -d= -f2)" | jq -r '.[0].name')
        RADARR_BACKUP_PATH="/docker/radarr/config/Backups/scheduled/$BACKUP_NAME"
        cp "$RADARR_BACKUP_PATH" /backup/arr/radarr.zip

        BACKUP_NAME=$(curl -s "http://192.168.1.28:8686/api/v1/system/backup" \
            -H "X-Api-Key: $(grep LIDARR_API_KEY /docker/apiKeys.env | cut -d= -f2)" | jq -r '.[0].name')
        LIDARR_BACKUP_PATH="/docker/lidarr/config/Backups/scheduled/$BACKUP_NAME"
        cp "$LIDARR_BACKUP_PATH" /backup/arr/lidarr.zip

        BACKUP_NAME=$(curl -s "http://192.168.1.28:9696/api/v1/system/backup" \
            -H "X-Api-Key: $(grep PROWLARR_API_KEY /docker/apiKeys.env | cut -d= -f2)" | jq -r '.[0].name')
        PROWLARR_BACKUP_PATH="/docker/prowlarr/config/Backups/scheduled/$BACKUP_NAME"
        cp "$PROWLARR_BACKUP_PATH" /backup/arr/prowlarr.zip

        BACKUP_NAME=$(curl -s "http://192.168.1.28:8787/api/v1/system/backup" \
            -H "X-Api-Key: $(grep READARR_API_KEY /docker/apiKeys.env | cut -d= -f2)" | jq -r '.[0].name')
        READARR_BACKUP_PATH="/docker/readarr/config/Backups/scheduled/$BACKUP_NAME"
        cp "$READARR_BACKUP_PATH" /backup/arr/readarr.zip
    '';
            
    
    # Script to set up environment and run Python script
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
    # Creates VPN Network & Open port for Transmission
    imports = [ ./gluetun.nix ];

    # Sets variables needed for the containers
    systemd.services.arr-conf = {
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
                    LOG_LEVEL = "info";
                    HOST = "0.0.0.0";
                    PORT = "8191";
                    HEADLESS = "true";
                    TEST_URL = "https://google.com";
                    BROWSER = "firefox";
                    USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
                };
                
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

    # Automatic Backup
    systemd.services.arr-backup = {
        serviceConfig = {
            Type = "oneshot";
            User = "dockeruser";
            ExecStart = "${bashBackup}/bin/backup-apps";
        };
    };
    systemd.timers.arr-backup = {
        wantedBy = ["timers.target"];
        timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
        };
    };

    # Automatic Restoration From Backup
#    systemd.services.arr-restore = {
#        wantedBy = ["multi-user.target"];
#        after = ["docker-radarr.service" "docker-sonarr.service" "docker-lidarr.service" "docker-readarr.service" "docker-prowlarr.service"];
#        requires = ["docker-radarr.service" "docker-sonarr.service" "docker-lidarr.service" "docker-readarr.service" "docker-prowlarr.service"];
#        script = ''
#            if [ ! -f /docker/.restored ]; then
#                ${pythonEnv}/bin/python ${pyRestore}
#                touch /docker/.restored
#            fi
#        '';
#        serviceConfig = {
#            Type = "oneshot";
#            User = "dockeruser";
#        };
#    };

    # Set /Docker Ownersihp and Permissions 
    system.activationScripts.dockerPermissions = {
        text = ''
            echo "Setting permissions and ownership for /docker directories..."
            mkdir -p /docker
            touch /docker/apiKeys.env
            chown -R dockeruser:dockeruser /docker
            chmod -R 700 /docker
        '';
    };}
    
