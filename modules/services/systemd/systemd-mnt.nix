{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : {

    systemd.services.nfs-mnt = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        requires = [ "network-online.target" ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = [
                "${pkgs.bash}/bin/bash -c '/run/current-system/sw/bin/sleep 30 && /run/wrappers/bin/mount -t nfs4 192.168.1.28:/ /mnt/Pool && /run/wrappers/bin/mount --bind /mnt/Pool /Pool && /run/wrappers/bin/mount -t nfs4 192.168.1.28:/ /mnt/backup && /run/wrappers/bin/mount --bind /mnt/backup /backup'"
            ];
            Restart = "on-failure";
            RestartSec = "2s";
            User = "root";
        };
    };}     
