# dotfiles/modules/networking/caddy.nix
{ 
  config,
  lib,
  pkgs,
  inputs,
  ...
} : let
  duckEnv1 = ''
    "@DUCKENV1@"
  '';

  duckEnvFile1 = 
    pkgs.runCommand "duckEnvFile1"
      { preferLocalBuild = true; }
      ''
        cat > $out <<EOF
${duckEnv1}
EOF
      '';
            
  duckEnv2 = ''
    "@DUCKENV2@"
  '';

  duckEnvFile2 = 
    pkgs.runCommand "duckEnvFile2"
      { preferLocalBuild = true; }
      ''
        cat > $out <<EOF
${duckEnv2}
EOF
      '';      

  duckEnv3 = ''
    "@DUCKENV3@"
  '';

  duckEnvFile3 = 
    pkgs.runCommand "duckEnvFile3"
      { preferLocalBuild = true; }
      ''
        cat > $out <<EOF
${duckEnv3}
EOF
      '';

    caddyConfig = ''
        "@CADDYFILE@"
    '';
    caddyFile = 
        pkgs.runCommand "caddyFile"
            { preferLocalBuild = true; }
            ''
            cat > $out <<EOF
${caddyConfig}
EOF
            '';
in {
    config = lib.mkIf (lib.elem "caddy" config.this.host.modules.networking) {
        environment.systemPackages = with pkgs; [ inputs.caddy-duckdns.packages.x86_64-linux.caddy ];

        networking.firewall.allowedUDPPorts = [ 443 53 ];
        networking.firewall.allowedTCPPorts = [ 443 53 ];

        systemd.services.caddy_config = lib.mkIf (!config.this.installer) {
            wantedBy = [ "multi-user.target" ];
            preStart = ''
                mkdir -p /run/caddy
                sed -e "/@CADDYFILE@/{
                    r ${config.sops.secrets.caddyfile.path}
                    d
                }" ${caddyFile} > /run/caddy/Caddyfile
            '';

            serviceConfig = {
                ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
                Restart = "on-failure";
                RestartSec = "2s";
                RuntimeDirectory = [ "caddy" ];
                User = "caddy";
            };
        };

        systemd.services.caddy = {
            description = "Caddy web server";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                Environment = "XDG_DATA_HOME=/var/lib/caddy";
                ExecStart = "${inputs.caddy-duckdns.packages.x86_64-linux.caddy}/bin/caddy run --config=/run/caddy/Caddyfile --adapter caddyfile";
                User = "caddy";
                StateDirectory = "caddy";
                AmbientCapabilities = "cap_net_bind_service";
            };
        };
        

        users.users.caddy = {
            isSystemUser = true;
            group = "caddy";
            home = "/var/lib/caddy";
            createHome = true;
        };
        users.groups.caddy = { };
        systemd.tmpfiles.rules = [
            "d /var/lib/caddy 0755 caddy caddy - -"
        ];
        
#      virtualisation.oci-containers = {
#        backend = "docker";
#        containers = {
#          duckdns1 = {
#            image = "lscr.io/linuxserver/duckdns:latest";
            #user = "${toString duckdnsUID}:${toString duckdnsGID}";
#            user = "2001:2001";
#            hostname = "duckdns1";
            #dependsOn = [ "" ];
#            autoStart = true;
#            environmentFiles = [ /run/duckdns/.1.env ];
           # environment = {
          #    PUID = toString duckdnsUID;
          #    PGID = toString duckdnsGID;
         #   };
#            environment = {
#              PUID = "2001";
#              PGID = "2001";
#            };
#          };
#          duckdns2 = {
#            image = "lscr.io/linuxserver/duckdns:latest";
#            user = "2001:2001";
#            hostname = "duckdns2";
            #dependsOn = [ "" ];
#            autoStart = true;
#            environmentFiles = [ /run/duckdns/.2.env ];
#            environment = {
#              PUID = "2001";
#              PGID = "2001";
#            };
#          };
#          duckdns3 = {
#            image = "lscr.io/linuxserver/duckdns:latest";
#            user = "2001:2001";
#            hostname = "duckdns3";
            #dependsOn = [ "" ];
#            autoStart = true;
#            environmentFiles = [ /run/duckdns/.3.env ];
#            environment = {
#              PUID = "2001";
#              PGID = "2001";
#            };
#          };
#        };
#      };

      systemd.services.duckdns_config1 = lib.mkIf (!config.this.installer) {
        wantedBy = [ "multi-user.target" ];

        preStart = ''
          mkdir -p /run/duckdns
          sed -e "/@DUCKENV1@/{
              r ${config.sops.secrets.duckdnsEnv-x.path}
              d
          }" ${duckEnvFile1} > /run/duckdns/.1.env
        '';

        serviceConfig = {
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
          Restart = "on-failure";
          RestartSec = "2s";
          RuntimeDirectory = [ "duckdns" ];
          User = "duckdns";
        };
      };


      systemd.services.duckdns_config2 = lib.mkIf (!config.this.installer) {
        wantedBy = [ "multi-user.target" ];

        preStart = ''
          mkdir -p /run/duckdns
          sed -e "/@DUCKENV2@/{
              r ${config.sops.secrets.duckdnsEnv-gh-pungkula.path}
              d
          }" ${duckEnvFile2} > /run/duckdns/.2.env
        '';

        serviceConfig = {
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
          Restart = "on-failure";
          RestartSec = "2s";
          RuntimeDirectory = [ "duckdns" ];
          User = "duckdns";
        };
      };

      systemd.services.duckdns_config3 = lib.mkIf (!config.this.installer) {
        wantedBy = [ "multi-user.target" ];
        preStart = ''
          mkdir -p /run/duckdns
          sed -e "/@DUCKENV3@/{
              r ${config.sops.secrets.duckdnsEnv-gh-quackhack.path}
              d
          }" ${duckEnvFile3} > /run/duckdns/.3.env
        '';

        serviceConfig = {
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
          Restart = "on-failure";
          RestartSec = "2s";
          RuntimeDirectory = [ "duckdns" ];
          User = "duckdns";
        };
      };

      sops.secrets = lib.mkIf (!config.this.installer) {
        caddyfile = {
          sopsFile = ./../../secrets/caddyfile.yaml;
          owner = "caddy";
          group = "caddy";
          mode = "0660";
        };
        duckdnsEnv-x = {
          sopsFile = ./../../secrets/duckdnsEnv-x.yaml;
          owner = "duckdns";
          group = "duckdns";
          mode = "0660";
        };
        duckdnsEnv-gh-pungkula = {
          sopsFile = ./../../secrets/duckdnsEnv-gh-pungkula.yaml;
          owner = "duckdns";
          group = "duckdns";
          mode = "0660";
        };
        duckdnsEnv-gh-quackhack = {
          sopsFile = ./../../secrets/duckdnsEnv-gh-quackhack.yaml;
          owner = "duckdns";
          group = "duckdns";
          mode = "0660";
        };
      };

      users.users.duckdns = {
        isSystemUser = true;
        group = "duckdns";
        uid = 2001;
      };

      users.groups.duckdns = {
        gid = 2001;
      };

    };}
