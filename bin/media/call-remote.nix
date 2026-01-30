# dotfiles/bin/media/call-remote.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ calls tv remote 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : { # 🦆 says ⮞ yo       
  yo.scripts.call-remote = {
    description = "Used to call the tv remote, for easy localization.";
    category = "🎧 Media Management";
    autoStart = false;
    logLevel = "INFO";
    code = ''
      ${cmdHelpers}
      yo tv call
    '';
    voice = { # 🦆 says ⮞ low priority = faser execution? wtf
      priority = 1; # 🦆 says ⮞ 1 to 5
      sentences = [
        # 🦆 says ⮞ find remote
        "ring (fjärren|fjärrkontroll|fjärrkontrollen|fjärris)"
        "hitta (fjärren|fjärrkontroll|fjärrkontrollen|fjärris)"            
      ]; # 🦆 says ⮞ lists are in word > out word

    };
      
  };}
