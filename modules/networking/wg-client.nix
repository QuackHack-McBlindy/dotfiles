{ 
  config,
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
  
    sopsEntry = host: {
        sopsFile = ./../../secrets/hosts/${host}/${host}_wireguard_private.yaml;
        owner = "wgUser";
        group = "wgUser";
        mode = "0440";
    };
    sopsSecrets = lib.listToAttrs (map (h: { name = "${h}_wireguard_private"; value = sopsEntry h; }) hosts) // {
      #  initrd_ed25519_key = {
      #      sopsFile = ./../../secrets/hosts/initrd_ed25519_key.yaml;
      #      owner = "initrduser";
      #      group = "initrduser";
      #      mode = "0440";
      #  };
    };

    currentInterface = host.face.${config.networking.hostName};
    currentIp = host.ip.${config.networking.hostName};
    currentHost = "${config.networking.hostName}";
 
in {
    config = lib.mkIf (lib.elem "wg-client" config.this.host.modules.networking) {
        sops.secrets = sopsSecrets;

        networking = {
            wireguard.interfaces.wg0 = {
                # Client configuration
                ips = [ "${host.wgip.${config.networking.hostName}}/24" ];
                privateKeyFile = config.sops.secrets."${config.networking.hostName}_wireguard_private".path;
                peers = [
                    {
                      publicKey = pubkey.wireguard.homie;
                      allowedIPs = [ "10.0.0.0/24" ];
                      endpoint = "192.168.1.211:51820";
                      persistentKeepalive = 25;
                    }
                ];
            };
        };

        users.groups.wgUser = { };
        users.users.wgUser = {
            group = "wgUser";
            home = "/home/wgUser";
            createHome = true;
            isSystemUser = true;
        };
    };}    
