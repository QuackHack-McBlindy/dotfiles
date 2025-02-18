{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 

    systemd.services.rclone-conf = {
        wantedBy = [ "multi-user.target" ];
        script = ''
            echo "  
            $(cat ${config.sops.secrets.rclone.path})
            " > ~/.config/rclone/rclone.conf
        '';
    
        serviceConfig = {
            User = "pungkula";
            #WorkingDirectory = "";
        };
    };

    sops.secrets = {
        rclone = {
            sopsFile = ./../../secrets/rclone.yaml;
            owner = "pungkula";
            group = "pungkula";
            mode = "0440"; # Read-only for owner and group
        };

    };}
    
