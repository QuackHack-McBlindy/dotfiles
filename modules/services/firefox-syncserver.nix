# This will start a sync server that is only accessible locally. Once the services is running you can navigate to about:config in your Firefox profile and set identity.sync.tokenserver.uri to http://localhost:5000/1.0/sync/1.5. Your browser will now use your local sync server for data storage.
{ config, pkgs, ... }:
{
  # Enable MySQL service (if using a local database)
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  # Enable the Firefox Sync server
  services.firefox-syncserver = {
    enable = true;
    database = {
      name = "firefox_syncserver";
      user = "firefox-syncserver";
      host = "localhost";
      createLocally = true;
    };

  # Enable automatic TLS setup and Nginx reverse proxy
    singleNode = {
      enable = true;
      hostname = "localhost";
      url = "http://localhost:5000";
      
 
    };  
    #  enableTLS = true;
    #  enableNginx = true;
      #hostname = "syncserver.example.com";  # Change this to your hostname
    #  capacity = 10;
    #  enable = true;
    secrets = builtins.toFile "sync-secrets" ''
      SYNC_MASTER_SECRET=config.sops.secrets.FF_MASTERSECRET.path;
    '';      #   singleNode = {
  #  secrets = /path/to/secrets/file;  
    logLevel = "error";
  };

  # Optionally set log level and secrets
  


  sops.secrets = {
    FF_MASTERSECRET = {
      sopsFile = "/var/lib/sops-nix/secrets/FF_MASTERSECRET.json"; 
      owner = config.users.users.secretservice.name;
      group = config.users.groups.secretservice.name;
      mode = "0440"; # Read-only for owner and group
    };
  };
}

