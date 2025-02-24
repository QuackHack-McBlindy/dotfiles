{ 
  config,
  pkgs,
  lib,
  ...
} : {
 
    networking.firewall.allowedTCPPorts = [ 10500 ];

    environment.systemPackages = [ pkgs.wyoming-satellite pkgs.alsa-utils pkgs.python312Packages.pysilero-vad pkgs.python312Packages.pyring-buffer pkgs.python312Packages.zeroconf pkgs.python312Packages.wyoming ];

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
        
        vad.enable = false;  # Enable or disable voice activity detection

    };}
    
