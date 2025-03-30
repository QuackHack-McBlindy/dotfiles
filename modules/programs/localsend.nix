{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : in
    localsend = {
        ip = "127.0.0.1";  
        port = 53317;      
    };
let { 
    networking.firewall.allowedTCPPorts = [ localsend.port ];

    programs.localsend = {
        enable = true;
        openFirewall = true;    
    };
        
    services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        virtualHosts = {
            "send" = {
                locations."/".proxyPass = "http://${localsend.ip}:${toString localsend.port}";
            };
        };
    };

    };}
