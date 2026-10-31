# dotfiles/modules/devices.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  config,
  lib,
  zigduck,
  hosts,
  icons,
  pkgs,
  ...
} : let


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

      "iphone" = {
        enable  = false;
        room    = "other";
        icon    = icons.intercom;
        ip      = "192.168.1.13";
      };
      "hue-bridge" = {
        enable  = false;
        room    = "other";
        icon    = icons.intercom;
        ip      = "192.168.1.33";
      };
      "hue-sync" = {
        enable  = false;
        room    = "other";
        icon    = icons.intercom;
        ip      = "192.168.1.34";
      };
      "shield" = {
        enable  = false;
        room    = "other";
        icon    = icons.intercom;
        ip      = "192.168.1.224";
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


    zigbee = {
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
        "0xa4c138b9aab1cf3f" = { friendly_name = "Fläkt"; aliases = [ "fläkten" "fläckten" ]; room = "kitchen"; type = "outlet"; icon = icons.outlet; endpoint = 1; };

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
        "0x00158d00053ec9b1" = { friendly_name = "Door Sensor Hall"; aliases = [ "dörr" "dörren" "ytterdörren" ]; room = "hallway"; type = "sensor"; icon = icons.sensor.contact; endpoint = 1; };
        "0x0017880109ac14f3" = { friendly_name = "Tak Hall"; room = "hallway"; type = "light"; icon = icons.light.ceiling; endpoint = 11; supports_color = true; };
        "0x000b57fffe0e2a04" = { friendly_name = "Vägg"; aliases = [ "väggen" ]; room = "hallway"; type = "light"; icon = icons.light.wall; supports_temperature = true; supports_color = false; endpoint = 1; };

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



in {
  devices = devices;
  zigbee  = zigbee;
}
