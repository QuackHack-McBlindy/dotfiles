{
  config,
  self,
  lib,
  pkgs,
  ...
} : let
in {
    config = lib.mkIf (lib.elem "mumble" config.this.host.modules.services) {
        environment.systemPackages = [ pkgs.mumble ];
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };

        services.pipewire.extraConfig.pipewire."97-null-sink" = {
          "context.objects" = [
            {
              factory = "adapter";
              args = {
                "factory.name" = "support.null-audio-sink";
                "node.name" = "Null-Sink";
                "node.description" = "Null Sink";
                "media.class" = "Audio/Sink";
                "audio.position" = "FL,FR";
              };
            }
            {
              factory = "adapter";
              args = {
                "factory.name" = "support.null-audio-sink";
                "node.name" = "Null-Source";
                "node.description" = "Null Source";
                "media.class" = "Audio/Source";
                "audio.position" = "FL,FR";
              };
            }
          ];
        };
        services.pipewire.extraConfig.pipewire."98-virtual-mic" = {
          "context.modules" = [
            {
              name = "libpipewire-module-loopback";
              args = {
                "audio.position" = "FL,FR";
                "node.description" = "Mumble as Microphone";
                "capture.props" = {
                  "node.target" = "Mumble";
                  "node.passive" = true;
                };
                "playback.props" = {
                  "node.name" = "Virtual-Mumble-Microphone";
                  "media.class" = "Audio/Source";
                };
              };
            }
          ];
        };
  
        services.murmur = {
          enable = true;
          bandwidth = 540000;
          bonjour = true;
          password = "choose_your_own_password";
          autobanTime = 0;
        };
        networking.firewall.allowedTCPPorts = [
          64738
        ];
        networking.firewall.allowedUDPPorts = [
          64738
        ];
    };}    

