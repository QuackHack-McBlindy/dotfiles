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
  config = lib.mkMerge [
    # 🦆 say ⮞ for da server
    (lib.mkIf (lib.elem "yo-rs" config.this.host.modules.services) {
      environment.systemPackages = [ self.packages.x86_64-linux.yo-rs ];
      networking.firewall.allowedTCPPorts = [ 12345 ];
      
      services.yo-rs = {
        server = {
          enable = true;
          host = "0.0.0.0:12345";
          shellTranslate = true;
          threshold = 0.8;    
          whisperModelPath = "/home/pungkula/models/stt/ggml-small.bin";
          language = "sv";
          beamSize = 5;
          temperature = 0.2; # 🦆 says ⮞ no more LSD plx
          threads = 8;
          textToSpeechModelPath = "${cfg.package}/share/yo-rs/models/tts/sv_SE-lisa-medium.onnx";
          debug = false;
          logFile = "/home/pungkula/.config/duckTrace/yo-rs-server.log";
        };
      };
      
    })

    # 🦆 say ⮞ microphones
    (lib.mkIf (lib.elem "yo-client" config.this.host.modules.services) {     
      environment.systemPackages = [ self.packages.x86_64-linux.yo-rs ];
      networking.firewall.allowedTCPPorts = [ 12345 ];
      
      services.yo-rs = {
        client = {
          enable = true;
          uri = "192.168.1.111:12345";
          room = 
            if config.this.host.hostname == "homie" then "livingroom"
            else if config.this.host.hostname == "desktop" then "livingroom"
            else if config.this.host.hostname == "nasty" then "bedroom"
            else "";
            
          silenceThreshold = 0.02;
          silenceTimeout = 1.0;
          maxDuration = 5.0;
          awakeCmd =
            if config.this.host.hostname == "homie" then ""
            else if config.this.host.hostname == "nasty" then "zg --device bloom --state on --brightness 100 --color blue"
            else "";

          doneCmd = 
            if config.this.host.hostname == "homie" then ""
            else if config.this.host.hostname == "nasty" then "zg --device bloom --state on --brightness 100 --color green"
            else "";

          debug = false;
          logFile = "/home/pungkula/.config/duckTrace/yo-rs-client.log";
        };
      };  
        
    })
        
  ];}
