{ 
  config,
  lib,
  pkgs,
  ...
} : {
    config = lib.mkIf (lib.elem "pool" config.this.host.modules.networking) {
        systemd.services.nfs-mnt = lib.mkIf (!config.this.installer) {
            wantedBy = [ "multi-user.target" ];
            after = [ "network-online.target" ];
            requires = [ "network-online.target" ];

            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = [
                    "${pkgs.bash}/bin/bash -c '/run/current-system/sw/bin/sleep 30 && /run/wrappers/bin/mount -t nfs4 192.168.1.28:/ /mnt/Pool && /run/wrappers/bin/mount --bind /mnt/Pool /Pool'"
                ];
                Restart = "on-failure";
                RestartSec = "2s";
                User = "root";
            };
        };
        
    };}
