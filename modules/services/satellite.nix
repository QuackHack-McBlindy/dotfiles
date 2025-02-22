{ 
  config,
  pkgs,
  lib,
  ...
} : {

    environment.systemPackages = [ pkgs.wyoming-satellite pkgs.alsa-utils pkgs.python312Packages.pysilero-vad pkgs.python312Packages.webrtcvad pkgs.webrtc-audio-processing pkgs.python312Packages.webrtc-models pkgs.python312Packages.webrtc-noise-gain pkgs.python312Packages.webrtc-noise-gain pkgs.wyoming-satellite pkgs.python312Packages.wyoming pkgs.wyoming-piper pkgs.webrtc-audio-processing pkgs.webrtc-audio-processing_1 pkgs.python312Packages.webrtc-models pkgs.python312Packages.webrtcvad ];

    services.wyoming.satellite = {
        enable = true;
      #  package = pkgs.wyoming-satellite;  
        user = "pungkula";            
        group = "pungkula";              
        uri = "tcp://localhost:10500";     
        area = "LivingRoom";               
        microphone = {
            command = "arecord -r 16000 -c 1 -f S16_LE -t raw"; 
            autoGain = 31;  
        };    
        sound.command = "aplay -r 22050 -c 1 -f S16_LE -t raw";  
        sounds = {
            awake = "/home/pungkula/dotfiles/home/sounds/awake.wav";
            done = "/home/pungkula/dotfiles/home/sounds/done.wav";
        };
        
        vad.enable = true;  # Enable or disable voice activity detection

    };}
    
