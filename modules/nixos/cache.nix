{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 
#°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°°•°
#°✶.•°••─→ SERVICE ←──  •°•.✶°°✶.•°•.•°•.•°•.✶°°✶.•°•.•°•.•°•.✶°  
    nix.settings.trusted-public-keys = [ "cache-1:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=" ];

    services.nix-serve = {
        enable = true;
        port = 10000; 
        secretKeyFile = "/etc/nix/private-key.pem";
    };

    services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        virtualHosts = {
            "cache" = {
                locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
            };
        };
    };

    system.activationScripts.sshConfig = {
        text = ''
            mkdir -p /etc/nix
            cat ${config.sops.secrets.nix_cache_private_key.path} > /etc/nix/private-key.pem
            cat ${config.sops.secrets.nix_cache_public_key.path} > /etc/nix/public-key.pem
        '';
    };    

    sops.secrets = { 
        nix_cache_public_key = {
            sopsFile = ./../../secrets/nixcache_public_desktop.yaml; 
            owner = "pungkula";
            group = "pungkula";
            mode = "0440"; 
        };    
        nix_cache_private_key = {
            sopsFile = ./../../secrets/nixcache_private_desktop.yaml; 
            owner = "pungkula";
            group = "pungkula";
            mode = "0440"; 
        };  
    };}
    
