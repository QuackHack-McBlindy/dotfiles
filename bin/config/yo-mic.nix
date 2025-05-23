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
      description = "Description of the script.";
#      keywords = [ ];
      category = "⚙️ Configuration";
#      category = "🌍 Localization";
#      aliases = [ "" ];
      code = ''
          ${cmdHelpers}
          arecord -f S16_LE -r 16000 -c 1 -d 5 -t raw audio.raw && curl -X POST http://localhost:10555/transcribe -F "audio=@audio.raw;type=audio/raw"

      '';        
  };}
  
