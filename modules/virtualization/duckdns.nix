{ config, pkgs, ... }:

let
  
  duckEnv = ''
    "@DUCKENV@"
  '';

  duckEnvFile = 
    pkgs.runCommand "duckEnvFile"
      { preferLocalBuild = true; }
      ''
        cat > $out <<EOF
${duckEnv}
EOF
      '';
in
{    
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      duckdns = {
        image = "lscr.io/linuxserver/duckdns:latest";
        hostname = "duckdns";
        #dependsOn = [ "" ];
        autoStart = true;
        environmentFiles = [ /run/duckdns/.env ];
      };
    };
  };
  

  systemd.services.duckdns_config = {
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      mkdir -p /run/duckdns
      sed -e "/@DUCKENV@/{
          r ${config.sops.secrets.duckdnsEnv.path}
          d
      }" ${duckEnvFile} > /run/duckdns/.env
    '';
    
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo succes; sleep 200'";
      Restart = "on-failure";
      RestartSec = "2s";
      RuntimeDirectory = [ "duckdns" ];
      User = "duckdns";
    };
  };

  sops.secrets = {
    duckdnsEnv = {
      sopsFile = ./../../secrets/duckdnsEnv.yaml;
      owner = "duckdns";
      group = "duckdns";
      mode = "0660"; 
    };
  };
 
  users.users.duckdns = {
    isSystemUser = true;
    group = "duckdns";
  };

  users.groups.duckdns = { };
  
}  











