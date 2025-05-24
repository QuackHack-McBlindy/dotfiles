# dotfiles/bin/<CATEGORY>/<SCRIPT>.nix
{ 
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
} : let

in {
  yo.scripts.mic = {
      description = "Manually trigger microphone recording for intent execution.";
#      keywords = [ ];
      category = "⚙️ Configuration";
#      category = "🌍 Localization";
#      aliases = [ "" ];
      code = ''
        ${cmdHelpers}
        CONFIG="${config.this.user.me.dotfilesDir}/home/.config/yo-bitch/config.yaml"

        SAMPLE_RATE=$(yq '.whisper.sample_rate' "$CONFIG")
        FORMAT=$(yq '.wyoming_satellite.mic_command' "$CONFIG" | grep -oP '(?<=-f )\S+')
        CHANNELS=$(yq '.wyoming_satellite.mic_command' "$CONFIG" | grep -oP '(?<=-c )\S+')
        HOST=$(yq -r '.api.host' "$CONFIG")
        PORT=$(yq '.api.port' "$CONFIG")

        AUDIO_FILE=$(mktemp --suffix=.raw)
        trap "rm -f $AUDIO_FILE" EXIT
        echo "Sending to: http://$HOST:$PORT/transcribe "
        arecord -f "$FORMAT" -r "$SAMPLE_RATE" -c "$CHANNELS" -d 5 -t raw "$AUDIO_FILE" && curl -X POST http://$HOST:$PORT/transcribe -F "audio=@$AUDIO_FILE;type=audio/raw"
      '';    
  };}
  
