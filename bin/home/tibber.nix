# dotfiles/bin/home/tibber.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Fetches electricity price data
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {  
  yo.scripts.tibber = {
    description = "Fetches home electricity price data";
    category = "🛖 Home Automation";
    aliases = ["el"];
    autoStart = false;
    runEvery = "120";
    parameters = [  
      { name = "homeIDFile"; description = "File path containing the Tibber user home ID"; default = config.sops.secrets.tibber_id.path;  }       
      { name = "APIKeyFile"; description = "File path containing the Tibber API key"; default = config.sops.secrets.tibber_key.path;  }      
      { name = "filePath"; description = "File path to store data"; default = "/home/pungkula/tibber_data.txt";  }            
    ];
    logLevel = "INFO";
    helpFooter = ''
      ${pkgs.gnuplot}/bin/gnuplot -persist <<EOF
set xdata time
set timefmt "%Y-%m-%d %H:%M"
set format x "%H:%M"
set title "Tibber Electricity Price (SEK/kWh)"
set xlabel "Time"
set ylabel "Price"
set grid
plot "/home/pungkula/tibber_data.txt" using 1:3 with linespoints title "Price"
EOF
    '';
    code = ''
      ${cmdHelpers}
      TIBBER_TOKEN=$(cat $APIKeyFile)
      HOME_ID=$(cat $homeIDFile)
      SAVE_PATH="$filePath"

      QUERY_JSON=$(${pkgs.jq}/bin/jq -n \
        --arg q "{
          viewer {
            home(id: \"$HOME_ID\") {
              currentSubscription {
               priceInfo {
                  current {
                    total
                    energy
                    tax
                    startsAt
                    currency
                  }
                }
              }
            }
          }
        }" \
        '{query: $q}')

      RESPONSE=$(curl -s -X POST https://api.tibber.com/v1-beta/gql \
        -H "Authorization: Bearer $TIBBER_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$QUERY_JSON")

      dt_debug "$RESPONSE"
  
      TOTAL_RAW=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r '.data.viewer.home.currentSubscription.priceInfo.current.total')
      TOTAL=$(printf "%.2f" "$TOTAL_RAW")


      TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
      echo "$TIMESTAMP $TOTAL" >> "$SAVE_PATH"
  

      dt_info "$TOTAL SEK / kWh"
      if_voice_say "Aktuellt elpris är just nu: $TOTAL kronor per kilo watt timme"

    '';
    voice = {
      priority = 3;
      sentences = [
        "vad kostar strömmen"
        "hur mycket kostar strömmen"
      ];         
    };
  };
 
  sops.secrets = {
    tibber_id = {
      sopsFile = ./../../secrets/tibber-id.yaml; 
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    }; 
    tibber_key = {
      sopsFile = ./../../secrets/tibber-key.yaml; 
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440"; # 🦆 says ⮞ Read-only for owner and group
    }; 
    
  };}
