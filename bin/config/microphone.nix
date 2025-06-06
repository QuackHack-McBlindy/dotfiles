# dotfiles/bin/config/microphone.nix
{ 
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
} : let
  autocorrect = {
    "ika" = "ica";
    "ikka" = "ica";
    "vågen" = "bågen";
    "båden" = "bågen";
  };
in {
  yo.scripts.mic = {
      description = "Manually trigger microphone recording for intent execution.";
      category = "⚙️ Configuration";
      code = ''
        ${cmdHelpers}
        RED='\033[1;5;31m'
        NC='\033[0m'
        CONFIG="${config.this.user.me.dotfilesDir}/home/.config/yo-bitch/config.yaml"

        SAMPLE_RATE=$(yq '.whisper.sample_rate' "$CONFIG")
        FORMAT=$(yq '.wyoming_satellite.mic_command' "$CONFIG" | grep -oP '(?<=-f )\S+')
        CHANNELS=$(yq '.wyoming_satellite.mic_command' "$CONFIG" | grep -oP '(?<=-c )\S+')
        HOST=$(yq -r '.api.host' "$CONFIG")
        PORT=$(yq '.api.port' "$CONFIG")

        AUDIO_FILE=$(mktemp --suffix=.raw)
        trap "rm -f $AUDIO_FILE" EXIT
        echo -e "''${RED}🎙️  [RECORDING]''${NC}"

        TRANSCRIPTION_JSON=$(arecord -f "$FORMAT" -r "$SAMPLE_RATE" -c "$CHANNELS" -d 5 -t raw "$AUDIO_FILE" > /dev/null 2>&1 && curl -s -X POST http://$HOST:$PORT/transcribe -F "audio=@$AUDIO_FILE;type=audio/raw")

        declare -A autocorrect=(
          ${lib.concatStringsSep "\n      " (lib.mapAttrsToList (k: v: ''["${k}"]="${v}"'') autocorrect)}
        )

        ORIGINAL=$(echo "$TRANSCRIPTION_JSON" | jq -r '.transcription')

        CORRECTED="$ORIGINAL"
        for wrong in "''${!autocorrect[@]}"; do
          corrected="''${autocorrect[$wrong]}"
          CORRECTED=$(echo "$CORRECTED" | sed -E "s/\b$wrong\b/$corrected/g")
        done

        FINAL_JSON=$(echo "$TRANSCRIPTION_JSON" | jq --arg corrected "$CORRECTED" '.transcription = $corrected')

        echo "$FINAL_JSON"
      '';    
  };}
  
