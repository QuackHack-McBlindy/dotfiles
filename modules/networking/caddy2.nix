# caddy-duckdns.packages.${system}.caddy;
{ config,inputs, pkgs, lib, ... }:
let

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
in
{
  imports = [ ./../virtualization/duckdns.nix ];

  systemd.services.caddy = {
    description = "Caddy web server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "/home/pungkula/dotfiles/modules/networking/bin/caddy run --config=/run/caddy/Caddyfile --adapter caddyfile";
    #  ExecStart = "${self.inputs.caddy-duckdns.packages.${system}.caddy}/bin/caddy run run --config=/run/caddy/Caddyfile --adapter caddyfile";
      User = "pungkula";
      AmbientCapabilities = "cap_net_bind_service";
    };
  };

  systemd.services.caddy_config = {
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

  sops.secrets = {
    caddyfile = {
      sopsFile = "/var/lib/sops-nix/secrets/caddyfile.yaml";
      owner = "caddy";
      group = "caddy";
      mode = "0660"; 
    };
  };
 
  users.users.caddy = {
    isSystemUser = true;
    group = "caddy";
  };

  users.groups.caddy = { };
}

