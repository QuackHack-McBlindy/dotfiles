{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SERVICE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°  
    services.homepage-dashboard = {
        enable = true;
        listenPort = 3001;
        openFirewall = false;
        #package 
        settings = {
            title = "Homeducks";
       #     favicon = ./../../home/.config/wallpaper.png;
      #      background = ./../../home/icons/favicons/favicon.ico;
            backgroundOpacity = "0.3";
        };
        #docker = { };
        customCSS = ''
        {
        /* General body styling */
          body {
            background-color: #1e2a34; /* Dark greenish background */
            color: #d1e7e6; /* Light teal text */
            font-family: 'Arial', sans-serif;
          }
          
          /* Header styling */
          header {
            background-color: #006d5b; /* Teal */
            color: #ffffff; /* White text */
            padding: 15px;
            text-align: center;
          }
          
          /* Navigation links */
          nav a {
            color: #ffffff; /* White text */
            text-decoration: none;
            padding: 10px 15px;
            display: inline-block;
          }
          
          nav a:hover {
            background-color: #004d42; /* Dark teal hover effect */
          }
          
          /* Card and box styling */
          .card {
            background-color: #003830; /* Dark green */
            border-radius: 10px;
            margin: 15px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          }
          
          .card h3 {
            color: #00b1a1; /* Teal */
          }
          
          .card p {
            color: #b5e7e0; /* Lighter teal */
          }
          
          /* Buttons */
          button {
            background-color: #00b1a1; /* Teal */
            color: #ffffff;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
          }
          
          button:hover {
            background-color: #008f82; /* Dark teal hover effect */
          }
          
          /* Links */
          a {
            color: #00b1a1; /* Teal */
            text-decoration: none;
          }
          
          a:hover {
            color: #007c66; /* Darker teal */
          }
          
          /* Footer styling */
          footer {
            background-color: #006d5b; /* Teal */
            color: #ffffff; /* White text */
            padding: 15px;
            text-align: center;
          }
          
          /* Widgets styling */
          .widget {
            background-color: #003830; /* Dark green */
            padding: 10px;
            border-radius: 8px;
          }
          
          .widget h4 {
            color: #00b1a1; /* Teal */
          }
          
          .widget p {
            color: #b5e7e0; /* Lighter teal */
          }
          
          /* Table styling */
          table {
            width: 100%;
            border-collapse: collapse;
          }
          
          table th, table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #444;
          }
          
          table th {
            background-color: #006d5b; /* Teal */
            color: #ffffff;
          }
          
          table tr:hover {
            background-color: #005c50; /* Dark teal hover */
          }
        }
        '';
        widgets = [
          {
            resources = {
              cpu = true;
              disk = "/";
              memory = true;
            };
          }
          {
            search = {
              provider = "duckduckgo";
              target = "_blank";
            };
          }
        ];

        services = {
          GroupA = [
            {
              Sonarr = {
                href = "http://sonarr.host";
                icon = "sonarr.png";
                description = "Series management";
                widget = {
                  type = "sonarr";
                  url = "http://sonarr.host";
                  key = "apikeyapikeyapikeyapikeyapikey";
                };
              };
            }
            {
              Radarr = {
                href = "http://radarr.host";
                icon = "radarr.png";
                description = "Movie management";
                widget = {
                  type = "radarr";
                  url = "http://radarr.host";
                  key = "apikeyapikeyapikeyapikeyapikey";
                };
              };
            }
          ];

          GroupB = [
            {
              Lidarr = {
                href = "http://lidarr.host";
                icon = "lidarr.png";
                description = "Music management";
                widget = {
                  type = "lidarr";
                  url = "http://lidarr.host";
                  key = "apikeyapikeyapikeyapikeyapikey";
                };
              };
            }
            {
              Readarr = {
                href = "http://readarr.host";
                icon = "readarr.png";
                description = "Ebook management";
                widget = {
                  type = "readarr";
                  url = "http://readarr.host";
                  key = "apikeyapikeyapikeyapikeyapikey";
                };
              };
            }
          ];

          GroupC = [
            {
              Prowlarr = {
                href = "http://prowlarr.host";
                icon = "prowlarr.png";
                description = "Indexer management";
                widget = {
                  type = "prowlarr";
                  url = "http://prowlarr.host";
                  key = "apikeyapikeyapikeyapikeyapikey";
                };
              };
            }
            {
              Jellyfin = {
                href = "http://jellyfin.host";
                icon = "jellyfin.png";
                description = "Media server";
                widget = {
                  type = "jellyfin";
                  url = "http://jellyfin.host";
                  key = "apikeyapikeyapikeyapikeyapikey";
                };
              };
            }
          ];

          GroupD = [
            {
              Navidrome = {
                href = "http://navidrome.host";
                icon = "navidrome.png";
                description = "Music streaming server";
                widget = {
                  type = "navidrome";
                  url = "http://navidrome.host";
                  key = "apikeyapikeyapikeyapikeyapikey";
                };
              };
            }
            {
              Zigbee2mqtt = {
                href = "http://zigbee2mqtt.host";
                description = "Zigbee gateway";
                widget = {
                  type = "zigbee2mqtt";
                  url = "http://zigbee2mqtt.host";
                  key = "apikeyapikeyapikeyapikeyapikey";
                };
              };
            }
            {
              Mosquitto = {
                href = "http://mosquitto.host";
                icon = "mosquitto.png";
                description = "MQTT broker";
                widget = {
                  type = "mosquitto";
                  url = "http://mosquitto.host";
                  key = "apikeyapikeyapikeyapikeyapikey";
                };
              };
            }
          ];
        };
   #     kubernetes = { };
   #     customJS = { };
        bookmarks = [
          {
            Developer = [
              {
                Github = [
                  {
                    abbr = "GH";
                    href = "https://github.com/QuackHack-McBlindy";
                  }
                ];
              }
            ];
          }
          {
            Entertainment = [
              {
                Spreadsheet = [
                  {
                    abbr = "Poké";
                    href = "https://docs.google.com/spreadsheets/d/1U2oEwJZ1ShrA0RvFWLMyLboLX2GWG2y2AhXd7IUIpSc/edit#gid=705464364";
                  }
                ];
              }
            ];
          }
          {
            Mail = [
              {
                PRotonMail = [
                  {
                    abbr = "PM";
                    href = "https://docs.google.com/spreadsheets/d/1U2oEwJZ1ShrA0RvFWLMyLboLX2GWG2y2AhXd7IUIpSc/edit#gid=705464364";
                  }
                ];
              }
            ];
          }
          {
            Misc = [
              {
                ICA = [
                  {
                    abbr = "ICA";
                    href = "https://docs.google.com/spreadsheets/d/1U2oEwJZ1ShrA0RvFWLMyLboLX2GWG2y2AhXd7IUIpSc/edit#gid=705464364";
                  }
                ];
              }
            ];
          }
        ];
       # environmentFile




    };}
