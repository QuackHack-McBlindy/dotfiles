{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : 
let
    inherit (lib) mkIf mkEnableOption mkOption;
    inherit (lib.types) str path bool;
    cfg = config.services.myService;
in
{
    options = {
        services.myService = {
            enable = mkEnableOption "My Custom Service";

            package = mkOption {
                type = path;
                default = "/path/to/binary"; # Replace with actual package reference
                description = "The package or binary for the service.";
            };

        user = mkOption {
            type = str;
            default = "myservice";
            description = "User under which the service runs.";
        };

        group = mkOption {
            type = str;
            default = "myservice";
            description = "Group under which the service runs.";
        };

        dataDir = mkOption {
            type = path;
            default = "/var/lib/myservice";
            description = "Directory for storing service data.";
        };

        configDir = mkOption {
            type = path;
            default = "${cfg.dataDir}/config";
            description = "Configuration directory.";
        };

        logDir = mkOption {
            type = path;
            default = "${cfg.dataDir}/log";
            description = "Log directory.";
        };

        openFirewall = mkOption {
            type = bool;
            default = false;
            description = "Open required ports in the firewall.";
        };

        extraArgs = mkOption {
            type = str;
            default = "";
            description = "Extra arguments passed to the service.";
        };
    };


    config = mkIf cfg.enable {
        systemd = {
            tmpfiles.settings.myServiceDirs = {
                "${cfg.dataDir}"."d" = {
                     mode = "700";
                     inherit (cfg) user group;
                };
            "${cfg.configDir}"."d" = {
                mode = "700";
                inherit (cfg) user group;
            };
            "${cfg.logDir}"."d" = {
                mode = "700";
                inherit (cfg) user group;
            };
        };

        services.myService = {
            description = "My Custom Service";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
                Type = "simple";
                User = cfg.user;
                Group = cfg.group;
                UMask = "0077";
                WorkingDirectory = cfg.dataDir;
                ExecStart = "${cfg.package} --config '${cfg.configDir}' --log '${cfg.logDir}' ${cfg.extraArgs}";
                Restart = "on-failure";
                TimeoutSec = 15;

                # Security hardening (modify as needed)
                NoNewPrivileges = true;
                PrivateTmp = true;
                ProtectSystem = "full";
                ProtectHome = true;
            };
        };
    };

    users.users = mkIf (cfg.user == "myservice") {
        myservice = {
            inherit (cfg) group;
            isSystemUser = true;
        };
    };

    users.groups = mkIf (cfg.group == "myservice") {
        myservice = { };
    };

    networking.firewall = mkIf cfg.openFirewall {
        allowedTCPPorts = [ 12345 ]; 
        allowedUDPPorts = [ ];
    };} 

