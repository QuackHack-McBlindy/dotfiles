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
        face = {
            "desktop" = "enp119s0";
            "laptop" = "wlan0";
            "nasty" = "enp3s0";
            "homie" = "eno1";
        };
    };    

    wgSubnet = "10.10.10";
    wgPort = 51820;
    wgInterface = "wg0";

    wgKeys = {
        "desktop" = { private = "/home/pungkula/.wireguard-keys/private_desktop"; public = "fsk+fG3+C9l4MIvg9YAT0O2Ao+7Z2oRrHbdOxtSbdTo="; };
        "laptop" = { private = "/home/pungkula/.wireguard-keys/private_laptop"; public = "XjjcIhjYwqzy/GeF0HpQkxBFwgHoESwvYmYQ88rVeRA="; };
        "homie" = { private = "/home/pungkula/.wireguard-keys/private_homie"; public = "7Gr+q1z/bJ2wlKg5zDcKB8A0e6RKzSq9KVeUNK/XUUI="; };
        "nasty" = { private = "/home/pungkula/.wireguard-keys/private_nasty"; public = "FZDrcOoNGUVtmp/I7jE1pAseWf867lBhXgvVkXyFUCs="; };
    };

    currentWgIp = let
        fullIp = host.ip.${config.networking.hostName} or "0.0.0.0";  # Fallback if undefined
        octets = builtins.split "\\." fullIp;  # Split IP into a list of octets
        lastOctet = if builtins.length octets == 4 then builtins.elemAt octets 3 else "0";  # Ensure valid extraction
    in  
        "${wgSubnet}.${lastOctet}/24";

    peers = {
        "desktop" = { ip = "${wgSubnet}.1"; pubkey = wgKeys.desktop.public; };
        "laptop" = { ip = "${wgSubnet}.2"; pubkey = wgKeys.laptop.public; };
        "homie" = { ip = "${wgSubnet}.3"; pubkey = wgKeys.homie.public; };
        "nasty" = { ip = "${wgSubnet}.4"; pubkey = wgKeys.nasty.public; };
    };

    currentWgKey = wgKeys.${config.networking.hostName};
    currentInterface = host.face.${config.networking.hostName};
    #currentHost = ${config.networking.hostName};

    peerConfigs = builtins.listToAttrs (builtins.filter (p: p.name != config.networking.hostName) (map (name: {
        name = name;  # Use each peer's actual name, not the hostname
        value = {
            allowedIPs = [ peers.${name}.ip ];
            publicKey = peers.${name}.pubkey;
            endpoint = "${host.ip.${name}}:${toString wgPort}";
            persistentKeepalive = 25;
        };
    }) (builtins.attrNames peers)));
  
in {
    environment.systemPackages = with pkgs; [ pkgs.wireguard-tools ];
    # enable NAT
    networking.nat.enable = true;
    networking.nat.externalInterface = currentInterface;
    networking.nat.internalInterfaces = [ "wg0" ];
    
    networking.firewall.allowedUDPPorts = [ wgPort ];
    networking.wireguard.interfaces.${wgInterface} = {
        ips = [ currentWgIp ];
        privateKeyFile = currentWgKey.private;
        listenPort = wgPort;
        peers = builtins.attrValues peerConfigs;

    };}
