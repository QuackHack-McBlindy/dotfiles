{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : let
  backupServer = "pungkula@192.168.1.111"; 
  sshKey = "/home/pungkula/.ssh/borg_ed25519";

  defaultPaths = [
    "/etc"
    "/var"
    "/root"
  ];

  destinations = {
    "192.168.1.111" = [ "/docker" "/home/pungkula" ];
    "192.168.1.28" = [ "/docker" ];
    "192.168.1.211" = [ "/docker" "/var/lib/zigbee2mqtt" "/var/lib/homeassistant" ];
  };
  
  mergedDestinations = lib.mapAttrs (_host: paths: defaultPaths ++ paths) destinations;

  excludePaths = [
    "*.pyc"
    "*.o"
    "*/node_modules/*"
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
    "*/cache2" # firefox
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
    config.systemd.services = {
      "notify-problems@" = {
        enable = true;
        serviceConfig.User = "pungkula";
       # serviceConfig.User = "%i";
        environment.SERVICE = "%i";
        script = ''
          export $(cat /proc/$(${pkgs.procps}/bin/pgrep "gnome-session" -u "$USER")/environ |grep -z '^DBUS_SESSION_BUS_ADDRESS=')
          ${pkgs.libnotify}/bin/notify-send -u critical "$SERVICE FAILED!" "Run journalctl -u $SERVICE for details"
        '';
      };
    } // flip mapAttrs' config.services.borgbackup.jobs (name: value:
      nameValuePair "borgbackup-job-${name}" {
        unitConfig.OnFailure = "notify-problems@%i.service";
        # unitConfig.OnFailure = "notify-problems@${name}.service";
      }
    );
    
    config.systemd.timers = flip mapAttrs' config.services.borgbackup.jobs (name: value:
      nameValuePair "borgbackup-job-${name}" {
        timerConfig.Persistent = lib.mkForce true;
      }
    );
  };

in
{
  imports = [ borgbackupMonitor ];

  services.borgbackup.jobs = lib.mapAttrs' (host: paths:
    lib.nameValuePair "backup-${host}" {
      repo = "${backupServer}:/borg/${host}";
      encryption.mode = "none";
      paths = paths; 
      exclude = excludePaths; 
      compression = "auto,zstd";
      environment.BORG_RSH = "ssh -p 2222 -o 'StrictHostKeyChecking=no' -i ${sshKey}";

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

#  systemd.services.borgbackup-job.preStart = ''
#    mkdir -p /var/log/telegraf
#    chown telegraf:telegraf /var/log/telegraf
#    chmod 0755 /var/log/telegraf
#
#    if [ ! -f /root/.ssh/borg-backup-key ]; then
#      mkdir -p /root/.ssh
#      ssh-keygen -t ed25519 -N "" -f /root/.ssh/borg-backup-key
#      chmod 600 /root/.ssh/borg-backup-key
#      chown root:root /root/.ssh/borg-backup-key
#    fi
#  '';

#  sops.secrets = {
#    borg@homie = {
#      sopsFile = "/var/lib/sops-nix/secrets/borg@homie.yaml";
#      owner = config.users.users.secretservice.name;
#      group = config.users.groups.secretservice.name;
#      mode = "0440"; # Read-only for owner and group
#    };
#  };

#  config.sops.secrets.borg@homie.path;

}

