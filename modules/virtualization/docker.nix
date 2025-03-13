{ config, pkgs, lib, ... }:
{
  virtualisation = {
      docker = {
          enable = true;
          extraOptions = "--iptables=false --ip-masq=false";
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
              };
          };
      };
  };
}
