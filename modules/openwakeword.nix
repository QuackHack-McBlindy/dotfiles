{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 

    networking.firewall.allowedTCPPorts = [ 10400 10500 10700 10555 ];
    environment.systemPackages = with pkgs; [ pkgs.wyoming-openwakeword ]; 

    services.wyoming.openwakeword = {
        enable = true;
        package = pkgs.wyoming-openwakeword;
        uri = "tcp://0.0.0.0:10400";
        preloadModels = [ "yo_bitch" ];
        customModelsDirectories = [ "/etc/openwakeword" ];
        threshold = 0.3;
        triggerLevel = 1;
        extraArgs = [ "--debug-probability" ];
        
    };}
