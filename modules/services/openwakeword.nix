{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ pkgs.wyoming-openwakeword ]; 
  
  services.wyoming.openwakeword = {
    #enable = true;
    package = pkgs.wyoming-openwakeword;
    uri = "tcp://0.0.0.0:10400";
    customModelsDirectories = [ "/home/pungkula/dotfiles/home/.config/openwakeword/yo_bitch.tflite" ];
   # preloadModels = [ "yo_bitch" ];
    threshold = 0.7;
    triggerLevel = 1;
    extraArgs = [ ];
  };
}
