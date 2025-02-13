{ config, pkgs, lib, user, ... }:
let
    pubkey = import ./../../hosts/pubkeys.nix;
in
{
    networking.firewall.allowedTCPPorts = [ 22 ];

    users.users.${user}.openssh.authorizedKeys.keys = [ 
        pubkey.desktop
        pubkey.laptop
    ];

    programs.ssh = {
        knownHosts = {    
            desktop = {
                extraHostNames = [ "desktop.löcal" "192.168.1.111" ];
                publicKey = pubkey.desktop;
            };
            laptop = {
                extraHostNames = [ "laptop.local" ];
                publicKey = pubkey.laptop;
            };
            nasty = {
                extraHostNames = [ "nasty.local" "192.168.1.28" ];
                publicKey = pubkey.nasty;
            };
            homie = {
                extraHostNames = [ "homie.local" "192.168.1.211" ];
               # publicKey = pubkey.nomie;
            };       
        };             
    };
    
    services.openssh = {
        enable = true;
        ports = [ 22 ];
        openFirewall = true;   
        knownHosts = {
            desktop.publicKey = pubkey.desktop;
            laptop.publicKey = pubkey.laptop;
            nasty.publicKey = pubkey.nasty;
            # homie.publicKey = pubkey.homie;
        };

        settings = {    
            AllowUsers = [ user ];  
            PasswordAuthentication = true;
            PermitRootLogin = "no"; 
            MaxAuthTries = "3";  
            # UsePAM = "yes"; 

            # DisableForwarding = false; 
            # PermitEmptyPasswords = false;  
            # ClientAliveInterval = 60;  # Server sends keep-alive messages every 60 seconds
            # ClientAliveCountMax = 3;  # Disconnect clients after 3 missed keep-alives

            # Specify which algorithms to use
            # Ciphers = "aes128-ctr,aes192-ctr,aes256-ctr";
            # MACs = "hmac-sha2-256,hmac-sha2-512";
            # KexAlgorithms = "curve25519-sha256@libssh.org,diffie-hellman-group14-sha1";
            
            LogLevel = "VERBOSE";
        };
    };
}



        


