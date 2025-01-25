{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 
    services.promtail = {
        enable = true;
        config = {
            clients = [{
                url = "http://<loki-server-ip>:3100/loki/api/v1/push";
            }];
            positions = {
                filename = "/var/lib/promtail/positions.yaml";
            };
            scrape_configs = [{
                job_name = "system";
                static_configs = [{
                    targets = ["localhost"];
                    labels = {
                        job = "varlogs";
                        __path__ = "/var/log/*log";
                    };
                }];
            }];
        };
    };}
