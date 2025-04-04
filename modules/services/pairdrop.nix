{   config,
    lib,
    pkgs,
    ...
} : let
    cfg = config.services.pairdrop;
in {
    options.services.pairdrop = {
        enable = lib.mkEnableOption "PairDrop file sharing service";
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

    config = lib.mkIf cfg.enable {
        systemd.services.pairdrop = {
            description = "PairDrop file sharing service";
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" ];

            serviceConfig = {
                ExecStart = "${cfg.package}/bin/pairdrop";
                Restart = "always";
                User = "pairdrop";
                Group = "pairdrop";
                WorkingDirectory = "/var/lib/pairdrop";
                StateDirectory = "pairdrop";
                Environment = lib.mkMerge [
                    (lib.mapAttrsToList (name: value: "${name}=${value}") cfg.extraEnv)
                    "PORT=${toString cfg.port}"
                ];
            };
        };

        users.users.pairdrop = {
            isSystemUser = true;
            group = "pairdrop";
            home = "/var/lib/pairdrop";
            createHome = true;
        };

        users.groups.pairdrop = { };

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

        environment.systemPackages = [ cfg.package ];
    };}
