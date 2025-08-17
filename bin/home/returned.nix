# dotfiles/bin/home/returned.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Disarm security, set returned home state etc
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
  mqttAuth = "-u mqtt -P $(cat ${config.sops.secrets.mosquitto.path})";
in {  
  yo.scripts.returned = {
    description = "Run when returned home to set home state";
    category = "🛖 Home Automation";
    autoStart = false;
    parameters = [  
           
    ];
    logLevel = "INFO";
    code = ''
      ${cmdHelpers}
      mosquitto_pub -h "${mqttHostip}" -t "zigbee2mqtt/returning_home" -m "RETURN" 
      dt_info "Set state to returned home!"
      yo notify --text "Returned home!"
    '';
    
  };}
