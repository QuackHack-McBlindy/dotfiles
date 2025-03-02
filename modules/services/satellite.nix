{ 
  config,
  pkgs,
  lib,
  ...
} : {
 
    networking.firewall.allowedTCPPorts = [ 10500 ];

    environment.systemPackages = [ pkgs.wyoming-satellite pkgs.alsa-utils pkgs.python312Packages.pysilero-vad pkgs.python312Packages.pyring-buffer pkgs.python312Packages.zeroconf pkgs.python312Packages.wyoming pkgs.python312Packages.webrtc-noise-gain ];


    systemd.services.wyoming-satellite = {
        enable = true;
        description = "Wyoming Satellite Voice Assistant";
        after = [ "network.target" ];
        wants = [ "network.target" ];
        serviceConfig = {
            ExecStart = ''
                ${pkgs.wyoming-satellite}/bin/wyoming-satellite \
                    --name '${config.networking.hostName}' \
                    --uri 'tcp://0.0.0.0:10500' \
                    --mic-command '/run/current-system/sw/bin/arecord -r 16000 -c 1 -f S16_LE -t raw' \
                    --snd-command '/run/current-system/sw/bin/aplay -r 22050 -c 1 -f S16_LE -t raw' \
                    --wake-uri 'tcp://127.0.0.1:10400' \
                    --wake-word-name 'yo_bitch' \
                    --awake-wav /home/pungkula/dotfiles/home/sounds/awake.wav \
                    --done-wav /home/pungkula/dotfiles/home/sounds/done.wav \
                    --timer-finished-wav /home/pungkula/dotfiles/home/sounds/finished.wav 
            '';
            Restart = "always";
            User = "pungkula"; # Change this to the correct user
            Group = "pungkula";   # Change this if necessary
            WorkingDirectory = "/home/pungkula"; # Adjust if needed
        };
        wantedBy = [ "multi-user.target" ];
        
    };}
    
