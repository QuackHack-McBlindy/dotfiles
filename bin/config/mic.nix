# dotfiles/bin/config/microphone.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Records audio from microphone input and sends to yo transcription.
  config, 
  lib,
  self,
  pkgs,       # 🦆 says ⮞ create a noise profile
  cmdHelpers, # 1. arecord -d 5 -f S16_LE -r 16000 -c 1 noise.wav
  ...         # 2. sox noise.wav -n noiseprof noise.prof
} : let 
  # 🦆 says ⮞ auto correct list yo 
  autocorrect = import ./../autoCorrect.nix;
  
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  transcriptionHost = lib.findFirst
    (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.yo.scripts.transcribe.autoStart or false
    ) null sysHosts;
  transcriptionHostIP = if transcriptionHost != null then
    self.nixosConfigurations.${transcriptionHost}.config.this.host.ip
  else
    "0.0.0.0";
in { # 🦆 says ⮞ here goez da yo script - yo!
  yo.scripts.mic = {
      description = "Trigger microphone recording sent to transcription.";
      category = "⚙️ Configuration";
      logLevel = "CRITICAL";
      parameters = [ # 🦆 says ⮞ some paramz to know where to pass audio
        { name = "port"; description = "Port to send audio to transcription on"; default = "25451"; } # 🦆 says ⮞ diz meanz "duck" in ASCII encoded truncated 32 bit 
        { name = "host"; description = "Host ip that has transcription"; default = transcriptionHostIP; }
        { name = "seconds"; description = "How many seconds to record before sending for transcription"; default = "5"; }
      ];  
      code = ''
        ${cmdHelpers}
        SAMPLE_RATE="16000"
        FORMAT="S16_LE"
        CHANNELS="1"
        HOST="$host"
        PORT="$port"
        SECONDS_RECORDING="$seconds"
        AUDIO_FILE="$(${pkgs.coreutils}/bin/mktemp --suffix=.raw)"
        dt_info "🎙️ [RECORDING]"
        ${pkgs.alsa-utils}/bin/arecord -f "$FORMAT" -r "$SAMPLE_RATE" -c "$CHANNELS" -d "$SECONDS_RECORDING" -t raw "$AUDIO_FILE" > /dev/null 2>&1
        trap "rm -f $AUDIO_FILE" EXIT

        # 🦆 says ⮞ measure loudness in dB
        DB_LEVEL="$(${pkgs.sox}/bin/sox "$NORMALIZED_FILE" -n stat 2>&1 | ${pkgs.gawk}/bin/awk '/RMS.*dB/ {print $4}')"
        LOG_FILE="/home/pungkula/mic.log"
        touch $LOG_FILE

        # 🦆 says ⮞ check if over X dB, then do Y
        THRESHOLD_DB="-10"
        if (( $(echo "$DB_LEVEL > $THRESHOLD_DB" | ${pkgs.bc}/bin/bc -l) )); then
          echo "[LOUDNESS: ''${DB_LEVEL} dB > $THRESHOLD_DB]" >> "$LOG_FILE"
          # ${pkgs.sox}/bin/sox "$NORMALIZED_FILE" "$NORMALIZED_FILE" gain -3
        else
          echo "[LOUDNESS: ''${DB_LEVEL} dB ≤ $THRESHOLD_DB] Proceeding normally" >> "$LOG_FILE"
        fi

        # 🦆 says ⮞ auto-adjust microphone volume
        WAV_FILE="$(${pkgs.coreutils}/bin/mktemp --suffix=.wav)"
        ${pkgs.sox}/bin/sox -t raw -r "$SAMPLE_RATE" -e signed -b 16 -c "$CHANNELS" "$AUDIO_FILE" "$WAV_FILE" 2>/dev/null

        NORMALIZED_FILE="$(${pkgs.coreutils}/bin/mktemp --suffix=.wav)"
        ${pkgs.sox}/bin/sox "$WAV_FILE" "$NORMALIZED_FILE" gain -n 2>/dev/null

        if [ -f "/home/pungkula/noise.prof" ]; then
          CLEANED_FILE="$(${pkgs.coreutils}/bin/mktemp --suffix=.wav)"
          ${pkgs.sox}/bin/sox "$NORMALIZED_FILE" "$CLEANED_FILE" noisered "/home/pungkula/noise.prof" 0.21
        else
          CLEANED_FILE="$NORMALIZED_FILE"
        fi

        TRIMMED_FILE="$(${pkgs.coreutils}/bin/mktemp --suffix=.wav)"
        ${pkgs.sox}/bin/sox "$CLEANED_FILE" "$TRIMMED_FILE" silence 1 0.1 1% 1 1.0 1% 2>/dev/null
        AUDIO_TO_SEND="$TRIMMED_FILE"

        # 🦆 says ⮞ send da audio to da param host ip
        TRANSCRIPTION_JSON="$(${pkgs.curl}/bin/curl -k -sS -X POST "https://''${HOST}:''${PORT}/transcribe" \
          -H "accept: application/json" \
          -H "Content-Type: multipart/form-data" \
          -F "audio=@''${AUDIO_TO_SEND};type=audio/wav" \
          -F "reduce_noise=true")"
#          -F "beam_size=$beamSize")"

        ORIGINAL="$(${pkgs.jq}/bin/jq -r '.transcription' <<< "$TRANSCRIPTION_JSON")"

        declare -A autocorrect=(
          ${lib.concatStringsSep "\n      " (lib.mapAttrsToList (k: v: ''["${k}"]="${v}"'') autocorrect)}
        )

        # 🦆 says ⮞ autocorrect substitutionz yo
        CORRECTED="$ORIGINAL"
        for wrong in "''${!autocorrect[@]}"; do
          corrected="''${autocorrect[$wrong]}"
          if echo "$CORRECTED" | grep -i -q "\\b$wrong\\b"; then 
            dt_debug "Autocorrected '$wrong' => '$corrected'"
          fi
          CORRECTED="$(${pkgs.gnused}/bin/sed -E "s/\\b$wrong\\b/$corrected/gI" <<< "$CORRECTED")"
        done
        # 🦆 says ⮞ removes duplicate words caused by auto bad correction logic 
        CLEANED="$(${pkgs.coreutils}/bin/echo "$CORRECTED" | ${pkgs.gnused}/bin/sed -E 's/\b([[:alnum:]]+)( \1\b)+/\1/Ig')"

        # 🦆 says ⮞ reconstruct da transcription into back into full json plz? ok np yo
        FINAL_JSON="$(${pkgs.jq}/bin/jq --arg corrected "$CLEANED" '.transcription = $corrected' <<< "$TRANSCRIPTION_JSON")"
        
        # 🦆 says ⮞ clean it up, trim it down and turn it upside down yo
        TEXT=$("${pkgs.jq}/bin/jq" -r .transcription <<< "$FINAL_JSON")
        CLEANED_TEXT=$(${pkgs.coreutils}/bin/echo "$TEXT" | ${pkgs.gnused}/bin/sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | tr -s ' ' | tr -d '.,!?' | tr '[:upper:]' '[:lower:]')
        # 🦆 says ⮞ aaaand... deliver! .. yo!
        ${pkgs.coreutils}/bin/echo "$CLEANED_TEXT"
      '';    
  };} # 🦆 says ⮞ QuackHack-McBLindy - out yo!  
