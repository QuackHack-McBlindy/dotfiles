{ 
  config,
  lib,
  pkgs,
  self,
  ...
} : let
  # Server configuration
  serverCfg = config.this.host;
  
  # Get NixOS host peers
  peerHosts = lib.filterAttrs (_: cfg:
    lib.elem "wg-client" (cfg.config.this.host.modules.networking or [])
  ) self.nixosConfigurations;

  # Mobile devices configuration
  mobileDevices = config.this.user.mobileDevices or {};

  # Helper functions
  peerPublicKey = host: host.config.this.host.keys.publicKeys.wireguard;
  peerWgIP = host: host.config.this.host.wgip;

  # SOPs configuration generator
  mkSopsSecret = name: {
    sopsFile = ../../secrets/hosts/${name}/${name}_wireguard_private.yaml;
    owner = "wgUser";
    group = "wgUser";
    mode = "0440";
  };

in {
  config = lib.mkIf (lib.elem "wg-server" serverCfg.modules.networking) {
    sops.secrets = lib.mkIf (!config.this.installer) (
      # Use parentheses for merged attribute sets, not curly braces
      { "${config.networking.hostName}_wireguard_private" = mkSopsSecret config.networking.hostName; }
      //
      (lib.mapAttrs' (n: _: lib.nameValuePair "${n}_wireguard_private" (mkSopsSecret n)) peerHosts)
      //
      (lib.listToAttrs (map (d: lib.nameValuePair "${d}_wireguard_private" (mkSopsSecret d)) (lib.attrNames mobileDevices)))
      //
      {
        domain = {
          sopsFile = ../../secrets/domain.yaml;
          owner = "wgUser";
          group = "wgUser";
          mode = "0440";
        };
      }
    );
  

    networking.wireguard.interfaces.wg0 = lib.mkIf (!config.this.installer) {
      ips = [ "${serverCfg.wgip}/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."${config.networking.hostName}_wireguard_private".path;
      peers = 
        # NixOS host peers
        (lib.mapAttrsToList (_: host: {
          publicKey = peerPublicKey host;
          allowedIPs = [ "${peerWgIP host}/32" ];
        }) peerHosts)
        ++
        # Mobile device peers
        (lib.mapAttrsToList (name: cfg: {
          publicKey = cfg.pubkey;
          allowedIPs = [ "${cfg.wgip}/32" ];
        }) mobileDevices);
    };

    systemd.services.generate-wg-qr = lib.mkIf (!config.this.installer) (let
      qrDependencies = with pkgs; [ qrencode imagemagick ];
      path = lib.makeBinPath ([ pkgs.coreutils pkgs.gnused ] ++ qrDependencies);
    in {
      serviceConfig = {
        Type = "oneshot";
        User = "wgUser";
        Group = "wgUser";
        Environment = "PATH=${path}";
      };

      script = let
        deleteOld = lib.concatMapStringsSep "\n" (d: ''
          rm -f "/home/wgUser/${d}.conf" "/home/wgUser/${d}.png"
        '') (lib.attrNames mobileDevices);

        generateQR = device: ''
          TEMP_DIR=$(mktemp -d)
          PRIVATE_KEY=$(cat ${config.sops.secrets."${device}_wireguard_private".path})

          cat > "$TEMP_DIR/${device}.conf" <<EOF
          [Interface]
          PrivateKey = $PRIVATE_KEY
          Address = ${mobileDevices.${device}.wgip}/24
          DNS = ${serverCfg.ip}

          [Peer]
          PublicKey = ${serverCfg.keys.publicKeys.wireguard}
          AllowedIPs = 10.0.0.0/24, 192.168.1.0/24
          Endpoint = $(cat ${config.sops.secrets.domain.path}):51820
          PersistentKeepalive = 25
          EOF

          qrencode -l H -s 5 -o "/home/wgUser/${device}.png" -r "$TEMP_DIR/${device}.conf"
          rm -rf "$TEMP_DIR"
        '';

      in ''
        ${deleteOld}
        ${lib.concatMapStringsSep "\n" generateQR (lib.attrNames mobileDevices)}
      '';

      wantedBy = [ "multi-user.target" ];
    });

    users = {
      groups.wgUser = {};
      users.wgUser = {
        group = "wgUser";
        home = "/home/wgUser";
        createHome = true;
        isSystemUser = true;
      };
    };

    system.activationScripts.wgUserSetup = lib.mkIf (!config.this.installer) {
      text = ''
        cp /home/pungkula/dotfiles/home/icons/duck2.png /home/wgUser/duck.png
        chown wgUser:wgUser /home/wgUser/duck.png
      '';
    };
  };}
