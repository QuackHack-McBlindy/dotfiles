{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : {
  config = lib.mkIf (lib.elem "bitch" config.this.host.modules.services) {

    networking.firewall.allowedTCPPorts = [ 10300 10400 10500 10700 10555 ];

    environment.systemPackages = with pkgs; [ pkgs.wyoming-faster-whisper pkgs.wyoming-openwakeword ]; 
  
    services.wyoming.faster-whisper = {
      package = pkgs.wyoming-faster-whisper;
      servers = {
        "whisper" = {
          enable = true;
          model = "small-int8";
          language = "sv";
          beamSize = 1;
          uri = "tcp://0.0.0.0:10300";
          device = "cpu";
          extraArgs = [ ];
        };
      };
    };

    services.wyoming.openwakeword = {
        enable = true;
        package = pkgs.wyoming-openwakeword;
        uri = "tcp://0.0.0.0:10400";
        preloadModels = [ "yo_bitch" ];
        customModelsDirectories = [ "/etc/openwakeword" ];
        threshold = 0.3;
        triggerLevel = 1;
        extraArgs = [ "--debug-probability" ];
        
    };
  };}  
