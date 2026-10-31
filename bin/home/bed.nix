# dotfiles/bin/home/bed.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ bed controller
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let # 🦆 says ⮞ configuration directory for diz module

in {
  yo.scripts.bed = {
    description = "Bed controller";
    category = "🛖 Home Automation";
    parameters = [
      { name = "part";  description = "Which part of the bed (head/feet)"; default = "head";
        values = [ "head" "feet" ]; }
      { name = "state"; description = "Move up or down"; default = "up";
        values = [ "up" "down" ]; }
    ];
    code = ''
      case "$part" in
        head) DEVICE="Robot Arm 3" ;;
        feet) DEVICE="Robot Arm 4" ;;
      esac

      case "$state" in
        up)   ZSTATE="off" ;;
        down) ZSTATE="on" ;;
      esac

      zigduck-cli --device "$DEVICE" --state "$ZSTATE"
    '';
    voice = {
      enabled = true;
      sentences = [
        "[styr|fixa|ta] [sängens|sängen|säng] {part} [del] {state}"
      ];
      lists = {
        part.values = [
          { "in" = "[huvud|huvudet|skallen|sänghuvud|övre|head]"; out = "head"; }
          { "in" = "[fot|fötter|fötterna|feet|nedre]"; out = "feet"; }
        ];
        state.values = [
          { "in" = "[upp|uppe|up|uppåt]"; out = "up"; }
          { "in" = "[ned|ner|down|nedåt]"; out = "down"; }
        ];
      };
    };

  };}
