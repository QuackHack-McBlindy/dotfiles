# dotfiles/modules/myHouse.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  config,
  lib,
  self,
  zigduck,
  hosts,
  devices,
  icons,
  pkgs,
  ...
} : let
  # 🦆 says ⮞ load custom pages for da dashboard
  customPages  = import ./dashboard.nix { inherit lib config pkgs; };
  pages        = customPages.pages;
  # 🦆 says ⮞ import ma devicez
  houseDevices    = import ./devices.nix { inherit lib config pkgs icons hosts zigduck; };
  myDevices       = houseDevices.devices;
  myZigbeeDevices = houseDevices.zigbee;

  # 🦆 says ⮞ load css files
  css.tv     = builtins.readFile ./themes/css/duckdash/tv.css;
  css.chat   = builtins.readFile ./themes/css/duckdash/chat.css;

  # 🦆 says ⮞
  Mqtt2jsonHistory = field: file: ''
    FILE="${zigduck.stateDir}/${file}"
    VALUE=$(echo "$MQTT_PAYLOAD" | jq '.${field}')
    mkdir -p "$(dirname "$FILE")"

    # 🦆 says ⮞ check current value
    if [ -s "$FILE" ]; then
        CURRENT=$(jq ".${field}" "$FILE")
        if [ "$CURRENT" = "$VALUE" ]; then
            exit 0 # 🦆 says ⮞ skip write – value unchanged
        fi
    fi

    # 🦆 says ⮞ otherwise, update
    if [ ! -s "$FILE" ]; then
        jq -n --argjson v "$VALUE" \
            '{ ${field}: $v, history: [$v] }' > "$FILE"
    else
        jq --argjson v "$VALUE" '
            .${field} = $v
            | .history += [$v]
            | .history = (.history[-200:])
        ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    fi
  '';

  # 🦆 says ⮞ auto detect summer/winter time (for EPG)
  flakeEpoch =
    if self ? lastModified then toString self.lastModified
    else throw "flake has no lastModified — needs to be a git-backed flake";
  tzProbe = pkgs.runCommand "tz-probe" {
    nativeBuildInputs = [ pkgs.tzdata ];
    env.TZDIR = "${pkgs.tzdata}/share/zoneinfo";
    env.EPOCH = flakeEpoch;
  } ''
    TZ=Europe/Stockholm date -d "@$EPOCH" +%z > $out
  '';
  tzOffset = lib.strings.trim (builtins.readFile tzProbe);
  timezone_offset_hours = {
    "+0100" = -1;
    "+0200" = -2;
  }.${tzOffset} or (throw "unexpected TZ offset from tzdata: ${tzOffset}");

  # 🦆 says ⮞ now we can stream tts yo - from zigduck yo
  yoClientsJson = pkgs.writeText "yo-clients.json" (builtins.toJSON (
    map (c: c // { connected_at = 0; })
    [
      { room = "livingroom"; ip = hosts.desktop.ip;               gain = 1.0; }
      { room = "esp";        ip = devices.ESP32-S3-BOX-3.ip;    gain = 1.0; }
    ]
  ));

in { # 🦆 duck say ⮞ house config
  house = {
    # 🦆 says ⮞ ROOM CONFIGURATION
    rooms = {
      bedroom    = {
        icon     = icons.room.bedroom;
        aliases  = [ "sovrum" "sovrummet" ];
      };
      hallway    = {
        icon     = icons.room.hallway;
        aliases  = [ "hall" "hallen" "entren" ];
      };
      kitchen    = {
        icon     = icons.room.kitchen;
        aliases  = [ "kök" "köket" "matsalen" ];
      };
      livingroom = {
        icon     = icons.room.livingroom;
        aliases  = [ "vardagsrum" "vardagsrummet" ];
      };
      wc         = {
        icon     = icons.room.wc;
        aliases  = [ "toa" "toan" "toaletten" "dass" "skithuset" ];
      };
      tv-area    = {
        entertainment = true;
        icon          = icons.tv;
      };
      other.icon      = icons.room.other;
    };

    # 🦆 says ⮞ presence (home/away) state
    presence = {
      probes      = [ devices.iphone.ip ];
      homeActions = [ ];
      awayActions = [ "släck alla lampor" ];
    };

    # 🦆 says ⮞ media
    https.media.urlFile       = config.sops.secrets.webserver.path;
    media.root                = "/Pool";
    media.youtubePasswordFile = config.sops.secrets.youtube_api_key.path;
    media = {
      movies      = "${config.house.media.root}/Movies";
      tv          = "${config.house.media.root}/TV";
      music       = "${config.house.media.root}/Music";
      musicVideos = "${config.house.media.root}/Music_Videos";
      otherVideos = "${config.house.media.root}/Other_Videos";
      podcasts    = "${config.house.media.root}/Podcasts";
      audiobooks  = "${config.house.media.root}/Audiobooks";
    };

    # 🦆 ⮞ DEVICES (non zigbee/NixOS) imported devices.nix ⮜
    devices = myDevices;

# 🦆 ⮞ ZIGBEE ⮜ 🐝
    zigbee = {
      # 🦆 ⮞ DEVICES (loaded from devices.nix) ⮜
      devices = myZigbeeDevices;

      # 🦆 says ⮞ encrypted zigbee network key
      networkKeyFile = config.sops.secrets.z2m_network_key.path;

      # 🦆 says ⮞ mosquitto authentication
      mosquitto = {
        host  = (lib.findFirst
              (h: lib.elem "zigduck" h.modules.services)
              (throw "NO ZIGDUCK HOST")
              (lib.attrValues hosts)).ip;
        username     = "mqtt";
        passwordFile = config.sops.secrets.mosquitto.path;
        baseTopic    = "zigduck";
      };

      # 🦆 says ⮞ TV light syncin'
      hueSyncBox = {
        enable   = true;
        # 🦆 says ⮞ sadly needed (i disable itz internet access - u should too)
        bridge   = {
          passwordFile = config.sops.secrets.hueBridgeAPI.path;
          # 🦆 says ⮞ run the following to get api token:
          # curl -X POST http://192.168.1.33/api -d '{"devicetype":"house#nixos"}'
          ip           = devices.hue-bridge.ip;
        };
        syncBox = { # C42996020AAE
          # 🦆 says ⮞ run the following to get api token for the sync box:
          # curl -k -sS -X POST "https://192.168.1.34/api/v1/registrations" -H "Content-Type: application/json" -d '{"appName": "zigduck", "instanceName": "zigduck"}'
          passwordFile = config.sops.secrets.hueSyncAPI.path;
          ip           = devices.hue-sync.ip;
          tv           = "shield";
        };
      };

      # 🦆says⮞ coordinator configuration
      coordinator = {
        vendorId  =  "10c4";
        productId = "ea60";
        symlink   = "zigbee"; # 🦆 says ⮞ diz symlinkz da serial port to /dev/zigbee
      };

      # 🦆 says ⮞ optional dimmer config
      dimmer.message            = "action";
      dimmer.doubleClickTimeout = 500;

      # 🦆 says ⮞ when motion triggers lights
      motion = {
        when.dark.enable = true;
        trigger.lights = {
          after        = 14;
          before       = 9;
          duration     = 700;
          transition   = true;
        };
      };

      # 🦆 says ⮞ when no motion triggers ALL lights off
      no.motion.trigger = {
        all.lights.off  = {
          enable  = true;
          after   = 90; # 🦆 says ⮞  min
          exclude = [ ]; # 🦆 says ⮞ list of strings, devices to exclude (friendly name, leaves their states as-is)
        };
      };


  # 🦆 ⮞ AUTOMATIONS ⮜
      automations = { # 🦆 says ⮞ i natural language diz home-auto yo
        string.prefix = "yo do";
        # 🦆 says ⮞ there are 6 different automation types
        # 🦆 ⮞ + a greeting automation
        greeting  = {
          enable       = true;
          awayDuration = 7200;
          door         = "Door Sensor Hall";
          delay        = 10; #🦆⮞i zet da prefix
          actions = [ "säg välkommen hem idiot" ];
        };

        # 🦆 says ⮞ 1. MQTT triggered automations
        mqtt_triggered  = {

          flash_lights  = {
            enable      = true;
            description = "Flash lights";
            topic       = "${zigduck.baseTopic}/effects/flash";
            actions  = [
              "skapa en snapshot och döp den till innan flashen samt vänta två sekunder"
              "tänd alla lampor samt vänta fyra sekunder"
              "släck alla lampor fort som fan samt vänta tre sekunder"
              "tänd alla lampor samt vänta fyra sekunder"
              "släck allt igen fort utav helvete samt vänta tre sekunder"
              "tänd allt samt vänta fem sekunder och slutligen återställ systemet till innan flashen"
            ];
          };

          alarm_wakeup  = {
            enable      = true;
            description = "Time to wake up!";
            conditions  = [ { type = "someone_home"; } ];
            topic       = "${zigduck.baseTopic}/alarm/triggered";
            actions  = [ # 🦆 say ⮞ GOOD LUCK STAYING IN BED
              "skicka en notis om ⏰ ALARM: Wake up! samt flasha ljuset"
              "säg UPP MED DIG LATMASK!!! sedan styr sängens fötter upp samt styr sängens huvud uppåt"
              "vänta tio sekunder sedan blinkepartaj"
              "pinga boxen samt pinga klockan sedan vänta tio sekunder"
              "rulla upp persiennerna samt pinga boxen"
              "om det inte är någon i sovrummet så ring fjärrkontrollen"
            ];
          };

          timer_finish  = {
            enable      = true;
            description = "a timer is ringing";
            conditions  = [ { type = "someone_home"; } ];
            topic       = "${zigduck.baseTopic}/timer/finished";
            actions  = [ # 🦆 says ⮞ notify
              "skicka en notis om ⏰ TIMER finish!! samt flasha ljuset"
              "säg timern ringer!! timern ringer!! sedan vänta sju sekunder samt pinga boxen"
            ];
          };

      # 🦆 says ⮞ below are used to create cards
      # 🦆 says ⮞ cards are read & displayed by the frontend
          # 🦆say⮞ crypto tickers
          xmr           = {
            enable      = true;
            description = "Updating XMR price data on dashboard";
            topic       = "${zigduck.baseTopic}/crypto/xmr/price";
            actions     = [{ type = "shell"; command = Mqtt2jsonHistory "current_price" "xmr.json"; }];
          };
          btc           = {
            enable      = true;
            description = "Updating BTC price data on dashboard";
            topic       = "${zigduck.baseTopic}/crypto/btc/price";
            actions     = [{ type = "shell"; command = Mqtt2jsonHistory "current_price" "btc.json"; }];
          };
          # 🦆say⮞ energy tracking
          energyPrice   = {
            enable      = true;
            description = "Updating energy data on dashboard";
            topic       = "${zigduck.baseTopic}/tibber/energy";
            actions     = [{ type = "shell"; command = Mqtt2jsonHistory "current_price" "energy_price.json"; }];
          };
          energyUsage   = {
            enable      = true;
            description = "Updating energy data on dashboard";
            topic       = "${zigduck.baseTopic}/tibber/energy";
            actions     = [{ type = "shell"; command = Mqtt2jsonHistory "monthly_usage" "energy_usage.json"; }];
          };
          # 🦆say⮞ hallway temperature
          temperature   = {
            enable      = true;
            description = "Updating temperature data on dashboard";
            topic       = "${zigduck.baseTopic}/Motion Sensor Hall";
            actions     = [{ type = "shell"; command = Mqtt2jsonHistory "temperature" "temperature.json"; }];
          };
          # 🦆say⮞ calendar
          calendar      = {
            enable      = true;
            description = "Updated calendar events";
            topic       = "${zigduck.baseTopic}/calendar";
            actions = [
              { type    = "shell"; command = ''
                iso_date=$(echo "$MQTT_PAYLOAD" | jq -r '.today_date')
                formatted_date=$(date -d "$iso_date" +"%b %d")
                MQTT_PAYLOAD=$(echo "$MQTT_PAYLOAD" | jq --arg d "$formatted_date" '.today_date = $d')
                echo "$MQTT_PAYLOAD" > ${zigduck.stateDir}/calendar.json
              ''; }
            ];
          };
        };

        # 🦆 says ⮞ 2. room action automations
        room_actions = {
          hallway = { # 🦆 says ⮞ while door is open say something fun until door closes.
            door_opened = [ "medans dörren är öppen så säg tittut! tittut!" ];
            door_closed = [];
          };

          kitchen = { # 🦆 ⮞ if fan is on and consuming power, start countdown to turn fan off. and slowly fade off lights.
            motion_not_detected = [
              "om fläkten drar mer än tjugo watt så stäng fläkten om etthundraåttio sekunder sedan släck köket långsamt"
            ];
            # 🦆 ⮞ 1: start lights. 2: cancel the off-countdown on fan. 3. if my team is playing right now activate scene.
            motion_detected = [
              # 🦆 ⮞ "big" 20ms win - worth it here
              { type = "scene"; scene = "kitchenInstant"; }
              "stäng fläkten om noll sekunder samt om fläkten är av så sätt på fläkten"
              "om björklöven spelar just nu så aktivera scen green devils"
            ];
          };
        };

        # 🦆 says ⮞ 3. global actions automations
        global_actions  = {
          leak_detected = [
            "flasha ljuset samt vänta sju sekunder samt tänd alla lampor"
            "notifiera 💧 🚨 WATER LEAK DETECTED! samt plinga klockan samt plinga boxen"
            "säg VATTEN VATTEN VATTEN VATTEN samt vänta femton sekunder sedan säg VATTEN VATTEN VATTEN!"
          ];
          smoke_detected = [
            "flasha ljuset samt vänta sju sekunder samt tänd alla lampor"
            "notifiera 🔥 🔥 FIRE DETECTED! 🔥 🔥 samt plinga klockan samt plinga boxen"
            "säg ELD ELD ELD ELD samt vänta femton sekunder sedan säg ELD ELD ELD ELD!"
          ];
        };

        # 🦆 says ⮞ 4. dimmer actions automations
        dimmer_actions = {
          bedroom      = {
            off_hold_release   = {
              enable           = true;
              description      = "Turn off all configured light devices";
              extra_actions    = [];
              override_actions = [ "släck alla lampor samt stäng av fläkten" ];
            };
          };

          kitchen = {
            on_press_release = {
              enable         = true;
              description    = "Turn on kitchen fan (+ lights)";
              extra_actions  = [ "starta fläkten" ];
              override_actions = [ ];
            };
          };

          livingroom = {
            on_press_release   = {
              enable           = true;
              description      = "Turn on kitchen fan (+ lights).";
              extra_actions    = [ "starta fläkten" ];
              override_actions = [];
            };
          };
        };

        # 🦆 says ⮞ 5. time based automations
        time_based = {
          morning_wakeup = {
            enable       = true;
            description  = "set morning wakeup alarm (dont miss lunch)";
            conditions  = [ { type = "someone_home"; } ];
            # 🦆 says ⮞ 01 AM mon-fri
            schedule     = {
              start      = "01:00";
              days       = ["mon" "tue" "wed" "thu" "fri"];
            };
            # 🦆 says ⮞ 11.30 AM (i like to sleep in)
            actions      = [ "väck mig klockan elva och trettio'" ];
          };

          # 🦆 says ⮞ daily tv scraper
          tv_scraping   = {
            enable      = true;
            description = "Scrape TV-guide";
            # 🦆 says ⮞ 03:30 AM everyday
            schedule    = {
              start     = "03:30";
              days      = ["mon" "tue" "wed" "thu" "fri" "sat" "sun"];
            };
            # 🦆 says ⮞ scrape & save so dashboard can read
            actions  = [
              "tv-scraper --json-out ${zigduck.stateDir}/epg.json --html-out ${zigduck.stateDir}/tv.html --xml-out ${zigduck.stateDir}/epg.xml"
            ];
          };
        };

        # 🦆 says ⮞ 6. presence based automations
        presence_based = {};
      };


  # 🦆 ⮞ SCENES ⮜
      scenes = {
          # 🦆 says ⮞ Scene name
          "Chill Scene"         = {
              # 🦆 says ⮞ device friendly name & state
              "PC"              = { state = "ON"; brightness = 200; color = { hex = "#8A2BE2"; }; };
              "Golvet"          = { state = "ON"; brightness = 200; color = { hex = "#40E0D0"; }; };
              "Uppe"            = { state = "ON"; brightness = 200; color = { hex = "#FF69B4"; }; };
              "Spotlight kök 1" = { state = "OFF"; brightness = 200; color = { hex = "#FFD700"; }; };
              "Spotlight Kök 2" = { state = "OFF"; brightness = 200; color = { hex = "#FF8C00"; }; };
              "Taket Sovrum 1"  = { state = "ON"; brightness = 200; color = { hex = "#00CED1"; }; };
              "Taket Sovrum 2"  = { state = "ON"; brightness = 200; color = { hex = "#9932CC"; }; };
              "Bloom"           = { state = "ON"; brightness = 200; color = { hex = "#FFB6C1"; }; };
              "Sänggavel"       = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };
              "Takkrona 1"      = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };
              "Takkrona 2"      = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };
              "Takkrona 3"      = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };
              "Takkrona 4"      = { state = "ON"; brightness = 200; color = { hex = "#7FFFD4"; }; };
          };

          "Green D"             = {
              "Golvet"          = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Uppe"            = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Spotlight kök 1" = { state = "OFF"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Spotlight Kök 2" = { state = "OFF"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Taket Sovrum 1"  = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Taket Sovrum 2"  = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Bloom"           = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Sänggavel"       = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Takkrona 1"      = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Takkrona 2"      = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Takkrona 3"      = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
              "Takkrona 4"      = { state = "ON"; brightness = 200; color = { hex = "#00FF00"; }; };
          };

          "kitchenInstant"      = {
              "Golvet"          = { state = "ON"; brightness = 124; color = { hex = "#7852A9"; }; };
              "Kök Bänk Slinga" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Spotlight Kök 2" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Spotlight kök 1" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Uppe"            = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
          };

          "kitchenGreenInstant" = {
              "Golvet"          = { state = "ON"; brightness = 124; color = { hex = "#00FF00"; }; };
              "Kök Bänk Slinga" = { state = "ON"; brightness = 254; color = { hex = "#00FF00"; }; };
              "Spotlight Kök 2" = { state = "ON"; brightness = 254; color = { hex = "#00FF00"; }; };
              "Spotlight kök 1" = { state = "ON"; brightness = 254; color = { hex = "#00FF00"; }; };
              "Uppe"            = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
          };

          # 🦆 says ⮞ veeeery slow turn off
          "kitchenFadeOff"      = {
              "Golvet"          = { state = "OFF"; transition = 180; };
              "Kök Bänk Slinga" = { state = "OFF"; transition = 180; };
              "PC"              = { state = "OFF"; transition = 180; };
              "Spotlight Kök 2" = { state = "OFF"; transition = 180; };
              "Spotlight kök 1" = { state = "OFF"; transition = 180; };
              "Uppe"            = { state = "OFF"; transition = 180; };
          };

          "dark"                = { # 🦆 says ⮞ eat darkness... lol YO! You're as blind as me now! HA HA!
              "Bloom"           = { state = "OFF"; transition = 10; };
              "Dörr"            = { state = "OFF"; transition = 10; };
              "Golvet"          = { state = "OFF"; transition = 10; };
              "Kök Bänk Slinga" = { state = "OFF"; transition = 10; };
              "PC"              = { state = "OFF"; transition = 10; };
              "Rustning"        = { state = "OFF"; transition = 10; };
              "Spotlight Kök 2" = { state = "OFF"; transition = 10; };
              "Spotlight kök 1" = { state = "OFF"; transition = 10; };
              "Sänggavel"       = { state = "OFF"; transition = 10; };
              "Tak Hall"        = { state = "OFF"; transition = 10; };
              "Taket Sovrum 1"  = { state = "OFF"; transition = 10; };
              "Taket Sovrum 2"  = { state = "OFF"; transition = 10; };
              "Uppe"            = { state = "OFF"; transition = 10; };
              "Vägg"            = { state = "OFF"; transition = 10; };
              "WC 1"            = { state = "OFF"; transition = 10; };
              "WC 2"            = { state = "OFF"; transition = 10; };
              "Takkrona 1"      = { state = "OFF"; transition = 10; };
              "Takkrona 2"      = { state = "OFF"; transition = 10; };
              "Takkrona 3"      = { state = "OFF"; transition = 10; };
              "Takkrona 4"      = { state = "OFF"; transition = 10; };
              "TV Play Strip"   = { state = "OFF"; transition = 150; };
              "TV Play 1"       = { state = "OFF"; transition = 150; };
              "TV Play 2"       = { state = "OFF"; transition = 150; };
              "TV Play 3"       = { state = "OFF"; transition = 150; };
              "TV Play 4"       = { state = "OFF"; transition = 150; };
              "Play Top L"      = { state = "OFF"; transition = 150; };
              "Play Top R"      = { state = "OFF"; transition = 150; };
          };

          "dark-fast"           = { # 🦆 says ⮞ eat darkness... NAO!
              "Bloom"           = { state = "OFF"; };
              "Dörr"            = { state = "OFF"; };
              "Golvet"          = { state = "OFF"; };
              "Kök Bänk Slinga" = { state = "OFF"; };
              "PC"              = { state = "OFF"; };
              "Rustning"        = { state = "OFF"; };
              "Spotlight Kök 2" = { state = "OFF"; };
              "Spotlight kök 1" = { state = "OFF"; };
              "Sänggavel"       = { state = "OFF"; };
              "Tak Hall"        = { state = "OFF"; };
              "Taket Sovrum 1"  = { state = "OFF"; };
              "Taket Sovrum 2"  = { state = "OFF"; };
              "Uppe"            = { state = "OFF"; };
              "Vägg"            = { state = "OFF"; };
              "WC 1"            = { state = "OFF"; };
              "WC 2"            = { state = "OFF"; };
              "Takkrona 1"      = { state = "OFF"; };
              "Takkrona 2"      = { state = "OFF"; };
              "Takkrona 3"      = { state = "OFF"; };
              "Takkrona 4"      = { state = "OFF"; };
              "TV Play Strip"   = { state = "OFF"; };
              "TV Play 1"       = { state = "OFF"; };
              "TV Play 2"       = { state = "OFF"; };
              "TV Play 3"       = { state = "OFF"; };
              "TV Play 4"       = { state = "OFF"; };
              "Play Top L"      = { state = "OFF"; };
              "Play Top R"      = { state = "OFF"; };
          };

          "max"                 = { # 🦆 says ⮞ let there be light
              "Bloom"           = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Dörr"            = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Golvet"          = { state = "ON"; brightness = 124; color = { hex = "#7852A9"; }; };
              "Kök Bänk Slinga" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "PC"              = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Rustning"        = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Spotlight Kök 2" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Spotlight kök 1" = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Sänggavel"       = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Tak Hall"        = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Taket Sovrum 1"  = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Taket Sovrum 2"  = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Uppe"            = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Vägg"            = { state = "ON"; brightness = 1; }; # 🦆 says ⮞ 1% bright enuff on dis qwackit...
              "WC 1"            = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "WC 2"            = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Takkrona 1"      = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Takkrona 2"      = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Takkrona 3"      = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "Takkrona 4"      = { state = "ON"; brightness = 254; color = { hex = "#FFFFFF"; }; };
              "TV Play Strip"   = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "TV Play 1"       = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "TV Play 2"       = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "TV Play 3"       = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "TV Play 4"       = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "Play Top L"      = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
              "Play Top R"      = { state = "ON"; brightness = 254; color = { xy = [ 0.3127 0.3290 ]; }; };
          };

          "tv-area1"          = {
              "TV Play Strip" = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.6321 0.2678 ]; }; transition = 15; };
              "TV Play 1"     = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.1491 0.3012 ]; }; transition = 15; };
              "TV Play 2"     = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.2654 0.6680 ]; }; transition = 15; };
              "TV Play 3"     = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.4995 0.4697 ]; }; transition = 15; };
              "TV Play 4"     = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.2293 0.0945 ]; }; transition = 15; };
              "Play Top L"    = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.6187 0.3687 ]; }; transition = 15; };
              "Play Top R"    = { state = "ON"; brightness = 254; hue = 49460; sat = 242; color = { xy = [ 0.1611 0.5294 ]; }; transition = 15; };
          };

          "tv-area2"          = {
              "TV Play Strip" = { state = "ON"; brightness = 254; hue = 56100; sat = 250; color = { xy = [ 0.3824 0.1600 ]; }; transition = 15; };
              "TV Play 1"     = { state = "ON"; brightness = 240; hue = 56100; sat = 250; color = { xy = [ 0.1682 0.0410 ]; }; transition = 15; };
              "TV Play 2"     = { state = "ON"; brightness = 240; hue = 56100; sat = 250; color = { xy = [ 0.1532 0.0475 ]; }; transition = 15; };
              "TV Play 3"     = { state = "ON"; brightness = 240; hue = 56100; sat = 250; color = { xy = [ 0.2746 0.1320 ]; }; transition = 15; };
              "TV Play 4"     = { state = "ON"; brightness = 240; hue = 56100; sat = 250; color = { xy = [ 0.4088 0.5170 ]; }; transition = 15; };
              "Play Top L"    = { state = "ON"; brightness = 254; hue = 56100; sat = 250; color = { xy = [ 0.2255 0.3299 ]; }; transition = 15; };
              "Play Top R"    = { state = "ON"; brightness = 254; hue = 56100; sat = 250; color = { xy = [ 0.1670 0.3520 ]; }; transition = 15; };
          };

          "tv-area3"          = {
              "TV Play Strip" = { state = "ON"; brightness = 254; hue = 12750; sat = 200; color = { xy = [ 0.5128 0.4147 ]; }; transition = 15; };
              "TV Play 1"     = { state = "ON"; brightness = 230; hue = 12750; sat = 200; color = { xy = [ 0.5752 0.3850 ]; }; transition = 15; };
              "TV Play 2"     = { state = "ON"; brightness = 230; hue = 12750; sat = 200; color = { xy = [ 0.4597 0.4106 ]; }; transition = 15; };
              "TV Play 3"     = { state = "ON"; brightness = 230; hue = 12750; sat = 200; color = { xy = [ 0.3690 0.3576 ]; }; transition = 15; };
              "TV Play 4"     = { state = "ON"; brightness = 230; hue = 12750; sat = 200; color = { xy = [ 0.5016 0.4400 ]; }; transition = 15; };
              "Play Top L"    = { state = "ON"; brightness = 254; hue = 12750; sat = 200; color = { xy = [ 0.4448 0.4066 ]; }; transition = 15; };
              "Play Top R"    = { state = "ON"; brightness = 254; hue = 12750; sat = 200; color = { xy = [ 0.4020 0.3810 ]; }; transition = 15; };
          };
        };
    };

    # 🦆 ⮞ TV ⮜
    # 🦆says⮞ configure TV devices with: room, ip, apps & channel information
    tv = {
      # 🦆 says ⮞ Livingroom
      shield      = {
        enable    = true;
        room      = "tv-area";
        ip        = devices.shield.ip;
        apps      = {
          telenor = "se.telenor.stream/.MainActivity";
          tv4     = "se.tv4.tv4playtab/se.tv4.tv4play.ui.mobile.main.BottomNavigationActivity";
        };

        # 🦆 says ⮞ EPG collector (can be overridden per-channel)
        scraper   = {
          row_xpath                = ''//table[@id="channel-schedule"]//tr'';
          time_xpath               = ".//time";
          time_attr                = "datetime";
          title_xpath              = ''.//a[contains(@class, "program-title")]'';
          desc_xpath               = ".//p";
          time_formats             = [ "%H:%M" "%H.%M" ];
          time_strip_pattern       = ''[^\d:\.]'';
          default_duration_minutes = 30;
          timezone_offset_hours    = timezone_offset_hours;
          pm_heuristic_after_hour  = null;
        };

        channels       = {
          "1"          = {
            name       = "SVT1";
            id         = 1; # 🦆 says ⮞ adb channel ID
            # 🦆 says ⮞ OR
            # stream_url = "https://url.com/";
            cmd        = "open_telenor && wait 5 && start_channel_1";
            # 🦆 says ⮞ automagi generated tv-guide web & EPG
            icon       = ./themes/icons/tv/1.png;
            scrape_url = "https://tv-tabla.se/tabla/svt1/";
            # 🦆 says ⮞ tv-scraper PER-CHANNEL overrides
            # scraper  = {};
          };
          "2"          = {
            id         = 2;
            name       = "SVT2";
            cmd        = "open_telenor && wait 5 && start_channel_2";
            icon       = ./themes/icons/tv/2.png;
            scrape_url = "https://tv-tabla.se/tabla/svt2/";
          };
          "3"          = {
            id         = 3;
            name       = "Kanal 3";
            cmd        = "open_telenor && wait 5 && start_channel_3";
            icon       = ./themes/icons/tv/3.png;
            scrape_url = "https://tv-tabla.se/tabla/tv3/";
          };
          "4"          = {
            id         = 4;
            name       = "TV4";
            cmd        = "open_telenor && wait 5 && start_channel_4";
            icon       = ./themes/icons/tv/4.png;
            scrape_url = "https://tv-tabla.se/tabla/tv4/";
          };
          "5"          = {
            id         = 5;
            name       = "Kanal 5";
            cmd        = "open_telenor && wait 5 && start_channel_5";
            icon       = ./themes/icons/tv/5.png;
            scrape_url = "https://tv-tabla.se/tabla/kanal_5/";
          };
          "6"          = {
            id         = 6;
            name       = "Kanal 6";
            cmd        = "open_telenor && wait 5 && start_channel_6";
            icon       = ./themes/icons/tv/6.png;
            scrape_url = "https://tv-tabla.se/tabla/tv6/";
          };
          "7"          = {
            id         = 7;
            name       = "Sjuan";
            cmd        = "open_telenor && wait 5 && start_channel_7";
            icon       = ./themes/icons/tv/7.png;
            scrape_url = "https://tv-tabla.se/tabla/sjuan/";
          };
          "8"          = {
            id         = 8;
            name       = "TV8";
            icon       = ./themes/icons/tv/8.png;
            scrape_url = "https://tv-tabla.se/tabla/tv8/";
          };
          "9"          = {
            id         = 9;
            name       = "Kanal 9";
            icon       = ./themes/icons/tv/9.png;
            scrape_url = "https://tv-tabla.se/tabla/kanal_9/";
          };
          "10"         = {
            id         = 10;
            name       = "Kanal 10";
            icon       = ./themes/icons/tv/10.png;
            scrape_url = "https://tv-tabla.se/tabla/tv10/";
          };
          "11"         = {
            id         = 11;
            name       = "Kanal 11";
            icon       = ./themes/icons/tv/11.png;
            scrape_url = "https://tv-tabla.se/tabla/tv11/";
          };
          "12"         = {
            id         = 12;
            name       = "Kanal 12";
            icon       = ./themes/icons/tv/12.png;
            scrape_url = "https://tv-tabla.se/tabla/tv12/";
          };
          "13"         = {
            id         = 13;
            name       = "TV4 Hockey";
            icon       = ./themes/icons/tv/13.png;
            cmd        = "open_tv4 && nav_select && nav_left && nav_down && nav_doown && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_select";
            scrape_url = "https://tv-tabla.se/tabla/tv4_hockey/";
          };
          "14"         = {
            id         = 14;
            name       = "TV4 Sport Live 1";
            icon       = ./themes/icons/tv/14.png;
            cmd        = "open_tv4 && nav_left && nav_down && nav_down && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_right && nav_right && nav_select";
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_1/";
          };
          "15"         = {
            id         = 15;
            name       = "TV4 Sport Live 2";
            icon       = ./themes/icons/tv/15.png;
            cmd        = "open_tv4 && nav_select && nav_left && nav_down && nav_down && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_down && nav_select";
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_2/";
          };
          "16"         = {
            id         = 16;
            name       = "TV4 Sport Live 3";
            icon       = ./themes/icons/tv/16.png;
            cmd        = "open_tv4 && nav_down && nav_right && nav_right && nav_center";
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_3/";
          };
          "17"         = {
            id         = 17;
            name       = "TV4 Sport Live 4";
            icon       = ./themes/icons/tv/17.png;
            cmd        = "open_tv4 && nav_left && nav_down && nav_down && nav_down && nav_select && wait 3 && nav_down && nav_down && nav_down && nav_down && nav_down && nav_down && nav_right && nav_right && nav_select";
            scrape_url = "https://tv-tabla.se/tabla/tv4_sport_live_4/";
          };
        };
      };
    };


# 🦆 says ⮞ DASHBOARD CONFIOGURATION
    https.dashboard.urlFile = config.sops.secrets.dashboard.path;

    dashboard   = {
      # 🦆 says ⮞  home page information cards
      statusCards          = {
        calendar           = {
          enable           = true;
          title            = "𝑪𝑨𝑳𝑬𝑵𝑫𝑨𝑹";
          group            = "1";
          icon             = "fas fa-calendar";
          color            = "#ff0000";
          theme            = "glass";
          filePath         = "${zigduck.stateDir}/calendar.json";
          jsonField        = "today_date";
          format           = "{value}";
          detailsJsonField = "today_events";
          detailsFormat    = "{value}";
          chart            = false;
          on_click_action  = [
            {
              type    = "shell";
              command = "yo say \"detta är ett ank test - testar ankor ankor anka naka naka ojojojjoj vad många ankor detta blev oj oj\" --host desktop";
            }
          ];
        };

        # 🦆 says ⮞ Monero USD price ticker
        xmr                = {
          enable           = true;
          title            = "𝑿𝑴𝑹";
          group            = "tickers";
          icon             = "fab fa-monero";
          color            = "#a78bfa";
          theme            = "colorful";
          filePath         = "${zigduck.stateDir}/xmr.json";
          jsonField        = "current_price";
          format           = "{value}";
          detailsJsonField = "7d_change";
          detailsFormat    = "7d: {value}%";
          chart            = true;
          historyField     = "history";
        };

        # 🦆 says ⮞ Bitcoin USD price ticker
        btc                = {
          enable           = true;
          title            = "𝑩𝑻𝑪";
          group            = "tickers";
          icon             = "fab fa-bitcoin";
          color            = "#ff6600";
          filePath         = "${zigduck.stateDir}/btc.json";
          jsonField        = "current_price";
          format           = "{value}";
          detailsJsonField = "7d_change";
          detailsFormat    = "7d: {value}%";
          chart            = true;
          historyField     = "history";
        };

        # 🦆 says ⮞ kWh/price chart card
        energyPrice    = {
          enable       = true;
          title        = "𝑷𝑹𝑰𝑪𝑬";
          group        = "energy";
          icon         = "fas fa-bolt";
          color        = "#ffff00";
          filePath     = "${zigduck.stateDir}/energy_price.json";
          jsonField    = "current_price";
          format       = "{value} SEK/kWh";
          chart        = true;
          historyField = "history";
        };

        # 🦆 says ⮞ energy usage card
        energyUsage    = {
          enable       = true;
          title        = "USAGE";
          group        = "energy";
          icon         = "fas fa-bolt";
          color        = "#ffff00";
          filePath     = "${zigduck.stateDir}/energy_usage.json";
          jsonField    = "monthly_usage";
          format       = "{value} kWh";
          chart        = true;
          historyField = "history";
        };

        # 🦆 says ⮞ show indoor temperature
        temperature     = {
          enable        = true;
          title         = "TEMPERATURE C";
          group         = "sensors";
          icon          = "fas fa-thermometer-half";
          color         = "#e74c3c";
          theme         = "glass";
          filePath      = "${zigduck.stateDir}/temperature.json";
          jsonField     = "temperature";
          format        = "{value} °C";
          detailsFormat = "Temperature in Hallway";
          chart         = true;
          historyField  = "history";
        };
      };

      # 🦆 says ⮞ DASHBOARD PAGES (extra tabs)
      pages  = {
        # 🦆says⮞ ChatBot (no LLM) - Less thinkin', more doin'!
        "4"     = {
          icon  = "fas fa-comments";
          title = "chat";
          css   = css.chat;
          # 🦆 says ⮞ symlink TTS audio to frontend webserver
          files = { tts = "${zigduck.stateDir}/tts"; };
          code  = pages.chat;
        };
      };
    };
  };

  systemd.tmpfiles.rules = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) [
    "d  ${zigduck.stateDir}/.config/yo             0700 zigduck zigduck - -"
    "C  ${zigduck.stateDir}/.config/yo/clients.json 0600 zigduck zigduck - ${yoClientsJson}"
  ];

  sops = {
    secrets =  {
      api = {
        sopsFile = ./../secrets/api.yaml;
        owner    = "zigduck";
        group    = "zigduck";
        mode     = "0440"; # Read-only for owner and group
      };
      hueBridgeAPI = {
        sopsFile   = ./../secrets/hueBridgeAPI.yaml;
        owner      = "zigduck";
        group      = "zigduck";
        mode       = "0440"; # Read-only for owner and group
      };
      hueSyncAPI = {
        sopsFile = ./../secrets/hueSyncAPI.yaml;
        owner    = "zigduck";
        group    = "zigduck";
        mode     = "0440"; # Read-only for owner and group
      };
      mosquitto  = { # 🦆 says ⮞ quack, stupid!
        sopsFile = ./../secrets/mosquitto.yaml;
        owner    = config.this.user.me.name;
        group    = config.this.user.me.name;
        mode     = "0444"; # 🦆 says ⮞ Read-only for owner and group
      }; # 🦆 says ⮞ Z2MQTT encryption key - if changed needs re-pairing devices
      z2m_network_key = {
        sopsFile      = ./../secrets/z2m_network_key.yaml;
        owner         = "zigbee2mqtt";
        group         = "zigbee2mqtt";
        mode          = "0440"; # 🦆 says ⮞ Read-only for owner and group
      };
      webserver  = { # 🦆 says ⮞ https required
        sopsFile = ./../secrets/webserver.yaml;
        owner    = config.this.user.me.name;
        group    = "zigduck";
        mode     = "0440";
      };
      dashboard  = { # 🦆 says ⮞ i likez TLS
        sopsFile = ./../secrets/dashboard.yaml;
        owner    = config.this.user.me.name;
        group    = "zigduck";
        mode     = "0440";
      }; # 🦆 says ⮞ required for youtube
      youtube_api_key = {
        sopsFile = ./../secrets/youtube.yaml;
        owner    = config.this.user.me.name;
        group    = config.this.user.me.name;
        mode     = "0440";
      };
      z2m_mosquitto = {
        sopsFile = ./../secrets/z2m_mosquitto.yaml;
        owner    = "zigbee2mqtt";
        group    = "zigbee2mqtt";
        mode     = "0440"; # 🦆 says ⮞ Read-only for owner and group
      };
    };

  };}
