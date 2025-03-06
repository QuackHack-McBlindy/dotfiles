{ 
  config, 
  lib, 
  pkgs, 
  ... 
} : let

  pubkey = import ./../pubkeys.nix;

in
{
  services.borgbackup.repos = {
    local = {
      user = "borg";
      group = "borg";
      path = "/var/lib/borgbackup";
      quota = "100G";
      allowSubRepos = true;
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s"
        pubkey.homie
        pubkey.nasty
      ];
      authorizedKeysAppendOnly = [ ];
    };
  };

  users.users.borg = {
    home = "/var/lib/borgbackup";
    createHome = true;
    isSystemUser = true;
    group = "borg";
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s"
        pubkey.homie
        pubkey.nasty
    ];
  };  


  systemd.services."borgbackup-job".serviceConfig.ReadWritePaths = [ "/var/log/telegraf" ];

  systemd.services.borg-key = {
    description = "Ensure SSH key for BorgBackup exists";
    after = [ "network.target" ];
    before = [ "borgbackup-job.service" ];
    wantedBy = [ "multi-user.target" ];
  
    script = ''
      echo "  
      $(cat ${config.sops.secrets.borg_ed25519.path})
      " > /var/lib/borgbackup/borg_ed25519
      chmod 600 /var/lib/borgbackup/borg_ed25519
      chown borg:borg /var/lib/borgbackup/borg_ed25519
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "borg";
      Group = "borg";
      WorkingDirectory = "/var/lib/borgbackup";
    };
  };
  
  sops.secrets = {
    borg_ed25519 = {
      sopsFile = ./../../secrets/borg_ed25519.yaml; 
      owner = "borg";
      group = "borg";
      mode = "0440"; # Read-only for owner and group
    };
  }; 
  
  

    services.openssh = {
        enable = true;
        ports = [ 2222 ];
        openFirewall = true;   
        settings = {    
            AllowUsers = [ "borg" ];  
            PasswordAuthentication = false;
            PermitRootLogin = "no"; 
            MaxAuthTries = "3";  
        };    
    };        
}

