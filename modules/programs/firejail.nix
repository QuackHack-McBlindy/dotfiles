# dotfiles/modules/programs/firejail.nix
{
  config,
  self,
  lib,
  pkgs,
  ...
} : let
  cfg = config.this.host.modules.programs;

  firefoxIcon = "${self}/modules/themes/icons/firefox.png";

  torfoxDesktopEntry = pkgs.writeText "torfox.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Firefox (Tor)
    Comment=Firefox running over Tor
    Exec=torfox %u
    Icon=${firefoxIcon}
    Terminal=false
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;
  '';

in {
  config = lib.mkIf (lib.elem "firefox" cfg) {

    programs.firejail = {
      enable = true;
      wrappedBinaries = {
        torfox = {
          executable = "${pkgs.firefox-esr}/bin/firefox-esr";
          profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
          desktop = torfoxDesktopEntry;
          extraArgs = [
            "--ignore=private-dev"
            "--env=GTK_THEME=Adwaita:dark"
            "--dbus-user.talk=org.freedesktop.Notifications"
            "--net=tornet"
            "--dns=46.182.19.48"
          ];
        };
      };
    };


    #file.".config/firejail/firefox.local" =
    #  lib.concatStringsSep "\n" (lib.splitString "\n" (builtins.readFile localProfile)) + "\n";

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
        ruleset = ''
          table ip nat {
            chain PREROUTING {
              type nat hook prerouting priority dstnat; policy accept;
              iifname "tornet" meta l4proto tcp dnat to 127.0.0.1:9040
              iifname "tornet" udp dport 53 dnat to 127.0.0.1:5353
            }
          }
        '';
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



  };}
