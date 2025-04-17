{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : let 
    pubkey = import ./pubkeys.nix;
    
    keyConfig = ''
        "@SSHKEY@"
    '';

    ed25519File = 
        pkgs.runCommand "ed25519File"
            { preferLocalBuild = true; }
            ''
                cat > $out <<EOF
${keyConfig}
EOF
            '';
in { 
    config = lib.mkIf (lib.elem "backup" config.this.host.modules.services) {
        services.borgbackup.jobs = {
            backupJob = {
                paths = "/";
                exclude = [ 
                    "/nix"            
                    "/borg"        
                    "/backup"
                    "/Pool"       
                    "/Files"   
                    "/proc"          
                    "/sys"      
                    "/dev"             
                    "/run"             
                    "/tmp"             
                    "/var/tmp"         
                    "/var/lib/docker"  
                    "/var/cache"       
                    "/var/log"         
                    "/mnt"             
                    "/media"           
                    "/swapfile"        
                    "/mnt"
                ];
                repo = "ssh://borg@nasty:2222/backup/backups/${config.networking.hostName}";
                doInit = true;
                encryption = {
                    mode = "repokey-blake2";
                    passCommand = "cat /run/secrets/borg";
                };
            
                prune = {
                    keep = {
                        within = "1d"; # Keep all archives from the last day
                        daily = 7;
                        weekly = 4;
                        monthly = -1;  # Keep at least one archive for each month
                    };
                };    
                compression = "auto,zstd";
                startAt = "weekly";
            
                environment = {
                    BORG_RSH = "ssh -i /run/keys/id_ed25519";
                };
            
                preHook = ''
                    echo "=== Starting backup of $HOSTNAME ==="
                '';
    
                postHook = ''
                    echo "=== Finished backup of $HOSTNAME ==="
                '';
            };
        };

        systemd.services.borg_config = {
            wantedBy = [ "multi-user.target" ];
            preStart = ''
                sed -e "/@SSHKEY@/{
                    r ${config.sops.secrets.borg_ed25519.path}
                    d
                }" ${ed25519File} > /run/keys/id_ed25519           
                chmod 600 /run/keys/id_ed25519
            '';
    
            serviceConfig = {
                ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
                Restart = "on-failure";
                RestartSec = "2s";
                RuntimeDirectory = [ "root" ];
                User = "root";
            };
        };

        sops.secrets = {
            borg = {
                sopsFile = ./../../secrets/borg.yaml;
                owner = "root";
                group = "root";
                mode = "0440"; 
            };
            borg_ed25519 = {
                sopsFile = ./../../secrets/borg_ed25519.yaml;
                owner = "root";
                group = "root";
                mode = "0440"; 
            };
        };
        
    };}
