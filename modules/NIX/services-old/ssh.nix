{ 
  config,
  lib,
  pkgs,
  user,
  ...
} : let
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
    hostkey = pubkey.host;    
in {
        system.activationScripts.sshConfig = {
            text = ''
                mkdir -p /home/${user}/.ssh
                cp ${sshConfig} /home/${user}/.ssh/config
                chown ${user}:${user} /home/${user}/.ssh/config
                chmod 600 /home/${user}/.ssh/config
            '';
        };

        networking.firewall.allowedTCPPorts = [ 2222 ];

        users.users.${user}.openssh.authorizedKeys.keys = [
            pubkey.desktop
            pubkey.homie
            pubkey.builder
            pubkey.laptop
            pubkey.iPhone
        ];

        programs.ssh = {
            knownHosts = {
                desktop = {
                    extraHostNames = [ "desktop.löcal" "192.168.1.111" ];
                    publicKey = hostkey.desktop;
                };
                laptop = {
                    extraHostNames = [ "laptop.local" ];
                    publicKey = hostkey.laptop;
                };
                nasty = {
                    extraHostNames = [ "nasty.local" "192.168.1.28" ];
                    publicKey = hostkey.nasty;
                };
                homie = {
                    extraHostNames = [ "homie.local" "192.168.1.211" ];
                    publicKey = hostkey.homie;
                };
            };
        };

        services.openssh = {
            enable = true;
            ports = [ 2222 ];
            openFirewall = true;

            settings = {
                AllowUsers = [ username "builder" ];
                PasswordAuthentication = false;
                PermitRootLogin = "no";
                MaxAuthTries = "5";
             #   UsePAM = "no";
                LogLevel = "VERBOSE";
            };

            extraConfig = ''GSSAPIAuthentication no'';
            moduliFile = pkgs.runCommand "filterModuliFile" {} ''
                awk '$5 >= 3071' "${config.programs.ssh.package}/etc/ssh/moduli" >"$out"
            '';

    #        hostKeys = [
    #            {
     #               comment = "${config.networking.hostName}.local";
    #                path = "/etc/ssh/ssh_host_ed25519_key";
    #                rounds = 100;
     #               type = "ed25519";
     #           }
      #      ];

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
        };}
