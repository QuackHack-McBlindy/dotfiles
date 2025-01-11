{ config, pkgs, lib, user, ... }:
let
    pubkey = import ./pubkeys.nix;
in
{
    networking.firewall.allowedTCPPorts = [ 22 ];

    users.users.${user}.openssh.authorizedKeys.keys = [ 
        pubkey.desktop
        pubkey.laptop
    ];

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
            PasswordAuthentication = lib.mkDefault false;
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
            
            # Configure X11 forwarding (useful for graphical applications)
            # X11Forwarding = "yes";
            # X11DisplayOffset = "10";
            
            # Disable DNS lookup for performance reasons (can be useful in some environments)
            # UseDNS = "no";
            LogLevel = "VERBOSE";
        };
    };
}



        


