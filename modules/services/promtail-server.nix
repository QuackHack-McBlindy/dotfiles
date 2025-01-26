{ 
    config, 
    lib, 
    pkgs, 
    ... 
} : { 


    environment.systemPackages = [
        pkgs.grafana-loki
        pkgs.promtail
    ];

    services.grafana = {
        enable = true;
        #declarativePlugins = with pkgs.grafanaPlugins; [ grafana-piechart-panel ]; # grafana-loki
        declarativePlugins = [ pkgs.grafana-loki ];
    };
    

#    services.loki = {
#        enable = true;
#        configuration = {
#            server = {
#                http_listen_port = 3100;
#            };
#            storage_config = {
#                boltdb_shipper = {
#                    active_index_directory = "/var/lib/loki/index";
#                    cache_location = "/var/lib/loki/cache";
#                    shared_store = "/var/lib/loki/store";
#                };
#            };
#            schema_config = {
#                configs = [{
#                    from = "2020-10-24";
#                    store = "boltdb-shipper";
#                    object_store = "filesystem";
#                    schema = "v11";
#                }];
#            };
#        };

        # Optional extra flags if needed
      #  extraFlags = [
            # "--some-flag"  # Add additional flags if required
     #   ];

        # Ensure that Loki can create necessary directories
     #   dataDir = "/var/lib/loki";
#    };

    services.promtail = {
        enable = true;
        configuration = {
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
    
