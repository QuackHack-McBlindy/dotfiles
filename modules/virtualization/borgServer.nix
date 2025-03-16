
        
        
{ 
  config,
  lib,
  pkgs,
  ...
}:

let
  # Import public keys
  pubkey = import ./../../hosts/pubkeys.nix;

  # Define the entrypoint script
  entrypointScript = pkgs.writeScript "entrypoint.sh" ''
    #!/bin/bash
    mkdir -p /home/borg/.ssh
    if [ -n "$AUTHORIZED_KEYS" ]; then
      echo "$AUTHORIZED_KEYS" > /home/borg/.ssh/authorized_keys
      chmod 600 /home/borg/.ssh/authorized_keys
      chown borg:borg /home/borg/.ssh/authorized_keys
    fi

    if [ "$PROTECTION" = "on" ]; then
      echo "PROTECTION mode enabled: Only public key authentication allowed."
      sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
    elif [ "$PROTECTION" = "off" ]; then
      echo "PROTECTION mode disabled: Allowing password authentication."
      sed -i "s/#PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
      echo "borg:borg" | chpasswd
    fi
    exec /usr/sbin/sshd -D
  '';

  # Define the Docker image
  borgImage = pkgs.dockerTools.buildImage {
    name = "borg";
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = with pkgs; [
        bash
        shadow
        openssh
        sudo
        toybox
        busybox
        debianutils
      ];
      pathsToLink = [ "/bin" "/etc" "/usr" "/var" ];
    };

    runAsRoot = ''
      #!${pkgs.runtimeShell}
      ${pkgs.dockerTools.shadowSetup}
      groupadd sudo
      useradd -m -s ${pkgs.bash}/bin/bash borg
      adduser borg sudo
      mkdir -p /run/sshd
      mkdir -p /home/borg/.ssh
      chmod 700 /home/borg/.ssh
      chown borg:borg /home/borg/.ssh
      echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
      chmod 644 /etc/ssh/sshd_config # Ensure the file is writable
      mkdir -p /etc/ssh/keys
      ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f /etc/ssh/keys/ssh_host_rsa_key -N ""
      ${pkgs.openssh}/bin/ssh-keygen -t ecdsa -b 521 -f /etc/ssh/keys/ssh_host_ecdsa_key -N ""
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f /etc/ssh/keys/ssh_host_ed25519_key -N ""
      cp ${entrypointScript} /bin/entrypoint.sh
      chmod +x /bin/entrypoint.sh
    '';

    config = {
      Cmd = [ "/bin/entrypoint.sh" ];
      ExposedPorts = {
        "2222/tcp" = {};
      };
      WorkingDir = "/home/borg"; # Absolute path
      Volumes = {
        "/etc/ssh/keys" = {};
        "/home/borg" = {};
      };
    };
  };

in {
  # Configure the Docker container
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      borgbackup = {
        imageFile = borgImage;
        image = "borg:latest";
        hostname = "borg";
        user = "977:968"; 
        autoStart = true;
        ports = [ "2223:2222" ];
        environment = {                
          AUTHORIZED_KEYS = "${pubkey.desktop} ${pubkey.homie} ${pubkey.nasty}";
          PROTECTION = "on";
        };
        volumes = [
          "/docker/borg:/etc/ssh/keys"
          "/docker/borg/entrypoint.sh:/bin/entrypoint.sh"
          "/backup/borg:/home/borg"
          "/home/borg/.ssh:/home/borg/.ssh" # Bind-mount the .ssh directory
          "/docker/borg/sshd_config:/etc/ssh/sshd_config" # Bind-mount a writable sshd_config
        ];
        extraOptions = [
          "--network=borgnet"
          "--ip=10.10.10.2"    
        ];
        entrypoint = "/bin/entrypoint.sh";
      };
    };    
  };

  # Systemd service to set up directories and Docker network
  systemd.services.borg-setup = {
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      ${pkgs.coreutils}/bin/mkdir -p /docker/borg
      ${pkgs.coreutils}/bin/chown -R $(whoami):$(whoami) /docker/borg
      ${pkgs.coreutils}/bin/chmod -R 755 /docker/borg
      ${pkgs.coreutils}/bin/cp ${entrypointScript} /docker/borg/entrypoint.sh
      ${pkgs.coreutils}/bin/chmod +x /docker/borg/entrypoint.sh

      if ! ${pkgs.docker}/bin/docker network ls | grep -q "borgnet"; then
        ${pkgs.docker}/bin/docker network create --subnet=10.10.10.0/24 borgnet
      fi
    '';

    serviceConfig = {
      ExecStart = "${pkgs.coreutils}/bin/true"; # No-op, as setup is done in preStart
      Restart = "on-failure";
      RestartSec = "2s";
      RuntimeDirectory = [ "/docker/borg" ];
      User = "dockeruser";
    };
  };
}

