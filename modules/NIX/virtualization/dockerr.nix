{ config, pkgs, lib, ... }:
{
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
              enable = false;
              setSocketVariable = false;
          };
          daemon = {
              settings = {
                  data-root = "/docker-root";
                  userland-proxy = false;
          #        experimental = true;
          #        metrics-addr = "0.0.0.0:9323";
                 # ipv6 = true;
                 # fixed-cidr-v6 = "fd00::/80";
           #       log-driver = "json-file";
            #      log-opts.max-size = "10m";
             #     log-opts.max-file = "10";
              };
          };
      };
  };
}
