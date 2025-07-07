# dotfiles/bin/config/microphone.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Records audio from microphone input and sends to yo transcription.
  config, # 🦆 says ⮞ Before returning transcription - auto correction against declaratively defined words are performed.
  lib,
  pkgs,
  cmdHelpers,
  ...
} : let 
  # 🦆 says ⮞ auto correct list yo 
  autocorrect = {
#🦆🦆⮟becomes⮟🦆🦆  yo!  
    "ika" = "ica";
    "ikka" = "ica";
    "vågen" = "bågen";
    "båden" = "bågen";
    "ante" = "anka";
    "anke" = "anka";
    "läck" = "släck";
    "arkisten" = "artisten";
    "björk leva" = "björklöven";
    "björk löfven" = "björklöven";
    "pjärkleven" = "björklöven";
    "fala upp" = "spela upp";
    "fälla upp" = "spela upp";
    "vi tar upp serien" = "spela upp serien";
  };
in { # 🦆 says ⮞ here goez da yo script - yo!
  yo.scripts.mic = {
      description = "Trigger microphone recording sent to transcription.";
      category = "⚙️ Configuration";
      logLevel = "CRITICAL";
      parameters = [ # 🦆 says ⮞ some paramz to know where to pass audio
        { name = "port"; description = "Port to send audio to transcription on"; default = "25451"; } # 🦆 says ⮞ diz meanz "duck" in ASCII encoded truncated 32 bit 
        { name = "host"; description = "Host ip that has transcription"; default = "0.0.0.0"; } # 🦆 says ⮞ set default values to avoid manual param wen executin'
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
        trap "rm -f $AUDIO_FILE" EXIT
        dt_info "🎙️ [RECORDING]"
        
        # 🦆 says ⮞ start recoin' yo!
        ${pkgs.alsa-utils}/bin/arecord -f "$FORMAT" -r "$SAMPLE_RATE" -c "$CHANNELS" -d "$SECONDS_RECORDING" -t raw "$AUDIO_FILE" > /dev/null 2>&1
        
        # 🦆 says ⮞ send da audio to da param host ip
        TRANSCRIPTION_JSON="$(${pkgs.curl}/bin/curl -k -sS -X POST "https://''${HOST}:''${PORT}/transcribe" \
          -H "accept: application/json" \
          -H "Content-Type: multipart/form-data" \
          -F "audio=@''${AUDIO_FILE};type=audio/vnd.wave")"

        ORIGINAL="$(${pkgs.jq}/bin/jq -r '.transcription' <<< "$TRANSCRIPTION_JSON")"

        declare -A autocorrect=(
          ${lib.concatStringsSep "\n      " (lib.mapAttrsToList (k: v: ''["${k}"]="${v}"'') autocorrect)}
        )

        # 🦆 says ⮞ autocorrect substitutionz yo
        ''${autocorrectBash}
        CORRECTED="$ORIGINAL"
        for wrong in "''${!autocorrect[@]}"; do
          corrected="''${autocorrect[$wrong]}"
          CORRECTED="$(${pkgs.gnused}/bin/sed -E "s/\\b$wrong\\b/$corrected/gI" <<< "$CORRECTED")"
        done
        
        # 🦆 says ⮞ reconstruct da transcription into back into full json plz? ok np yo
        FINAL_JSON="$(${pkgs.jq}/bin/jq --arg corrected "$CORRECTED" '.transcription = $corrected' <<< "$TRANSCRIPTION_JSON")"
        
        # 🦆 says ⮞ clean it up, trim it down and turn it upside down yo
        TEXT=$("${pkgs.jq}/bin/jq" -r .transcription <<< "$FINAL_JSON")
        CLEANED_TEXT=$(${pkgs.coreutils}/bin/echo "$TEXT" | ${pkgs.gnused}/bin/sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | tr -s ' ' | tr -d '.,!?' | tr '[:upper:]' '[:lower:]')
        # 🦆 says ⮞ aaaand... deliver! .. yo!
        ${pkgs.coreutils}/bin/echo "$CLEANED_TEXT"
      '';    
  };} # 🦆 says ⮞ cyaaaa!
  # 🦆 says ⮞ quacky hacky ducky jumpy to da next filez yo
# 🦆 says ⮞ QuackHack-McBLindy - out yo!  
