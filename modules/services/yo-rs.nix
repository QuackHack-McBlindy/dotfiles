# dotfiles/modules/services/yo-rs.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞ voice assistant configuration 
  config,
  lib,
  pkgs,
  self,
  ...
} : let
  cfg = config.services.yo-rs;
in {
  config = lib.mkMerge [{

    environment.systemPackages = [ self.inputs.yo.packages.x86_64-linux.yo-rs ];
    networking.firewall.allowedTCPPorts = [ 12345 ];
      
    services.yo-rs = {
      port = "12345";
      openFirewall = true;
      server = {
        enable = lib.mkIf (lib.elem "yo" config.this.host.modules.services) true;
        language = "sv";
        whisper = "base";
        ttsSpeed = "1.3";
        shellTranslate = true;        
        threshold = 0.6;  
        beamSize = 0;
        temperature = 0.4; # 🦆 says ⮞ no more LSD plx
        threads = 8;
      };
        
      client = {
        enable = lib.mkIf (lib.elem "yo-client" config.this.host.modules.services) true;
        uri = "192.168.1.211:12345";
        room = 
          if config.this.host.hostname == "homie" then "livingroom"
          else if config.this.host.hostname == "desktop" then "livingroom"
          else if config.this.host.hostname == "nasty" then "bedroom"
          else "";
            
        silenceThreshold = 0.03;
        silenceTimeout = 1.5;
        maxDuration = 5.0;
        awakeCmd =
          if config.this.host.hostname == "homie" then "zigduck-cli --device PC --state on --brightness 50 --color blue" 
          else if config.this.host.hostname == "desktop" then "zigduck-cli --device PC --state on --brightness 50 --color blue"            
          else if config.this.host.hostname == "nasty" then "curl http://192.168.1.13/api/ding"
          else "";

        doneCmd = 
          if config.this.host.hostname == "homie" then "zigduck-cli --device PC --state off"
          else if config.this.host.hostname == "desktop" then "zigduck-cli --device PC --state off"
          else if config.this.host.hostname == "nasty" then "curl http://192.168.1.13/api/done"
          else "";

        failCmd = 
          if config.this.host.hostname == "homie" then "zigduck-cli --device PC --state off"
          else if config.this.host.hostname == "desktop" then "zigduck-cli --device PC --state off"
          else if config.this.host.hostname == "nasty" then "curl http://192.168.1.13/api/fail"
          else "";
      };   
    };

    yo = {
      legacy = false;
      SplitWords = [ "samt" ];
      sorryPhrases = [
        "Det låter som du har en köttebulle i käften. Ät klart middagen och försök sedan igen."
        "Vad fan säger du för något?"
        "Prata som en människa snälla"
      ];
    };
       
  }];}
