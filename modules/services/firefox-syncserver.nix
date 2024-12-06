# This will start a sync server that is only accessible locally. Once the services is running you can navigate to about:config in your Firefox profile and set identity.sync.tokenserver.uri to http://localhost:5000/1.0/sync/1.5. Your browser will now use your local sync server for data storage.
{ config, pkgs, ... }:
{
  services.mysql.package = pkgs.mariadb;

  services.firefox-syncserver = {
    enable = true;
    secrets = builtins.toFile "sync-secrets" ''
      SYNC_MASTER_SECRET=config.sops.secrets.FF_MASTERSECRET.path;
    '';
    singleNode = {
      enable = true;
      hostname = "localhost";
      url = "http://localhost:5000";
    };
  };
  sops.secrets = {
    FF_MASTERSECRET = {
      sopsFile = "/var/lib/sops-nix/secrets/FF_MASTERSECRET.json"; 
      owner = config.users.users.secretservice.name;
      group = config.users.groups.secretservice.name;
      mode = "0440"; # Read-only for owner and group
    };
  };
}

