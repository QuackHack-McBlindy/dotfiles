{ 
  config,
  lib,
  ...
} : let
    pubkey = import ./../../hosts/pubkeys.nix;
    mobileDevices = [ "iphone" "tablet" ];

    hosts = [ "desktop" "homie" "nasty" "laptop" "phone" "watch" "iphone" "tablet" ];
    hostsList = [
        { name = "homie";   wgip = "10.0.0.1";   ip = "192.168.1.211"; face = "eno1"; }
        { name = "desktop"; wgip = "10.0.0.2";   ip = "192.168.1.111"; face = "enp119s0"; }
        { name = "laptop";  wgip = "10.0.0.3";   ip = "192.168.1.222"; face = "wlan0"; }
        { name = "nasty";   wgip = "10.0.0.4";   ip = "192.168.1.28";  face = "enp3s0"; }
        { name = "phone";   wgip = "10.0.0.5"; }
        { name = "watch";   wgip = "10.0.0.6"; }
        { name = "iphone";  wgip = "10.0.0.7"; }
        { name = "tablet";  wgip = "10.0.0.8"; }
    ];
    host = {
        wgip = lib.listToAttrs (map (h: { name = h.name; value = h.wgip; }) hostsList);
        ip   = lib.listToAttrs (map (h: { name = h.name; value = h.ip or null; }) hostsList);
        face = lib.listToAttrs (map (h: { name = h.name; value = h.face or null; }) hostsList);
    };

    currentInterface = host.face.${config.networking.hostName};
    currentIp = host.ip.${config.networking.hostName};
    currentHost = "${config.networking.hostName}";

    
    defaultNetworking = {
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
            };
            hosts = {
                "192.168.1.1" = [ "router.lan" "router.local" "router" ];
                "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" "vaultwarden.local" ];
                "192.168.1.211" = [ "homie.lan" "homie.local" "homie" "cache" ];
                "192.168.1.222" = [ "laptop.lan" "laptop.local" "laptop" ];
                "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
                "192.169.1.223" = [ "shield.lan" "shield.local" "shield" ];
                "192.169.1.152" = [ "arris.lan" "arris.local" "arris" ];
            };                                                                                        defaultGateway = {
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
                if config.this.host.hostname == "homie"
                then [ "127.0.0.1" ]  
                else [ "192.168.1.211" ]; 
            firewall = {
                enable = true;
                logRefusedConnections = true;
                allowedUDPPorts = lib.mkMerge [
                    (lib.mkIf (config.networking.hostName == "homie") [51820])
                    [6222 443 53]
                ];
                allowedTCPPorts = [6262 443 53];
            };
            resolvconf = {
                useLocalResolver = false;
            };
            dhcpcd.extraConfig = "nohook resolv.conf";  # Stop DHCP from managing DNS
        };
    };
    
    wirelessNetworking = {
        networking.wireless.networks."pungkula2".psk = config.sops.secrets.w.path;
        networking.wireless.iwd = {
            enable = true;
            settings = {
                Settings = {
                    AutoConnect = true;
                };
            };
        };
        networking.networkmanager.wifi.backend = "iwd";    
    };
in {
    config = lib.mkMerge [
        (lib.mkIf (lib.elem "default" config.this.host.modules.networking) defaultNetworking)
    
        (lib.mkIf (lib.elem "wireless" config.this.host.modules.networking) (lib.mkMerge [
            defaultNetworking
            wirelessNetworking
        ]))        
    ];}
