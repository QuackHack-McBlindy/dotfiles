
{ 
    config,
    pkgs,
    lib,
    inputs,
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

    initrdConfig = ''
        "@INITRDKEY@"
    '';
     
    sopsEntry = host: {
        sopsFile = ./../../secrets/hosts/${host}/${host}_wireguard_private.yaml;
        owner = "wgqr";
        group = "wgqr";
        mode = "0440";
    };
    sopsSecrets = lib.listToAttrs (map (h: { name = "${h}_wireguard_private"; value = sopsEntry h; }) hosts) // {
        initrd_ed25519_key = {
            sopsFile = ./../../secrets/hosts/initrd_ed25519_key.yaml;
            owner = "initrduser";
            group = "initrduser";
            mode = "0440";
        };
    };

    splitHorizon = lib.optionals (currentHost == "homie") [ ./unbound.nix ];
    reverseProxy = lib.optionals (currentHost == "nasty") [ ./caddy2.nix ];
    
    currentInterface = host.face.${config.networking.hostName};
    currentIp = host.ip.${config.networking.hostName};
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

    sops.secrets = sopsSecrets;

    networking = {   
        # WireGuard
        wireguard.interfaces.wg0 = {
            ips = [ "${host.wgip.homie}/24" ];
            listenPort = 51820;
            privateKeyFile = config.sops.secrets."${config.networking.hostName}_wireguard_private".path;
            peers = [
                {
                    publicKey = pubkey.wireguard.desktop;
                    allowedIPs = [ "${host.wgip.desktop}/32" ];
                }
                {
                    publicKey = pubkey.wireguard.laptop;
                    allowedIPs = [ "${host.wgip.laptop}/32" ];
                }
                {
                    publicKey = pubkey.wireguard.nasty;
                    allowedIPs = [ "${host.wgip.nasty}/32" ];
                }           
                {
                    publicKey = pubkey.wireguard.iphone;
                    allowedIPs = [ "${host.wgip.iphone}/32" ];
                }
                {
                    publicKey = pubkey.wireguard.phone;
                    allowedIPs = [ "${host.wgip.phone}/32" ];
                }
                {
                    publicKey = pubkey.wireguard.watch;
                    allowedIPs = [ "${host.wgip.watch}/32" ];
                }
                {
                    publicKey = pubkey.wireguard.tablet;
                    allowedIPs = [ "${host.wgip.tablet}/32" ];
                }
            ];
        };  
    };
    services.nginx = {
        enable = true;
        virtualHosts."wg-qr" = {
            root = "/home/wgqr/qr_codes";
            extraConfig = ''
                autoindex on;
                autoindex_exact_size off;
                autoindex_localtime on;
            '';
        };
    };
  
    systemd.services.generate-wg-qr = {
        serviceConfig = {
            Type = "oneshot";
            User = "wgqr";
            Group = "wgqr";
            Environment = "PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.qrencode pkgs.gnused ]}";
        };
        script = ''
            QR_DIR="/home/wgqr"
            ${pkgs.coreutils}/bin/rm -f "$QR_DIR/${device}.conf" "$QR_DIR/${device}.png"
            ${lib.concatMapStringsSep "\n" (device: ''
                TEMP_DIR="$(${pkgs.coreutils}/bin/mktemp -d)"
                

                ${pkgs.coreutils}/bin/cat > "$TEMP_DIR/template.conf" <<EOF
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
                  -e "s|@PRIVATE_KEY@|$(${pkgs.coreutils}/bin/cat ${config.sops.secrets."${device}_wireguard_private".path})|" \
                  "$TEMP_DIR/template.conf"

                ${pkgs.coreutils}/bin/mv "$TEMP_DIR/template.conf" "$QR_DIR/${device}.conf"
                ${pkgs.qrencode}/bin/qrencode -t PNG -o "$QR_DIR/${device}.png" -r "$QR_DIR/${device}.conf"

                ${pkgs.coreutils}/bin/rm -rf "$TEMP_DIR"
                ${pkgs.coreutils}/bin/chmod 440 "$QR_DIR/${device}."*
            '') mobileDevices}
        '';
        wantedBy = [ "multi-user.target" ];
    };
   
    users.groups.wgqr = { }; 
    users.users.wgqr = {
        group = "wgqr";
        home = "/home/wgqr";
        createHome = true;
        isSystemUser = true;
    };}
