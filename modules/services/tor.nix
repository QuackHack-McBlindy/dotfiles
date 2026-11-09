# dotfiles/modules/services/tor.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{
  config,
  lib,
  pkgs,
  self,
  ...
} : let

in {

    services.tor = lib.mkIf (lib.elem "tor" config.this.host.modules.services) {
      enable = true;
      openFirewall = true;
      settings = {
        TransPort = [ 9040 ];
        DNSPort = 5353;
        VirtualAddrNetworkIPv4 = "172.30.0.0/16";
      };

    };}
