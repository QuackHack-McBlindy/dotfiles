{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : let 
    pubkey = ./pubkeys.nix;
in { 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SERVICE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°  
    sops.secrets = {
        borg = {
            sopsFile = ./../secrets/borg.yaml;
            owner = config.users.users.secretservice.name;
            group = config.users.groups.secretservice.name;
            mode = "0440"; # Read-only for owner and group;
        };
    };

    services.borgbackup.repos = {
        desktop = {
            authorizedKeys = [
               pubkey.desktop
            ];
            path = "/backup/desktop";
        };
        homie = {
            authorizedKeys = [
               pubkey.homie
            ];
            path = "/backup/homie";
        };
        nasty = {
            authorizedKeys = [
               pubkey.nasty
            ];
            path = "/backup/nasty";
        };
    };

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
            repo = "borg@nasty:/backup/${config.networking.hostName}";
            doInit = true;
            encryption = {
                mode = "repokey";
                passphrase = config.sops.secrets.borg.path;
            };
            prune = {
                keep = {
                    daily = 7;  
                };
            };    
            compression = "auto,lzma";
            startAt = "weekly";
        };

    };}
