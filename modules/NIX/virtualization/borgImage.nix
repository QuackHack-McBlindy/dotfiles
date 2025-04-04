{ pkgs ? import <nixpkgs> {} }:

let
  entrypointScript = pkgs.writeScript "entrypoint.sh" ''
    #!/bin/bash
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

in
pkgs.dockerTools.buildImage {
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
    WorkingDir = "/home/borg";
    Volumes = {
      "/etc/ssh/keys" = {};
      "/home/borg" = {};
    };
  };
}
