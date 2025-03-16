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
      #  Match User borg
      #  ChrootDirectory /backup
      #  ForceCommand internal-sftp
      #  X11Forwarding no
      #  AllowTCPForwarding no
    };
    
    users = {
        groups.borg = { };
        users.borg = {
            isNormalUser = true;
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
    };}
