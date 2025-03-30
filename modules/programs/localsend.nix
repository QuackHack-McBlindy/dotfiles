{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 

    programs.localsend = {
        enable = true;
        openFirewall = true;    
    };}
