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
              #  "laptop" = { id = "FDDGVYW-PFMTSFS-EFOK3VI-K66RDUI-G5J5USL-PVTKSJF-PDTEX22-LNCNHQY"; };
                "homie" = { id = "LSSUP2H-ZAWQAKQ-C65EX37-ITHGKG6-2BGOHXW-LDLV24B-JXRRTO5-IFJUEQV"; };
                "nasty" = { id = "6DNQMMQ-MGUYQRJ-PIDGQLA-7ZLSJMO-L4E5LC3-RKAZEBE-LAAIA2A-PH5ZLQR"; };
            };

            folders."dotfiles" = {
                path = "/home/pungkula/dotfiles";
                devices = [ "desktop" "homie" "nasty" ];
            };
        };


    };}
