# dotfiles/bin/voice/cancel.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ camcel commands
  config, 
  lib,
  self,
  pkgs,
  cmdHelpers,
  ...
} : let 

in { # 🦆 says ⮞ 
  yo.scripts.cancel = {
      description = "Cancel coammands microphone recording sent to transcription.";
      category = "🗣️ Voice";
      logLevel = "CRITICAL";
      parameters = [ # 🦆 says ⮞ some paramz to know where to pass audio
        { name = "input"; type = "string"; description = "Input"; }
      ];  
      code = ''
        ${cmdHelpers}
        dt_info "canceled command"
      '';
      voice = {
        enabled = true;
        priority = 1;
        sentences = [
          "nej {input}"
          "{input} nej nej"
          "{input} nej"
          "avbryt {input}"
        ];
        lists.input.wildcard = true;
      };
      
    };} # 🦆 says ⮞ QuackHack-McBLindy - out yo!  
