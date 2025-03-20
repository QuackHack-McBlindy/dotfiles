{ config, pkgs, lib, ... }:
{

  users = {
      groups.dockeruser = {
          gid = 993;
      };
      users.dockeruser = {
          group = "dockeruser";
          home = "/docker";
          createHome = true;
          isSystemUser = true;
          extraGroups = [ "docker" ]; 
          uid = 982;
          
      };
  };
  
  systemd.tmpfiles.rules = [
    # Create the /docker directory (if it doesn't exist)
    # Set ownership to dockeruser:dockeruser
    # Set permissions to 775 (rwxrwxr-x)
    "d /docker 0775 dockeruser dockeruser - -"
  ];
  
  
  virtualisation = {
      docker = {
          enable = true;
          enableOnBoot = true;
          #extraOptions = "--iptables=false --ip-masq=false";
          autoPrune = {
              enable = true;
              dates = "weekly";
          };
          rootless = {
              enable = true;
              setSocketVariable = true;
          };
          daemon = {
              settings = {
                  data-root = "/docker";
                  userland-proxy = false;
                  experimental = true;
                  metrics-addr = "0.0.0.0:9323";
                 # ipv6 = true;
                 # fixed-cidr-v6 = "fd00::/80";
                  log-driver = "json-file";
                  log-opts.max-size = "10m";
                  log-opts.max-file = "10";
              };
          };
      };
  };
}
