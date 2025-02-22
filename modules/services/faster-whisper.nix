{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 10300 ];

  environment.systemPackages = with pkgs; [ pkgs.wyoming-faster-whisper ]; 
  
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
}
