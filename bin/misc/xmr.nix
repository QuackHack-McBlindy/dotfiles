# dotfiles/bin/misc/xmr.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ tracks crypto XMR price
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
  yo.scripts.xmr = {
    description = "Crypto currency XMR price tracker";
    category = "🧩 Miscellaneous";
    runAt = lib.mkIf (config.this.host.hostname != "homie") [ "07:00" "18:00" ];
    runEvery = lib.mkIf (config.this.host.hostname == "homie") "55";
    parameters = [ 
      { name = "filePath"; description = "File path to store data"; default = "/home/pungkula/xmr_data.txt";  }           
      { name = "user"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "pwfile"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
    ]; # 🦆 says ⮞ show graph when calling --help
    helpFooter = ''
      ${pkgs.gnuplot}/bin/gnuplot -persist <<EOF
set xdata time
set timefmt "%Y-%m-%d %H:%M"
set format x "%H:%M"
set title "Monero Price in dollar"
set xlabel "Time"
set ylabel "Price"
set grid
plot "/home/pungkula/xmr_data.txt" using 1:3 with linespoints title "Price"
EOF
    '';
    code = ''
      ${cmdHelpers}
            
      MQTT_BROKER="${mqttHostip}"
      MQTT_USER="$user"
      MQTT_PASSWORD=$(cat "$pwfile")
      SAVE_PATH="$filePath"

      format_change() {
        local change=$1
        if [ "$(echo "$change > 0" | bc -l)" -eq 1 ]; then
          printf "↑%.2f%%" "$change"
        else
          printf "↓%.2f%%" "$(echo "$change * -1" | bc -l)"
        fi
      }

      get_voice_direction() {
        local change=$1
        if [ "$(echo "$change > 0" | bc -l)" -eq 1 ]; then
          echo "upp" # 🦆 says ⮞ ↑ gained value
        else
          echo "ner" # 🦆 says ⮞ ↓ lost value
        fi
      }

      # 🦆 says ⮞ CoinGecko with 7d support
      DATA=$(curl -s "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=monero&price_change_percentage=7d")
      XMR_PRICE=$(echo "$DATA" | jq -r '.[0].current_price')
      XMR_24H=$(echo "$DATA" | jq -r '.[0].price_change_percentage_24h')
      XMR_7D=$(echo "$DATA" | jq -r '.[0].price_change_percentage_7d_in_currency')

      XMR_24H_FORMATTED=$(format_change "$XMR_24H")
      XMR_7D_FORMATTED=$(format_change "$XMR_7D")
      XMR_24H_VOICE_DIR=$(get_voice_direction "$XMR_24H")
      XMR_7D_VOICE_DIR=$(get_voice_direction "$XMR_7D")

      TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
      echo "$TIMESTAMP $XMR_PRICE $XMR_24H $XMR_7D_FORMATTED" >> "$SAVE_PATH"

      #mqtt_pub -t "zigbee2mqtt/crypto/xmr/price" -m "{\"current_price\": $XMR_PRICE, \"24h_change\": $XMR_24H, \"7d_change\": $XMR_7D}"
      FORMATTED_24H=$(printf "%.1f" "$XMR_24H")
      FORMATTED_7D=$(printf "%.1f" "$XMR_7D")
      mqtt_pub -t "zigbee2mqtt/crypto/xmr/price" -m "{\"current_price\": $XMR_PRICE, \"24h_change\": $FORMATTED_24H, \"7d_change\": $FORMATTED_7D}"

      echo "Monero: $XMR_PRICE$  24h: $XMR_24H_FORMATTED  (7d: $XMR_7D_FORMATTED)"
      dt_info "Monero: $XMR_PRICE$  24h: $XMR_24H_FORMATTED  (7d: $XMR_7D_FORMATTED)"
      
      if_voice_say "Monero kostar $XMR_PRICE dollar, $XMR_24H_VOICE_DIR $XMR_24H_FORMATTED idag och $XMR_7D_VOICE_DIR $XMR_7D_FORMATTED den senaste veckan"
    '';
    voice = {
      enabled = true;
      priority = 3;    
      sentences = [
        "(va|vad|hur) [mycket|är] (priset|kostar) [på] [en] (xmr|monero)"
      ];
    };
    
  };}
