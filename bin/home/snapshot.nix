# dotfiles/bin/home/snapshot.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
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

  yo.scripts.snapshot = {
    description = "Create or restore a named snapshot of the Zigduck light/device states.";
    category = "🛖 Home Automation";
    parameters = [
      { name = "action"; description = "Create or restore snapshot"; optional = false;
        values = [ "create" "restore" ]; }
      { name = "name"; type = "string"; description = "Name of the snapshot."; optional = false; }
    ];
    code = ''
      zigduck-cli snapshot "$action" "$name"
    '';
    voice = {
      priority = 4;
      sentences = [
        "{action} [en] (snap|snapp|snapshot|ögonblicksbild|systembild|bild) [av] [system|systemet] [och] (döp|namnge) den [till] [innan] {name}"
        "{action} [en] (system|systemet|lamporna) till [innan] {name}"
      ];
      lists = {
        action.values = [
          { "in" = "skap|skapa|gör|fixa|greja";   out = "create"; }
          { "in" = "återskapa|återställ|återuppbygga|ursprungligt|returnera|rekonstruera"; out = "restore"; }
        ];
        name.wildcard = true;
      };
    };

  };}
