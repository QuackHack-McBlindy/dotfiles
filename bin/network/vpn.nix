# dotfiles/bin/network/vpn.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{
  self,
  lib,
  config,
  pkgs,
  ...
} : let


in {


  yo.scripts.vpn = {
    description =  "Toggle WireGuard sate/config.";
    category = "🌐 Networking";
    #aliases = [ "vpn" ];
#    helpFooter = ''

#    '';
    parameters = [
      { name = "mode"; description = "up/down"; type = "string"; default = "up";
        values = [ "up" "down" ]; }
      { name = "type"; description = "home/hide"; optional = false; default = "home";
        values = [ "home" "hide" ]; }
    ];
    code = ''
      echo 'hello world'

    '';


  };}
