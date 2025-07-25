{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 

    services.navidrome = lib.mkIf (lib.elem "navidrome" config.this.host.modules.services) {
        enable = true;
        user = "navidrome";
        group = "navidrome";
        settings = {
            Address = "0.0.0.0";
            Port = 4533;
            MusicFolder = "/Pool/Music";
            LogLevel = "DEBUG";
            Scanner.Schedule = "@every 24h";
            TranscodingCacheSize = "150MiB";
        };
        openFirewall = true;
#    };
            
#    services.nginx = {
#        enable = true;
#        recommendedProxySettings = true;
#        virtualHosts = {
#            "music" = {
#                locations."/".proxyPass = "http://${config.services.navidrome.settings.Address}:${toString config.services.navidrome.settings.Port}";
#            };
#        };
    };}

