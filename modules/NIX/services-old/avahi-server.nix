{ config, ... }:

{
  # discover services on other systems
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
    };
  };
}

