
{ 
    config,
    pkgs,
    lib,
    inputs,
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

   # sopsEntry = host: {
   #     sopsFile = ./../../secrets/hosts/${host}/${host}_wireguard_private.yaml;
   #     owner = "pungkula";
   #     group = "pungkula";
   #     mode = "0440";
   # };
#    sopsSecrets = lib.listToAttrs (map (h: { name = "${h}_wireguard_private"; value = sopsEntry h; }) hosts) // {
    #    initrd_ed25519_key = {
    #        sopsFile = ./../../secrets/hosts/initrd_ed25519_key.yaml;
    #        owner = "initrduser";
    #        group = "initrduser";
    #        mode = "0440";
    #    };
#    };

    currentInterface = host.face.${config.networking.hostName};
    currentIp = host.ip.${config.networking.hostName};
    currentHost = "${config.networking.hostName}";
in {

 #   imports = [
 #       ./../services/fail2ban.nix
 #   ];
 #   sops.secrets = sopsSecrets;
    
    services.resolved = { 
        enable = true;
   #     domains = [ "~." ];
  #      fallbackDns = [ ]; # Empty to prevent bypass
   #     dnsovertls = "true"; 
  #      dnssec = "allow-downgrade";
    };    
    
    networking = { 
   #     search = [ "local" "duckdns.org" "lan" ];
        networkmanager = {
            enable = true;
     #       dns = lib.mkDefault "none";
        };
        hosts = {
            "192.168.1.1" = [ "router.lan" "router.local" "router" ];
            "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" "cache" ];
            "192.168.1.211" = [ "homie.lan" "homie.local" "homie" ];
            "192.168.1.222" = [ "laptop.lan" "laptop.local" "laptop" ];
            "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
            "192.169.1.223" = [ "shield.lan" "shield.local" "shield" ];
            "192.169.1.152" = [ "arris.lan" "arris.local" "arris" ];
        }; 
        defaultGateway = {
            address = "192.168.1.1";
           # interface = currentInterface;
            interface = "enp119s0";
            metric = 1;
        };             
        
        interfaces = {
            ${currentInterface} = {
                useDHCP = true;
                ipv4 = {
                    addresses = [{
                        address = currentIp;
                        prefixLength = 24;
                    }];
                    routes = [
                        {
                            address = "0.0.0.0";  
                            prefixLength = 0;
                            via = "192.168.1.1";
                        }
                        {
                            address = "192.168.1.0";
                            prefixLength = 24;
                        }
                    ];        
                };
            };
        };  
        
        #nameservers = lib.mkMerge [
        #    (lib.mkIf (config.networking.hostName == "homie") (lib.mkForce [ "127.0.0.1" ]))
        #    (lib.mkIf (config.networking.hostName != "homie") (lib.mkForce [ "192.168.1.211" ]))
        nameservers = [
            "8.8.8.8"
        ];
        firewall = {
            enable = true;
            logRefusedConnections = true;
            allowedUDPPorts = lib.mkMerge [
                (lib.mkIf (config.networking.hostName == "homie") [51820])
                [6222 443 53]
            ];
            allowedTCPPorts = [6262 443 53];
        }; 
        resolvconf = {  
            useLocalResolver = false;
        };
        
    };}
