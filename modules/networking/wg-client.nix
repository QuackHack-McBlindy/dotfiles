# dotfiles/modules/networking/wg-client.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 say ⮞  Simple WireGuard™ client configuration
  config,
  lib,
  pkgs,
  self,
  ...
} : let # 🦆 duck say ⮞ get'z all potential servers
  potentialServers = lib.filter (cfg:
    lib.elem "wg-server" (cfg.config.this.host.modules.networking or [])
  ) (lib.attrValues self.nixosConfigurations);

  # 🦆 duck say ⮞ select'z first found server with safety check
  wgServer = if potentialServers != []
    then lib.head potentialServers
    else throw "No WireGuard server configuration found";

  # 🦆 duck say ⮞ helper functionz
  serverPublicKey    = wgServer.config.this.host.keys.publicKeys.wireguard or "";
  serverIP           = wgServer.config.this.host.ip or (throw "WireGuard server IP not found");
  serverPort         = wgServer.config.networking.wireguard.interfaces.wg0.listenPort or 51820;
  serverEndpointPath = config.sops.secrets.domain.path;

  # 🦆 duck say ⮞ client configuration
  clientWgIP = config.this.host.wgip or (throw "Client WireGuard IP not configured");
  clientPrivateKeySecret = "${config.networking.hostName}_wireguard_private";

  # 🦆 duck say ⮞ client-side output directory
  wgUserHome = "/home/wgUser";
in { # 🦆 duck say ⮞ activate client service by exposing `"wg-client"` at `config.this.host.modules.networking`
  config = lib.mkIf (lib.elem "wg-client" config.this.host.modules.networking) {
    # 🦆 duck say ⮞ secret keepin' (unconditional now)
    sops.secrets = {
      ${clientPrivateKeySecret} = {
        sopsFile = ../../secrets/hosts/${config.networking.hostName}/${clientPrivateKeySecret}.yaml;
        owner = "wgUser";
        group = "wgUser";
        mode = "0440";
      };
      domain = {
        sopsFile = ../../secrets/domain.yaml;
        owner = "wgUser";
        group = "wgUser";
        mode = "0440";
      };
    };

    # 🦆 duck say ⮞ generate THIS client's own .conf + QR (not other hosts')
    systemd.services.wg-client-qr-generate = (let
      qrDependencies = with pkgs; [ qrencode imagemagick ];
      path = lib.makeBinPath ([ pkgs.coreutils pkgs.gnused ] ++ qrDependencies);
    in {
      serviceConfig = {
        Type = "oneshot";
        User = "wgUser";
        Group = "wgUser";
        Environment = "PATH=${path}";
      };
      script = ''
        mkdir -p "${wgUserHome}"
        TEMP_DIR=$(mktemp -d)
        PRIVATE_KEY=$(cat ${config.sops.secrets.${clientPrivateKeySecret}.path})
        ENDPOINT=$(cat ${config.sops.secrets.domain.path})
        cat > "$TEMP_DIR/${config.networking.hostName}.conf" <<EOF
[Interface]
PrivateKey = $PRIVATE_KEY
Address = ${clientWgIP}/24
DNS = ${serverIP}

[Peer]
PublicKey = ${serverPublicKey}
AllowedIPs = 10.0.0.0/24, 192.168.1.0/24
Endpoint = $ENDPOINT:${toString serverPort}
PersistentKeepalive = 25
EOF
        ${pkgs.coreutils}/bin/cp "$TEMP_DIR/${config.networking.hostName}.conf" "${wgUserHome}/${config.networking.hostName}.conf"
        ${config.yo.pkgs}/bin/yo-qr --input "$TEMP_DIR/${config.networking.hostName}.conf" --output "${wgUserHome}/${config.networking.hostName}.png"
        rm -rf "$TEMP_DIR"
      '';
      after = [ "sops-nix.service" ];
      wantedBy = [ "multi-user.target" ];
    });

    # 🦆 duck say ⮞ NixOS user configuration
    users.users.wgUser = {
      group = "wgUser";
      home = "/home/wgUser";
      createHome = true;
      isSystemUser = true;
    };

    users.groups.wgUser = {};
  };}
