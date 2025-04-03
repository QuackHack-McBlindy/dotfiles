{ 
  config,
  lib,
  pkgs,
  ...
} : let 

in {    
    
    virtualisation.oci-containers = {
        backend = "docker";
        containers = {
            homepage = {
                image = "ghcr.io/gethomepage/homepage:latest";
                user = "2000:2000";
                autoStart = true;
                volumes = [
                    "/docker/homepage/config:/app/config"
                  #  "/var/run/docker.sock:/var/run/docker.sock:ro"
                ];
                ports = [ 3001:3000 ];
                environment = { 
                    HOMEPAGE_ALLOWED_HOSTS = "localhost:"; 
                };
            }; 
            
            sockProxy = {
                image = "ghcr.io/tecnativa/docker-socket-proxy:latest";
                user = "2000:2000";
                autoStart = true;
                volumes = [
                    "/var/run/docker.sock:/var/run/docker.sock:ro"
                ];
                ports = [ 2375:2375/tcp ];
                environment = { 
                    CONTAINERS = "1";
                    TZ = "Europe/Stockholm"; 
                    POST = "0";
                };
            }; 
 
        };
    
    };}
        
