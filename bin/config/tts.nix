# dotfiles/bin/config/tts.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ TTS with built in language detection and automatic model downloading.  
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ quack quack quack  
  environment.systemPackages = [ pkgs.alsa-utils pkgs.pipertts ];  
in { # 🦆 says ⮞ yo yo yo yo  
  yo.scripts.say = {
    description = "Text to speech with built in language detection and automatic model downloading";
    category = "⚙️ Configuration";
    autoStart = false;
    logLevel = "WARNING";
    parameters = [ # 🦆 says ⮞ server api configuration goez here yo
      { name = "text"; description = "Input text that should be spoken"; optional = false; }      
      { name = "model"; description = "File name of the model"; default = "sv_SE-lisa-medium.onnx"; } 
      { name = "modelDir"; description = "Path to the directory containing model"; default = "/home/" + config.this.user.me.name + "/.local/share/piper"; }
      { name = "silence"; description = "Number of seconds of silence between sentences"; default = "0.2"; } 
      { name = "host"; description = "Host to play the audio on"; default = "desktop"; }       
      { name = "blocking"; description = "Wait for TTS playback to finish"; default = "false"; }
    ];
    code = ''
      ${cmdHelpers} # 🦆 says ⮞ load default helper functions 
      INPUT="$text"
      MODEL_DIR="$modelDir"
      MODEL="$model"
      HOST="$host"
      MODEL_PATH="$MODEL_DIR/$MODEL"
      BLOCKING="$blocking"
      SENTENCE_SILENCE="$silence" 
      CURRENT_HOST=$(hostname)

      if [ -z "$HOST" ] || [ "$HOST" = "$CURRENT_HOST" ]; then
        if [ ! -f "$MODEL_PATH" ]; then
          dt_error "Model not found: $MODEL_PATH"
          exit 1
        fi
        if [ "$BLOCKING" = "true" ]; then
          TMP_WAV=$(mktemp --suffix=.wav)
          trap 'rm -f "$TMP_WAV"' EXIT
          echo "$INPUT" | piper -q -m "$MODEL_PATH" -f "$TMP_WAV" -sentence_silence "$SENTENCE_SILENCE" >/dev/null 2>&1
          ${pkgs.alsa-utils}/bin/aplay "$TMP_WAV" >/dev/null 2>&1
        else
          (
            TMP_WAV=$(mktemp --suffix=.wav)
            trap 'rm -f "$TMP_WAV"' EXIT
            echo "$INPUT" | piper -q -m "$MODEL_PATH" -f "$TMP_WAV" -sentence_silence "$SENTENCE_SILENCE" >/dev/null 2>&1
            ${pkgs.alsa-utils}/bin/aplay "$TMP_WAV" >/dev/null 2>&1
          ) &
        fi  
      else
                   
        ${pkgs.openssh}/bin/ssh "$HOST" yo say \
          --text "$(printf '%q' "$INPUT")" \
          --model "$(printf '%q' "$MODEL")" \
          --modelDir "$(printf '%q' "$MODEL_DIR")" \
          --silence "$(printf '%q' "$SENTENCE_SILENCE")" \
          --host "$HOST"
      fi  
    ''; # 🦆 says ⮞ quack quack quack   
  };} # 🦆 says ⮞ duckie duck duck
# 🦆 says ⮞ QuackHack-McBLindy out - peace!  
