{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 

    services.adguardhome = {
        enable = true;
        package = pkgs.adguardhome;
        # Web Interface
        host = "0.0.0.0";
        port =  3000;
        openFirewall = false;
        
        # allowDHCP =   # Allows AdGuard Home to open raw sockets (CAP_NET_RAW), which is required for the integrated DHCP server.
        mutableSettings = true;
        # settings.schema_version = cfg.package.schema_version;
        settings = {
            #
        };
    };}
