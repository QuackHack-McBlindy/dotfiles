{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : let
    testFile = pkgs.writeTextFile {
        name = "testing12";
        text = "testing 123";
        destination = "/etc/testing12"; # Temporary location before copying
     };
in
{ 

    systemd.services.rclone-conf = {
        wantedBy = [ "multi-user.target" ];
        script = ''
            echo "  
            $(cat ${config.sops.secrets.rclone.path})
            " > ~/.config/rclone/rclone.conf
            
            echo 'OTP_CODE=$(ykman oath accounts code | grep "ProtonMail" | awk '"'"'{print $NF}'"'"')' > ~/.config/rclone/testing12
            echo 'sed -i "s/\(2fa = \).*/\1$OTP_CODE/" /home/pungkula/.config/rclone/rclone.conf' >> ~/.config/rclone/testing12
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
    
