{ config, lib, pkgs, ... }:
{
  environment.systemPackages = [
      pkgs.grafana-loki
      pkgs.promtail
  ];
    
#  services.promtail = {
#      enable = true;
#      configuration = {
#          clients = [{
#              url = "http://localhost:3100/loki/api/v1/push";
#          }];
#          positions = {
#              filename = "/var/lib/promtail/positions.yaml";
#          };
#          scrape_configs = [{
#              job_name = "system";
#              static_configs = [{
#                  targets = ["localhost"];
#                  labels = {
#                      job = "varlogs";
#                      __path__ = "/var/log/*log";
#                  };
##          }];
 #     };    
 # };  
    
  services.grafana = {
    enable = true;
    declarativePlugins = [ pkgs.grafana-loki ];
    settings = {
      server = {
        http_port = 3000;
      };
    };
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = { http_listen_port = 3100; };
      common = {
        path_prefix = "/var/lib/loki";
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };
      schema_config.configs = [{
        from = "2020-11-08";
        store = "tsdb";
        object_store = "filesystem";
        schema = "v13";
        index.prefix = "index_";
        index.period = "24h";
      }];
    };
  };
}


