# dotfiles/bin/network/vpn.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{
  self,
  lib,
  config,
  pkgs,
  ...
} : let
  wgQuick = "${pkgs.wireguard-tools}/bin/wg-quick";
in {
  yo.scripts.vpn = {
    description =  "Toggle WireGuard sate/config.";
    category = "🌐 Networking";
#    helpFooter = ''

#    '';
    parameters = [
      { name = "mode"; description = "up/down"; type = "string"; default = "up";
        values = [ "up" "down" ]; }
      { name = "type"; description = "home/hide"; optional = false; default = "away";
        values = [ "home" "hide" ]; }
    ];
    code = ''
      MODE=$mode
      TYPE=$type

      CONFIG="/home/wgUser/$TYPE.conf"


      case "$MODE" in
        up)
          sudo ${wgQuick} up "$CONFIG"
          ;;
        down)
          sudo ${wgQuick} down "$CONFIG"
          ;;
        *)
          echo "Usage: vpn [up|down] [home|hide]"
          exit 1
          ;;
      esac
    '';

  };}
