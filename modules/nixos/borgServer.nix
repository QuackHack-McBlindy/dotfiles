{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : let 

    pubkey = import ./../../hosts/pubkeys.nix;

in { 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SERVICE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°  
# sudo chown borg:borg /backup
# sudo chmod 700 /backup

    services.openssh.settings = {
        AllowUsers = [ "borg" ];  
#        extraConfig = ''
#            Match User borg
#            ChrootDirectory /backup
#            ForceCommand internal-sftp
#        '';
    };
    
    users = {
        groups.borg = { };
        users.borg = {
            isNormalUser = true;
            isSystemUser = false;
            shell = pkgs.bash;
            home = "/backup";
            createHome = false;
            description = "borg Server";
            group = "borg";
           # extraGroups = [ "networkmanager" "wheel" "dialout" "docker" "dockeruser" ];
           # packages = with pkgs; [ ];
            openssh.authorizedKeys.keys = [
                pubkey.desktop
                pubkey.homie
                pubkey.nasty
            ];
        };  
    };
   
    # Set /backup Ownersihp and Permissions 
    system.activationScripts.backupPermissions = {
        text = ''
            mkdir -p /backup
            chown borg:borg /backup
            chmod 700 /backup
        '';
    };}
    
