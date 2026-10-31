# dotfiles/bin/misc/wait.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  sweSpeech,
  ...
} : let

in {
  yo.scripts.wait = {
    description = "Sleep before continue.";
    category = "🧩 Miscellaneous";
    parameters = [
      { name = "duration"; description = "Duration in seconds to sleep for"; type = "int"; optional = true; }
    ];
    code = ''
      ${cmdHelpers}
      sleep "''${duration:-0}"
    '';
    voice = {
      enabled = true;
      fuzzy.enable = false;
      priority = 3;
      sentences = [
        "vänta [i] {duration} [sec|sekunder]"
      ];
      lists = {
        duration.values = sweSpeech.numberValuesOneBased 59;
      };
    };

  };}
