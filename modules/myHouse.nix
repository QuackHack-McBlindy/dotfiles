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
} : let # 🦆 say ⮞ load dash pages css files
  strip = text:
    builtins.replaceStrings [ "/*" "*/" ] [ "" "" ] text;

  # 🦆 says ⮞ load custom pages 4 dashboard
  customPages = import ./dashboard.nix { inherit lib config pkgs; };
  pages       = customPages.pages;

  # 🦆 says ⮞ load css files
  css = {
    tv        = builtins.readFile ./themes/css/duckdash/tv.css;
    chat      = builtins.readFile ./themes/css/duckdash/chat.css;
  };

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

  # 🦆 says ⮞ detect summer/winter time (for EPG)
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
in { # 🦆 duck say ⮞ house config
  house = {
    # 🦆 says ⮞ ROOM CONFIGURATION
    rooms = {
      bedroom.icon    = icons.room.bedroom;
      hallway.icon    = icons.room.hallway;
      kitchen.icon    = icons.room.kitchen;
      livingroom.icon = icons.room.livingroom;
      wc.icon         = icons.room.wc;
      tv-area = {
        entertainment = true;
        icon          = icons.tv;
      };
      other.icon      = icons.room.other;
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

# 🦆 ⮞ DEVICES ⮜
    devices = {
      # 🦆 ⮞ NixOS machines....
      "desktop" = { # 🦆 ⮞ mqtt published @ "zigduck/desktop"
        enable  = true; # 🦆 ⮞ will be displayed in da frontend!
        room    = "other"; # 🦆 ⮞ i pub system health there yo (json)
        icon    = icons.desktop;
        ip      = hosts.desktop.ip;
      };
      "homie"   = {
        enable  = true;
        room    = "other";
        icon    = icons.desktop;
        ip      = hosts.homie.ip;
      };
      "nasty"   = {
        enable  = true;
        room    = "other";
        icon    = icons.desktop;
        ip      = hosts.nasty.ip;
      };

      # 🦆 ⮞ ★ ESP32-S3-WATCH-rs ★ » https://github.com/QuackHack-McBlindy/ESP32-S3-WATCH-rs
      "watch"   = {
        enable  = true;
        room    = "other";
        icon    = icons.watch;
        ip      = "192.168.1.182";
        state.endpoint = "/api/sensors"; # ⮜ 🦆 says ⮞ refresh device states from this endpoint
        state.refresh  = null; # ⮜ 🦆 every x sec (null = only on demand)

        # 🦆 ⮞ create action controls for automations / frontend control
        controls = { # 🦆 ⮞ publish your devices payload @ "zigduck/watch" to show in frontend
          brightness    = { # 🦆 ⮞ if u interact with da "brightness" slider it will publish @ "zigduck/watch/set"
            type        = "slider"; # 🦆 ⮞ which then will run the corresponding defined action
            icon        = icons.brightness;
            min         = 0;
            max         = 100;
            description = "Controls the display backlight brightness level";
            actions     = [{ type = "shell"; command = "curl http://$IP/api/settings/display/brightness/$VALUE"; }];
          };
          battery_percent = {
            description   = "Displays the battery percentage on the watch.";
            type          = "sensor";
            icon          = icons.battery;
          };
          rssi          = {
            description = "Displays the current RSSI on the watch.";
            type        = "sensor";
            icon        = icons.wifi;
          };
          display_state = {
            description = "Toggles the state of the display.";
            type        = "bool";
            icon        = icons.display;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/display/state/toggle"; }];
          };
          display_timeout = {
            description   = "Configure the idle time in seconds before the display turns off.";
            type          = "slider";
            icon          = icons.display;
            min           = 0;
            max           = 300;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/display/timeout/$VALUE"; }];
          };
          mic_volume    = {
            description = "Configure the microphone gain.";
            type        = "slider";
            icon        = icons.microphone;
            min         = 0;
            max         = 100;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/mic/volume/$VALUE"; }];
          };
          mic_muted     = {
            description = "Mute the microphone";
            type        = "bool";
            icon        = icons.mic_off;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/mic/mute/toggle"; }];
          };
          speaker_volume = {
            description  = "Change the watch speaker volume.";
            type         = "slider";
            icon         = icons.volume;
            min          = 0;
            max          = 100;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/speaker/volume/$VALUE"; }];
          };
          speaker_muted = {
            description = "Mute the speaker on the watch";
            type        = "bool";
            icon        = icons.mute;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/speaker/mute/toggle"; }];
          };
          amplifier_state = {
            description   = "Turn the amplifier state on/off.";
            type          = "bool";
            icon          = icons.amplifier;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/speaker/amp/toggle"; }];
          };
          speaker_task_state  = {
            description       = "Turn the speaker task on the watch on/off.";
            type              = "bool";
            icon              = icons.speaker;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/speaker/toggle"; }];
          };
          speaker_allow_streaming = {
            description = "Enabling this allows the watch to playback audio sent over LAN.";
            type        = "bool";
            icon        = icons.cast;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/speaker/stream/toggle"; }];
          };
          play_ding = {
            description = "Play ding sound on the watch.";
            type        = "bool";
            icon        = icons.speaker;
            actions = [{
              type      = "shell";
              command   = ''if [ "$VALUE" = "true" ]; then curl -s "http://$IP/api/settings/speaker/play/ding"; fi'';
            }];
          };
          media_play_pause = {
            description    = "Toggles the media player state on the watch between play/pause.";
            type           = "bool";
            icon           = icons.play_pause;
            actions = [{
              type         = "shell";
              command      = ''if [ "$VALUE" = "true" ]; then curl -s "http://$IP/api/media/play_pause"; fi'';
            }];
          };
          cpu_freq = {
            description = "Change clock frequency on the watch.";
            type        = "slider";
            icon        = icons.cpu;
            values      = [ "80" "160" "240" ];
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/cpu/$VALUE"; }];
          };
          low_power_mode = {
            description  = "Toggles low power mode on/off, turning off basically every task that draws battery.";
            type         = "bool";
            icon         = icons.power_sleep;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/power/low/toggle"; }];
          };
          ssh_state     = {
            description = "Toggle SSHd on/off.";
            type        = "bool";
            icon        = icons.console;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/ssh/toggle"; }];
          };
          vpn_state     = {
            description = "Toggle VPN on/off.";
            type        = "bool";
            icon        = icons.vpn;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/vpn/toggle"; }];
          };
        };
      };

      # 🦆 ⮞ ★ ESP32-S3-BOX-3-rs ★ » https://github.com/QuackHack-McBlindy/ESP32-S3-BOX-3-rs
      "ESP32-S3-BOX-3" = {
        enable = true;
        room   = "other";
        icon   = icons.microphone;
        ip     = "192.168.1.16";
        state.endpoint = "/api/sensors";
        state.refresh  = 60;

        controls = {
          battery_percent = {
            description   = "Displays the battery percentage.";
            type          = "sensor";
            icon          = icons.battery;
          };
          presence      = {
            description = "Presence detection.";
            type        = "sensor";
            icon        = icons.sensor.motion;
          };
          temperature   = {
            description = "Temperature sensor.";
            type        = "sensor";
            icon        = icons.sensor.temperature;
          };
          humidity      = {
            description = "Humidity sensor.";
            type        = "sensor";
            icon        = icons.sensor.humidity;
          };
          uptime        = {
            description = "Time since last boot.";
            type        = "sensor";
            icon        = icons.uptime;
          };
          firmware      = {
            description = "Displays the currently running firmware version om the device.";
            type        = "sensor";
            icon        = icons.battery;
          };
          rssi          = {
            description = "Displays the current RSSI.";
            type        = "sensor";
            icon        = icons.wifi;
          };
          brightness    = {
            description = "Controls the display backlight brightness level";
            type        = "slider";
            icon        = icons.brightness;
            min         = 0;
            max         = 100;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/display/brightness/$VALUE"; }];
          };
          display_state = {
            description = "Toggles the state of the display.";
            type        = "bool";
            icon        = icons.display;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/display/state/toggle"; }];
          };
          display_timeout = {
            description   = "Idle seconds before display turns off.";
            type          = "slider";
            icon          = icons.display;
            min           = 0;
            max           = 300;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/display/timeout/$VALUE"; }];
          };
          display_page  = {
            description = "Change display page.";
            type        = "slider";
            icon        = icons.display_page;
            values      = [ "0" "1" "2" "10" ];
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/display/page/$VALUE"; }];
          };
          mic_volume    = {
            description = "Configure the microphone gain.";
            type        = "slider";
            icon        = icons.microphone;
            min         = 0;
            max         = 100;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/mic/volume/$VALUE"; }];
          };
          mic_muted     = {
            description = "Mute the microphone.";
            type        = "bool";
            icon        = icons.mic_off;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/mic/mute/toggle"; }];
          };
          speaker_volume = {
            description  = "Change the speaker volume.";
            type         = "slider";
            icon         = icons.volume;
            min          = 0;
            max          = 100;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/speaker/volume/$VALUE"; }];
          };
          speaker_muted = {
            description = "Mute the speaker.";
            type        = "bool";
            icon        = icons.mute;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/speaker/mute/toggle"; }];
          };
          amplifier_state = {
            description   = "Turn the amplifier on/off.";
            type          = "bool";
            icon          = icons.amplifier;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/speaker/amp/toggle"; }];
          };
          speaker_task_state = {
            description      = "Turn the speaker task on/off.";
            type             = "bool";
            icon             = icons.speaker;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/speaker/toggle"; }];
          };
          speaker_allow_streaming = {
            description = "Allow playback of audio sent over LAN.";
            type        = "bool";
            icon        = icons.cast;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/speaker/stream/toggle"; }];
          };
          play_ding     = {
            description = "Play test ding sound.";
            type        = "bool";
            icon        = icons.speaker;
            actions = [{
              type      = "shell";
              command   = ''if [ "$VALUE" = "true" ]; then curl -s "http://$IP/api/settings/speaker/play/ding"; fi'';
            }];
          };
          ding          = {
            description = "Play awake sound and light up display.";
            type        = "bool";
            icon        = icons.bell;
            actions = [{ type = "shell"; command = ''if [ "$VALUE" = "true" ]; then curl -s "http://$IP/api/ding"; fi''; }];
          };
          done          = {
            description = "Play done sound and dim display.";
            type        = "bool";
            icon        = icons.check;
            actions = [{ type = "shell"; command = ''if [ "$VALUE" = "true" ]; then curl -s "http://$IP/api/done"; fi''; }];
          };

          media_play_pause = {
            description    = "Toggle media play/pause.";
            type           = "bool";
            icon           = icons.play_pause;
            actions = [{
              type         = "shell";
              command      = ''if [ "$VALUE" = "true" ]; then curl -s "http://$IP/api/media/play_pause"; fi'';
            }];
          };
          media_prev    = {
            description = "Previous track.";
            type        = "bool";
            icon        = icons.skip_prev;
            actions = [{
              type      = "shell";
              command   = ''if [ "$VALUE" = "true" ]; then curl -s "http://$IP/api/media/prev"; fi'';
            }];
          };
          media_next    = {
            description = "Next track.";
            type        = "bool";
            icon        = icons.skip_next;
            actions = [{
              type      = "shell";
              command   = ''if [ "$VALUE" = "true" ]; then curl -s "http://$IP/api/media/next"; fi'';
            }];
          };
          media_heart   = {
            description = "Save current track to favourites.";
            type        = "bool";
            icon        = icons.heart;
            actions = [{
              type      = "shell";
              command   = ''if [ "$VALUE" = "true" ]; then curl -s "http://$IP/api/media/heart"; fi'';
            }];
          };
          media_playlist_clear = {
            description = "Clear the temporary playlist.";
            type        = "bool";
            icon        = icons.playlist_remove;
            actions = [{
              type      = "shell";
              command   = ''if [ "$VALUE" = "true" ]; then curl -s "http://$IP/api/media/playlist/clear"; fi'';
            }];
          };
          voice_state   = {
            description = "Toggle the entire voice pipeline.";
            type        = "bool";
            icon        = icons.voice;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/voice/toggle"; }];
          };
          wake_word_enabled = {
            description  = "Toggle wake-word streaming.";
            type         = "bool";
            icon         = icons.wakeword;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/voice/wakeword/toggle"; }];
          };
          intercom_state = {
            description  = "Toggle intercom mode.";
            type         = "bool";
            icon         = icons.intercom;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/voice/intercom/toggle"; }];
          };
          cpu_freq      = {
            description = "Change clock frequency.";
            type        = "slider";
            icon        = icons.cpu;
            values      = [ "80" "160" "240" ];
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/cpu/$VALUE"; }];
          };
          low_power_mode = {
            description  = "Toggle low power mode.";
            type         = "bool";
            icon         = icons.power_sleep;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/power/low/toggle"; }];
          };
          reboot        = {
            description = "Reboot the device.";
            type        = "bool";
            icon        = icons.power_sleep;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/power/reboot"; }];
          };
          ssh_state     = {
            description = "Toggle SSHd.";
            type        = "bool";
            icon        = icons.console;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/ssh/toggle"; }];
          };
          vpn_state     = {
            description = "Toggle VPN.";
            type        = "bool";
            icon        = icons.vpn;
            actions = [{ type = "shell"; command = "curl http://$IP/api/settings/vpn/toggle"; }];
          };
        };
      };
    };

# 🦆 ⮞ ZIGBEE ⮜ 🐝
    zigbee = {
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
          # 🦆 says ⮞ run the following to get api token:
          # curl -X POST http://192.168.1.33/api -d '{"devicetype":"house#nixos"}'
          ip           = "192.168.1.33";
          passwordFile = config.sops.secrets.hueBridgeAPI.path;
        };
        syncBox = { # C42996020AAE
          # 🦆 says ⮞ run the following to get api token for the sync box:
          # curl -k -sS -X POST "https://192.168.1.34/api/v1/registrations" -H "Content-Type: application/json" -d '{"appName": "zigduck", "instanceName": "zigduck"}'
          ip           = "192.168.1.34";
          passwordFile = config.sops.secrets.hueSyncAPI.path;
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
      dimmer = {
        message            = "action";
        doubleClickTimeout = 500;
      };

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
      automations = {
      # 🦆 says ⮞ there are 6 different automation types
        # 🦆 says ⮞ + a greeting automation
        greeting  = {
          enable       = true;
          awayDuration = 7200;
          door         = "Door Sensor Hall";
          delay        = 10;
          actions = [ { type = "shell"; command = "zigduck-cli --notify '🚪 Welcome back!'"; } ];
        };


        # 🦆 says ⮞ 1. MQTT triggered automations
        mqtt_triggered  = {

          flash_lights  = {
            enable      = true;
            description = "Flash lights";
            topic       = "${zigduck.baseTopic}/effects/flash";
            actions  = [
              { type = "snapshot"; snapshot_name = "before_timer"; }
              { type = "scene"; scene = "max"; }
              { type = "wait"; duration = 2; }
              { type = "scene"; scene = "dark-fast"; }
              { type = "wait"; duration = 2; }
              { type = "scene"; scene = "max"; }
              { type = "wait"; duration = 2; }
              { type = "scene"; scene = "dark-fast"; }
              { type = "wait"; duration = 2; }
              { type = "scene"; scene = "max"; }
              { type = "wait"; duration = 2; }
              { type = "restore"; snapshot_name = "before_timer"; }
            ];
          };

          alarm_wakeup  = {
            enable      = true;
            description = "Time to wake up!";
            topic       = "${zigduck.baseTopic}/alarm/triggered";
            actions  = [ # 🦆 say ⮞ START WITH A NOTIFY
              { type = "shell"; command = "zigduck-cli --notify '⏰ ALARM: Wake up!'"; }
              # 🦆 SCREAMS ⮞ FLASH LIGHTS!
              { type = "mqtt"; topic = "${zigduck.baseTopic}/effects/flash"; message = " "; }
              # 🦆 says ⮞ TTS time to wake up
              { type = "shell"; command = "yo say 'wakieee wakiee dags att vaknaaaaaaa'"; }
              # 🦆 says ⮞ fuck up bed (neck up + feet up)
              { type = "mqtt"; topic = "${zigduck.baseTopic}/Robot Arm 3/set"; message = ''{"state":"OFF"}''; }
              { type = "mqtt"; topic = "${zigduck.baseTopic}/Robot Arm 4/set"; message = ''{"state":"OFF"}''; }
              { type = "wait"; duration = 10; }
              # 🦆 says ⮞ FLASH!
              { type = "mqtt"; topic = "${zigduck.baseTopic}/effects/flash"; message = " "; }
              # 🦆 ⮞ play sound on bedroom esp32 assistant
              { type = "shell"; command = "curl http://${devices.ESP32-S3-BOX-3.ip}/api/settings/speaker/play/ding"; }
              { type = "wait"; duration = 2; }
              # 🦆 says ⮞ ping watch with a ding
              { type = "shell"; command = "curl http://${devices.watch.ip}/api/settings/speaker/play/ding"; }
              # 🦆 says ⮞ gib me a sec pls...
              { type = "wait"; duration = 10; }
              # 🦆 says ⮞ roll up da blindz let da sun come in
              { type = "mqtt"; topic = "${zigduck.baseTopic}/Roller Shade/set"; message = ''{"state":"ON"}''; }
              # 🦆 says ⮞ check if im up yet....
              { type = "shell"; command = ''
                motion=$(jq -r '."Motion Sensor Sovrum".occupancy' ${zigduck.stateDir}/state.json)
                # 🦆 says ⮞  if my lazy ass is still in bed, try calling the TV remote!
                if [[ "$motion" == "false" ]]; then
                  tv --typ call
                fi
              ''; }
            ];
          };

          timer_finish  = {
            enable      = true;
            description = "a timer is ringing";
            topic       = "${zigduck.baseTopic}/timer/finished";
            actions  = [ # 🦆 says ⮞ notify
              { type = "shell"; command = "zigduck-cli --notify '⏰ TIMER finish!'"; }
              # 🦆 says ⮞ FLASH!
              { type = "mqtt"; topic = "${zigduck.baseTopic}/effects/flash"; message = " "; }
              # 🦆 says ⮞ ping watch with ding
              { type = "shell"; command = "curl http://${devices.watch.ip}/api/settings/speaker/play/ding"; }
              { type = "wait"; duration = 7; }
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
              { type    = "shell";
                command = ''
                  iso_date=$(echo "$MQTT_PAYLOAD" | jq -r '.today_date')
                  formatted_date=$(date -d "$iso_date" +"%b %d")
                  MQTT_PAYLOAD=$(echo "$MQTT_PAYLOAD" | jq --arg d "$formatted_date" '.today_date = $d')
                  echo "$MQTT_PAYLOAD" > ${zigduck.stateDir}/calendar.json
                '';
              }
            ];
          };
        };

        # 🦆 says ⮞ 2. room action automations
        room_actions = {
          hallway = {
            door_opened = [ # 🦆 says ⮞ ping watch & send notification
              { type = "shell"; command = "zigduck-cli --notify '🚪 DOOR OPEN!'"; }
              { type = "shell"; command = "curl http://${devices.watch.ip}/api/settings/speaker/play/ding"; }
            ];
            door_closed = [];
          };

          kitchen = {
            motion_not_detected = [
              {
                type = "shell";
                command = ''
                  power=$(jq -r '."Fläkt".power' ${zigduck.stateDir}/state.json)
                  # 🦆 says ⮞ no need 2 turn off if it'z not on
                  if (( power > 20 )); then
                    zigduck-cli --publish --topic "${zigduck.baseTopic}/Fläkt/set" --payload '{"countdown": 180}'
                  fi
                '';
              } # 🦆 says ⮞  slow go light go bye bye
              { type = "scene"; scene = "kitchenFadeOff"; }
            ];

            motion_detected = [
              { type = "scene"; scene = "kitchenInstant"; }
              { type = "shell";
                command = ''
                  # 🦆 says ⮞ cancel any pending countdown
                  zigduck-cli --publish --topic "${zigduck.baseTopic}/Fläkt/set" --payload '{"countdown": 0}'

                  # 🦆 says ⮞ if fan is off - start it
                  STATE=$(jq -r '."Fläkt".state' ${zigduck.stateDir}/state.json)
                  if [ "$STATE" = "OFF" ]; then
                    zigduck-cli --device "Fläkt" --state on
                  fi

                  # 🦆 says ⮞ if my team is playing NOW - go green!!
                  if jq -e '
                       def epoch: (strptime("%Y%m%d%H%M%S +0000") | mktime);
                       now as $now
                       | any(.channels[].programs[];
                           ((.start | epoch) <= $now)
                           and ((.stop  | epoch) >  $now)
                           and (.title | ascii_downcase | contains("björklöven")))
                     ' "${zigduck.stateDir}/epg.json" > /dev/null 2>&1; then
                    zigduck-cli --scene "kitchenGreenInstant"
                  fi
                '';
              }
            ];
          };
        };

        # 🦆 says ⮞ 3. global actions automations
        global_actions  = {
          leak_detected = [ # 🦆 QUICK ⮞ FLASH FOR DA NOTICE
            { type = "mqtt"; topic = "${zigduck.baseTopic}/effects/flash"; message = " "; }
            # 🦆 LIGHT⮞FAST⮞HELP⮞SEE⮞THEN⮞NOTIFY
            { type = "scene"; scene = "max"; }
            { type = "shell"; command = "zigduck-cli --notify '💧 🚨 WATER LEAK DETECTED!'"; }
            # 🦆 says ⮞ ping watch with ding
            { type = "shell"; command = "curl http://${devices.watch.ip}/api/settings/speaker/play/ding"; }
            # 🦆SAY⮞CALM⮞DOWN⮞itz⮞juzt⮞water
            { type = "shell"; command = "yo say 'eld eld eld'"; }
          ];

          smoke_detected = [ # 🦆 QUICK ⮞ FLASH FOR DA NOTICE
            { type = "mqtt"; topic = "${zigduck.baseTopic}/effects/flash"; message = " "; }
            # 🦆 LIGHT⮞FAST⮞HELP⮞SEE
            { type = "scene"; scene = "max"; }
            { type = "shell"; command = "zigduck-cli --notify '🔥 FIRE/SMOKE DETECTED!' --tag critical"; }
            # 🦆 says ⮞ ping watch with ding
            { type = "shell"; command = "curl http://${devices.watch.ip}/api/settings/speaker/play/ding"; }
            # 🦆SAY⮞FIRE
            { type = "shell"; command = "yo say 'eld eld eld'"; }
          ];
        };

        # 🦆 says ⮞ 4. dimmer actions automations
        dimmer_actions = {
          bedroom      = {
            off_hold_release   = {
              enable           = true;
              description      = "Turn off all configured light devices";
              extra_actions    = [];
              override_actions = [
                { type = "scene"; scene = "dark"; }
                { type = "mqtt"; topic = "${zigduck.baseTopic}/Fläkt/set"; message = ''{"state":"OFF"}''; }
              ];
            };
          };

          kitchen = {
            on_press_release = {
              enable         = true;
              description    = "Turn on kitchen fan (+ lights)";
              extra_actions  = [
                {
                  type       = "mqtt";
                  topic      = "${zigduck.baseTopic}/Fläkt/set";
                  message    = ''{"state":"ON"}'';
                }
              ];
              override_actions = [ ];
            };
          };
        };

        # 🦆 says ⮞ 5. time based automations
        time_based = {
          morning_wakeup = {
            enable       = true;
            description  = "set morning wakeup alarm (dont miss lunch)";
            # 🦆 says ⮞ 01 AM mon-fri
            schedule     = {
              start      = "01:00";
              days       = ["mon" "tue" "wed" "thu" "fri"];
            };
            # 🦆 says ⮞ 11 AM (i like to sleep in)
            actions      = [ "zigduck-cli alarm add --hours 10 --minutes 45 --name vakna" ];
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
            actions  = [ "tv-scraper --json-out ${zigduck.stateDir}/epg.json --html-out ${zigduck.stateDir}/tv.html --xml-out ${zigduck.stateDir}/epg.xml" ];
          };
        };

        # 🦆 says ⮞ 6. presence based automations
        presence_based = {};
      };


# 🦆 ⮞ DEVICES ⮜
      devices = {
        # 🦆 says ⮞ Kitchen
        "0x0017880103ca6e95" = { # 🦆 says ⮞ 64bit IEEE adress (this is the unique device ID)
          friendly_name      = "Dimmer Switch Kök"; # 🦆 says ⮞ simple human readable friendly name
          room               = "kitchen"; # 🦆 says ⮞ bind to group
          type               = "dimmer"; # 🦆 says ⮞ set a custom device type
          icon               = icons.dimmer;
          endpoint           = 1; # 🦆 says ⮞ endpoint to call the device on
          batteryType        = "CR2450"; # 🦆 says ⮞ optional yo
        };
        "0x0017880102f0848a" = {
          friendly_name      = "Spotlight kök 1";
          room               = "kitchen";
          type               = "light";
          icon               = icons.light.spotlight;
          endpoint           = 11;
        };
        "0x0017880102f08526" = { friendly_name = "Spotlight Kök 2"; room = "kitchen"; type = "light"; icon = icons.light.spotlight; endpoint = 11; };
        "0x0017880103a0d280" = { friendly_name = "Uppe"; room = "kitchen"; type = "light"; icon = icons.light.strip_rgb; endpoint = 11; supports_color = true; };
        "0x0017880103e0add1" = { friendly_name = "Golvet"; room = "kitchen"; type = "light"; icon = icons.light.strip_rgb; endpoint = 11; supports_color = true; };
        "0xa4c13873044cb7ea" = { friendly_name = "Kök Bänk Slinga"; room = "kitchen"; type = "light"; icon = icons.light.strip_rgb; endpoint = 11; };
        "0x70ac08fffe9fa3d1" = { friendly_name = "Motion Sensor Kök"; room = "kitchen"; type = "motion"; icon = icons.sensor.motion; endpoint = 1; batteryType = "CR2032"; };
        "0xa4c1380afa9f7f3e" = { friendly_name = "Smoke Alarm Kitchen"; room = "kitchen"; type = "sensor"; icon = icons.sensor.smoke; endpoint = 1; };
        "0xa4c138b9aab1cf3f" = { friendly_name = "Fläkt"; room = "kitchen"; type = "outlet"; icon = icons.outlet; endpoint = 1; };

        # 🦆 says ⮞ LIVING ROOM
        "0x0c4314fffe179b05" = { friendly_name = "Larm"; room = "livingroom"; type = "outlet"; icon = icons.outlet; endpoint = 1; };
        "0x0017880104f78065" = { friendly_name = "Dimmer Switch Vardagsrum"; room = "livingroom"; type = "dimmer"; icon = icons.dimmer; endpoint = 1; batteryType = "CR2450"; };
        "0x00178801037e754e" = { friendly_name = "Takkrona 1"; room = "livingroom"; type = "light"; icon = icons.light.chandelier; endpoint = 1; supports_color = true; supports_temperature = false; };
        "0x0017880103c73f85" = { friendly_name = "Takkrona 2"; room = "livingroom"; type = "light"; icon = icons.light.chandelier; endpoint = 1; supports_color = true; supports_temperature = false; };
        "0x0017880103f94041" = { friendly_name = "Takkrona 3"; room = "livingroom"; type = "light"; icon = icons.light.chandelier; endpoint = 1; supports_color = true; supports_temperature = false; };
        "0x0017880103c753b8" = { friendly_name = "Takkrona 4"; room = "livingroom"; type = "light"; icon = icons.light.chandelier; endpoint = 1; supports_color = true; supports_temperature = false; };
        "0x54ef4410003e58e2" = { friendly_name = "Roller Shade"; room = "livingroom"; type = "blind"; icon = icons.blinds; endpoint = 1; };
        "0x0017880104540411" = { friendly_name = "PC"; room = "livingroom"; type = "light"; icon = icons.light.spotlight; endpoint = 11; supports_color = true; };
        "0x0017880102de8570" = { friendly_name = "Rustning"; room = "livingroom"; type = "light"; icon = icons.light.spotlight; endpoint = 11; supports_color = true; };
        "0x540f57fffe85c9c3" = { friendly_name = "Water Sensor"; room = "livingroom"; type = "sensor"; icon = icons.sensor.water; endpoint = 1; };

        # 🦆 says ⮞ HALLWAY
        "0x00178801021311c4" = { friendly_name = "Motion Sensor Hall"; room = "hallway"; type = "motion"; icon = icons.sensor.motion; endpoint = 1; batteryType = "AAA"; };#⮜ AAA-AWESOME 🦆
        "0x00158d00053ec9b1" = { friendly_name = "Door Sensor Hall"; room = "hallway"; type = "sensor"; icon = icons.sensor.contact; endpoint = 1; };
        "0x0017880109ac14f3" = { friendly_name = "Tak Hall"; room = "hallway"; type = "light"; icon = icons.light.ceiling; endpoint = 11; supports_color = true; };
        "0x000b57fffe0e2a04" = { friendly_name = "Vägg"; room = "hallway"; type = "light"; icon = icons.light.wall; supports_temperature = true; supports_color = false; endpoint = 1; };

        # 🦆 says ⮞ WC
        "0x001788010361b842" = { friendly_name = "WC 1"; room = "wc"; type = "light"; icon = icons.light.ceiling; supports_temperature = true; endpoint = 11; };
        "0x0017880103406f41" = { friendly_name = "WC 2"; room = "wc"; type = "light"; icon = icons.light.ceiling; supports_temperature = true; endpoint = 11; };

        # 🦆 says ⮞ BEDROOM
        "0xa4c13832742c96f7" = { friendly_name = "Robot Arm 1"; room = "bedroom"; type = "pusher"; endpoint = 11; icon = icons.pusher; batteryType = "CR02"; };
        "0xa4c138387966b58d" = { friendly_name = "Robot Arm 2"; room = "bedroom"; type = "pusher"; endpoint = 11; icon = icons.pusher; batteryType = "CR02"; };
        "0xa4c1380c0a35052e" = { friendly_name = "Robot Arm 3"; room = "bedroom"; type = "pusher"; endpoint = 11; icon = icons.pusher; batteryType = "CR02"; };
        "0xa4c1381e74b6d2e6" = { friendly_name = "Robot Arm 4"; room = "bedroom"; type = "pusher"; endpoint = 11; icon = icons.pusher; batteryType = "CR02"; };
        "0x0017880104f77d61" = { friendly_name = "Dimmer Switch Sovrum"; room = "bedroom"; type = "dimmer"; icon = icons.dimmer; endpoint = 1; batteryType = "CR2450"; };
        "0x0017880106156cb0" = { friendly_name = "Taket Sovrum 1"; room = "bedroom"; type = "light"; icon = icons.light.ceiling; endpoint = 11; supports_color = true; };
        "0x0017880103c7467d" = { friendly_name = "Taket Sovrum 2"; room = "bedroom"; type = "light"; icon = icons.light.ceiling; endpoint = 11; supports_color = true; };
        "0x0017880104051a86" = { friendly_name = "Sänggavel"; room = "bedroom"; type = "light"; icon = icons.light.strip_rgb; endpoint = 11; supports_color = true; };
        "0xf4b3b1fffeaccb27" = { friendly_name = "Motion Sensor Sovrum"; room = "bedroom"; type = "motion"; icon = icons.sensor.motion; endpoint = 1; batteryType = "CR2032"; };
        "0x0017880103f44b5f" = { friendly_name = "Dörr"; room = "bedroom"; type = "light"; icon = icons.light.strip_rgb; endpoint = 11; supports_color = true; };
        "0x00178801001ecdaa" = { friendly_name = "Bloom"; room = "bedroom"; type = "light"; icon = icons.light.desk; endpoint = 11; supports_color = true; };

        # 🦆 says ⮞ MISCELLANEOUS
        "0xa4c1382543627626" = { friendly_name = "Power Plug"; room = "other"; type = "outlet"; icon = icons.outlet; endpoint = 1; };
        "0x000b57fffe0f0807" = { friendly_name = "IKEA 5 Dimmer"; room = "other"; type = "remote"; icon = icons.remote; endpoint = 1; };
        "0x70ac08fffe6497be" = { friendly_name = "On/Off Switch 1"; room = "other"; type = "remote"; icon = icons.remote; endpoint = 1; batteryType = "CR2032"; };
        "0x70ac08fffe65211e" = { friendly_name = "On/Off Switch 2"; room = "other"; type = "remote"; icon = icons.remote; endpoint = 1; batteryType = "CR2032"; };

        # 🦆 says ⮞ TV-AREA (entertainment area)
        "00178801095f06300b" = { friendly_name = "TV Play Strip"; room = "tv-area"; type = "hue_light"; icon = icons.light.strip_rgb; endpoint = 1; supports_color = true; hue_id = 38; };
        "0017880106ff30720b" = { friendly_name = "TV Play 1"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 40; };
        "0017880109f06a700b" = { friendly_name = "TV Play 2"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 41; };
        "0017880109f06a7c0b" = { friendly_name = "TV Play 3"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 37; };
        "0017880106ff22530b" = { friendly_name = "TV Play 4"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 39; };
        "001788010985d1820b" = { friendly_name = "Play Top L"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 61; };
        "00178801098d5b320b" = { friendly_name = "Play Top R"; room = "tv-area"; type = "hue_light"; icon = icons.light.ambient; endpoint = 1; supports_color = true; hue_id = 60; };
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
        ip        = "192.168.1.224";
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
