{ config, lib, ... }:

{
  services.ntp.enable = false;

  services.timesyncd = {
    enable = lib.mkDefault true;
    servers = [
      "0.de.pool.ntp.org"
      "1.de.pool.ntp.org"
      "2.de.pool.ntp.org"
      "3.de.pool.ntp.org"
    ];
  };
}

