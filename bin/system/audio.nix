# dotfiles/bin/system/audio.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ time based volume adjuster
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let

in {
  yo.scripts = { 
    audio = {
      description = "Time based volume control";
      category = "🖥️ System Management";
      runEvery = lib.mkIf (config.this.host.hostname == "desktop") "05";
      parameters = [
        { name = "auto"; type = "bool"; description = "Auto adjust volume based on time"; optional = true; }     
        { name = "up"; type = "bool"; description = "Increase volume with 10%"; optional = true; }
        { name = "down"; type = "bool"; description = "Decrease volume with 10%"; optional = true; }
        { name = "mute"; type = "bool"; description = "Toggle mute"; optional = true; }
        { name = "get"; type = "bool"; description = "Print current volume"; optional = true; }
      ];
      code = ''   
        ${cmdHelpers}
        sink="@DEFAULT_AUDIO_SINK@"

        get() {
          wpctl get-volume "$sink" | awk '{print $2}'
        }

        up() {
          wpctl set-volume "$sink" 10%+
        }

        down() {
          wpctl set-volume "$sink" 10%-
        }

        mute() {
          wpctl set-mute "$sink" toggle
        }

        auto() {
          hour=$(date +%H)
          # 🦆 00–07 → 20% 🔉
          # ⏰ 08–17 → 50% 🔊
          # ⏰ 18–21 → 35% 🔊
          # ⏰ 22–23 → 25% 🔉
          if [ "$hour" -ge 0 ] && [ "$hour" -lt 8 ]; then
            wpctl set-volume "$sink" 0.20
          elif [ "$hour" -lt 18 ]; then
            wpctl set-volume "$sink" 0.50
          elif [ "$hour" -lt 22 ]; then
            wpctl set-volume "$sink" 0.35
          else
            wpctl set-volume "$sink" 0.25
          fi
        }

        if [ "$auto" = "true" ]; then
          auto
        elif [ "$get" = "true" ]; then
          get
        elif [ "$up" = "true" ]; then
          up
        elif [ "$down" = "true" ]; then
          down
        elif [ "$mute" = "true" ]; then
          mute
        else
          echo "No valid option given. Use --help for usage." >&2
          exit 1
        fi

        exit 0
      '';
    };
    
  };}
