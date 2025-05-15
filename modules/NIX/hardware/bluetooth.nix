{
  config,
  options,
  lib,
  pkgs,
  ...
}


    services.blueman.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        ControllerMode = "bredr";
        Experimental = true;
      };
    };

    systemd.user.services.mpris-proxy = {
      description = "mpris-proxy -> bluetooth (media) ctrl";
      after = ["network.target" "sound.target"];
      wantedBy = ["default.target"];
      serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };
  };
}
