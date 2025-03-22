{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : let 

    TextToBeWritten = ''
      here goes text
    '';

    TextFile = pkgs.writeTextFile {
        name = "TextFile";
        text = TextToBeWritten;
    };

    cacheKeyPublic =  config.sops.secrets.nixcache_public.path;
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
            cp ${TextFile} /etc/nix/private-key.pem
        '';
    };    

    sops.secrets = {
        nixcache_public = {
            sopsFile = ./../../secrets/nixcache_public_desktop.yaml; 
            owner = "pungkula";
            group = "pungkula";
            mode = "0440"; 
        };    
        nixcache_private = {
            sopsFile = ./../../secrets/nixcache_private_desktop.yaml; 
            owner = "pungkula";
            group = "pungkula";
            mode = "0440"; 
        };  
    };}
    
    
    
    
    
    
    
    



