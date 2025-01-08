# EMPTY NIX OS MODULE
# import into flake.
{ config, pkgs, ... }:

{
  services.open-webui = {
    enable = true;
    package = pkgs.open-webui;
    stateDir = "/var/lib/open-webui";
    host = "0.0.0.0";
    port = 8080;
    environment = {
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      ANONYMIZED_TELEMETRY = "False";
    };
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];

  # Other configuration settings...
}
