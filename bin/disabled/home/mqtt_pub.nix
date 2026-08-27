# dotfiles/bin/home/mqtt_pub.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ mosquitto publisher
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let # 🦆 says ⮞ configuration directory for diz module
  zigduckDir = "/home/" + config.this.user.me.name + "/.config/zigduck";
  # 🦆 says ⮞ findz da mosquitto host
  sysHosts = lib.attrNames self.nixosConfigurations;
  mqttHost = let
    sysHosts = lib.attrNames self.nixosConfigurations;
    mqttHosts = lib.filter (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) sysHosts;
  in
    if mqttHosts != [] then lib.head mqttHosts else null;

  # 🦆 says ⮞ get MQTT broker IP (fallback to localhost)
  mqttHostIp = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or "127.0.0.1"
    else "127.0.0.1";





in {
  yo.scripts.mqtt_pub = {
    description = "Mosquitto publisher";
    category = "🛖 Home Automation"; # 🦆 says ⮞ thnx for following me home
    logLevel = "INFO";
    parameters = [
      { 
        name = "topic"; 
        description = "MQTT topic"; 
        optional = false; 
      }
      { 
        name = "message"; 
        description = "MQTT message"; 
        optional = false; 
      }
    ];  
    code = ''
      ${cmdHelpers}
      MQTT_BROKER="${mqttHostIp}"
      dt_info "MQTT_BROKER: $MQTT_BROKER" 
      MQTT_USER="${config.house.zigbee.mosquitto.username}"
      MQTT_PASSWORD=$(cat "${config.house.zigbee.mosquitto.passwordFile}")
   
      # 🦆 says ⮞ publish to MQTT
      ${pkgs.mosquitto}/bin/mosquitto_pub \
        -h "$MQTT_BROKER" \
        -u "$MQTT_USER" \
        -P "$MQTT_PASSWORD" \
        -t "$topic" \
        -m "$message"
      
      dt_info "Published to topic: $topic"
      dt_info "Message: $message"
    '';

  };}  
    
