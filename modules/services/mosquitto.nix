# dotfiles/modules/services/mosquitto.nix
{ 
  config,
  lib,
  pkgs,
  ... 
} : {
    config = lib.mkIf (lib.elem "mqtt" config.this.host.modules.services) {
        services.mosquitto = lib.mkIf (!config.this.installer) {
            enable = true;
            listeners = [
              {
                acl = [ "pattern readwrite #" ];
                omitPasswordAuth = true;
                settings.allow_anonymous = true;
                users.mqtt.password = config.sops.secrets.mosquitto.path;
              }
            ];
          };

          networking.firewall = {
            enable = true;
            allowedTCPPorts = [ 1883 ];
          };

        };
    } 
