# dotfiles/bin/home/blink.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ blinks all lights - used for timers, alarms etc.
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

  # 🦆 says ⮞ define Zigbee devices here yo 
  zigbeeDevices = config.house.zigbee.devices;

  # 🦆 says ⮞ Filter to only include light devices
  lightDevices = lib.filterAttrs (_: device: device.type == "light") zigbeeDevices;
 
  # 🦆 says ⮞ case-insensitive device matching
  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  # 🦆 says ⮞ Group devices by room
  roomDevicesMap = let
    grouped = lib.groupBy (device: device.room) (lib.attrValues zigbeeDevices);
  in lib.mapAttrs (room: devices: 
      map (d: d.friendly_name) devices
    ) grouped;

  # 🦆 says ⮞ All devices list for 'all' area
  allDevicesList = lib.attrValues normalizedDeviceMap;

  # 🦆 says ⮞ device validation list
  deviceList = builtins.attrNames normalizedDeviceMap;

  # 🦆 says ⮞ Get Zigbee configuration
  zigbeeCfg = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.services.zigbee2mqtt.settings or {}
    else {};

  # 🦆 says ⮞ Precompute device and group mappings
  devicesSet = zigbeeCfg.devices or {};
  groupsSet = zigbeeCfg.groups or {};

  # 🦆 says ⮞ Room bash map with only lights, using | as separator
  roomBashMap = lib.mapAttrs' (room: devices:
    lib.nameValuePair room (lib.concatStringsSep "|" devices)
  ) roomDevicesMap;

  # 🦆 says ⮞ All devices as a pipe-separated string
  allDevicesStr = lib.concatStringsSep "|" allDevicesList;
in { 
  yo.scripts.blink = {
    description = "Blink all lights for a specified duration";
    category = "🛖 Home Automation";
    parameters = [
      { name = "duration"; description = "Blink duration in seconds"; default = "12"; }
      { name = "user"; description = "Mosquitto username to use"; default = "mqtt"; }    
      { name = "passwordfile"; description = "File path containing password for Mosquitto user"; default = config.sops.secrets.mosquitto.path; }      
    ];
    logLevel =  "INFO";
    code = ''
      ${cmdHelpers}
      MQTT_BROKER="${mqttHostIp}"
      PWFILE="$passwordfile"
      MQTT_USER="$user"
      MQTT_PASSWORD=$(<"$PWFILE")
      interval=1.2
      end=$((SECONDS + duration))    
      MQTT_HOST="${mqttHost}"
      STATE_DIR="${zigduckDir}"
      dt_debug "Mosquitto host: $MQTT_HOST"
      INITIAL_STATE=$(ssh "$MQTT_HOST" "cat .config/zigduck/state.json")
      dt_debug "init state: $INITIAL_STATE"
      lightDeviceNames=( ${lib.concatMapStringsSep " " (dev: "\"${dev.friendly_name}\"") (lib.attrValues lightDevices)} )
      declare -A initial_states=()
      for device in "''${lightDeviceNames[@]}"; do
          device_state=$(jq -r --arg dev "$device" '
              .[$dev] as $d |
              {
                  state: ($d.state // null),
                  brightness: ($d.brightness | if . then tonumber? else null end),
                  color: ($d.color // null)
              } | tostring
          ' <<< "$INITIAL_STATE")          
          initial_states["$device"]="$device_state"
      done
      restore_lights() {
          dt_info "Restoring lights to original state..."
          for device in "''${!initial_states[@]}"; do
              state_json="''${initial_states[$device]}"
              state=$(jq -r '.state' <<< "$state_json")
              brightness=$(jq -r '.brightness' <<< "$state_json")
              color_raw=$(jq -r '.color // empty' <<< "$state_json")
              if jq -e 'type == "string"' <<< "$color_raw" >/dev/null; then
                  color=$(jq -r '.' <<< "$color_raw" 2>/dev/null || echo null)
              else
                  color="$color_raw"
              fi
              if [[ "$state" == "null" || -z "$state" ]]; then
                  dt_info "Skipping $device (no initial state)"
                  continue
              fi 
              if [[ "$state" == "OFF" ]]; then
                  mqtt_pub -t "zigbee2mqtt/$device/set" -m '{"state":"OFF"}'
              else
                  payload='{"state":"ON"'
                  if [[ "$brightness" != "null" && -n "$brightness" ]]; then
                      payload+=", \"brightness\":$brightness"
                  fi
                  if [[ "$color" != "null" && -n "$color" ]]; then
                      color_type=$(jq -r 'type' <<< "$color")
                      if [[ "$color_type" == "string" ]]; then
                          parsed_color=$(jq -r '.' <<< "$color")
                      else
                          parsed_color="$color"
                      fi
                      if jq -e '.hue? and .saturation?' <<< "$parsed_color" >/dev/null; then
                          hue=$(jq -r '.hue' <<< "$parsed_color")
                          sat=$(jq -r '.saturation' <<< "$parsed_color")
                          payload+=", \"color\":{\"hue\":$hue, \"saturation\":$sat}"
                      elif jq -e '.x? and .y?' <<< "$parsed_color" >/dev/null; then
                          x=$(jq -r '.x' <<< "$parsed_color")
                          y=$(jq -r '.y' <<< "$parsed_color")
                          payload+=", \"color\":{\"x\":$x, \"y\":$y}"
                      fi
                  fi
                  payload+="}" 
                  mqtt_pub -t "zigbee2mqtt/$device/set" -m "$payload"
                  dt_debug "Restoring $device with payload: $payload"
              fi
          done
          dt_info "Restoration complete"
      }  
      trap 'restore_lights' EXIT
      dt_info "Blinking all lights for $duration seconds..."
      if_voice_say "Jag blinkar alla lampor i $duration sekunder!"    
      while ((SECONDS < end)); do
          scene max
          sleep $interval
          scene dark-fast
          sleep $interval
      done
      dt_info "Finished blinking lights"
      restore_lights
      trap - EXIT
    '';
#    voice = {
    
#    };
  };}

