{ 
    config,
    pkgs,
    lib,
    inputs,
    ...
} : let
    pubkey = import ./../../hosts/pubkeys.nix;
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

    NFSMountScript = pkgs.writeShellScript "NFSMount" ''
        #!/bin/sh
        LAN_IP="192.168.1.1" # Your LAN gateway IP
        NFS_SERVER="192.168.1.28"
        MOUNT_POINT="/mnt/Pool"
        BIND_POINT="/Pool"
        case "$2" in
            up)
                if /run/current-system/sw/bin/ping -c 1 "$LAN_IP" >/dev/null 2>&1; then
                    /run/current-system/sw/bin/echo "Connected to LAN, mounting NFS..."
                    /run/current-system/sw/bin/sleep 5  
                    /run/wrappers/bin/mount -t nfs4 "$NFS_SERVER:/" "$MOUNT_POINT"
                    /run/wrappers/bin/mount --bind "$MOUNT_POINT" "$BIND_POINT"
                fi
            ;;
        down)
            /run/current-system/sw/bin/echo "Network down, unmounting NFS..."
            /run/wrappers/bin/umount "$BIND_POINT"
            /run/wrappers/bin/umount "$MOUNT_POINT"
            ;;
    esac
    '';
    currentInterface = host.face.${config.networking.hostName};
    currentIp = host.ip.${config.networking.hostName};
    currentHost = "${config.networking.hostName}";
in {
    imports = [ ./stubby.nix ];
    
    services.resolved.fallbackDns = [ "8.8.8.8" ];
    services.resolved.dnsovertls = "true";
    
    networking = { 
        search = [ "local" "duckdns.org" "lan" ];
        networkmanager = {
            enable = true;
           # dispatcherScripts = [
           #     { 
           #         source = NFSMountScript;
           #         type = "basic";
           #     }    
           # ];
        };
        hosts = {
            "192.168.1.1" = [ "router.lan" "router.local" "router" ];
            "192.168.1.111" = [ "desktop.lan" "desktop.local" "desktop" "vaultwarden.local" ];
            "192.168.1.211" = [ "homie.lan" "homie.local" "homie" ];
            "192.168.1.222" = [ "laptop.lan" "laptop.local" "laptop" ];
            "192.168.1.28" = [ "nasty.lan" "nasty.local" "nasty" ];
            "192.169.1.223" = [ "shield.lan" "shield.local" "shield" ];
            "192.169.1.152" = [ "arris.lan" "arris.local" "arris" ];
        }; 
        defaultGateway = {
            address = "192.168.1.1";
            interface = currentInterface;
            metric = 15;
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
        nameservers =  [ "127.0.0.1" ];
       # nameservers = if currentHost == "homie" then
       #     [ "127.0.0.1" ]
       # else
       #     [ "192.168.1.211" ];
     
        firewall = {
            enable = true;
            logRefusedConnections = true;
            allowedUDPPorts = [ 6222 443 53 ];
            allowedTCPPorts = [ 6262 443 53 ];
        };   
        resolvconf = {  
            useLocalResolver = true;
        };
   # };      

#    system.activationScripts.generateSSHHostKeys = {
#        deps = [ "etc" ]; 
#        text = ''
#            if [ ! -d /etc/secrets/initrd ]; then
#                mkdir -p /etc/secrets/initrd
#                ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
#                ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
#            fi
#        '';
#    };

   # boot.initrd.network = {
   #     enable = true;
   #     ssh = {
   #         enable = true;
   #         port = 22;
   #         hostKeys = [
   #             "/etc/secrets/initrd/ssh_host_rsa_key"
   #             "/etc/secrets/initrd/ssh_host_ed25519_key"  
   #         ];
   #         authorizedKeys = [
   #             pubkey.desktop
   #             pubkey.laptop
   #         ];
     #   };  
    };}

