# dotfiles/modules/services/ssh.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ 
  config,
  lib,
  pkgs,
  self,
  ...
} : let
  user = config.this.user.me.name;
  allHosts = self.nixosConfigurations;
  
  # 🦆 duck say ⮞ filter out current host
  otherHosts = lib.filterAttrs (name: _: name != config.networking.hostName) allHosts;

  # 🦆 duck say ⮞ generate knownHosts for all other hostz
  knownHostsEntries = lib.filterAttrs (_: v: v.publicKey != null) (lib.mapAttrs' (hostName: hostCfg: 
    lib.nameValuePair hostName {
      extraHostNames = [ hostCfg.config.networking.hostName ];
      publicKey = hostCfg.config.this.host.keys.publicKeys.host or null;
    }
  ) otherHosts);

  # 🦆 duck say ⮞ collect all user SSH keys from other hostz yo
  authorizedKeys = let
    # 🦆 duck say ⮞ SSH keys from all hosts
    hostKeys = lib.concatMap (hostCfg:
      let keys = hostCfg.config.this.host.keys.publicKeys.ssh or [];
      in if builtins.isList keys then keys else [ keys ]
    ) (lib.attrValues allHosts);
    # 🦆 duck say ⮞ additional keys
    extraKeys = builtins.filter (x: x != null) [
      config.this.host.keys.publicKeys.iPhone or null
    ];
  in hostKeys ++ extraKeys;

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
  
  sshUserKey = ''
      "@SSHUSERKEY@"
  '';
  sshUserKeyFile = 
      pkgs.runCommand "sshUserKeyFile"
          { preferLocalBuild = true; }
          ''
          cat > $out <<EOF
${sshUserKey}
EOF
          '';
in {
  config = lib.mkIf (lib.elem "ssh" config.this.host.modules.services) {
    system.activationScripts.sshConfig = {
      text = ''
        mkdir -p /home/${user}/.ssh
        chown ${user}:${user} /home/${user}/.ssh
        chmod 700 /home/${user}/.ssh
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

#      extraConfig = ''GSSAPIAuthentication no'';
      moduliFile = pkgs.runCommand "filterModuliFile" {} ''
        awk '$5 >= 3071' "${config.programs.ssh.package}/etc/ssh/moduli" >"$out"
      '';

      listenAddresses = [
        { addr = "0.0.0.0"; port = 2222; }
        { addr = "[::]"; port = 2222; }
      ];
    };
    
    systemd.services.userkey = lib.mkIf (!config.this.installer) {
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        sed -e "/@SSHUSERKEY/{
            r ${config.sops.secrets."users/pungkula/ssh_ed25519".path}
            d
        }" ${sshUserKeyFile} > ~/.ssh/id_ed25519
        echo '${config.this.host.keys.publicKeys.ssh}' > ~/.ssh/id_ed25519.pub
        chmod 600 ~/.ssh/id_ed25519
        chmod 644 ~/.ssh/id_ed25519.pub
        chown ${config.this.user.me.name}:${config.this.user.me.name} ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub
      '';

      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
        Restart = "on-failure";
        RestartSec = "2s";
        RuntimeDirectory = [ config.this.user.me.name ];
        User = config.this.user.me.name;
      };
    };

    sops.secrets = lib.mkIf (!config.this.installer) {
      "users/pungkula/ssh_ed25519" = {
        sopsFile = ./../../secrets/users/${config.this.user.me.name}/ssh_ed25519.yaml; 
        owner = config.this.user.me.name;
        group = config.this.user.me.name;
        mode = "0400"; # Read-only for owner and group
      };    
    };
  };
}
