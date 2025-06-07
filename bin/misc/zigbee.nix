# dotfiles/bin/misc/zigbee.nix
{ 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
#  sysHosts = lib.attrNames self.nixosConfigurations;
  hasMqtt = host:
    let
      services = (self.nixosConfigurations.${host}.config.this.host.modules.services or {});
    in
      builtins.hasAttr "mqtt" services && services.mqtt != null;

  sysHosts = lib.attrNames self.nixosConfigurations;
  
  # Find the first host with Mosquitto enabled and get its IP
  mqttHost = let
    # Filter hosts that have Mosquitto enabled
    mqttHosts = lib.filter (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) sysHosts;
    
    # Get the first host with Mosquitto enabled
    firstHost = if mqttHosts != [] then lib.head mqttHosts else null;
  in
    if firstHost != null then
      self.nixosConfigurations.${firstHost}.config.this.host.ip
    else
      "localhost";  # Fallback to localhost

  mqttPublish = group: power: let
    topic = "zigbee2mqtt/${group}/set";
    payload = 
      if power == "on" then ''{ "state": "ON" }''
      else if power == "off" then ''{ "state": "OFF" }''
      else if power == "max" then ''{ "state": "ON", "brightness": 255 }''
      else ''{ "state": "UNKNOWN" }'';
  in ''
    echo "Sending to ${group}: ${power} via ${mqttHost}"
    ${pkgs.mosquitto}/bin/mosquitto_pub -h ${mqttHost} -t "${topic}" -m '${payload}'
  '';
in {  
  yo.bitch = { 
    intents = {
      lights = {
        data = [{
          sentences = [
            "{group} {power}"
          ];        
          lists = {
            power.values = [
              { "in" = "tänd"; out = "on"; } 
              { "in" = "ljus"; out = "on"; }
              { "in" = "start"; out = "on"; } 
              { "in" = "starta"; out = "on"; }
              { "in" = "max"; out = "max"; }
              { "in" = "maxxa"; out = "max"; }
                            
              { "in" = "släck"; out = "off"; } 
              { "in" = "släcka"; out = "off"; }
              { "in" = "stäng"; out = "off"; } 
              { "in" = "stänga"; out = "off"; }      
            ];
            group.values = [              
              { "in" = "kök"; out = "kitchen"; } 
              { "in" = "köket"; out = "kitchen"; }            
              { "in" = "vardagsrum"; out = "livingroom"; } 
              { "in" = "vardagsrummet"; out = "livingroom"; }           
              { "in" = "toa"; out = "wc"; } 
              { "in" = "toan"; out = "wc"; }
              { "in" = "toalett"; out = "wc"; } 
              { "in" = "toaletten"; out = "wc"; }
              { "in" = "wc"; out = "wc"; }              
              { "in" = "dass"; out = "wc"; }                                                         
              { "in" = "hall"; out = "hallway"; } 
              { "in" = "hallen"; out = "hallway"; }       
              { "in" = "sovrum"; out = "bedroom"; } 
              { "in" = "sovrummet"; out = "bedroom"; }      
              { "in" = "tv"; out = "entertainment"; } 
              { "in" = "teve"; out = "entertainment"; }
              { "in" = "teven"; out = "entertainment"; } 
              { "in" = "tvn"; out = "entertainment"; }    
              { "in" = "all"; out = "all"; } 
              { "in" = "allt"; out = "all"; }
              { "in" = "alla"; out = "all"; } 
            ];  
          };
        }];
      };  
    };
  };

  yo.scripts.lights = {
    description = "Control lights and other home automatioon devices";
    category = "🧩 Miscellaneous";
    aliases = [ "zb" ];
#    helpFooter = ''
#    '';
    parameters = [  
      { name = "power"; description = "State of the device or group"; }     
      { name = "group"; description = "Device or group to control"; }     
    ];
    code = ''
      ${cmdHelpers}
      mqttPublish() {
        local group="$1"
        local power="$2"
        local topic="zigbee2mqtt/''${group}/set"
        local payload=""

        if [[ "$power" == "on" ]]; then
          payload='{ "state": "ON" }'
        elif [[ "$power" == "off" ]]; then
          payload='{ "state": "OFF" }'
        elif [[ "$power" == "max" ]]; then
          payload='{ "state": "ON", "brightness": 255 }'
        else
          payload='{ "state": "UNKNOWN" }'
        fi

        echo "Sending to ''${group}: ''${power}"
        ''${pkgs.mosquitto}/bin/mosquitto_pub -h ''${mqttHostIp} -t "$topic" -m "$payload"
      }

      map_group() {
        case "$1" in
          kitchen) echo "kitchen" ;;
          livingroom) echo "livingroom" ;;
          wc) echo "wc" ;;
          hallway) echo "hallway" ;;
          bedroom) echo "bedroom" ;;
          entertainment) echo "entertainment" ;;
          all) echo "all" ;;
          *) 
            echo "Unknown group: $1" >&2
            return 1
            ;;
        esac
      }

      power="$1"
      group_key="$2"
      
      group=$(map_group "$group_key") || exit 1

      if [[ "$group" == "all" ]]; then
        # Request list of groups
        ${pkgs.mosquitto}/bin/mosquitto_pub -h ''${mqttHostIp} -t 'zigbee2mqtt/bridge/config/get' -m '{"groups":""}'

        # Read exactly one message with group list
        groups=$(${pkgs.mosquitto}/bin/mosquitto_sub -h ''${mqttHostIp} -t 'zigbee2mqtt/bridge/groups' -C 1 | jq -r '.[].friendly_name')

        for g in $groups; do
          if [[ "$g" != "default_bind_group" ]]; then
            mqttPublish "$g" "$power"
          fi
        done
      else
        mqttPublish "$group" "$power"
      fi

      echo "✅ Sent $power command to $group_key"

    '';
    
  };}
