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
    ];
    code = ''
      ${cmdHelpers} # 🦆 says ⮞ load default helper functions 
      INPUT="$text"
      MODEL_DIR="$modelDir"
      MODEL="$model"
      MODEL_PATH="$MODEL_DIR/$MODEL"
      SENTENCE_SILENCE="$silence"
      if [ ! -f "$MODEL_PATH" ]; then
        echo "❌ Model not found: $MODEL_PATH"
        exit 1
      fi  
      
      (
        TMP_WAV=$(mktemp --suffix=.wav)
        trap 'rm -f "$TMP_WAV"' EXIT
        echo "$INPUT" | piper -q -m "$MODEL_PATH" -f "$TMP_WAV" -sentence_silence "$SENTENCE_SILENCE" >/dev/null 2>&1
        aplay "$TMP_WAV" >/dev/null 2>&1
      ) &      
      
#      TMP_WAV=$(mktemp --suffix=.wav)
#      trap 'rm -f "$TMP_WAV"' EXIT
#      echo "$INPUT" | piper -q -m "$MODEL_PATH" -f "$TMP_WAV" -sentence_silence $SENTENCE_SILENCE >>/dev/null && aplay "$TMP_WAV" >>/dev/null
    ''; # 🦆 says ⮞ quack quack quack   
  };} # 🦆 says ⮞ duckie duck duck
# 🦆 says ⮞ QuackHack-McBLindy out - peace!  
