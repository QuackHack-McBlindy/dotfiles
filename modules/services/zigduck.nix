# dotfiles/modules/services/zigduck.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 say ⮞ enables zigduck services
  config,
  lib,
  pkgs,
  self,
  ...
} : let

in {
  config = lib.mkMerge [
    {
      services.zigduck = {
        enable = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) true;
        cli.enable = true;
        gnomeExtension.enable = lib.mkIf (lib.elem "gnome" config.this.host.modules.system) true;
        dashboard.enable = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) true;
        dashboard.port = 13337;
        dashboard.openFirewall = lib.mkIf (lib.elem "zigduck" config.this.host.modules.services) true;
        dashboard.passwordFile = config.sops.secrets.api.path;
        dashboard.secure = true;
        ##extraEnv.PATH =
        #  "/run/current-system/sw/bin:"
        #  + "/run/current-system/sw/sbin";
      };
    }

  ];}
