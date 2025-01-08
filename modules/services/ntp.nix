{ config, lib, ... }:

{
  services.ntp.enable = false;

  services.timesyncd = {
    enable = lib.mkDefault true;
    servers = [
      "0.se.pool.ntp.org"
      "1.se.pool.ntp.org"
      "2.se.pool.ntp.org"
      "3.se.pool.ntp.org"
    ];
  };
}

