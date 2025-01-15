{ config, pkgs, ... }:
{    
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      duckdns = {
        image = "ghcr.io/anujdatar/duckdns";
        hostname = "duckdns";
        #dependsOn = [ "" ];
        autoStart = true;
        environments = [
          SUBDOMAINS=domain1,domain2
          TOKEN=xxxxxxxxxxxxxxxxx
          FREQUENCY=1  # OPTIONAL, default is 5          
        ];
      };
    };
  };
}  
