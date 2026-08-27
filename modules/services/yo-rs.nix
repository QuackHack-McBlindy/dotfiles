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

    services.yo-rs = {
      port = 12345;
      openFirewall = true;
      server = {
        enable = lib.mkIf (lib.elem "yo" config.this.host.modules.services) true;
        language = "swedish";
        whisper = "small";
        ttsSpeed = "1.3";
        shellTranslate = true;        
        threshold = 0.6;  
        beamSize = 0;
        temperature = 0.4; # 🦆 says ⮞ no more LSD plx
        threads = 8;
        logFile = "/home/pungkula/.config/duckTrace/yo-rs-server.log";
      };
        
      client = {
        enable = lib.mkIf (lib.elem "yo-client" config.this.host.modules.services) true;
        logFile = "/home/pungkula/.config/duckTrace/yo-rs-client.log";
        uri = "192.168.1.111:12345";
        room = 
          if config.this.host.hostname == "homie" then "livingroom"
          else if config.this.host.hostname == "desktop" then "local"
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
      # default fuzzy settings (overridden by per-script configurations)
      fuzzy = {
        threshold = 0.7;
        conflict.detection = false;
        conflict.threshold = 70;
      };
      splitWords = [ "samt" ];      
      sorryPhrases = [
        "Det låter som du har en köttebulle i käften. Ät klart middagen och försök sedan igen."
        "Vad fan säger du för något?"
        "Prata som en människa snälla"
      ];
    };
       
  }];}
