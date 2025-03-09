{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : 
let
  host.desktop = "http://192.168.1.111";
  host.laptop = "http://192.168.1.222";
  host.homie = "http://192.168.1.211";
  host.nasty = "http://192.168.1.28";
  host.localhost = "http://localhost";
in
{ 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SERVICE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°  
    services.homepage-dashboard = {
        enable = true;
        listenPort = 3001;
        openFirewall = false;
        settings = {
            title = "Start";
            #favicon = ./../../home/icons/favicons/duck.ico;
            background = ./../../home/.config/wallpaper.png;
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
              disk = "/Pool";
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

        services = [
          {
            "Pirat Arrr'! Transmission" = [
              {
                "Transmission" = {
                  description = "Torrent Client";
                  href = "http://192.168.1.28:9091";
                  widgets = [
                    {
                      type = "transmission";
                      url = "http://192.168.1.28:9091";
                    }
                  ];
                };
              }
            ];
          }
          {
            "Pirat Arrr'! Sonarr" = [
              {
                "Sonarr" = {
                  icon = "sonarr";
                  description = "TV Shows";
                  href = "http://192.168.1.28:8989";
                  widgets = [
                    {
                      type = "sonarr";
                      url = "http://192.168.1.28:8989";
                      key = "apikeyapikeyapikeyapikeyapikey";
                    }
                  ];
                };
                
                
                "Radarr" = {
                  icon = "radarr";
                  description = "Movies";
                  href = "http://192.168.1.28:8989";
                  widgets = [
                    {
                      type = "Radarr";
                      url = "http://192.168.1.28:8989";
                      key = "apikeyapikeyapikeyapikeyapikey";
                    }
                  ];
                };
          

                "Lidarr" = {
                  icon = "lidarr";
                  description = "Music";
                  href = "http://192.168.1.28:8989";
                  widgets = [
                    {
                      type = "Lidarr";
                      url = "http://192.168.1.28:8989";
                      key = "apikeyapikeyapikeyapikeyapikey";
                    }
                  ];
                };


                
              }
            ];
          }

          
          
          
          
        ]; 
        
        
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
                    href = "https://docs.google.com/spreadsheets/d/1U2oEwJZ1ShrA0RvFWLMyLboLX2GWG2y2AhXd7IUIpSc/edit?gid=242408756#gid=242408756";
                    
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

    };}
