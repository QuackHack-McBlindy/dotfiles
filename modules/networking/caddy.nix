{ 
  config,
  inputs,
  pkgs,
  lib,
  ...
} : let

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
    imports = [ ./../virtualization/duckdns.nix ];
  
    environment.systemPackages = with pkgs; [ inputs.caddy-duckdns.packages.x86_64-linux.caddy ];

    networking.firewall.allowedUDPPorts = [ 443 ];
    networking.firewall.allowedTCPPorts = [ 443 ];

    systemd.services.caddy_config = {
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

    sops.secrets = {
        caddyfile = {
            sopsFile = ./../../secrets/caddyfile.yaml;
            owner = "caddy";
            group = "caddy";
            mode = "0660"; 
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
    ];}

