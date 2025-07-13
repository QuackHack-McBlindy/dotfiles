# dotfiles/bin/system/transport.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
} : let

in {
  yo.scripts.transport = {
      description = "Public transportation helper. Fetches current airplane, bus, boats and train departure and arrival times. (Sweden)";
      aliases = [ "bus" ];
      category = "🌍 Localization";
      autoStart = false;
      logLevel = "INFO";
      parameters = [
        { name = "arrival"; description = "Name of City or stop for the arrival"; optional = false; }
        { name = "departure"; description = "Name of City or stop for the departure "; default = config.sops.secrets."users/pungkula/homeStop".path; }
        { name = "apikeyPath"; description = "Trafiklab API key. Can be optained from https://trafiklab.se"; default = config.sops.secrets.resrobot.path; }
      ];
#      helpFooter = ''    
#      '';
      code = ''
        ${cmdHelpers}
      
        API_KEY=$(cat $apikeyPath)
        origin="$departure"
        destination="$arrival"
      
 
  
        # Set Swedish timezone
        export TZ="Europe/Stockholm"
        
        # Load API key
        API_KEY=$(cat "$apikeyPath")
        origin="$departure"
        destination="$arrival"
        
        # Ensure required commands are available
        PATH="${lib.makeBinPath runtimeDeps}:$PATH"
        
        get_stop_id() {
          local stop_name="$1"
          local url="https://api.resrobot.se/v2.1/location.name?input=${stop_name}&format=json&accessId=${API_KEY}"
          
          local response
          response=$(curl -s -w "%{http_code}" "$url")
          local status_code=${"$"{response: -3}}
          local content=${"$"{response%???}}
          
          if [ "$status_code" -ne 200 ]; then
            echo "Fel: Mottog statuskod $status_code från API." >&2
            exit 1
          fi
          
          local stop_id=$(echo "$content" | jq -r '.stopLocationOrCoordLocation[].StopLocation.extId' 2>/dev/null | head -1)
          
          if [ -z "$stop_id" ]; then
            echo "Fel: Inga hållplatser hittades för $stop_name." >&2
            exit 1
          fi
          
          echo "$stop_id"
        }
        
        get_next_route() {
          local origin_id="$1"
          local dest_id="$2"
          local url="https://api.resrobot.se/v2.1/trip?format=json&originId=${origin_id}&destId=${dest_id}&passlist=0&showPassingPoints=0&numF=3&accessId=${API_KEY}"
          
          local response
          response=$(curl -s -w "%{http_code}" "$url")
          local status_code=${"$"{response: -3}}
          local content=${"$"{response%???}}
          
          if [ "$status_code" -eq 400 ]; then
            echo "Fel: Dålig förfrågan - Ogiltig kombination av hållplatser eller inkompatibel rutt." >&2
            exit 1
          elif [ "$status_code" -ne 200 ]; then
            echo "Fel: Mottog statuskod $status_code från API." >&2
            exit 1
          fi
          
          local trip_count=$(echo "$content" | jq '.Trip | length' 2>/dev/null)
          if [ -z "$trip_count" ] || [ "$trip_count" -eq 0 ]; then
            echo "Fel: Inga resor hittades." >&2
            exit 1
          fi
          
          echo "$content"
        }
        
        format_response() {
          local json="$1"
          local now_epoch=$(date +%s)
          local formatted_response="Aktuell tid är $(date +%H:%M).\n"
          
          for i in 0 1 2; do
            local trip=$(echo "$json" | jq -c ".Trip[$i]")
            if [ -z "$trip" ] || [ "$trip" = "null" ]; then
              continue
            fi
            
            local origin=$(echo "$trip" | jq -r '.LegList.Leg[0].Origin.name')
            local destination=$(echo "$trip" | jq -r '.LegList.Leg[0].Destination.name')
            local dep_date=$(echo "$trip" | jq -r '.LegList.Leg[0].Origin.date')
            local dep_time=$(echo "$trip" | jq -r '.LegList.Leg[0].Origin.time')
            local arr_time=$(echo "$trip" | jq -r '.LegList.Leg[0].Destination.time')
            local bus_num=$(echo "$trip" | jq -r '.LegList.Leg[0].Product[0].num // "okänd"')
            
            # Parse and convert departure time to epoch
            local dep_epoch=$(date -d "${dep_date} ${dep_time}" +%s)
            local minutes_to_departure=$(( (dep_epoch - now_epoch) / 60 ))
            
            # Format day name in Swedish
            local day=$(date -d "${dep_date}" "+%A" | sed -e '
              s/Monday/måndag/;
              s/Tuesday/tisdag/;
              s/Wednesday/onsdag/;
              s/Thursday/torsdag/;
              s/Friday/fredag/;
              s/Saturday/lördag/;
              s/Sunday/söndag/
            ')
            
            if [ "$i" -eq 0 ]; then
              formatted_response+="Nästa resa från $origin till $destination "
              formatted_response+="med buss $bus_num avgår om $minutes_to_departure minuter "
              formatted_response+="($(date -d "${dep_date} ${dep_time}" +"%H:%M")) på $day "
              formatted_response+="och anländer kl. $arr_time."
            else
              formatted_response+=" Nästa avgång efter det med buss $bus_num är "
              formatted_response+="om $minutes_to_departure minuter ($(date -d "${dep_date} ${dep_time}" +"%H:%M"))."
            fi
          done
          
          echo -e "$formatted_response"
        }
        
        # Main execution
        origin_id=$(get_stop_id "$origin")
        dest_id=$(get_stop_id "$destination")
        
        trips_json=$(get_next_route "$origin_id" "$dest_id")
        

        echo "----- RAW TRIP DATA -----"
        echo "$trips_json" | jq .
        echo "-------------------------"
        echo
        
        format_response "$trips_json"
      '';    
  };
  sops = {
      secrets = {
          resrobot = {
              sopsFile = ./../../secrets/resrobot.yaml;
              owner = config.this.user.me.name;
              group = config.this.user.me.name;
              mode = "0440"; # Read-only for owner and group
          };
          "users/pungkula/homeStop" = {
              sopsFile = ./../../secrets/users/pungkula/homeStop.yaml;
              owner = config.this.user.me.name;
              group = config.this.user.me.name;
              mode = "0440"; # Read-only for owner and group
          };      
      };
      
  };}
  




