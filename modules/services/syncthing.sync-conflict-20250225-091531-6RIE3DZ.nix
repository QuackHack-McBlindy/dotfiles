{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 

   networking.firewall.allowedTCPPorts = [ 8384 22000 ];
   networking.firewall.allowedUDPPorts = [ 22000 21027 ];

    services.syncthing = {
        enable = true;  # Enables the Syncthing service
        user = "pungkula";
        group = "pungkula";
        dataDir = "/home/pungkula/Documents";  
        configDir = "/home/pungkula/.config/syncthing";   
        overrideDevices = true;     # overrides any devices added or deleted through the WebUI
        overrideFolders = true;     # overrides any folders added or deleted through the WebUI

        settings = {
            devices = {
                "desktop" = { id = "6RIE3DZ-XWAP6NX-OF2JF4Z-N35U3RZ-IL5FX7H-AFWROYH-5HMM35U-WQHY4Q3"; };
            #    "laptop" = { id = "DEVICE-ID-2"; autoAcceptFolders = true; };
                "homie" = { id = "R4DUXJ4-IBMIMIU-Y5ROSQV-7HHWSCH-QCUV7XX-ZSE6ZEG-HGPYK3D-YC5E6A2"; };
                "nasty" = { id = "JKK3F7P-P23AKMA-CSG7CDI-WZQBVW3-PLXKSWA-CLHG272-M2AQ2ZW-P3HTRA6"; };
            };

            folders."dotfiles" = {
                path = "/home/pungkula/dotfiles";
                devices = [ "desktop" "homie" "nasty" ];
            };
        };


    };}
