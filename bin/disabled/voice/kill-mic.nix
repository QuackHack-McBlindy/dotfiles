# dotfiles/bin/voice/kill-mic.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ damn gangsta
  config,
  lib,
  self,
  pkgs,
  cmdHelpers,
  PythonDuckTrace,
  ...
} : let
in {
  yo.scripts.kill-mic = {
    description = "Kill mic-stream by port with voice";
    category = "🗣️ Voice";
    logLevel = "INFO";
    code = ''
      yo say "yo peace out yo" --host "desktop"
      lsof -ti:8765 | xargs kill -9 2>/dev/null || true
      dt_info "Killed microphone stream"
    '';
    voice = {
      enabled = true;
      priority = 1;
      fuzzy.enable = true;
      sentences = [
        "(hej|hejdå|avbryt|nej)"
        "[good][ ]bye[ ][bye]"
        "vi hörs"
      ];
    };

  };}
