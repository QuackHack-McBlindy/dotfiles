{ config, pkgs, ... }:

{
  services.wyoming.satellite = {
    enable = true;
    package = pkgs.wyoming-satellite;
    user = "pungkula";
    group = "users";
    uri = "tcp://0.0.0.0:10700";
    name = "desktop";
    area = "vardagsrum";
    microphone = {
      command = "arecord -r 16000 -c 1 -f S16_LE -t raw";
      autoGain = 10;
      noiseSuppression = 1;
    };
    sound = {
      command = "aplay -r 22050 -c 1 -f S16_LE -t raw";
    };
    sounds = {
      awake = "/pungkula/.config/wyoming/sounds/awake.wav";
      done = "/pungkula/.config/wyoming/sounds/done.wav";
    };
    vad = {
      enable = true;
    };
  #  extraArgs = [ "--some-extra-arg" ];
  };
}
