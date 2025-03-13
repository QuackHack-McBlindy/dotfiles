{
  config,
  lib, 
  pkgs,
  ...
} : let

    host = {
        ip = {
            "desktop" = "192.169.1.111";
            "laptop" = "192.168.1.222";
            "homie" = "192.168.1.211";
            "nasty" = "192.168.1.28";
        };
      #  face = {
     #       "desktop" = "enp119s0";
      #      "laptop" = "wlan0";
      #      "nasty" = "enp3s0";
      #      "homie" = "eno1";
      #  };
    };    

    wgSubnet = "10.10.10";
    wgPort = 51820;
    wgInterface = "wg0";

    wgKeys = {
        "desktop" = { private = "~/.wireguard-keys/private_desktop"; public = "~/.wireguard-keys/public_desktop"; };
        "laptop" = { private = "~/.wireguard-keys/private_laptop"; public = "~/.wireguard-keys/public_laptop"; };
        "homie" = { private = "~/.wireguard-keys/private_homie"; public = "~/.wireguard-keys/public_homie"; };
        "nasty" = { private = "~/.wireguard-keys/private_nasty"; public = "~/.wireguard-keys/public_nasty"; };
    };

    currentWgKey = wgKeys.${config.networking.hostName};
    #currentWgIp = "${wgSubnet}.${builtins.elemAt (builtins.attrNames host.ip) (builtins.elemIndex config.networking.hostName (builtins.attrNames host.ip))}/24";
    currentIp = host.ip.${config.networking.hostName};

    peers = {
        "desktop" = { ip = "${wgSubnet}.1"; pubkey = wgKeys.desktop.public; };
        "laptop" = { ip = "${wgSubnet}.2"; pubkey = wgKeys.laptop.public; };
        "homie" = { ip = "${wgSubnet}.3"; pubkey = wgKeys.homie.public; };
        "nasty" = { ip = "${wgSubnet}.4"; pubkey = wgKeys.nasty.public; };
    };

    peerConfigs = builtins.listToAttrs (builtins.filter (p: p.name != config.networking.hostName) (map (name: {
        name = name;
        value = {
            allowedIPs = [ peers.${name}.ip ];
            publicKey = peers.${name}.pubkey;
            endpoint = "${host.ip.${name}}:${toString wgPort}";
            persistentKeepalive = 25;
        };
    }) (builtins.attrNames peers)));
  
in {
    # enable NAT
    networking.nat.enable = true;
    networking.nat.externalInterface = "eth0";
    networking.nat.internalInterfaces = [ "wg0" ];
    
    networking.firewall.allowedUDPPorts = [ wgPort ];
    networking.wireguard.interfaces.${wgInterface} = {
        ips = [ currentWgIp ];
        privateKeyFile = currentWgKey.private;
        generatePrivateKeyFile = true;
        listenPort = wgPort;
        peers = builtins.attrValues peerConfigs;

    };}
