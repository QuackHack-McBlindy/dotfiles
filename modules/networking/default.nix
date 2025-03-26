{ 
    config,
    pkgs,
    lib,
    inputs,
    ...
} : let

    pubkey = import ./../../hosts/pubkeys.nix;
    mobileDevices = [ "iphone" "tablet" ];
    host = {
        desktop = { wgip = "10.0.0.2"; ip = "192.168.1.111"; face = "enp119s0"; };
        laptop = { wgip = "10.0.0.3"; ip = "192.168.1.222"; face = "wlan0"; };
        homie = { wgip = "10.0.0.1"; ip = "192.168.1.211"; face = "eno1"; };
        nasty = { wgip = "10.0.0.4"; ip = "192.168.1.28"; face = "enp3s0"; };
        phone = { wgip = "10.0.0.5"; };
        watch = { wgip = "10.0.0.6"; };
        iphone = { wgip = "10.0.0.7"; };
        tablet = { wgip = "10.0.0.8"; };
    };  
    defaultSecretPerms = { owner = "wgqr"; group = "wgqr"; mode = "0440"; };
    wireguardSecrets = {
        desktop_wireguard_private = ./../../secrets/hosts/desktop/desktop_wireguard_private.yaml;
        homie_wireguard_private = ./../../secrets/hosts/homie/homie_wireguard_private.yaml;
        nasty_wireguard_private = ./../../secrets/hosts/nasty/nasty_wireguard_private.yaml;
        laptop_wireguard_private = ./../../secrets/hosts/laptop/laptop_wireguard_private.yaml;
        phone_wireguard_private = ./../../secrets/hosts/phone/phone_wireguard_private.yaml;
        watch_wireguard_private = ./../../secrets/hosts/watch/watch_wireguard_private.yaml;
        iphone_wireguard_private = ./../../secrets/hosts/iphone/iphone_wireguard_private.yaml;
        tablet_wireguard_private = ./../../secrets/hosts/tablet/tablet_wireguard_private.yaml;
    };
    
    initrdConfig = ''
        "@INITRDKEY@"
    '';

    currentInterface = lib.attrByPath [config.networking.hostName "face"] null host;
    currentIp = lib.attrByPath [config.networking.hostName "ip"] null host;
    currentHost = "${config.networking.hostName}";

    initrdFile = 
        pkgs.runCommand "initrdFile"
            { preferLocalBuild = true; }
            ''
            cat > $out <<EOF
${initrdConfig}
EOF
            '';
in {
    imports = 
        [ ./stubby.nix ] ++
        (lib.mkIf (config.networking.hostName == "homie") [ ./unbound.nix ]);
        
    services.resolved.fallbackDns = [ "8.8.8.8" ];
    services.resolved.dnsovertls = "true";
    
    networking = { 
        search = [ "local" "duckdns.org" "lan" ];
        networkmanager = {
            enable = true;
        };
        hosts = {
            "192.168.1.1" = [ "router.lan" "router.local" "router" ];
            "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" "vaultwarden.local" ];
            "192.168.1.211" = [ "homie.lan" "homie.local" "homie" "cache" ];
            "192.168.1.222" = [ "laptop.lan" "laptop.local" "laptop" ];
            "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
            "192.168.1.223" = [ "shield.lan" "shield.local" "shield" ];
            "192.168.1.152" = [ "arris.lan" "arris.local" "arris" ];
        }; 
        defaultGateway = {
            address = "192.168.1.1";
            interface = currentInterface;
            metric = 15;
        };             
        
        interfaces = {
            ${currentInterface} = {
                useDHCP = false;
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
        
        # WireGuard Server
        wireguard.interfaces.wg0 = lib.mkMerge [
            (lib.mkIf (config.networking.hostName == "homie") {
                # Server configuration
                ips = [ "${host.wgip.homie}/24" ];
                listenPort = 51820;
                privateKeyFile = config.sops.secrets."${config.networking.hostName}_wireguard_private".path;
                peers = lib.mapAttrsToList (name: value: {
                    publicKey = pubkey.wireguard.${name};
                    allowedIPs = [ "${value.wgip}/32" ];
                }) (lib.filterAttrs (n: _: n != "homie") host);
            })
  
            (lib.mkIf (config.networking.hostName != "homie") {
                # Client configuration
                ips = [ "${host.wgip.${config.networking.hostName}}/24" ];
                privateKeyFile = config.sops.secrets."${config.networking.hostName}_wireguard_private".path;
                peers = [
                   {
                     publicKey = pubkey.wireguard.homie;
                     allowedIPs = [ "10.0.0.0/24" ];
                     endpoint = "${host.ip.homie}:51820";
                     persistentKeepalive = 25;
                   }
                ];
            })
        ];

        nameservers = lib.mkIf (config.networking.hostName == "homie") [ "127.0.0.1" ]
              ++ lib.mkIf (config.networking.hostName != "homie") [ "192.168.1.211" ];

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
            useLocalResolver = true;
        };
    };      
    
    services.nginx = lib.mkIf (config.networking.hostName == "homie") {
        enable = true;
        virtualHosts."wg-qr" = {
            root = "/etc/wireguard/qr_codes";
            extraConfig = ''
                autoindex on;
                auth_basic "Restricted";
                auth_basic_user_file /etc/nginx/.htpasswd;
            '';
        };
    };

    systemd.services.generate-wg-qr = lib.mkIf (config.networking.hostName == "homie") {
        serviceConfig = {
            ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
            Type = "oneshot";
            User = "root";
            Group = "root";
            WorkingDirectory = "/etc/wireguard/qr_codes";
            Environment = "PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.qrencode pkgs.gnused ]}";
        };
        preStart = ''
            ${pkgs.coreutils}/bin/mkdir -p /etc/wireguard/qr_codes
            ${lib.concatMapStringsSep "\n" (device: ''
                ${pkgs.coreutils}/bin/cat > template.conf <<EOF
                [Interface]
                PrivateKey = @PRIVATE_KEY@
                Address = ${host.wgip.${device}}/24
                DNS = 192.168.1.211

                [Peer]
                PublicKey = ${pubkey.wireguard.homie}
                AllowedIPs = 10.0.0.0/24, 192.168.1.0/24
                Endpoint = ${host.ip.homie}:51820
                PersistentKeepalive = 25
                EOF
                ${pkgs.gnused}/bin/sed -i \
                  -e "s|@PRIVATE_KEY@|$(${pkgs.gnused}/bin/sed -z 's/\n/\\n/g' ${config.sops.secrets."${device}_wireguard_private".path})|" \
                  template.conf

                ${pkgs.coreutils}/bin/mv template.conf ${device}.conf
                ${pkgs.qrencode}/bin/qrencode -t PNG -o ${device}.png -r ${device}.conf
                ${pkgs.coreutils}/bin/chmod 440 ${device}.*
            '') mobileDevices}
        '';
        wantedBy = [ "multi-user.target" ];
    };

    systemd.services.initrd_setup = {
        wantedBy = [ "multi-user.target" ];
        preStart = ''
            mkdir -p /etc/secrets/initrd/
            sed -e "/@INITRDKEY@/{
                r ${config.sops.secrets.initrd_ed25519_key.path}
                d
            }" ${initrdFile} > /etc/secrets/initrd/ssh_host_ed25519_key
            chmod 0400 /etc/secrets/initrd/ssh_host_ed25519_key
        '';  
        serviceConfig = {
            ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
            Restart = "on-failure";
            RestartSec = "2s";
            RuntimeDirectory = [ "initrduser" ];
            User = "initrduser";
        };
    };

    boot.initrd.network = {
        enable = true;
        ssh = {
            enable = true;
            port = 22;
            hostKeys = [
                "/etc/secrets/initrd/ssh_host_ed25519_key"  
            ];
            authorizedKeys = [
                pubkey.desktop
                pubkey.laptop
            ];
        };  
    };

    users.users = {
        initrduser = {
            isSystemUser = true;
            group = "initrduser";
        };
        wgqr = {
            isSystemUser = true;
            group = "wgqr";
        };
    };    
    users.groups.initrduser = { };
    users.groups.wgqr = { };

    sops.secrets = lib.mapAttrs' (name: path: {
        name = name;
        value = defaultSecretPerms // { sopsFile = path; };
    }) wireguardSecrets // {
        initrd_ed25519_key = {
            sopsFile = ./../../secrets/hosts/initrd_ed25519_key.yaml;
            owner = "initrduser";
            group = "initrduser";
            mode = "0440"; 
        };
        
    };}




