# dotfiles/bin/misc/btc.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ BTC price tracker
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = "desktop";
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
  yo.scripts.btc = {
    description = "Crypto currency BTC price tracker";
    category = "🧩 Miscellaneous";
    runAt = lib.mkIf (config.this.host.hostname != "homie") [ "07:00" "18:00" ];
    runEvery = lib.mkIf (config.this.host.hostname == "homie") "55";
    parameters = [ 
      { name = "filePath"; description = "File path to store data"; default = "/home/pungkula/btc_data.txt";  }           
      { name = "user"; description = "User which Mosquitto runs on"; default = "mqtt"; optional = false; }
      { name = "pwfile"; description = "Password file for Mosquitto user"; optional = false; default = config.sops.secrets.mosquitto.path; }
    ];
    helpFooter = ''
      ${pkgs.gnuplot}/bin/gnuplot -persist <<EOF
set xdata time
set timefmt "%Y-%m-%d %H:%M"
set format x "%H:%M"
set title "Bitcoin Price in dollar"
set xlabel "Time"
set ylabel "Price"
set grid
plot "/home/pungkula/btc_data.txt" using 1:3 with linespoints title "Price"
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
          echo "upp"
        else
          echo "ner"
        fi
      }

      DATA=$(curl -s "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=bitcoin&price_change_percentage=7d")
      BTC_PRICE=$(echo "$DATA" | jq -r '.[0].current_price')
      BTC_24H=$(echo "$DATA" | jq -r '.[0].price_change_percentage_24h')
      BTC_7D=$(echo "$DATA" | jq -r '.[0].price_change_percentage_7d_in_currency')

      BTC_24H_FORMATTED=$(format_change "$BTC_24H")
      BTC_7D_FORMATTED=$(format_change "$BTC_7D")
      BTC_24H_VOICE_DIR=$(get_voice_direction "$BTC_24H")
      BTC_7D_VOICE_DIR=$(get_voice_direction "$BTC_7D")

      echo "$(date '+%Y-%m-%d %H:%M') $BTC_PRICE $BTC_24H $BTC_7D_FORMATTED" >> "$filePath"

      # 🦆 says ⮞ publish to MQTT like XMR does
      mqtt_pub -t "zigbee2mqtt/crypto/btc/price" -m "{\"current_price\": $BTC_PRICE, \"24h_change\": $BTC_24H, \"7d_change\": $BTC_7D}"

      echo "Bitcoin $BTC_PRICE$  24h: $BTC_24H_FORMATTED  (7d: $BTC_7D_FORMATTED)"
      dt_info "₿ $BTC_PRICE$  24h: $BTC_24H_FORMATTED  (7d: $BTC_7D_FORMATTED)"
      
      if_voice_say "Bitcoin kostar $BTC_PRICE dollar, $BTC_24H_VOICE_DIR $BTC_24H_FORMATTED idag och $BTC_7D_VOICE_DIR $BTC_7D_FORMATTED den senaste veckan"
    '';
    voice = {
      enabled = true;
      priority = 3;    
      sentences = [
        "(va|vad|hur) [mycket|är] (priset|kostar) [på] [en] (bitcoin|btc)"
      ];
    };
    
  };}
