# dotfiles/bin/misc/shop-list.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  # 🦆 says ⮞ mqtt is used for tracking channel states on devices
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
  yo.scripts.shop-list = {
    description = "Shopping list management";
    
    category = "🧩 Miscellaneous";
    parameters = [
      { name = "operation"; description = "Possible operation modes: add, remove or clear"; default = "add"; }
      { name = "item"; description = "Item that will be managed"; }
      { name = "list"; type = "bool"; description = "List items in the shopping list"; default = false; }      
      { name = "mqttUser"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "mqttPWFile"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
    ];
    code = ''
      ${cmdHelpers}
      MQTT_BROKER="${mqttHostip}" && dt_debug "$MQTT_BROKER"
      MQTT_USER="$mqttUser" && dt_debug "$MQTT_USER"
      MQTT_PASSWORD=$(cat "$mqttPWFile")
      LIST_FILE="$HOME/.shopping_list.txt"
      mkdir -p "$(dirname "$LIST_FILE")"
      touch "$LIST_FILE"
      
      if [ "$list" = "true" ]; then
        cat "$LIST_FILE"
        exit 1
      fi
      
      case "$operation" in
        add)
          if [ -z "$item" ]; then
            echo "Error: Item required for 'add' operation"
            exit 1
          fi
          if ! grep -Fxq "$item" "$LIST_FILE"; then
            echo "$item" >> "$LIST_FILE"
            echo "Added '$item' locally"
          else
            echo "'$item' already in list"
          fi
          mqtt_pub -t "zigbee2mqtt/shopping_list" -m "{\"shopping_action\": \"add\", \"item\": \"$item\"}"
          ;;
        remove)
          if [ -z "$item" ]; then
            echo "Error: Item required for 'remove' operation"
            exit 1
          fi
          if grep -Fxq "$item" "$LIST_FILE"; then
            grep -Fxv "$item" "$LIST_FILE" > "$LIST_FILE.tmp" && mv "$LIST_FILE.tmp" "$LIST_FILE"
            echo "Removed '$item' locally"
          else
            echo "'$item' not found in list"
          fi
          mqtt_pub -t "zigbee2mqtt/shopping_list" -m "{\"shopping_action\": \"remove\", \"item\": \"$item\"}"
          ;;
        clear)
          > "$LIST_FILE"
          echo "Cleared shopping list locally"
          mqtt_pub -t "zigbee2mqtt/shopping_list" -m "{\"shopping_action\": \"clear\"}"
          ;;
        *)
          echo "Invalid operation: '$operation'. Use add, remove, clear, or view."
          exit 1
          ;;
      esac
    '';
    voice = {
      enabled = true;
      priority = 4;
      sentences = [
        "{operation} till {item} i (inköpslistan|shoppinglistan)"
        "{operation} {item} till (inköpslistan|shoppinglistan)"
        "{operation} till {item} på listan"
        "{operation} till {item}"
        "{operation} {item} på (inköpslistan|shoppinglistan)"

        "{operation} [bort] {item} (från|i) (inköpslistan|shoppinglistan)"
        "{operation} [bort] {item} (från|i) listan"
        "{operation} bort {item}"
        "{operation} {item} från listan"
            
        "visa inköpslistan"
        "vad finns på inköpslistan"
        "visa listan"
        "vad är på listan"
      ];
      lists = {
        operation.values = [
          { "in" = "[lägg]"; out = "add"; }
          { "in" = "[ta|bort|radera]"; out = "remove"; }  
          { "in" = "[rensa]"; out = "clear"; }      
        ];
        item.wildcard = true;
      };
    };  
    
  };}
