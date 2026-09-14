# dotfiles/modules/virtualisation/gluetun.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ Containerized VPN connection
  config,
  lib,
  pkgs,
  ...
} : let
in {
  config = lib.mkIf (lib.elem "caddy" config.this.host.modules.virtualisation) {
    networking.firewall.allowedTCPPorts = [ 443 ];

    virtualisation.oci-containers = {
      backend = "docker";
      containers.caddy = {
        image = "ghcr.io/serfriz/caddy-duckdns:latest";
        user = "0:0";
        hostname = "caddy";
        ports = [ "443:443" ];
        volumes = [
          "/docker/caddy/config:/caddy"
          "/run/secrets/caddyfile:/etc/caddy/Caddyfile:ro"
          "/Pool:/Pool"
        ];
        environment = {
          CADDY_CONFIG = "/etc/caddy/Caddyfile";
        };
      };
    };

    sops.secrets.caddyfile = lib.mkIf (!config.this.installer) {
      sopsFile = ./../../secrets/caddyfile.yaml;
      owner = "dockeruser";
      group = "dockeruser";
      mode = "0660";
    };

  };}
