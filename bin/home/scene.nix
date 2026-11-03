# dotfiles/bin/home/scene.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  self,
  lib,
  config,
  pkgs,
  sweSpeech,
  ...
} : let

in {

  yo.scripts.scene = {
    description = "Activate a scene by name.";
    category = "🛖 Home Automation";
    parameters = [{ name = "name"; description = "Scene name"; type = "string"; }];
    code = ''zigduck-cli --scene "$name"'';
    voice = {
      priority = 2;
      sentences = [
        "(aktivera|sätt|kör|tänd) scen {name}"
        "(aktivera|sätt|kör|tänd) scenen {name}"
        "(aktivera|sätt|kör|tänd) scen levande tak {name}"
        "(aktivera|sätt|kör|tänd) scenen levande tak {name}"
        "(aktivera|sätt|kör|tänd) scen green {name}"
        "(aktivera|sätt|kör|tänd) scenen green {name}"
        "(aktivera|sätt|kör|tänd) scen köket {name}"
        "(aktivera|sätt|kör|tänd) scenen {name} köket"
      ];
      lists.name.values = sweSpeech.scenes;
    };

  };}
