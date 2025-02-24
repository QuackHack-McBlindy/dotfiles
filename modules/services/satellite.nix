{ 
  config,
  pkgs,
  lib,
  ...
} : {
 
    networking.firewall.allowedTCPPorts = [ 10500 ];

    environment.systemPackages = [ pkgs.wyoming-satellite pkgs.alsa-utils ];

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
    
