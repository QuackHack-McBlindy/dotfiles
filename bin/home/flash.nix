# dotfiles/bin/home/flash.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
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

  yo.scripts.flash_lights = {
    description = "Flash lights 3 times then restore previous state.";
    category = "🛖 Home Automation";
    parameters = [];
    code = ''
      zigduck-cli snapshot create before_flash
      for i in 1 2 3; do
        zigduck-cli --scene max
        sleep 2
        zigduck-cli --scene dark-fast
        sleep 2
      done
      zigduck-cli snapshot restore before_flash
    '';
    voice = {
      priority = 4;
      sentences = [
        "(flash|flasha|blinka) ljusen"
        "blinkepartaj"
        "blinkaparty"
        "flash sekvens"
        "dramatisk flash"
      ];
    };

  };}
