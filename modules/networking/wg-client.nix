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
  serverPublicKey = wgServer.config.this.host.keys.publicKeys.wireguard or "";
  serverIP = wgServer.config.this.host.ip or (throw "WireGuard server IP not found");
  serverPort = wgServer.config.networking.wireguard.interfaces.wg0.listenPort or 51820;

  # 🦆 duck say ⮞ client configuration
  clientWgIP = config.this.host.wgip or (throw "Client WireGuard IP not configured");
  clientPrivateKeySecret = "${config.networking.hostName}_wireguard_private";
in { # 🦆 duck say ⮞ activate client service by exposing `"wg-client"` at `config.this.host.modules.networking`
  config = lib.mkIf (lib.elem "wg-client" config.this.host.modules.networking) {
    # 🦆 duck say ⮞ secret keepin'
    sops.secrets.${clientPrivateKeySecret} = lib.mkIf (!config.this.installer) {
      sopsFile = ../../secrets/hosts/${config.networking.hostName}/${clientPrivateKeySecret}.yaml;
      owner = "wgUser";
      group = "wgUser";
      mode = "0440";
    };
    
    # 🦆 duck say ⮞ network keepin'
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
    # 🦆 duck say ⮞ NixOS user configuration 
    users.users.wgUser = {
      group = "wgUser";
      home = "/home/wgUser";
      createHome = true;
      isSystemUser = true;
    };

    users.groups.wgUser = {};
  };}
