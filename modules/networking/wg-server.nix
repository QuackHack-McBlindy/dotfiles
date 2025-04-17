{ 
  config,
  this,
  lib,
  pkgs,
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

    domain = config.sops.secrets.domain.path; 
    sopsEntry = hostName: {
        sopsFile = ./../../secrets/hosts/${hostName}/${hostName}_wireguard_private.yaml;
        owner = "wgUser";
        group = "wgUser";
        mode = "0440";
    };
  
    currentInterface = host.face.${config.networking.hostName};
    currentIp = host.ip.${config.networking.hostName};
    currentHost = "${config.networking.hostName}";
in {
    config = lib.mkIf (lib.elem "wg-server" config.this.host.modules.networking) {
        sops.secrets = lib.listToAttrs (map (h: {
            name = "${h}_wireguard_private";
            value = sopsEntry h;
        }) hosts) // {
            domain = {
                sopsFile = ./../../secrets/domain.yaml;
                owner = "wgUser";
                group = "wgUser";
                mode = "0440";
            };
        };

        networking = {
            wireguard.interfaces.wg0 = {
                ips = [ "${host.wgip.homie}/24" ];
                listenPort = 51820;
                privateKeyFile = config.sops.secrets."${config.networking.hostName}_wireguard_private".path;
                peers = [
                    {
                        publicKey = pubkey.wireguard.desktop;
                        allowedIPs = [ "${host.wgip.desktop}/32" ];
                    }
                    {                                                                                             publicKey = pubkey.wireguard.laptop;
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
                root = "/home/wgUser/qr_codes";
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
                User = "wgUser";
                Group = "wgUser";
                Environment = "PATH=${lib.makeBinPath [
                    pkgs.coreutils
                    pkgs.qrencode
                    pkgs.gnused
                    pkgs.imagemagick
                ]}";
            };
            script = let
                deleteCommands = lib.concatMapStringsSep "\n" (d: ''
                    rm -f "/home/wgUser/${d}.conf" "/home/wgUser/${d}.png"
                '') mobileDevices;

                generateCommands = lib.concatMapStringsSep "\n" (device: ''
                    TEMP_DIR=$(mktemp -d)

                    # Generate config
                    cat > "$TEMP_DIR/template.conf" <<EOF
                    [Interface]
                    PrivateKey = $(cat ${config.sops.secrets."${device}_wireguard_private".path})
                    Address = ${host.wgip.${device}}/24
                    DNS = 192.168.1.211

                    [Peer]
                    PublicKey = ${pubkey.wireguard.homie}
                    AllowedIPs = 10.0.0.0/24, 192.168.1.0/24                                                  Endpoint = $(cat ${config.sops.secrets.domain.path}):51820
                    PersistentKeepalive = 25
                    EOF

                    mv "$TEMP_DIR/template.conf" "/home/wgUser/${device}.conf"

                    # Generate QR code with smaller module size
                    qrencode -l H -s 5 -o "$TEMP_DIR/qr.png" -r "/home/wgUser/${device}.conf"

                    # Generate colors
                    FG_COLOR=$(printf "#%06X" $((RANDOM * 256 * 256 * 256 / 32768)))
                    BG_COLOR=$(printf "#%06X" $((RANDOM * 256 * 256 * 256 / 32768)))

                    # Apply styling
                    magick "$TEMP_DIR/qr.png" \
                        -fill "$FG_COLOR" -opaque black \
                        -fill "$BG_COLOR" -opaque white \
                        "$TEMP_DIR/qr_colored.png"

                    magick "$TEMP_DIR/qr_colored.png" \
                        \( +clone -background black -shadow 50x10+0+0 \) +swap \
                        -background none -layers merge +repage \
                        "$TEMP_DIR/qr_shadow.png"

                    # Resize QR code to a reasonable size
                    magick "$TEMP_DIR/qr_shadow.png" -resize 300x300 "$TEMP_DIR/qr_resized.png"

                    # Resize duck image while keeping transparency
                    magick /home/wgUser/duck.png -resize x60 -background none "$TEMP_DIR/duck_resized.png"
                                                                                                              # Overlay resized duck on QR code
                    magick "$TEMP_DIR/qr_resized.png" "$TEMP_DIR/duck_resized.png" \
                        -gravity center -composite "/home/wgUser/${device}.png"
                                                                                                              rm -rf "$TEMP_DIR"
                '') mobileDevices;
            in ''
                ${deleteCommands}
                ${generateCommands}
            '';
            wantedBy = [ "multi-user.target" ];
        };

        system.activationScripts.dockerPermissions = {
            text = ''
                cp /home/pungkula/dotfiles/home/icons/duck2.png /home/wgUser/duck.png
            '';
         };

        users.groups.wgUser = { };
        users.users.wgUser = {
            group = "wgUser";
            home = "/home/wgUser";
            createHome = true;
            isSystemUser = true;
        };
    };}   
