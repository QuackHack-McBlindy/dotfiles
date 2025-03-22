{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : let 
    cacheKeyPublic = config.sops.secrets.nixcache_public_desktop.path;
in { 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SERVICE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°  
    nix.settings.trusted-public-keys = [ cacheKeyPublic ];

    services.nix-serve = {
        enable = true;
        port = 10000; 
        secretKeyFile = "/etc/nix/private-key.pem";
    };

    system.activationScripts.sshConfig = {
        text = ''
            mkdir -p /etc/nix
            cat ${config.sops.secrets.nixcache_private_desktop.path} > /etc/nix/private-key.pem
        '';
    };    

    sops.secrets = { 
        nixcache_public_desktop = {
            sopsFile = ./../../secrets/nixcache_public_desktop.yaml; 
            owner = config.users.groups.secretservice.name;
            group = config.users.groups.secretservice.name;
            mode = "0440"; 
        };    
        nixcache_private_desktop = {
            sopsFile = ./../../secrets/nixcache_private_desktop.yaml; 
            owner = config.users.groups.secretservice.name;
            group = config.users.groups.secretservice.name;
            mode = "0440"; 
        };  
    };}
    
