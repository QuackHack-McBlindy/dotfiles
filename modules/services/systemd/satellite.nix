{ config, pkgs, lib, ... }:

let
  user = "pungkula";
  group = "pungkula";
in
{
  options.services.wyoming-satellite = {
    enable = lib.mkEnableOption "Wyoming Satellite voice service";
  };

  config = lib.mkIf config.services.wyoming-satellite.enable {

    # Ensure dependencies are installed
    environment.systemPackages = with pkgs; [ wyoming-satellite alsa-utils ];

    systemd.services.wyoming-satellite = {
      description = "Wyoming Satellite Voice Service";
      after = [ "network.target" "sound.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.wyoming-satellite}/bin/wyoming-satellite \
            --uri tcp://localhost:10500 \
            --area LivingRoom \
            --mic-command "arecord -r 16000 -c 1 -f S16_LE -t raw" \
            --snd-command "aplay -r 22050 -c 1 -f S16_LE -t raw" \
            --awake-wav /home/pungkula/dotfiles/home/sounds/awake.wav \
            --done-wav /home/pungkula/dotfiles/home/sounds/done.wav \
            --vad
        '';

        User = user;
        Group = group;
        Restart = "always";
        RestartSec = 5;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ 10500 ];
  };
}
