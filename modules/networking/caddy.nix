# dotfiles/modules/networking/caddy.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞ Reverse proxy configuration - keeping my domain names hidden 
  config,
  lib,
  pkgs,
  inputs,
  ...
} : let

    caddyConfig = ''
        "@CADDYFILE@"
    '';
    caddyFile = 
        pkgs.runCommand "caddyFile"
            { preferLocalBuild = true; }
            ''
            cat > $out <<EOF
${caddyConfig}
EOF
            '';
in {
    config = lib.mkIf (lib.elem "caddy" config.this.host.modules.networking) {
        environment.systemPackages = with pkgs; [ inputs.caddy-duckdns.packages.x86_64-linux.caddy ];

        networking.firewall.allowedUDPPorts = [ 443 53 ];
        networking.firewall.allowedTCPPorts = [ 443 53 ];

        systemd.services.caddy_config = lib.mkIf (!config.this.installer) {
            wantedBy = [ "multi-user.target" ];
            preStart = ''
                mkdir -p /run/caddy
                sed -e "/@CADDYFILE@/{
                    r ${config.sops.secrets.caddyfile.path}
                    d
                }" ${caddyFile} > /run/caddy/Caddyfile
            '';

            serviceConfig = {
                ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
                Restart = "on-failure";
                RestartSec = "2s";
                RuntimeDirectory = [ "caddy" ];
                User = "caddy";
            };
        };

        systemd.services.caddy = {
            description = "Caddy web server";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                Environment = "XDG_DATA_HOME=/var/lib/caddy";
                ExecStart = "${inputs.caddy-duckdns.packages.x86_64-linux.caddy}/bin/caddy run --config=/run/caddy/Caddyfile --adapter caddyfile";
                User = "caddy";
                StateDirectory = "caddy";
                AmbientCapabilities = "cap_net_bind_service";
            };
        };
        

        users.users.caddy = {
            isSystemUser = true;
            group = "caddy";
            home = "/var/lib/caddy";
            createHome = true;
        };
        users.groups.caddy = { };
        systemd.tmpfiles.rules = [
            "d /var/lib/caddy 0755 caddy caddy - -"
        ];

      sops.secrets = lib.mkIf (!config.this.installer) {
        caddyfile = {
          sopsFile = ./../../secrets/caddyfile.yaml;
          owner = "caddy";
          group = "caddy";
          mode = "0660";
        };
      };

    };}
