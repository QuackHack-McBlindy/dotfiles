{ config, pkgs, lib, user, ... }:

let
  lanHosts = lib.concatStringsSep "\n" (  
    lib.flatten (  
      lib.mapAttrsToList (ip: names:  
        lib.concatStringsSep "\n" (map (name: "Host ${name}\n    Port 2222") names)  
      ) config.networking.hosts  
    )  
  );

    
    sshConfigText = ''
      ${lanHosts}

      Host *
        Port 22
    '';

    sshConfig = pkgs.writeTextFile {
        name = "ssh-config";
        text = sshConfigText;
    };

    pubkey = import ./../../hosts/pubkeys.nix;
    username = user;
in
{
    system.activationScripts.sshConfig = {
        text = ''
            mkdir -p /home/${user}/.ssh
            cp ${sshConfig} /home/${user}/.ssh/config
            chown ${user}:${user} /home/${user}/.ssh/config
            chmod 600 /home/${user}/.ssh/config
        '';
    };

 #   networking.firewall.allowedTCPPorts = [ 2222 ];

 #   users.users.root.openssh.authorizedKeys.keys = [  

    users.users.${user}.openssh.authorizedKeys.keys = [ 
        pubkey.desktop
        pubkey.homie
        pubkey.laptop
        pubkey.borg
        pubkey.iPhone
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
                publicKey = pubkey.homie;
            };       
        };             
    };
    
    services.openssh = {
        enable = true;
        ports = [ 2222 ];
        openFirewall = true;   
  #      knownHosts = {
  #          desktop.publicKey = pubkey.desktop;
  #          laptop.publicKey = pubkey.laptop;
  #          nasty.publicKey = pubkey.nasty;
            # homie.publicKey = pubkey.homie;
#        };

        settings = {    
            AllowUsers = [ username ];  
            PasswordAuthentication = true;
            PermitRootLogin = "no"; 
            MaxAuthTries = "3";  
            # UsePAM = "yes"; 
            LogLevel = "VERBOSE";
        };
        
        listenAddresses = [
            {
                addr = "0.0.0.0";
                port = 2222;
            }
            {
                addr = "[::]";
                port = 2222;
            }
        ];
    };
}

