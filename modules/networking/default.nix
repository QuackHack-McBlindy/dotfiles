# dotfiles/modules/networking/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 say ⮞ default networking
  config,
  self,
  lib,
  hosts,
  devices,
  ...
} : let

    designatedDNSHost = builtins.attrValues (
        lib.mapAttrs (_: cfg: cfg.config.this.host.ip) (
            lib.filterAttrs (_: cfg:
                lib.elem "dns" (cfg.config.this.host.modules.networking or [])
            ) self.nixosConfigurations
        )
    );

    currentInterface = "${builtins.elemAt config.this.host.interface 0}";
    currentIp = "${config.this.host.ip}";
    currentHost = "${config.this.host.hostname}";

    defaultNetworking = {
        boot.kernel.sysctl = {
          "net.ipv4.conf.tornet.route_localnet" = 1;
        };
        services.resolved = {
            enable = false;
            domains = [ "~." ];
            fallbackDns = [ ]; # Empty to prevent bypass
            dnsovertls = "true";

            # github.com/systemd/systemd/issues/10579
            # dnssec = "allow-downgrade";
            dnssec = "false";
        };

        networking = {
            networkmanager = {
                enable = true;
                dns = lib.mkDefault "none";

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

            hosts = {
                "192.168.1.1" = [ "router.lan" "router.local" "router" ];
                # 🦆 say ⮞ NixOS hosts
                "${hosts.desktop.ip}"          = [ "desktop.lan" "desktop.local" "desktop" "vaultwarden.local" ];
                "${hosts.homie.ip}"            = [ "homie.lan" "homie.local" "homie" "cache" ];
                "${hosts.laptop.ip}"           = [ "laptop.lan" "laptop.local" "laptop" ];
                "${hosts.nasty.ip}"            = [ "nasty.lan" "nasty.local" "nasty" ];
                "${hosts.pinephone.ip}"        = [ "pinephone.lan" "pinephone.local" "pinephone" "phone" ];
                # 🦆 say ⮞ OTHER devices
                "${devices.iphone.ip}"         = [ "iphone.lan" "iphone.local" "iphone" ];
                "${devices.ESP32-S3-BOX-3.ip}" = [ "box.lan" "box.local" "box" ];
                "${devices.watch.ip}"          = [ "watch.lan" "watch.local" "watch" ];
                "${devices.shield.ip}"         = [ "shield.lan" "shield.local" "shield" ];
                #"$devices.arris.ip}"          = [ "arris.lan" "arris.local" "arris" ];
                "${devices.hue-bridge.ip}"     = [ "hue-bridge.lan" "hue-bridge.local" "hue-bridge" ];
                "${devices.hue-sync.ip}"       = [ "hue-sync.lan" "hue-sync.local" "hue-sync" ];
            };

            defaultGateway = {
                address = "192.168.1.1";
                interface = currentInterface;
                metric = 15;
            };

            interfaces = {
                ${currentInterface} = {
                    useDHCP = true;
                    ipv4 = {
                        addresses = [{
                            address = currentIp;
                            prefixLength = 24;
                        }];
                        routes = [
                            {
                                address = "0.0.0.0";
                                prefixLength = 0;
                                via = "192.168.1.1";
                            }
                            {
                                address = "192.168.1.0";
                                prefixLength = 24;
                            }
                        ];
                    };
                };
            };

            nameservers =
                if builtins.elem "dns" (config.this.host.modules.networking or [])
                then [ "127.0.0.1" ]
                else designatedDNSHost;
            firewall = {
                enable = true;
                logRefusedConnections = true;
                allowedUDPPorts =
                    if builtins.elem "wg-server" (config.this.host.modules.networking or [])
                    then [51820]
                    else  [6222 5353 443 53];
                allowedTCPPorts = [6262 9040 443 53];
            };
            resolvconf = {
                useLocalResolver = false;
            };
            dhcpcd.extraConfig = "nohook resolv.conf";
        };
    };

  wirelessNetworking = lib.mkIf (!config.this.installer) {
    networking.networkmanager.enable = lib.mkForce false;

    networking.wireless = {
      enable = lib.mkForce false;
      iwd.enable = true;
    };

  };

in {
    config = lib.mkMerge [
        (lib.mkIf (lib.elem "default" config.this.host.modules.networking) defaultNetworking)

        (lib.mkIf (lib.elem "wireless" config.this.host.modules.networking) (lib.mkMerge [
            #defaultNetworking
            wirelessNetworking
        ]))

    ];}
