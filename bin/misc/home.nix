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
  mqttHost = let
    sysHosts = lib.attrNames self.nixosConfigurations;
    mqttHosts = lib.filter (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) sysHosts;
  in
    if mqttHosts != [] then lib.head mqttHosts else null;

  # Get MQTT broker IP (fallback to localhost)
  mqttHostIp = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or "127.0.0.1"
    else "127.0.0.1";
  
  mqttPort = 1883;

  # Get Zigbee configuration
  zigbeeCfg = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.services.zigbee2mqtt.settings or {}
    else {};

  # Precompute device and group mappings
  devicesSet = zigbeeCfg.devices or {};
  groupsSet = zigbeeCfg.groups or {};

  # Create device list for help footer
  deviceList = 
    let
      names = lib.mapAttrsToList (_: cfg: cfg.friendly_name or (cfg.description or "Unknown")) devicesSet;
      uniqueNames = lib.unique names;
    in
      lib.concatMapStringsSep "\n" (name: "    ${name}") uniqueNames;

  
in {  
  yo.bitch = { 
    intents = {
      lights = {
        data = [{
          sentences = [
            "{device} {state}"
#            "{device} {state}"
#            "{area} {color}"
#            "{area} {state} {color}"
          ];        
          lists = {
            state.values = [
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
            area.values = [              
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
            color.values = [
              { "in" = "röd"; out = "red"; }
              { "in" = "rött"; out = "red"; }
              { "in" = "grön"; out = "green"; }
              { "in" = "grönt"; out = "green"; }
              { "in" = "blå"; out = "blue"; }
              { "in" = "blått"; out = "blue"; }
              { "in" = "vit"; out = "white"; }
              { "in" = "vitt"; out = "white"; }
              { "in" = "gul"; out = "yellow"; }
              { "in" = "gult"; out = "yellow"; }
              { "in" = "lila"; out = "purple"; }
              { "in" = "ljust"; out = "bright"; }
              { "in" = "warm"; out = "warm"; }
              { "in" = "kall"; out = "cold"; }
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
    helpFooter = ''
      \n📟 Available devices:
      ${deviceList}
      
      \n🎨 Color options:
        red, green, blue, white, yellow, purple
        bright, warm, cold
        or use hex codes like #FF0000 for red
    '';
    parameters = [  
      { name = "state"; description = "State of the device or group"; optional = true; }    
      { name = "device"; description = "Device to control"; optional = true; }
      { name = "area"; description = "Device or group to control"; optional = true; }
      { name = "brightness"; description = "Brightness value of the device or group"; optional = true; }    
      { name = "color"; description = "Color to set on the device"; optional = true; }    
    ];
    code = ''
      ${cmdHelpers}
      
      power="$state"
      device="$device"
      group="$area"
      mqttHostIp="$mmqttHostIp"
      mqttPort=toString "1883"

      target="$device"
      if [ -z "$target" ]; then
        target="$group"
      fi

      [[ -z "$target" ]] && fail "No device or area specified"
      [[ -z "$power" ]] && fail "Missing state (on/off/max)"

      echo "Using MQTT broker at: ${mqttHostIp}:'1883'"


      if [[ "$target" == "all" ]]; then
        # Get all unique friendly names
        devices=$(
          ${pkgs.jq}/bin/jq -rn '
            ${builtins.toJSON (lib.unique (lib.mapAttrsToList (_: v: v.friendly_name or "") devicesSet))
            } .[]'
        )
      elif [[ -n "$group" ]]; then
        # Resolve group devices
        devices=$(
          ${pkgs.jq}/bin/jq -rn --arg group "$group" '
            ${builtins.toJSON groupsSet} 
            | .[$group] // {}
            | .devices // []
            | map(split("/")[0] as $id | 
                ${builtins.toJSON devicesSet}[$id].friendly_name // $id)
            | .[]'
        )
        [[ -z "$devices" ]] && die "Unknown group: $group"
      else
        # Resolve single device
        devices=$(
          ${pkgs.jq}/bin/jq -rn --arg target "$target" '
            ${builtins.toJSON devicesSet}
            | to_entries[]
            | select(.value.friendly_name == $target).value.friendly_name'
        )
        [[ -z "$devices" ]] && die "Unknown device: $target"
      fi

      # MQTT publish function
      mqtt_publish() {
        local device="$1"
        local topic="zigbee2mqtt/$device/set"
        local payload
        
        case "$power" in
          on) payload='{"state":"ON"}' ;;
          off) payload='{"state":"OFF"}' ;;
          max) payload='{"state":"ON","brightness":255}' ;;
          *) die "Invalid state: $power" ;;
        esac

        echo "  → $device: $power"
        ${pkgs.mosquitto}/bin/mosquitto_pub \
          -h "${mqttHostIp}" \
          -p "${toString mqttPort}" \
          -t "$topic" \
          -m "$payload"
      }

      echo "Controlling devices:"
      while IFS= read -r dev; do
        [[ -n "$dev" ]] && mqtt_publish "$dev"
      done <<< "$devices"


      #######################################
      ##    FAILOVER MECHANISM (Conceptual)
      # TODO: Implement actual failover logic
      # This would monitor the system and transfer control to a backup host
      # if the primary becomes unresponsive for more than 1 minute
      #
      # while true; do
      #   if ! check_primary_alive; then
      #     echo "⚠️ Primary down! Transferring to backup..."
      #     yo deploy <backup-host> && reboot
      #     break
      #   fi
      #   sleep 30
      # done
    ''; 
  };}
