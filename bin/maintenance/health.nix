# dotfiles/bin/maintenance/health.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ systemwide health checks  
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let   
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = lib.findSingle (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) null null sysHosts;    
  mqttHostip = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or (
      let
        resolved = builtins.readFile (pkgs.runCommand "resolve-host" {} ''
          ${pkgs.dnsutils}/bin/host -t A ${mqttHost} > $out
        '');
      in
        lib.lists.head (lib.strings.splitString " " (lib.lists.elemAt (lib.strings.splitString "\n" resolved) 0))
    )
    else (throw "No Mosquitto host found in configuration");
  mqttAuth = "-u mqtt -P $(cat ${config.house.mosquitto.passwordFile})";
  
in { # 🦆 says ⮞  
  yo.scripts.health = {
    description = "Check system health status across your machines. Returns JSON structured responses.";
    category = "🧹 Maintenance";  
    aliases = [ "hc" ];
    runEvery = "15";
    code = ''
      ${cmdHelpers}            
      MQTT_BROKER="${mqttHostip}"
      MQTT_USER="${config.house.zigbee.mosquitto.username}"
      MQTT_PASSWORD=$(cat "${config.house.zigbee.mosquitto.passwordFile}")
      HC="$(sudo health)"
      mqtt_pub -t "zigbee2mqtt/health/${config.this.host.hostname}" -m "$HC"
    '';  
    voice = {
      priority = 4;
      sentences = [
        "kolla hälsan på {host}"
        "hur mår {host}"
        "mår {host} okej"
        "visa status för {host}"
      ];
      lists = {
        host.values = [
          { "in" = "[desktop|datorn]"; out = "desktop"; }
          { "in" = "nas"; out = "nasty"; }
          { "in" = "laptop"; out = "laptop"; }
          { "in" = "homie"; out = "homie"; }
        ];
      };   
    };        
    
  };}
