{ pkgs, ... }:
#let
#  conf = pkgs.writeText "Caddyfile" ''
#    http://0.0.0.0:8080 {
#      file_server /* browse {
 #       root /home/pungkula/web
#      }
#    }
#  '';
#in
{
  systemd.services.caddy = {
    description = "Caddy web server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "/home/pungkula/dotfiles/modules/networking/bin/caddy run --config=/etc/caddy/Caddyfile --adapter caddyfile";
      User = "pungkula";
      AmbientCapabilities = "cap_net_bind_service";
    };
  };
}
