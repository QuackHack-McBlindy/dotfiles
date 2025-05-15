{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SERVICE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°  
 
    virtualisation.oci-containers = {
        backend = "docker";
        containers = {
            duck-tv = {
                image = "jellyfin/jellyfin:latest";
                hostname = "duck-tv";
                autoStart = true;
                ports = [
                    "8096:8096"
                    "8920:8920" #optional
                   # "7359:7359/udp" #optional
                   # "1900:1900/udp" #optional
                ];
                volumes = [
                    "/docker/duck-tv/config:/config"
                    "/docker/duck-tv/jellyfin-web:/jellyfin-web:ro"
                    "/Pool/TV:/data/tvshows"
                    "/Pool/Movies:/data/movies"
                    

                ];
            #    enviorments = [ 
            #        PUID=1000
             #       PGID=1000
            #        TZ=Europe/Stockholm
                  #  JELLYFIN_PublishedServerUrl=http://192.168.0.5 #optional
      #          ];
            };  
        };

    };}
