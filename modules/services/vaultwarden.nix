{ config, pkgs, lib, ... }:
{

  environment.systemPackages = with pkgs; [ pkgs.caddy ];

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vaultwarden.local";
      SIGNUPS_ALLOWED = true;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
  };

  systemd.services.vaultwarden.serviceConfig = {
    EnvironmentFile = [ config.sops.secrets.vaultwarden.path ];
  };


  systemd.services.vaultwarden_admin = {
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      sed \
        -e "s=@ADMIN_TOKEN@=$(<${config.sops.secrets.vaultwarden.path})=" \
        > /run/vaultwarden/config.toml
    '';

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "2s";
      Environment = "CONFIG_PATH=/run/vaultwarden_admin/config.toml";

    };
  };



  sops.secrets = {
    vaultwarden = {
      sopsFile = "/var/lib/sops-nix/secrets/vaultwarden.yaml";
      owner = config.users.users.secretservice.name;
      group = config.users.groups.secretservice.name;
      mode = "0440"; # Read-only for owner and group
    };
  };

 
}

