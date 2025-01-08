{ config, pkgs, ... }:
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
      name = "homie";
      latitude = 0;
      longitude = 0;
      elevation = 0;
      unit_system = "metric";
      time_zone = "UTC";
      temperature_unit = "C";
      country = "US";
      media_dirs = [];
      allowlist_external_dirs = [];
      allowlist_external_urls = [];
      media_url = "http://localhost:8123/local";
      auth_mfa_modules = [ "totp" ];
      auth_mfa_enabled = false;
    };
  };  
  networking.firewall.allowedTCPPorts = [ 8123 ];
}










