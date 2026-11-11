# dotfiles/modules/posts/tor-in-a-shell.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 ⮞ nuthin' to see here... (just some html generation)
  lib,
  config,
  ...
} : {

  blog = {
    enable = true;
    posts.tor-in-a-shell = {
      filename    = "tor-in-a-shell.html";
      title       = "Tor in a Shell";
      date        = "2025-01-01";
      tags        = [ "tor" "privacy" "nixos" ];
      tagline     = "Every other Tor setup asks you to point something at something. This one asks you to type <code>hide</code>.";

      header1 = "Tor";
      header2 = "in a Shell";
      eyebrow = "Firejail · nftables · NetworkManager";

      text = ''
        Every other Tor setup asks you to point something at something.
        This one asks you to type <code>hide</code>.

        ## The bridge

        A NetworkManager bridge called <code>tornet</code> at
        <code>10.100.100.1/24</code>.<br><br>

        After setup, go ahead and open up your terminal and run `curl icanhazip.com`, the first thing you will notice is the decreased speed, and that you are now under Tor.
      '';

      sections = [
        {
          code = {
            title = "networking/tor.nix";
            content = ''
              programs.firejail = {
                enable = true;
              };

              services.tor = {
                enable = true;
                openFirewall = true;
                settings = {
                  TransPort = [ 9040 ];
                  DNSPort = 5353;
                  VirtualAddrNetworkIPv4 = "172.30.0.0/16";
                };
              };

              networking = {
                networkmanager = {
                  enable = true;
                  ensureProfiles.profiles = {
                    tornet = {
                      connection = {
                        id = "tornet";
                        type = "bridge";
                        interface-name = "tornet";
                        autoconnect = true;
                      };
                      bridge = {
                        stp = false;
                      };
                      ipv4 = {
                        method = "manual";
                        address1 = "10.100.100.1/24";
                      };
                      ipv6 = {
                        method = "disabled";
                      };
                    };
                  };
                };

                nftables = {
                  enable = true;
                  ruleset = '''
                    table ip nat {
                      chain PREROUTING {
                        type nat hook prerouting priority dstnat; policy accept;
                        iifname "tornet" meta l4proto tcp dnat to 127.0.0.1:9040
                        iifname "tornet" udp dport 53 dnat to 127.0.0.1:5353
                      }
                    }
                  ''';
                };

                nat = {
                  internalInterfaces = [ "tornet" ];
                  forwardPorts = [
                    {
                      destination = "127.0.0.1:5353";
                      proto = "udp";
                      sourcePort = 53;
                    }
                  ];
                };

                firewall = {
                  enable = true;
                  interfaces.tornet = {
                    allowedTCPPorts = [ 9040 ];
                    allowedUDPPorts = [ 5353 ];
                  };
                };
              };

              boot.kernel.sysctl = {
                "net.ipv4.conf.tornet.route_localnet" = 1;
              };

              programs.bash = {
                shellAliases = {
                  hide = "firejail --net=tornet bash";
                };
              };
            '';
          };
        }
      ];


      quote = "The network is unchanged. <strong>What changed is the ceremony.</strong>";
    };

  };}
