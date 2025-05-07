{ 
  config,
  lib,
  pkgs,
  self,
  ...
} : let
  # Get all potential servers
  potentialServers = lib.filter (cfg:
    lib.elem "wg-server" (cfg.config.this.host.modules.networking or [])
  ) (lib.attrValues self.nixosConfigurations);

  # Select first found server with safety check
  wgServer = if potentialServers != [] 
    then lib.head potentialServers 
    else throw "No WireGuard server configuration found";

  # Helper functions with null safety
  serverPublicKey = wgServer.config.this.host.keys.publicKeys.wireguard or "";
  serverIP = wgServer.config.this.host.ip or (throw "WireGuard server IP not found");
  serverPort = wgServer.config.networking.wireguard.interfaces.wg0.listenPort or 51820;

  # Client configuration
  clientWgIP = config.this.host.wgip or (throw "Client WireGuard IP not configured");
  clientPrivateKeySecret = "${config.networking.hostName}_wireguard_private";

in {
  config = lib.mkIf (lib.elem "wg-client" config.this.host.modules.networking) {
    sops.secrets.${clientPrivateKeySecret} = lib.mkIf (!config.this.installer) {
      sopsFile = ../../secrets/hosts/${config.networking.hostName}/${clientPrivateKeySecret}.yaml;
      owner = "wgUser";
      group = "wgUser";
      mode = "0440";
    };

    networking.wireguard.interfaces.wg0 = lib.mkIf (!config.this.installer) {
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
