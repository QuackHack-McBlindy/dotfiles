{ 
    config,
    lib,
    pkgs,
    ...
} : let
    pubkey = import ./../../hosts/pubkeys.nix;
    
    textDockerfile = ''
        FROM ubuntu:latest
        RUN apt-get update && apt-get install -y \
            openssh-server \
            sudo \
            toybox \
            busybox \
            debianutils \
            && rm -rf /var/lib/apt/lists/*
        RUN useradd -m -s /bin/bash borg && \
            adduser borg sudo
        RUN mkdir -p /run/sshd
        RUN mkdir -p /home/borg/.ssh && chmod 700 /home/borg/.ssh && chown borg:borg /home/borg/.ssh
        RUN echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
        EXPOSE 2222
        RUN sed -i "s/#Port 22/Port 2222/" /etc/ssh/sshd_config && \
        sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
        RUN mkdir -p /etc/ssh/keys && \
            if [ ! -f /etc/ssh/keys/ssh_host_rsa_key ]; then \
                ssh-keygen -t rsa -b 4096 -f /etc/ssh/keys/ssh_host_rsa_key -N ""; \
            fi && \
            if [ ! -f /etc/ssh/keys/ssh_host_ecdsa_key ]; then \
                ssh-keygen -t ecdsa -b 521 -f /etc/ssh/keys/ssh_host_ecdsa_key -N ""; \
            fi && \
            if [ ! -f /etc/ssh/keys/ssh_host_ed25519_key ]; then \
                ssh-keygen -t ed25519 -f /etc/ssh/keys/ssh_host_ed25519_key -N ""; \
            fi
        RUN echo "Host Public Key (RSA):" && cat /etc/ssh/keys/ssh_host_rsa_key.pub && \
            echo "Host Public Key (ECDSA):" && cat /etc/ssh/keys/ssh_host_ecdsa_key.pub && \
            echo "Host Public Key (ED25519):" && cat /etc/ssh/keys/ssh_host_ed25519_key.pu
        COPY entrypoint.sh /entrypoint.sh
        RUN chmod +x /entrypoint.sh
        ENTRYPOINT ["/entrypoint.sh"]
    '';
    
    textentrypoint = ''    
        #!/bin/bash
        if [ -n "$AUTHORIZED_KEYS" ]; then
            echo "$AUTHORIZED_KEYS" > /home/borg/.ssh/authorized_keys
            chmod 600 /home/borg/.ssh/authorized_keys
            chown borg:borg /home/borg/.ssh/authorized_keys
        fi
        exec /usr/sbin/sshd -D
    '';

    Dockerfile = pkgs.writeTextFile {
        name = "Dockerfile";
        text = textDockerfile;
        destination = "/docker/borg";
    };

    entrypoint = pkgs.writeTextFile {
        name = "entrypoint.sh";
        text = textentrypoint;
        destination = "/docker/borg";
    };    
    
in {
    system.activationScripts.sshConfig = {
        text = ''
           mkdir -p /docker/borg
           ${pkgs.docker}/bin/docker build -t borg-borgbackup:latest /docker/borg
        '';
    };
    
    virtualisation.oci-containers = {
        backend = "docker";
        containers = {
            borgbackup = {
                image = "borg-borgbackup:latest";
                autoStart = true;
                ports = [ "2225:2222" ];
                environment = {
                    #AUTHORIZED_KEYS = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwZL27kGTQDIlSe03abT9F24nSAizORyjo5cI3BD92s";
                    AUTHORIZED_KEYS = "${pubkey.desktop} ${pubkey.homie} ${pubkey.nasty}";
                };
                volumes = [
                    "/docker/borg:/etc/ssh/keys"
                    "/backup/borg:/home/borg"
                ];
                extraOptions = [
                   "--network=borgnet"  # Attach to the custom network
                    "--ip=10.10.10.2"    # Assign a static IP
                ];
            };
        };    
    };}

