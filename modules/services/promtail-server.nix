{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 

    services.grafana = {
        enable = true;
        plugins = [ "grafana-loki" ];
    };

    services.loki = {
        enable = true;
        config = {
            server = {
                http_listen_port = 3100;
            };
            storage_config = {
                boltdb_shipper = {
                    active_index_directory = "/var/lib/loki/index";
                    cache_location = "/var/lib/loki/cache";
                    shared_store = "/var/lib/loki/store";
                };
            };
            schema_config = {
                configs = [{
                    from = "2020-10-24";
                    store = "boltdb-shipper";
                    object_store = "filesystem";
                    schema = "v11";
                }];
            };
        };

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
        };
    };}  
















  
  

