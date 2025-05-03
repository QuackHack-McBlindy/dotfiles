{ 
  config,
  lib,
  pkgs,
  self,
  ...
} : let
  user = config.this.user.me.name;
  
  # Get all host configurations through self
  allHosts = self.nixosConfigurations;
  
  # Filter out current host
  otherHosts = lib.filterAttrs (name: _: name != config.networking.hostName) allHosts;

  # Generate knownHosts entries for all other hosts
  knownHostsEntries = lib.mapAttrs' (hostName: hostCfg: 
    lib.nameValuePair hostName {
      extraHostNames = hostCfg.config.networking.hosts.${hostCfg.config.networking.hostName}.hostnames or [];
      publicKey = config.this.host.keys.publicKeys.host;
    }
  ) otherHosts;

  # Collect all user SSH keys from other hosts (FIXED HERE)
  authorizedKeys = lib.concatMap (hostCfg:
    let keys = hostCfg.config.this.host.keys.publicKeys.ssh or [];
    in if builtins.isList keys then keys else [keys]
  ) (lib.attrValues allHosts);

  # Rest of your original LAN hosts configuration
  lanHosts = lib.concatStringsSep "\n" (  
    lib.flatten (  
      lib.mapAttrsToList (ip: names:  
        lib.concatStringsSep "\n" (map (name: "Host ${name}\n    Port 2222\n    UseRoaming no") names)  
      ) config.networking.hosts  
    )  
  );

  sshConfigText = ''
    ${lanHosts}

    Host *
      Port 22
      UseRoaming no
  '';

  sshConfig = pkgs.writeTextFile {
    name = "ssh-config";
    text = sshConfigText;
  };


in {
  config = lib.mkIf (lib.elem "ssh" config.this.host.modules.services) {
    system.activationScripts.sshConfig = {
      text = ''
        mkdir -p /home/${user}/.ssh
        cp ${sshConfig} /home/${user}/.ssh/config
        chown ${user}:${user} /home/${user}/.ssh/config
        chmod 600 /home/${user}/.ssh/config
      '';
    };

    networking.firewall.allowedTCPPorts = [ 2222 ];

    users.users.${user}.openssh.authorizedKeys.keys = authorizedKeys;

    programs.ssh.knownHosts = knownHostsEntries;

    services.openssh = {
      enable = true;
      ports = [ 2222 ];
      openFirewall = true;

      settings = {
        AllowUsers = [ user "builder" ];
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        MaxAuthTries = "5";
        LogLevel = "VERBOSE";
      };

      extraConfig = ''GSSAPIAuthentication no'';
      moduliFile = pkgs.runCommand "filterModuliFile" {} ''
        awk '$5 >= 3071' "${config.programs.ssh.package}/etc/ssh/moduli" >"$out"
      '';

      listenAddresses = [
        { addr = "0.0.0.0"; port = 2222; }
        { addr = "[::]"; port = 2222; }
      ];
    };
  };
}
