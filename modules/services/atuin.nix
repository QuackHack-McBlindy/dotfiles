{ 
  config,
  lib,
  pkgs,
  ... 
} : {
    config = lib.mkIf (lib.elem "atuin" config.this.host.modules.services) {
        environment.systemPackages = [
            pkgs.atuin
            pkgs.postgresql_17_jit
        ];

        services.postgresql = {
            enable = true;
            ensureDatabases = [ "atuin" ];
            ensureUsers = [
                {
                    name = "atuin";
                    ensureDBOwnership = true;
                }
            ];
            
            settings = {
                port = 5432;
                log_connections = true;
                log_statement = "all";
                logging_collector = true;
                log_disconnections = true;
                log_destination = lib.mkForce "syslog";
            };
            # Automatically create the `atuin` user and database
            package = pkgs.postgresql_17_jit;
        };

        services.atuin = {
            enable = true;
            host = "127.0.0.1";
            port = 8888;
            package = pkgs.atuin;
            path = "";
            openFirewall = false;
            openRegistration = true;
            maxHistoryLength = 8192;
            database = {
                createLocally = true;
                # default "postgresql:///atuin?host=/run/postgresql"
                # example "postgresql://atuin@localhost:5432/atuin"
                #uri = "postgresql://atuin@localhost:5432/atuin";
                uri = "postgresql://@/atuin";
            };
        };
    };}   
