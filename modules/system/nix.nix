{ 
  config,
  lib,
  pkgs,
  ...
} : let
      
    SSLpem = ''
        "@SSLCERT@"
    '';
    SSLFile = 
        pkgs.runCommand "SSLFile"
            { preferLocalBuild = true; }
            ''
            cat > $out <<EOF
${SSLpem}
EOF
            '';   
    buildKey = ''
        "@BUILDKEY@"
    '';

    buildKeyFile = 
        pkgs.runCommand "buildKeyFile"
            { preferLocalBuild = true; }
            ''
            cat > $out <<EOF
${buildKey}
EOF
            '';   
in {
    config = lib.mkIf (lib.elem "nix" config.this.host.modules.system) {
        documentation.nixos.enable = false;
        nixpkgs.config.allowUnfree = true;
        system.tools.nixos-option.enable = true;

        nix = {
            distributedBuilds = true;

            buildMachines = [{
                protocol = "ssh";
                hostName = "desktop";
                sshUser = "builder";
                sshKey = "/root/.ssh/id_ed25519_builder";
                system = "x86_64-linux";
                maxJobs = 4;
                speedFactor = 5;
                supportedFeatures = [ "kvm" "big-parallel" ];
                mandatoryFeatures = [ "big-parallel" ];
            }];

            settings = {
                # direnv
                keep-outputs = true;
                keep-derivations = true;

                warn-dirty = false;
                experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
                auto-optimise-store = true;
                sandbox = true;
                log-lines = 30;
                min-free = 1073741824; # 1GB
                max-free = 8589934592; # 8GB

                builders-use-substitutes = true;
                allowed-users = [
                    "@wheel"
                    "builder"
                    "pungkula"
                ];
                trusted-users = [
                    "root"
                    "pungkula"
                    "builder"
                ];
                trusted-public-keys = [ config.this.host.keys.publicKeys.cache ];
                substituters = [
                    "https://cache/"
                    "https://cache.nixos.org/"
                ];
            };

            extraOptions = ''
                download-buffer-size = 2097152
                connect-timeout = 15
                http-connections = 50

                show-trace = true
                trace-function-calls = false
            '';

            gc = {
                automatic = true;
                dates = "weekly";
                options = "--delete-older-than 7d";
            };
        };

        systemd.services.clear-log = {
            description = "Clear >1 month-old logs every week";
            serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs.systemd}/bin/journalctl --vacuum-time=21d";
            };
        };    
        systemd.timers.clear-log = {
            wantedBy = [ "timers.target" ];
            partOf = [ "clear-log.service" ];
            timerConfig.OnCalendar = "weekly UTC";
        }; 

        systemd.services.build_config = lib.mkIf (!config.this.installer) {
            wantedBy = [ "multi-user.target" ];

            preStart = ''
                mkdir -p /root/.ssh
                sed -e "/@BUILDKEY@/{
                    r ${config.sops.secrets.id_ed25519_builder.path}
                    d
                }" ${buildKeyFile} > /root/.ssh/id_ed25519_builder
                
                mkdir -p /root/.ssh
                sed -e "/@SSLCERT@/{
                    r ${config.sops.secrets.cache_cert.path}
                    d
                }" ${SSLFile} > /etc/ssl/certs/cache_cert.pem
            '';

            serviceConfig = {
                ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes;'";
                Restart = "on-failure";
                RestartSec = "2s";
                RuntimeDirectory = [ "root" ];
                User = "root";
            };
        };

       # FIXME TRUST CERTIFICATE
        security.pki.certificateFiles = [  ];

        sops.secrets = lib.mkIf (!config.this.installer) {
            id_ed25519_builder = {
                sopsFile = ./../../secrets/id_ed25519_builder.yaml;
                owner = "root";
                group = "root";
                mode = "0440";
            };
            cache_cert = {
                sopsFile = ./../../secrets/cache_cert.yaml;
                owner = "root";
                group = "root";
                mode = "0440";
            };
        };    
    };}
