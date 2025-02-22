{ config, pkgs, lib, ... }:
let
  env = ''
    VAULTWARDEN_URL="https://hemlis.duckdns.org"
    ADMIN_TOKEN="@ADMIN_TOKEN@"
  '';

  envFile = 
    pkgs.runCommand "vaultwarden.env"
      { preferLocalBuild = true; }
      ''
        cat > $out <<EOF
${env}
EOF
      '';
in
{
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://hemlis.duckdns.org";
      SIGNUPS_ALLOWED = true;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
    environmentFile = "/run/vaultwarden/vaultwarden.env";
  };

  systemd.services.vaultwarden_auth = {
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      mkdir -p /run/vaultwarden
      sed -e "s|@ADMIN_TOKEN@|$(<${config.sops.secrets.vaultwarden.path})|" \
          ${envFile} > /run/vaultwarden/vaultwarden.env
    '';

    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
      Restart = "on-failure";
      RestartSec = "2s";
      RuntimeDirectory = [ "vaultwarden" ];
      User = "vaultwarden";
    };
  };

  sops.secrets = {
    vaultwarden = {
      sopsFile = "/var/lib/sops-nix/secrets/vaultwarden.yaml";
      owner = "vaultwarden";
      group = "vaultwarden";
      mode = "0660"; 
    };
  };
 
  users.users.vaultwarden = {
    isSystemUser = true;
    group = "vaultwarden";
  };

  users.groups.vaultwarden = { };
}

