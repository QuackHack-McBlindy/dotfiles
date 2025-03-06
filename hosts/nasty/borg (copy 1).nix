{ 
  config, 
  lib, 
  pkgs, 
  ... 
} : let

  pubkey = import ./../pubkeys.nix;
  backupServer = "borg@nasty"; 

  defaultPaths = [
    "/etc"
    "/var"
  ];

  destinations = {
    "desktop" = [ "/docker" "/home/pungkula" ];
    "nasty" = [ "/docker" ];
    "homie" = [ "/docker" "/var/lib/zigbee2mqtt" "/var/lib/homeassistant" ];
    "laptop" = [ ];
  };
  
  mergedDestinations = lib.mapAttrs (_host: paths: defaultPaths ++ paths) destinations;

  excludePaths = [
    "*.pyc"
    "*.o"
    "*/node_modules/*"
    "/home/*/proton"
    "/home/*/.cache"
    "/home/*/.cargo"
    "/home/*/.npm"
    "/home/*/.m2"
    "/home/*/.gradle"
    "/home/*/.opam"
    "/home/*/.clangd"
    "/home/*/.mozilla/firefox/*/storage"
    "/home/*/Android"
    "/var/lib/containerd"
    "/var/lib/docker/"
    "/var/lib/postgresql"
    "/var/log/journal"
    "/var/lib/systemd"
    "/var/cache"
    "/var/tmp"
    "/var/log"
    ".cache"
    "*/cache2"
    "*/Cache"
    ".config/Slack/logs"
    ".config/Code/CachedData"
    ".container-diff"
    ".npm/_cacache"
    "*/node_modules"
    "*/bower_components"
    "*/_build"
    "*/.tox"
    "*/venv"
    "*/.venv"
  ];

  borgbackupMonitor = { config, pkgs, lib, ... }: with lib; {
    key = "borgbackupMonitor";
    _file = "borgbackupMonitor";
    config.systemd.services = lib.mapAttrs' (name: value:
      nameValuePair "borgbackup-job-${name}" {
        unitConfig.OnFailure = "notify-problems@${name}.service";
      }
    ) config.services.borgbackup.jobs // {
      "notify-problems@" = {
        enable = true;
        serviceConfig.User = "borg";
        environment.SERVICE = "%i";
        script = ''
          export $(cat /proc/$(${pkgs.procps}/bin/pgrep "gnome-session" -u "$USER")/environ | grep -z '^DBUS_SESSION_BUS_ADDRESS=')
          ${pkgs.libnotify}/bin/notify-send -u critical "$SERVICE FAILED!" "Run journalctl -u $SERVICE for details"
        '';
      };
    };
  };

in
{
  imports = [ borgbackupMonitor ];

  services.borgbackup.repos = {
    local = {
      user = "borg";
      group = "borg";
      path = "/var/lib/borgbackup";
      quota = "100G";
      allowSubRepos = true;
      authorizedKeys = [
        "command=\"borg serve --restrict-to-path /var/lib/borgbackup\" ${pubkey.desktop}"
        "command=\"borg serve --restrict-to-path /var/lib/borgbackup\" ${pubkey.homie}"
        "command=\"borg serve --restrict-to-path /var/lib/borgbackup\" ${pubkey.laptop}"
        "command=\"borg serve --restrict-to-path /var/lib/borgbackup\" ${pubkey.nasty}"
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
      "command=\"borg serve --restrict-to-path /var/lib/borgbackup\" ${pubkey.desktop}"
      "command=\"borg serve --restrict-to-path /var/lib/borgbackup\" ${pubkey.nasty}"
      "command=\"borg serve --restrict-to-path /var/lib/borgbackup\" ${pubkey.homie}"
    ];
  };  

  services.borgbackup.jobs = lib.mapAttrs' (host: paths:
    lib.nameValuePair "backup-${host}" {
      repo = "/var/lib/borgbackup";
      encryption.mode = "none";
      paths = paths; 
      exclude = excludePaths; 
      compression = "auto,zstd";
      environment.BORG_RSH = "ssh -p 2222 -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i /var/lib/borgbackup/borg_ed25519";

      preHook = lib.optionalString config.networking.networkmanager.enable ''
        while ! ${pkgs.networkmanager}/bin/nm-online --quiet || ${pkgs.networkmanager}/bin/nmcli --terse --fields GENERAL.METERED dev show 2>/dev/null | grep --quiet "yes"; do
          sleep 60
        done
      '';

      postHook = ''
        cat > /var/log/telegraf/borgbackup-job-${host}.log <<EOF
        task,frequency=daily last_run=$(date +%s)i,state="$([[ $exitStatus == 0 ]] && echo ok || echo fail)"
        EOF
      '';

      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    }
  ) mergedDestinations;

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
}

