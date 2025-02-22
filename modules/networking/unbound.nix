# unbound

{
  services.unbound = {
    enable = true;
    settings = {
      server = {
       #  When only using Unbound as DNS, make sure to replace 127.0.0.1 with your ip address
        # When using Unbound in combination with pi-hole or Adguard, leave 127.0.0.1, and point Adguard to 127.0.0.1:PORT
        interface = [ "127.0.0.1" "192.168.1.211" "0.0.0.0" ];
        port = 5335;
        access-control = [ "127.0.0.1 allow" "192.168.1.0/24 allow" ]; 
        # Based on recommended settings in https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
        harden-glue = true;
        harden-dnssec-stripped = true;
        use-caps-for-id = false;
        prefetch = true;
        edns-buffer-size = 1232;

        # Custom settings
        hide-identity = true;
        hide-version = true;
      };
      forward-zone = [
        # Example config with quad9
        {
          name = ".";
          forward-addr = [
            "9.9.9.9#dns.quad9.net"
            "149.112.112.112#dns.quad9.net"
          ];
          forward-tls-upstream = true;  # Protected DNS
        }
      ];
    };
  };

  systemd.services.unbound.stopIfChanged = false;
}


