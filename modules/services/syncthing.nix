{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 

    services.syncthing = {
        enable = true;  # Enables the Syncthing service
     #   configDir = ./../../../.config/syncthing;
        user = "pungkula";  # Runs under your user
        group = "pungkula";  # Adjust if needed
        systemService = false;  # Runs as a user service (not system-wide)
        openDefaultPorts = true;  # Opens required ports in firewall

        settings = {
            options = {
                urAccepted = 0;  # Accept Syncthing usage reporting (optional)
                relaysEnabled = false;  # Disable public relay servers (LAN only)
                localAnnounceEnabled = true;  # Enable LAN discovery
                limitBandwidthInLan = false;  # No bandwidth limit for LAN sync
            };

            devices = {
                "desktop" = { id = "VS7N2LS-FIXYWOX-UGWKHDQ-C22YRR2-JIQHD6A-YEHEKAO-6OMZ47V-ZVTM5QR"; autoAcceptFolders = false; };
            #    "laptop" = { id = "DEVICE-ID-2"; autoAcceptFolders = true; };
                "homie" = { id = "R4DUXJ4-IBMIMIU-Y5ROSQV-7HHWSCH-QCUV7XX-ZSE6ZEG-HGPYK3D-YC5E6A2"; autoAcceptFolders = true; };
          #      "nasty" = { id = "DEVICE-ID-4"; autoAcceptFolders = true; };
            };

            folders."dotfiles" = {
                path = "/home/pungkula/dotfiles";
                label = "Dotfiles";
                enable = true;
                type = "sendreceive";  # Enables bidirectional sync
                devices = [ "desktop" ];
                copyOwnershipFromParent = true;
                versioning = { type = "trashcan"; };  # Keeps deleted files in .stversions
            };
        };

    };}
