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
           listen-http = ":443";
       };
    };}
