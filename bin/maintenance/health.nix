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
      HC="$(health 2>/dev/null | sed -n '/^{/,$p' | jq -c .)"
      yo mqtt_pub --topic "zigduck/health/${config.this.host.hostname}" --message "$HC"
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
