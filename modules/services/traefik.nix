{ config, pkgs, ... }:

{

  services.traefik = {
    enable = true;
    package = pkgs.traefik;
    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":8080"; # HTTP on custom port 8080
        };
        websecure = {
          address = ":8443"; # HTTPS on custom port 8443
        };
      };

      api = {
        dashboard = true;
      };

      providers = {
        file = {
          directory = "/etc/traefik/dynamic";
        };
      };
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          my-router = {
            rule = "Host(`mycustomdomain.com`)";
            entryPoints = ["web", "websecure"];
            service = "my-service";
          };
        };
        services = {
          "my-service" = {
            loadBalancer = {
              servers = [
                { url = "http://localhost:9000"; }
              ];
            };
          };
        };
      };
    };
  };
}

