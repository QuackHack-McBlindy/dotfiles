{
  config,
  lib,
  pkgs,
  ...
} : let
  backupHosts = [
    "192.168.1.111"
    "192.168.1.28"
    "192.168.1.211"
  ];
in
{
  services.telegraf = {
    enable = true;
    package = pkgs.telegraf;

    extraConfig.inputs = {
      statsd = {
        delete_timings = true;
        service_address = ":8125";
      };
    };
    extraConfig.outputs = {
      influxdb = {
        database = "telegraf";
        urls = [
          "http://localhost:8086"
        ];
      };
    };
 };
}


