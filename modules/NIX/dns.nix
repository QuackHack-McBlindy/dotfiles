
{
    config,
    pkgs,
    lib,
    ...
} : {
    # Add CA certificates package
    environment.systemPackages = [ pkgs.cacert ];
    # Trust system certificates
    security.pki.certificates = [
        (builtins.readFile "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt")
    ];

    services.unbound = {
        enable = true;
        settings = {
            remote-control.control-enable = true;
            server = {
                #  When only using Unbound as DNS, make sure to replace 127.0.0.1 with your ip address
                # When using Unbound in combination with pi-hole or Adguard, leave 127.0.0.1, and point Adguard to 127.0.0.1:PORT
                interface = [ "127.0.0.1" ]; #"::1"
                port = 5335;
                access-control = [ "127.0.0.1 allow" "192.168.1.0/24 allow" ];
                # Based on recommended settings in https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
                harden-glue = true;
                harden-dnssec-stripped = true;
                use-caps-for-id = false;
                prefetch = true;
                edns-buffer-size = 1232;
                hide-identity = true;
                hide-version = true;

                local-zone = [
                    "homie.lan static"
                    "nasty.lan static"
                    "desktop.lan static"
                    "laptop.lan static"
                ];
                local-data = [
                    "\"homie.lan 3600 IN A 192.168.1.211\""
                    "\"*.homie.lan 3600 IN A 192.168.1.211\""
                    "\"*.nasty.lan 3600 IN A 192.168.1.28\""
                    "\"*.desktop.lan 3600 IN A 192.168.1.111\""
                    "\"*.laptop.lan 3600 IN A 192.168.1.222\""
                ];
            };
            forward-zone = [
                {
                    name = ".";
                    forward-tls-upstream = "yes";
                    forward-addr = [
                        "1.1.1.1@853#cloudflare-dns.com"
                        "1.0.0.1@853#cloudflare-dns.com"
                    ];
                }
            ];
        };
    };



  #  services.stubby = {
#        enable = true;
#        settings = {
            # ::1 cause error, use 0::1 instead
 #           listen_addresses = [ "127.0.0.1@5300" "0::1@5300" ];
#            resolution_type = "GETDNS_RESOLUTION_STUB";
#            dns_transport_list = [ "GETDNS_TRANSPORT_TLS" ];
#            tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
#            tls_query_padding_blocksize = 128;
 #           idle_timeout = 10000;
 #           round_robin_upstreams = 1;
 #           tls_min_version = "GETDNS_TLS1_3";
  #          dnssec = "GETDNS_EXTENSION_TRUE";
  #          upstream_recursive_servers = [
 #               { address_data = "1.0.0.2"; tls_auth_name = "cloudflare-dns.com"; }
 #               { address_data = "9.9.9.9"; tls_auth_name = "dns.quad9.net"; }
 #           ];
 #       };
#    };

    services.adguardhome = {
        enable = true;
        host = "0.0.0.0";
        port = 3005;
        mutableSettings = true;
        openFirewall = true;
        settings = {
            http = {
                address = "127.0.0.1:3005";
            };
            dns = {
                bind_host = "0.0.0.0";
                bind_port = 53;
                upstream_dns = [ "127.0.0.1:5335" ];
                bootstrap_dns = [ "127.0.0.1:5335" ];
            };
            filtering = {
                protection_enabled = true;
                filtering_enabled = true;

                parental_enabled = false;
                safe_search.enabled = false;
            };
            filters = map(url: { enabled = true; url = url; }) [
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
                "https://raw.githubusercontent.com/lassekongo83/Frellwits-filter-lists/master/Frellwits-Swedish-Hosts-File.txt"
                "https://raw.githubusercontent.com/QuackHack-McBlindy/dotfiles/refs/heads/main/home/.blocklist.txt"
                "https://easylist.to/easylist/easylist.txt"  # Base filter
                "https://easylist.to/easylist/easyprivacy.txt"  # Privacy protection
                "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"  # Scam protection
                "https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/nocoin.txt"  # Cryptominers
                "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"  # Malware domains
            ];
        };
    };

    networking.firewall.allowedUDPPorts = [ 53 5335 ];
    networking.firewall.allowedTCPPorts = [ 53 5335 ];
    systemd.services.unbound.stopIfChanged = false;

    systemd.services.adguardhome.serviceConfig = {
        After = [ "network.target" "unbound.service" ];
        Requires = [ "unbound.service" ];

    };}
