{ config, pkgs, ... }:

{
  services.wyoming.piper = {
    package = pkgs.wyoming-piper;
    servers = {
      "piper" = {
        enable = true;
        piper = pkgs.piper-tts;
        voice = "sv_SE-nst-medium";
        uri = "tcp://0.0.0.0:10200";
        speaker = 0;
        noiseScale = 0.667;
        noiseWidth = 0.333;
        lengthScale = 1.0;
        extraArgs = [ ];
      };
    };
  };

}
