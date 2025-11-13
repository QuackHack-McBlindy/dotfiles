# dotfiles/bin/misc/reminder.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ memory management
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = "homie";
#  mqttHost = lib.findSingle (host:
#      let cfg = self.nixosConfigurations.${host}.config;
#      in cfg.services.mosquitto.enable or false
#    ) null null sysHosts;    
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
  environment.systemPackages = [ pkgs.at ]; # 🦆 says ⮞ when at wat
  # 🦆 says ⮞ dat
  yo.scripts.reminder = {
    description = "Reminder Assistant";
    category = "🧩 Miscellaneous";
    aliases = [ "remind" ];
    autoStart = false;
    logLevel = "DEBUG";
    parameters = [
      { name = "about"; description = "What to be reminded about"; optional = true; }
      { name = "list"; type = "bool"; description = "Flag for listing all reminders"; optional = true; default = false; }            
      { name = "clear"; type = "bool"; description = "Clear all reminders"; optional = true; default = false; }
      { name = "user"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "pwfile"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
    ];
    code = ''
      ${cmdHelpers}
      MQTT_BROKER="${mqttHostip}" && dt_debug "$MQTT_BROKER"
      MQTT_USER="$user" && dt_debug "$MQTT_USER"
      MQTT_PASSWORD=$(cat "$pwfile")
      REMINDER_DIR="/home/pungkula/.reminders"
      mkdir -p "$REMINDER_DIR"

      REMINDER_DIR="/home/pungkula/.reminders"
      mkdir -p "$REMINDER_DIR"

      # 🦆 says ⮞ MQTT functions
      publish_reminder() {
        local action="$1"
        local id="$2"
        local text="$3"
        
        local payload
        payload=$(jq -n \
          --arg action "$action" \
          --arg id "$id" \
          --arg text "$text" \
          --arg timestamp "$(date -Iseconds)" \
          '{
            action: $action,
            reminder: {
              id: $id,
              text: $text,
              timestamp: $timestamp
            }
          }')
        
        ${pkgs.mosquitto}/bin/mosquitto_pub -h ${mqttHostip} -t "zigbee2mqtt/reminders" -m "$payload" ${mqttAuth}
      }

      publish_reminder_list() {
        local reminders=()
        
        if [ "$(ls -A "$REMINDER_DIR")" ]; then
          for file in "$REMINDER_DIR"/*; do
            if [ -f "$file" ]; then
              local id=$(basename "$file")
              local text=$(<"$file")
              reminders+=("$(jq -n --arg id "$id" --arg text "$text" '{id: $id, text: $text}')")
            fi
          done
        fi
        
        local reminder_list=$(printf '%s\n' "''${reminders[@]}" | jq -s '.')
        local payload
        payload=$(jq -n \
          --argjson reminders "$reminder_list" \
          '{
            action: "list",
            reminders: $reminders
          }')
        
        ${pkgs.mosquitto}/bin/mosquitto_pub -h ${mqttHostip} -t "zigbee2mqtt/reminders" -m "$payload" ${mqttAuth}
      }
  
      list_reminders() {
        if [ "$(ls -A "$REMINDER_DIR")" ]; then
          dt_info "Current reminders:"
          for file in "$REMINDER_DIR"/*; do
            if [ -f "$file" ]; then
              content=$(<"$file")
              echo "$content"
            fi
          done
          publish_reminder_list
        else
          dt_info "No reminders found."
          publish_reminder_list
        fi
      }
  
      add_reminder() {
        local id
        id=$(date +%s)
        echo "$about" > "$REMINDER_DIR/$id"
        dt_info "Reminder added: $about"
        publish_reminder "add" "$id" "$about"
        
        # 🦆 says ⮞ schedule automatic removal after 24 hours
        echo "rm '$REMINDER_DIR/$id'" | at now + 24 hours 2>/dev/null || true
      }
      
      clear_reminders() {
        if [ "$(ls -A "$REMINDER_DIR")" ]; then
          rm -f "$REMINDER_DIR"/*
          dt_info "All reminders cleared"
          publish_reminder "clear" "" ""
        else
          dt_info "No reminders to clear"
        fi
      }
  
      if [[ "$clear" == "true" ]]; then
        clear_reminders
      elif [[ -n "$about" ]]; then
        add_reminder
      else
        list_reminders
      fi
    '';
    voice = {
      sentences = [
        "påminn [mig] om [att] {about}"
        "{list} påminnelser"
        "{clear} påminnelser"
      ];
      lists = {
        about.wildcard = true;
        list.values = [
          { "in" = "[visa]"; out = "true"; }        
        ];
        clear.values = [
          { "in" = "[rensa]"; out = "true"; }
        ];
      };
    };
 
  };}
