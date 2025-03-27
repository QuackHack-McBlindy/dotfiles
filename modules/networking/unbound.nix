{ config, pkgs, ... }:

{
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "127.0.0.1@5335" ];
        access-control = [ "127.0.0.1/32 allow" ];
        local-zone = [
          ''"home.lan." static''
          ''"1.168.192.in-addr.arpa." static''
        ];
        local-data = [
          ''"router.home.lan. IN A 192.168.1.1"''
          ''"nas.home.lan. IN A 192.168.1.100"''
          ''"1.1.168.192.in-addr.arpa. IN PTR router.home.lan."''
          ''"100.1.168.192.in-addr.arpa. IN PTR nas.home.lan."''
        ];
      };
      forward-zone = {
        name = ".";
        forward-tls-upstream = "yes";
        forward-addr = [
          "1.1.1.1@853#cloudflare-dns.com"
          "9.9.9.9@853#dns.quad9.net"
        ];
      };
    };
  };

  services.adguardhome = {
    enable = true;
    settings = {
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
        upstream_dns = [ "127.0.0.1:5335" ];
        bootstrap_dns = [ "1.1.1.1" "9.9.9.9" ];
        rewrites = [
          {
            domain = "router.home.lan";
            answer = "192.168.1.1";
          }
          {
            domain = "nas.home.lan";
            answer = "192.168.1.100";
          }
        ];
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
          name = "AdGuard DNS Filter";
          id = 1;
        }
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          name = "StevenBlack Unified";
          id = 2;
        }
      ];
    };
  };

  # Required for AdGuardHome to bind to privileged port
  systemd.services.adguardhome.serviceConfig = {
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
  };

  # Ensure Unbound starts before AdGuardHome
  systemd.services.adguardhome.after = [ "unbound.service" ];
  systemd.services.adguardhome.requires = [ "unbound.service" ];

  networking.firewall = {
    allowedTCPPorts = [ 53 80 443 ]; # DNS + AdGuard web interface
    allowedUDPPorts = [ 53 ];
  };

  # Optional: Set as default DNS resolver
  networking.nameservers = [ "127.0.0.1" ];
}
