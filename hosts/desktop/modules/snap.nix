{ config, pkgs, ... }:

{

    services.snapserver = {
      enable = true;
      codec = "flac";
      streams = {
        pipewire  = {
          type = "pipe";
          location = "/run/snapserver/pipewire";
        };
      };
    };

    systemd.user.services.snapcast-sink = {
      wantedBy = [
        "pipewire.service"
      ];
      after = [
        "pipewire.service"
      ];
      bindsTo = [
        "pipewire.service"
     ];
      path = with pkgs; [
        gawk
        pulseaudio
      ];
      script = ''
        pactl load-module module-pipe-sink file=/run/snapserver/pipewire sink_name=Snapcast format=s16le rate=48000
      '';
    };
  
    security.rtkit.enable = true;
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    
    # playback
    systemd.user.services.snapclient-local = {
      wantedBy = [
        "pipewire.service"
      ];
      after = [
        "pipewire.service"
      ];
      serviceConfig = {
       ExecStart = "${pkgs.snapcast}/bin/snapclient -h ::1";
      };
    };
}
