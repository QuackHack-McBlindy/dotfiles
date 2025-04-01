{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : let 
    pubkey = import ./pubkeys.nix;
in { 
# MANUALLY INITZIATE WITH:
# borg init --encryption=repokey-blake2 ssh://borg@nasty:2222/./${HOSTNAME}

    services.borgbackup.jobs = {
        backupJob = {
            paths = "/";
            exclude = [ 
                "/nix"             # Nix store (reproducible from nix expressions)
                "/borg"            # Backup repository itself (prevents recursion)
                "/backup"
                "/Pool"            # Custom directory (check if needed)
                "/Files"           # Custom directory (check if needed)
                "/proc"            # Virtual filesystem (kernel-related, no real files)
                "/sys"             # System information, dynamically generated
                "/dev"             # Device files, not needed in backups
                "/run"             # Runtime data (sockets, temp files)
                "/tmp"             # Temporary files, not needed in long-term backups
                "/var/tmp"         # Another temporary storage location
                "/var/lib/docker"  # Docker container data (backup separately if needed)
                "/var/cache"       # Cached data (can be regenerated)
                "/var/log"         # Logs (backup separately if needed)
                "/mnt"             # Mounted external storage (ensure you want this excluded)
                "/media"           # Removable media
                "/swapfile"        # Swap file (not useful in backups)
                "/mnt"
            ];
            repo = "borg@nasty:./${config.networking.hostName}";
            doInit = false;
            encryption = {
                mode = "repokey-blake2";
                passCommand = "cat /run/secrets/borg";
            };
            
            prune = {
                keep = {
                    daily = 7;  
                    weekly = 4;
                    monthly = 12;
                };
            };    
            compression = "auto,zstd";
            startAt = "weekly";
            
            environment = {
                BORG_RSH = "ssh -p 2222 -o StrictHostKeyChecking=yes";
            };
            
            preHook = ''
                echo "=== Starting backup of $HOSTNAME ==="
            '';
    
            postHook = ''
                echo "=== Finished backup of $HOSTNAME ==="
            '';
        };
    };

    sops.secrets = {
        borg = {
            sopsFile = ./../secrets/borg.yaml;
            owner = "root";
            group = "root";
            mode = "0440"; 
        };

    };}
