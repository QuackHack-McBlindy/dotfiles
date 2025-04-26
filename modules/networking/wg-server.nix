{ 
  config,
  lib,
  pkgs,
  self,
  ...
} : let

  # Get all hosts that have wireguard client configuration
  peers = lib.filterAttrs (_: cfg:
    lib.elem "wg-server" (cfg.config.this.host.modules.networking or [])
  ) self.nixosConfigurations;

  # Helper functions to get peer attributes
  getPeerAttr = attr: host: host.config.this.host.${attr};
  peerPublicKey = host: host.config.this.host.keys.publicKeys.wireguard;
  peerWgIP = host: host.config.this.host.wgip;

  # Mobile devices from user config
  mobileDevices = config.this.user.me.extraDevices;

  # Domain from secrets
  domain = config.sops.secrets.domain.path;

  # SOPs configuration generator
  # SOPs configuration generator (FIXED: Use hostname from peers' keys)
  hostname = config.this.host.hostname;
  mkSopsSecret = hostname: host: {
    name = "${hostname}_wireguard_private";
    value = {
      sopsFile = ../../secrets/hosts/${hostname}/${hostname}_wireguard_private.yaml;
      owner = "wgUser";
      group = "wgUser";
      mode = "0440";
    };
  };


in {
  config = lib.mkIf (lib.elem "wg-server" config.this.host.modules.networking) {
    sops.secrets = lib.listToAttrs (map mkSopsSecret (builtins.attrValues peers)) // {
      domain = {
        sopsFile = ../../secrets/domain.yaml;
        owner = "wgUser";
        group = "wgUser";
        mode = "0440";
      };
    };

    networking.wireguard.interfaces.wg0 = {
      ips = [ "${config.this.host.wgip}/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."${config.networking.hostName}_wireguard_private".path;
      peers = lib.mapAttrsToList (_: host: {
        publicKey = peerPublicKey host;
        allowedIPs = [ "${peerWgIP host}/32" ];
      }) peers;
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

    systemd.services.generate-wg-qr = let
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
        '') mobileDevices;

        generateQR = device: ''
          TEMP_DIR=$(mktemp -d)
          PRIVATE_KEY=$(cat ${config.sops.secrets."${device}_wireguard_private".path})

          cat > "$TEMP_DIR/${device}.conf" <<EOF
          [Interface]
          PrivateKey = $PRIVATE_KEY
          Address = ${peerWgIP self.nixosConfigurations.${device}}/24
          DNS = ${getPeerAttr "ip" self.nixosConfigurations.homie}

          [Peer]
          PublicKey = ${config.this.host.keys.publicKeys.wireguard}
          AllowedIPs = 10.0.0.0/24, 192.168.1.0/24
          Endpoint = $(cat ${domain}):51820
          PersistentKeepalive = 25
          EOF

          qrencode -l H -s 5 -o "/home/wgUser/${device}.png" -r "$TEMP_DIR/${device}.conf"
          rm -rf "$TEMP_DIR"
        '';

      in ''
        ${deleteOld}
        ${lib.concatMapStringsSep "\n" generateQR mobileDevices}
      '';

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.wgUser = {};
      users.wgUser = {
        group = "wgUser";
        home = "/home/wgUser";
        createHome = true;
        isSystemUser = true;
      };
    };

    system.activationScripts.wgUserSetup = {
      text = ''
        cp ${../../assets/duck.png} /home/wgUser/duck.png
        chown wgUser:wgUser /home/wgUser/duck.png
      '';
    };
  };
}

