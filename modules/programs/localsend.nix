{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : let
    pairdrop = {
        ip = "127.0.0.1";  
        port = 3000;      
    };
in { 
    environment.systemPackages = [ pkgs.pairdrop ];
    networking.firewall.allowedTCPPorts = [ pairdrop.port ];
 
    services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        virtualHosts = {
            "send" = {
                locations."/".proxyPass = "http://${pairdrop.ip}:${toString pairdrop.port}";
            };
        };

    };}
