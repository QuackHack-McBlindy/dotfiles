{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 
    services.ntfy-sh = {
       enable = true;
       settings = {
           base-url = "https://notfy.duckdns.org"; 
           listen-http = ":9913";
           behind-proxy = true;
           
           web-push-public-key = "BGxWiWgvfogQXS9Lz9diQe7G29jvuca0856U6Fb8m9NPUQj525BS62syNrBXUTFx4H32GQFomdVs0lHrHDIXD3U";
           web-push-private-key = config.sops.secrets.ntfy-private.path;
           web-push-file = "/var/lib/ntfy-sh/webpush.db";
           web-push-email-address = "example@mail.com";
           enable-web-push = true;
       };
    };   
       
    sops.secrets = {
        ntfy-private = {
            sopsFile = ./../../secrets/ntfy-private.yaml;
            owner = "ntfy-sh";
            group = "ntfy-sh";
            mode = "0440"; # Read-only for owner and group
        };

    };}
    
