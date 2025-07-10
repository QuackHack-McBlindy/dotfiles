# dotfiles/lib/hidden.nix
{ lib, pkgs }:

let
  hidden = secretName: { config, ... }: let
    # Automatic inference of all parameters
    placeholder = "@${lib.toUpper secretName}@";
    dest = "/run/secrets/${secretName}";
    user = config.this.user.me.name;
    serviceName = "${secretName}-secret-setup";
    
    templateFile = pkgs.runCommand "secret-template" {
      preferLocalBuild = true;
    } "echo -n '${placeholder}' > $out";  # -n to avoid trailing newline
    
  in {
    options = {
      hidden.secrets.${secretName} = lib.mkOption {
        type = lib.types.path;
        default = dest;
        readOnly = true;
        description = "Runtime path to ${secretName} secret";
      };
    };

    config = {
      sops.secrets.${secretName} = {
        sopsFile = ./../../secrets/${secretName}.yaml;
        owner = user;
      };

      systemd.services.${serviceName} = {
        wantedBy = ["multi-user.target"];
        preStart = ''
          mkdir -p $(dirname ${dest})
          sed -e "/${placeholder}/{
            r ${config.sops.secrets.${secretName}.path}
            d
          }" ${templateFile} > ${dest}
        '';
        serviceConfig = {
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo ${secretName} secret ready'";
          Restart = "on-failure";
          RestartSec = "2s";
          RuntimeDirectory = [serviceName];
          User = user;
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    };
  };
in {
  inherit hidden;
}
