{ pkgs, ... }:
{
  #imports = [
  #  ./mosquitto.nix
 #   ./media.nix
 # ];

  services.home-assistant = {
    enable = true;
  #  package = (pkgs.home-assistant.override { extraPackages = ps: [ ps.psycopg2 ]; });
    extraPackages = python3Packages: with python3Packages; [ psycopg2 ];
  };  
  services.home-assistant.extraComponents = [ "pushover" ];
  services.home-assistant.config =
    let
      hiddenEntities = [
        "sensor.last_boot"
        "sensor.date"
      ];
    in
    {
      icloud = { };
      frontend = { };
  #    http = {
  #      use_x_forwarded_for = true;
  #      trusted_proxies = [
  #        "127.0.0.1"
  #        "::1"
  #      ];
  #    };
      history.exclude = {
        entities = hiddenEntities;
        domains = [
   #       "automation"
  #        "updater"
        ];
      };
      shopping_list = { };
      backup = { };
      logbook.exclude.entities = hiddenEntities;
      logger.default = "info";
      sun = { };
      prometheus.filter.include_domains = [ "persistent_notification" ];
   #   device_tracker = [
   #     {
   #       platform = "luci";
   #       host = "rauter.r";
   #       username = "!secret openwrt_user";
   #       password = "!secret openwrt_password";
   #     }
   #   ];
      config = { 

        homeassistant = {
          name = "Home";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = "!secret elevation";
          unit_system = "metric";
          time_zone = "UTC";
        };
        frontend = {
          themes = "!include_dir_merge_named themes";
        };
        http = {};
        feedreader.urls = [ "https://nixos.org/blogs.xml" ];
      };
      mobile_app = { };

      cloud = { };
      network = { };
      zeroconf = { };
      system_health = { };
      default_config = { };
      system_log = { };
      mqtt = { };
     # sensor = [
     #   {
     #     platform = "template";
     #     sensors.shannan_joerg_distance.value_template = ''{{ distance('person.jorg_thalheim', 'person.shannan_lekwati') | round(2) }}'';
     #     sensors.joerg_last_updated = {
     #       friendly_name = "Jörg's last location update";
     #       value_template = ''{{ states.person.jorg_thalheim.last_updated.strftime('%Y-%m-%dT%H:%M:%S') }}Z'';
     #       device_class = "timestamp";
     #     };
     #     sensors.shannan_last_updated = {
     #       friendly_name = "Shannan's last location update";
     #       value_template = ''{{ states.person.shannan_lekwati.last_updated.strftime('%Y-%m-%dT%H:%M:%S') }}Z'';
     #       device_class = "timestamp";
     #     };
     #   }
     # ];
    };

  services.nginx.virtualHosts."ha.local" = {
    useACMEHost = "ha.local";
    forceSSL = true;
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/".extraConfig = ''
      proxy_pass http://127.0.0.1:8123;
      proxy_set_header Host $host;
      proxy_redirect http:// https://;
      proxy_http_version 1.1;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
    '';
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  
  # Create _cummon.yaml for Voice Assistant
 # system.activationScripts.writeCommonFile = ''
 
  sops.secrets = {
    ha-secrets = {
      sopsFile = "/var/lib/sops-nix/secrets/ha-secrets.yaml"; 
   #  owner = config.users.users.secretservice.name;
      #group = config.users.groups.secretservice.name;
      mode = "0440"; # Read-only for owner and group
      owner = "hass";
      path = "/var/lib/sops-nix/secrets/hasecrets.yaml";
      restartUnits = [ "home-assistant.service" ];
    };
  };

#  config.sops.secrets.ha-secrets.path;

  sops.secrets."home-assistant-secrets.yaml" = {
    owner = "hass";
    path = "/var/lib/sops-nix/secrets/hasecrets.yaml";
    restartUnits = [ "home-assistant.service" ];
  };
}
