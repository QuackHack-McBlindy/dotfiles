# dotfiles/modules/programs/proxychains.nix
{
  config,
  self,
  lib,
  pkgs,
  ...
} : let
  cfg = config.this.host.modules.programs;

in {
  programs.proxychains = {
    enable = true;
    proxies = {
      glue = {
        enable = true;
        type = "http";
        host = "192.168.1.28";
        port = 8388;
      };
    };

  };}
