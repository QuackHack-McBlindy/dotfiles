
{

    services.mako = {
        enable = true;
        package = "pkgs.makoctl";

        actions = {        
            echo hej
        };
        extraConfig = {
            [urgency=low]
            border-color=#b8bb26
        };    
    };
}
