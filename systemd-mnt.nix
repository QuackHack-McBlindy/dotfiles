
  
  
  
  
    systemd.services.nfs-mnt = {
        description = "nfs-mnt";
        after = [ "network.target" ];
        wantedBy = [ "local-fs.target" ];
        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = [
                "${pkgs.bash}/bin/bash -c 'echo sleep 30" 
                "${pkgs.bash}/bin/bash -c 'echo sudo mount -t nfs4 192.168.1.28:/ /mnt/Pool"
                "${pkgs.bash}/bin/bash -c 'echo sudo mount --bind /mnt/Pool /Pool"
            ];
            User = "root";  
        };










