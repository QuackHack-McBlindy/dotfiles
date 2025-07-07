# dotfiles/modules/networking/wg-server.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ A duck'z dynamic approach to configuring a WireGuard™ server
  config,
  lib, # 🦆 says ⮞ 📌 FEATURES:
  pkgs,  # 🦆 says ⮞ ⭐ Automated fun QR codegeneration for mobile devices
  self,  # 🦆 says ⮞ ⭐ Secure private key storage featuring SOPS-nix
  ...    # 🦆 says ⮞ ⭐ Dynamically configured server interface
} : let
# 🦆 says ⮞ Place your encrypted private keys in `dotfiles/secrets/hosts/<device>/<device>_wireguard_private.yaml` 
# 🦆 says ⮞ Define your NIxOS clients like this: 
# config.this.host.wgip = "<ip>";
# config.this.host.keys.publicKeys = { wireguard = "<pubkey>": };
# 🦆 says ⮞ Define your mobile device clients like this: 
# config.this.user.me.mobileDevices = { <device> = { wgip = "<ip>"; pubkey = "<pubkey>"; }; };

  # 🦆 says ⮞ WireGuard™ User home directory
  wgUserHome = "/home/wgUser";
  
  # 🦆 says ⮞ WireGuard™ tunnel'z allowed IP'z
  defaultAllowedIPs = [ "10.0.0.0/24" "192.168.1.0/24" ];
  # 🦆 says ⮞ can also be defined per device at `config.this.user.me.mobileDevices.<device.allowedIPs` but this is optional
  
  # 🦆 says ⮞ Server configuration
  serverCfg = config.this.host;
  
  # 🦆 says ⮞ Get NixOS host peers
  peerHosts = lib.filterAttrs (_: cfg:
    lib.elem "wg-client" (cfg.config.this.host.modules.networking or [])
  ) self.nixosConfigurations;

  # 🦆 says ⮞ Mobile devices configuration
  mobileDevices = config.this.user.me.mobileDevices or {};

  # 🦆 says ⮞ Helper functions
  peerPublicKey = host: host.config.this.host.keys.publicKeys.wireguard;
  peerWgIP = host: host.config.this.host.wgip;

  # 🦆 says ⮞ SOPS configuration generator
  mkSopsSecret = name: {
    sopsFile = ../../secrets/hosts/${name}/${name}_wireguard_private.yaml;
    owner = "wgUser";
    group = "wgUser";
    mode = "0440";
  };

in { # 🦆 says ⮞ choose server host by exposing `"wg-server"` in `this.host.modules.networking`
  config = lib.mkIf (lib.elem "wg-server" serverCfg.modules.networking) {
    sops.secrets = (
      { "${config.networking.hostName}_wireguard_private" = mkSopsSecret config.networking.hostName; }
      //
      (lib.mapAttrs' (n: _: lib.nameValuePair "${n}_wireguard_private" (mkSopsSecret n)) peerHosts)
      //
      (lib.listToAttrs (map (d: lib.nameValuePair "${d}_wireguard_private" (mkSopsSecret d)) (lib.attrNames mobileDevices)))
      //
      { # 🦆 says ⮞ domain/ip to run da server on
        domain = { 
          sopsFile = ../../secrets/domain.yaml;
          owner = "wgUser";
          group = "wgUser";
          mode = "0440";
        };
      }
    );
   
    # 🦆 says ⮞ network configuration 
    networking = { # 🦆 says ⮞ open UDP firewall port
      firewall.allowedUDPPorts = [ 51820 ];
      # 🦆 says ⮞ WireGuard™ interface config 
      wireguard.interfaces.wg0 = {
        ips = [ "${serverCfg.wgip}/24" ];
        listenPort = 51820;
        privateKeyFile = config.sops.secrets."${config.networking.hostName}_wireguard_private".path;
        peers = 
          # 🦆 says ⮞ NixOS host peers
          (lib.mapAttrsToList (_: host: {
            publicKey = peerPublicKey host;
            allowedIPs = [ "${peerWgIP host}/32" ];
          }) peerHosts)
          ++
          # 🦆 says ⮞ mobile device peers
          (lib.mapAttrsToList (name: cfg: {
            publicKey = cfg.pubkey;
            allowedIPs = [ "${cfg.wgip}/32" ];
          }) mobileDevices);
      };
    };

    # 🦆 says ⮞ systemd service dat generates fun random colored QR codes for appropriate devices
    systemd.services.generate-wg-qr = (let
      qrDependencies = with pkgs; [ qrencode imagemagick ];
      path = lib.makeBinPath ([ pkgs.coreutils pkgs.gnused ] ++ qrDependencies);
    in {
      serviceConfig = {
        Type = "oneshot";
        User = "wgUser";
        Group = "wgUser";
        Environment = "PATH=${path}";
      };
      # 🦆 says ⮞ da script that daz everything, yo!
      script = let
        # 🦆 says ⮞ removes old QR files
        deleteOld = lib.concatMapStringsSep "\n" (d: ''
          rm -f "${wgUserHome}/${d}.conf" "${wgUserHome}/${d}.png"
        '') (lib.attrNames mobileDevices);
        # 🦆 says ⮞ create new QR
        generateQR = device: let
          allowed = lib.concatStringsSep ", " (mobileDevices.${device}.allowedIPs or defaultAllowedIPs);
        in ''
          TEMP_DIR=$(mktemp -d)
          PRIVATE_KEY=$(cat ${config.sops.secrets."${device}_wireguard_private".path})
          # 🦆 says ⮞ insert data into QR
          cat > "$TEMP_DIR/${device}.conf" <<EOF
[Interface]
PrivateKey = $PRIVATE_KEY
Address = ${mobileDevices.${device}.wgip}/24
DNS = ${serverCfg.ip}

[Peer]
PublicKey = ${serverCfg.keys.publicKeys.wireguard}
AllowedIPs = ${allowed}
Endpoint = $(cat ${config.sops.secrets.domain.path}):51820
PersistentKeepalive = 25
EOF
          ${pkgs.coreutils}/bin/cp "$TEMP_DIR/${device}.conf" "${wgUserHome}/${device}.conf"
          ${pkgs.qrencode}/bin/qrencode -t png -o "${wgUserHome}/${device}1.png" < "$TEMP_DIR/${device}.conf"
          ${config.yo.pkgs}/bin/yo-qr --input "$TEMP_DIR/${device}.conf" --output "${wgUserHome}/${device}.png"
          rm -rf "$TEMP_DIR" # 🦆 says ⮞ cleanup
        '';
      in ''
        # 🦆 says ⮞ juzt 2 make sure it rly existz 
        mkdir -p "${wgUserHome}"        
        ${deleteOld}
        ${lib.concatMapStringsSep "\n" generateQR (lib.attrNames mobileDevices)}
      '';   
      wantedBy = [ "multi-user.target" ];
    });

    # 🦆 says ⮞ NixOS user configuration
    users = {
      groups.wgUser = {};
      users.wgUser = {
        group = "wgUser";
        home = "${wgUserHome}";
        createHome = true;
        isSystemUser = true;
      };
    }; # 🦆 says ⮞ zimple az dat, yo!
  };} # 🦆 says ⮞ now'z u can access u home net wen u awayz!
# 🦆 says ⮞ QuackHack-McBlindy out!
