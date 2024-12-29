{ config, pkgs, lib, ... }:
{
  virtualisation = {
      docker = {
          enable = true;
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
