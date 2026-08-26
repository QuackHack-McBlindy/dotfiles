# dotfiles/modules/programs/firejail.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ anon 🦊
  config,
  self,
  lib,
  pkgs,
  ...  
} : let
  cfg = config.this.host.modules.programs;
in {
  # 🦆 duck say ⮞ enabled by exposing `"firefox"` in `this.host.modules.programs`
  config = lib.mkIf (lib.elem "firefox" cfg) {
    programs.firejail = {
      enable = true;
      wrappedBinaries = {
        firefox = {
          executable = "${pkgs.firefox-esr}/bin/firefox-esr";
          profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
          extraArgs = [
            "--ignore=private-dev"
            "--env=GTK_THEME=Adwaita:dark"
            "--dbus-user.talk=org.freedesktop.Notifications"
          ];
        };  
      };
    };

    # firejail --net=tornet --dns=46.182.19.48 --profile=$(nix --extra-experimental-features nix-command --extra-experimental-features flakes eval -f '<nixpkgs>' --raw 'firejail')/etc/firejail/firefox.profile firefox
#    services.tor = {
#      enable = true;
#      openFirewall = true;
#      settings = {
#        TransPort = [ 9040 ];
#        DNSPort = 5353;
#        VirtualAddrNetworkIPv4 = "172.30.0.0/16";
#      };
#    };
    
#    networking = {
#      useNetworkd = true;
#      bridges."tornet".interfaces = [];
#      nftables = {
#        enable = true;
#        ruleset = ''
#          table ip nat {
#            chain PREROUTING {
#              type nat hook prerouting priority dstnat; policy accept;
#              iifname "tornet" meta l4proto tcp dnat to 127.0.0.1:9040
#              iifname "tornet" udp dport 53 dnat to 127.0.0.1:5353
#            }
#          }
#        '';
#      };
#      nat = {
#        internalInterfaces = [ "tornet " ];
#        forwardPorts = [
#          {
#            destination = "127.0.0.1:5353";
#            proto = "udp";
#            sourcePort = 53;
#          }
#        ];
#      };
#      firewall = {
#        enable = true;
#        interfaces.tornet = {
#          allowedTCPPorts = [ 9040 ];
#          allowedUDPPorts = [ 5353 ];
#        };
#      };
#    };
    
#    systemd.network = {
#      enable = true;
#      networks.tornet = {
#        matchConfig.Name = "tornet";
#        DHCP = "no";
#        networkConfig = {
#          ConfigureWithoutCarrier = true;
#          Address = "10.100.100.1/24";
#        };
#        linkConfig.ActivationPolicy = "always-up";
#      };
#    };
    
#    boot.kernel.sysctl = {
#      "net.ipv4.conf.tornet.route_localnet" = 1;
#    };
    
    


  };}

