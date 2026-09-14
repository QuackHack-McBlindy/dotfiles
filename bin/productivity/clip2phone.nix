# dotfiles/bin/productivity/clip2phone.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ sends clipboard to iPhone for copy paste
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {
  # 🦆 says ⮞ port for stop url
  networking.firewall.allowedTCPPorts = [ 9876 ];

  yo.scripts.clip2phone = {
    description = "Send clipboard to an iPhone, for quick copy paste";
    category = "⚡ Productivity";
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "copy"; description = "Value to send to phone clipboard"; optional = false; }
    ];
    code = ''
      ${cmdHelpers}
      COPY=$copy
      yo notify --text "Clipboard received" --title "yo klistra in" --autoCopy 1 --copy "$COPY"
    '';
    voice = {
      enabled = true;
      priority = 4;
      sentences = [
        "kopiera till telefonen"
        "skicka clipboard till telefonen"
      ];
    };

  };}
