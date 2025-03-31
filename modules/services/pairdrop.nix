{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 

    imports = [ ./pairdropModule.nix ];
    services.pairdrop = {
        enable = true;
        port = 3000;
        openFirewall = true;
        extraEnv = {
            NODE_ENV = "production";
        };
    };
    
    services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        virtualHosts = {
            "send" = {
                locations."/".proxyPass = "http://127.0.0.1:3000";
            };
        };

    };}
