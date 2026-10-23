# dotfiles/modules/services/sunshine.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 say ⮞ sunshine configuration (Casting PC -> TV)
  config,
  lib,
  pkgs,
  ...
} : let

in {
    services.sunshine = lib.mkIf (lib.elem "sunshine" config.this.host.modules.services) {
      enable       = true;
      autoStart    = true;
      openFirewall = true;
      # 🦆 say ⮞ required for screen capture via DRM/KMS on Wayland
      capSysAdmin  = true;
      settings = {
        port          = 47989;
        sunshine_name = config.this.host.hostname;
        capture       = "kms";
        encoder       = "vaapi";
        adapter_name  = "/dev/dri/renderD128";
        output_name   = "HDMI-1";
      };

      applications = {
        apps = [{ name = "Desktop"; }];
      };

    };}
