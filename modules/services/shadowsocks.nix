# dotfiles/modules/services/shadowsocks.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞
  config,
  lib,
  pkgs,
  ...
} : let
  inherit (lib) mkEnableOption mkOption types mkIf mkDefault;
  cfg = config.modules.services.nixCache;
in {
  config = lib.mkIf (lib.elem "ss" config.this.host.modules.services) {
    networking.firewall.allowedTCPPorts = [ 8388 ];

    systemd.services.sing-box.serviceConfig = {
      User = lib.mkForce "root";
      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
    };


    services.sing-box = {
      enable = true;

      settings = {
        log.level = "info";

        inbounds = [
          {
            type = "redirect";
            tag = "redirect-in";
            listen = "127.0.0.1";
            listen_port = 9040;
          }
          {
            type = "mixed";
            tag = "mixed-in";
            listen = "10.100.100.1";
            listen_port = 1080;
          }
        ];

        outbounds = [
          {
            type = "shadowsocks";
            tag = "ss";
            server = "192.168.1.28";
            server_port = 8388;
            method = "chacha20-ietf-poly1305";
            password = { _secret = config.sops.secrets.SHADOWSOCKS_PASSWORD.path; };
          }
        ];
      };
    };

    sops.secrets = {
      SHADOWSOCKS_PASSWORD = {
        sopsFile = ./../../secrets/SHADOWSOCKS_PASSWORD.yaml;
        owner = config.this.user.me.name;
        group = config.this.user.me.name;
        mode = "0440";
      };
    };

  };}
