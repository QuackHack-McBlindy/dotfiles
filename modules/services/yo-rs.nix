# dotfiles/modules/services/yo-rs.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞ voice assistant configuration 
  config,
  lib,
  pkgs,
  self,
  ...
} : let
 
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
          wakeWordPath = "/home/pungkula/dotfiles/home/.config/models/yo_bitch.onnx";
          threshold = 0.8; 
          awakeSound = "/home/pungkula/dotfiles/modules/themes/sounds/awake.wav";
          whisperModelPath = "/home/pungkula/models/stt/ggml-small.bin";
          language = "sv";
          beamSize = 5;
          temperature = 0.2; # 🦆 says ⮞ no more LSD plx
          threads = 4;  
          execCommand = "yo do";
          debug = false;
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
          silenceThreshold = 0.03;
          silenceTimeout = 0.9;
          maxDuration = 5.0;
          debug = false;          
        };
      };  
        
    })
        
  ];}

