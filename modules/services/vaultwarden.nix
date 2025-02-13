{ config, pkgs, lib, ... }:
let
  env = ''
    VAULTWARDEN_URL="https://vaultwarden.local"
    ADMIN_TOKEN="@ADMIN_TOKEN@"
  '';

  envFile = pkgs.writeTextFile {
    name = "vaultwarden-env";
    text = env;
    destination = "/var/lib/vaultwarden/.env";
  };
in
{
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vaultwarden.local";
      SIGNUPS_ALLOWED = true;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
#    environmentFile = envFile;
  };

  systemd.services.vaultwarden_auth = {
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      sed \
        -e "s=@ADMIN_TOKEN@=$(<${config.sops.secrets.vaultwarden.path})=" \
        ${envFile} \
        > /var/lib/vaultwarden/.env
    '';

    serviceConfig = {
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

