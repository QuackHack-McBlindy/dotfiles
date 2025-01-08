# EMPTY NIX OS MODULE
# import into flake.
{ config, pkgs, ... }:

{
   services.home-assistant = {
    enable = true;

    config = {
      homeassistant = {
        name = "My Home Assistant";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        unit_system = "metric";
        time_zone = "Europe/Amsterdam";
      };

      frontend = {
        themes = "!include_dir_merge_named themes";
      };

      http = {
        server_port = 8123;
      };

      lovelace = {
        mode = "yaml";
      };
    };

    # Default and extra integrations
    defaultIntegrations = [ "default_config" ];
    extraComponents = [ "esphome" ];

    # Custom components
    customComponents = [
      pkgs.home-assistant-custom-components.prometheus_sensor
    ];

    # Custom Lovelace modules
    customLovelaceModules = [
      pkgs.home-assistant-custom-lovelace-modules.mini-graph-card
    ];

    # Make config files writable
    configWritable = true;
    lovelaceConfigWritable = true;

    # Open firewall
    openFirewall = true;
  };
}
