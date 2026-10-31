# dotfiles/bin/home/countdown.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  self,
  lib,
  config,
  pkgs,
  zigduck,
  sweSpeech,
  ...
} : let

in {
  yo.scripts.countdown = {
    description = "Set a (nedräkning|countdown) on a Zigbee device (turns off after N seconds).";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "device";  description = "Device to set countdown on"; type = "string"; optional = false; }
      { name = "seconds"; description = "Seconds until device turns off"; default = "0"; }
    ];

    code = ''
      zigduck-cli --publish \
        --topic "${zigduck.baseTopic}/''${device}/set" \
        --payload "{\"countdown\": ''${seconds}}"
    '';

    voice = {
      priority = 2;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;
      sentences = [
        "sätt {seconds} sekunders (nedräkning|countdown) på {device}"
        "låt {device} stänga om {seconds} sekunder"
        "sätt {device} att stänga om {seconds} sekunder"
        "stäng {device} om {seconds} sekunder"
        "sätt (nedräkning|countdown) {seconds} på {device}"
        "sätt {device} (nedräkning|countdown) {seconds}"
        "stoppa (nedräkning|countdown) på {device}"
        "avbryt (nedräkning|countdown) på {device}"
      ];
      lists = {
        device.values  = sweSpeech.deviceValues;
        seconds.values = sweSpeech.numberValues 300;
      };
    };

  };}
