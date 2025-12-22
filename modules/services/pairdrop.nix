# dotfiles/modules/services/pairdrop.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ file sharing between devices from browser
  config,
  lib,
  pkgs,
  ...
} : let
  enabled = lib.elem "pairdrop" config.this.host.modules.services;
in {

  options.services.pairdropp = {
    package = lib.mkPackageOption pkgs "pairdrop" { };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port to run PairDrop server on";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall port for PairDrop";
    };
    extraEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional environment variables for PairDrop";
    };
  };

  config = lib.mkIf enabled {
    systemd.services.pairdrop = {
      description = "PairDrop file sharing service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${config.services.pairdropp.package}/bin/pairdrop";
        Restart = "always";
        User = "pairdrop";
        Group = "pairdrop";
        WorkingDirectory = "/var/lib/pairdrop";
        StateDirectory = "pairdrop";
        Environment = 
          (lib.mapAttrsToList (name: value: "${name}=${value}") config.services.pairdropp.extraEnv)
          ++ [ "PORT=${toString config.services.pairdropp.port}" ];
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
      lib.mkIf config.services.pairdropp.openFirewall [ config.services.pairdrop.port ];

    environment.systemPackages = [ config.services.pairdropp.package ];

  };}
