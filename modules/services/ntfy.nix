{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 
    services.ntfy-sh = {
       enable = true;
       settings = {
           base-url = "https://pungkula.duckdns.org"; 
           listen-http = ":5060";
           behind-proxy = true;
           
           web-push-public-key = "BGxWiWgvfogQXS9Lz9diQe7G29jvuca0856U6Fb8m9NPUQj525BS62syNrBXUTFx4H32GQFomdVs0lHrHDIXD3U";
           web-push-private-key = config.sops.secrets.ntfy-private.path;
           web-push-file = "/var/cache/ntfy/webpush.db";
       };
    };   
       
    sops.secrets = {
        ntfy-private = {
            sopsFile = "/var/lib/sops-nix/secrets/ntfy-private.yaml";
            owner = config.users.users.secretservice.name;
            group = config.users.groups.secretservice.name;
            mode = "0440"; # Read-only for owner and group
        };

    };}
