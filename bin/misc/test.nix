# 
{ # 🦆 says ⮞ Tells bad jokes
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
  yo.scripts = {
    testStatusCard = {
      description = "Test the unified status card with MQTT messages";
      category = "🛖 Home Automation";
      parameters = [ # 🦆 says ⮞ set your mosquitto user & password
        { name = "testing"; description = "test nr"; optional = false; }      
        { name = "user"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
        { name = "pwfile"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
      ];  
      code = ''
        ${cmdHelpers}
        MQTT_BROKER="${mqttHostip}" && dt_debug "$MQTT_BROKER"
        MQTT_USER="$user" && dt_debug "$MQTT_USER"
        MQTT_PASSWORD=$(cat "$pwfile") 
        # 🦆 says ⮞ MQTT test messages for status card
        MOSQUITTO_AUTH="${mqttAuth}"
        if [ "$testing" -eq 1 ]; then   
          mqtt_pub -t "house/reminders" -m '{"reminders": [{"text": "Call mom - birthday!"}]}'
        fi
        if [ "$testing" -eq 2 ]; then
          mqtt_pub -t "house/shopping/list" -m '{"items": ["Milk", "Eggs", "Bread"], "updated": "'$(date -Iseconds)'"}'  
        fi
        if [ "$testing" -eq 3 ]; then
          mqtt_pub -t "house/calendar/events" -m '{"events": [{"title": "Doctor Appointment", "start": "'$(date -Iseconds -d "+1 hour")'"}]}'
        fi
        if [ "$testing" -eq 4 ]; then
          mqtt_pub -t "house/timers" -m '{"active_timers": [{"name": "Tea Timer", "remaining": 300}]}'
        fi  
        if [ "$testing" -eq 5 ]; then
          mqtt_pub -t "house/reminders" -m '{"reminders": []}'
          mqtt_pub -t "house/timers" -m '{"active_timers": []}'
          mqtt_pub -t "house/calendar/events" -m '{"events": []}'
          mqtt_pub -t "house/shopping/list" -m '{"items": []}'
        fi          
      '';
    };
  };}  
