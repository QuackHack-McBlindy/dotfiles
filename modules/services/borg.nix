{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : let 
    pubkey = import ./../../hosts/pubkeys.nix;
in { 
    config = lib.mkIf (lib.elem "borg" config.this.host.modules.services) {
        services.borgbackup.repos.backups = {
            user = "borg";
            quota = "1000G";
            path = "/backup/backups";
            authorizedKeys = [ pubkey.borg ];
            allowSubRepos = true;
        };    

        services.openssh.settings = {
            AllowUsers = [ "borg" ];  
            KbdInteractiveAuthentication = false;
        };
    
        users = {
            groups.borg = { };
            users.borg = {
                isNormalUser = lib.mkForce true;
                isSystemUser = lib.mkForce false;
                shell = pkgs.bash;
                home = "/backup";
                createHome = false;
                description = "borg Server";
                group = "borg";
            };  
        };
    };}    
    
