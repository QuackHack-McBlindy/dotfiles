{ config, pkgs, ... }:

{
  services.wyoming.openwakeword = {
    #enable = true;
    package = pkgs.wyoming-openwakeword;
    uri = "tcp://0.0.0.0:10400";
    customModelsDirectories = [ "/home/pungkula/models/yo_bitch.tflite" ];
   # preloadModels = [ "yo_bitch" ];
    threshold = 0.7;
    triggerLevel = 1;
    extraArgs = [ ];
  };
}
