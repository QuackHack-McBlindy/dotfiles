{ config, pkgs, lib, ... }:
{

  users = {
      groups.dockeruser = {
          gid = 2000;
      };
      users.dockeruser = {
          group = "dockeruser";
          home = "/docker";
          createHome = true;
          isSystemUser = true;
          extraGroups = [ "docker" ]; 
          uid = 2000;
          
      };
  };
   
  
  
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
                  data-root = "/docker-d";
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
  
#  system.activationScripts = {
#    dockerPermissions = lib.stringAfter [ "users" "groups" ] ''
#      echo "Setting ownership and permissions for /docker..."
#      chown -R dockeruser:dockeruser /docker
#      chmod -R 750 /docker
#    '';
#  };
  
}
