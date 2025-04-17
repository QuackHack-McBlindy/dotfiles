{ config, lib, pkgs, ... }:

let
  # Check if "pairdrop" is enabled via custom module list
  enabled = lib.elem "pairdrop" config.this.host.modules.services;
in {
  # Declare options unconditionally (but configuration is conditional)
  options.services.pairdrop = {
    package = lib.mkPackageOption pkgs "pairdrop" { };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port to run PairDrop server on";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall port for PairDrop";
    };
    extraEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional environment variables for PairDrop";
    };
  };

  # Conditionally apply the configuration
  config = lib.mkIf enabled {
    systemd.services.pairdrop = {
      description = "PairDrop file sharing service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${config.services.pairdrop.package}/bin/pairdrop";
        Restart = "always";
        User = "pairdrop";
        Group = "pairdrop";
        WorkingDirectory = "/var/lib/pairdrop";
        StateDirectory = "pairdrop";
        Environment = 
          (lib.mapAttrsToList (name: value: "${name}=${value}") config.services.pairdrop.extraEnv)
          ++ [ "PORT=${toString config.services.pairdrop.port}" ];
      };
    };

    users.users.pairdrop = {
      isSystemUser = true;
      group = "pairdrop";
      home = "/var/lib/pairdrop";
      createHome = true;
    };

    users.groups.pairdrop = { };

    networking.firewall.allowedTCPPorts = 
      lib.mkIf config.services.pairdrop.openFirewall [ config.services.pairdrop.port ];

    environment.systemPackages = [ config.services.pairdrop.package ];
  };
}
