{ 
    config,
    lib,
    pkgs,
    ...
} : let

    pubkey = import ./../../hosts/pubkeys.nix;

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
    };

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


    Dockerfile = pkgs.writeText "Dockerfile" ''
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
            echo "Host Public Key (ED25519):" && cat /etc/ssh/keys/ssh_host_ed25519_key.pub
    '';

    run = pkgs.writeText "run.sh" ''
        docker run -d \
            --name borgbackup \
            --hostname borg \
            --user 977:968 \
            --restart unless-stopped \
            -p 2225:2222 \
            -e AUTHORIZED_KEYS="${pubkey.desktop} ${pubkey.homie} ${pubkey.nasty}" \
            -e PROTECTION="on" \
            -v /docker/borg:/etc/ssh/keys \
            -v /docker/borg/entrypoint.sh:/bin/entrypoint.sh \
            -v /backup/borg:/home/borg \
            --network=borgnet \
            --ip=10.10.10.2 \
            borg-borgbackup \
            /bin/entrypoint.sh
    '';
    
    entrypoint = pkgs.writeText "entrypoint.sh" ''
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
    
in {
# sudo chown -R dockeruser:dockeruser /docker/borg
# sudo chmod -R 755 /docker/borg

    virtualisation.oci-containers = {
        backend = "docker";
        containers = {
            borgbackup = {
                imageFile = borgImage;
               # image = "borg:latest";
                hostname = "borg";
                user = "977:968"; 
                autoStart = true;
                ports = [ "2223:2222" ];
                environment = {                
                    AUTHORIZED_KEYS = "${pubkey.desktop} ${pubkey.homie} ${pubkey.nasty}";
                    PROTECTION="on";
                };
                volumes = [
                    "/docker/borg:/etc/ssh/keys"
                    "/docker/borg/entrypoint.sh:/bin/entrypoint.sh"
                    "/backup/borg:/home/borg"
                ];
                extraOptions = [
                   "--network=borgnet"
                   "--ip=10.10.10.2"    
                ];
                entrypoint = "/bin/entrypoint.sh";
            };
        };    
    };
    
    systemd.services.borg-setup = {
        wantedBy = [ "multi-user.target" ];
        preStart = ''
            ${pkgs.coreutils}/bin/mkdir -p /docker/borg
            ${pkgs.coreutils}/bin/cp ${Dockerfile} /docker/borg/Dockerfile
            ${pkgs.coreutils}/bin/cp ${run} /docker/borg/run.sh
            ${pkgs.coreutils}/bin/cp ${entrypoint} /docker/borg/entrypoint.sh
            
            if ! ${pkgs.docker}/bin/docker network ls | grep -q "borgnet"; then
                ${pkgs.docker}/bin/docker network create --subnet=10.10.10.0/24 borgnet
            fi 
        '';
    
        serviceConfig = {
            ExecStart = "${pkgs.bash}/bin/bash -c 'echo Ready to receieve backups! at borg@10.10.10.2; '";
            Restart = "on-failure";
            RestartSec = "2s";
            #RuntimeDirectory = [ "/docker/borg" ];
            User = "dockeruser";
        };
    };}

