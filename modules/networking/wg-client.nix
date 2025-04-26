{ 
  config,
  lib,
  pkgs,
  self,
  ...
}:

let
  # Get the WireGuard server configuration
  wgServer = lib.findSingle (cfg: 
    lib.elem "wg-server" (cfg.config.this.host.modules.networking or [])
  ) {} {} (lib.attrValues self.nixosConfigurations);

  # Helper functions
  serverPublicKey = wgServer.config.this.host.keys.publicKeys.wireguard;
  serverIP = wgServer.config.this.host.ip;
  serverPort = wgServer.config.networking.wireguard.interfaces.wg0.listenPort;

  # Client configuration
  clientWgIP = config.this.host.wgip;
  clientPrivateKeySecret = "${config.networking.hostName}_wireguard_private";

in {
  config = lib.mkIf (lib.elem "wg-client" config.this.host.modules.networking) {
    sops.secrets.${clientPrivateKeySecret} = {
      sopsFile = ../../secrets/hosts/${config.networking.hostName}/${clientPrivateKeySecret}.yaml;
      owner = "wgUser";
      group = "wgUser";
      mode = "0440";
    };

    networking.wireguard.interfaces.wg0 = {
      ips = [ "${clientWgIP}/24" ];
      privateKeyFile = config.sops.secrets.${clientPrivateKeySecret}.path;
      
      peers = [
        {
          publicKey = serverPublicKey;
          allowedIPs = [ "10.0.0.0/24" "192.168.1.0/24" ];
          endpoint = "${serverIP}:${toString serverPort}";
          persistentKeepalive = 25;
        }
      ];
    };

    users.users.wgUser = {
      group = "wgUser";
      home = "/home/wgUser";
      createHome = true;
      isSystemUser = true;
    };

    users.groups.wgUser = {};
  };
}
