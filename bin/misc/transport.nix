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
#      keywords = [ ];
      category = "🌍 Localization";
      aliases = [ "buss" "trafiklab" ];
      parameters = [
        { 
          name = "arrival"; 
          description = "Name of City or stop for the arrival"; 
          optional = false; 
        }
        { 
          name = "departure"; 
          description = "Name of City or stop for the departure "; 
          default = config.sops.secrets."users/pungkula/homeStop".path;  # Setting default value makes param optional
        }
        { 
          name = "apikey"; 
          description = "Trafiklab API key. Can be optained from https://trafiklab.se"; 
          default = config.sops.secrets.resrobot.path; 
        }
      ];
#      helpFooter = ''    
#      '';
      code = ''
        ${cmdHelpers}
       
        API_KEY="''$apikey"
        if [ -z "''$API_KEY" ]; then
            echo "Fel: TRAFIKLAB_API_KEY är inte satt." >&2
            exit 1
        fi

        # Use direct parameters instead of query parsing
        origin="''$departure"
        destination="''$arrival"

        # Function to fetch stop ID
        get_stop_id() {
            local stop_name="''$1"
            local encoded_stop=$(echo "''$stop_name" | sed 's/ /%20/g')
            local url="https://api.resrobot.se/v2.1/location.name?input=''${encoded_stop}&format=json&accessId=''${API_KEY}"
            local response=$(curl -s "''$url")

            if [ $? -ne 0 ]; then
                echo "Fel: API-anrop misslyckades för ''$stop_name" >&2
                exit 1
            fi

            local stop_id=$(echo "''$response" | jq -r '.stopLocationOrCoordLocation[0].StopLocation.extId' 2>/dev/null)
            if [ -z "''$stop_id" ] || [ "''$stop_id" = "null" ]; then
                echo "Fel: Hittade inte hållplatsen ''$stop_name" >&2
                exit 1
            fi
            echo "''$stop_id"
        }

        origin_id=$(get_stop_id "''$origin")
        dest_id=$(get_stop_id "''$destination")

        # Fetch trips
        url="https://api.resrobot.se/v2.1/trip?format=json&originId=''${origin_id}&destId=''${dest_id}&numF=3&accessId=''${API_KEY}"
        response=$(curl -s "''$url")

        if echo "''$response" | jq -e 'has("error")' >/dev/null; then
            echo "Fel: $(echo "''$response" | jq -r '.error.text')" >&2
            exit 1
        fi

        trips=$(echo "''$response" | jq -r '.Trip')
        if [ "''$trips" = "null" ] || [ -z "''$trips" ]; then
            echo "Inga resor hittades." >&2
            exit 1
        fi

        # Process trips
        current_epoch=$(TZ="Europe/Stockholm" date +%s)
        now=$(TZ="Europe/Stockholm" date +'%H:%M')
        output="Aktuell tid är ''${now}."

        for ((i=0; i<3; i++)); do
            trip=$(echo "''$trips" | jq -r ".[''$i]")
           [ "''$trip" = "null" ] && break

            leg=$(echo "''$trip" | jq -r '.LegList.Leg[0]')
            origin_info=$(echo "''$leg" | jq -r '.Origin')
            dest_info=$(echo "''$leg" | jq -r '.Destination')
            product=$(echo "''$leg" | jq -r '.Product[0]')

            dep_time=''${origin_info#*\"date\":\"}
            dep_time=$(echo "''$dep_time" | awk -F'"' '{print $1 " " $4}')
            dep_epoch=$(TZ="Europe/Stockholm" date -d "''${dep_time/:30:/:30:}" +%s 2>/dev/null)

            if [ -z "''$dep_epoch" ] || [ "''$dep_epoch" -lt "''$current_epoch" ]; then
                continue
            fi

            minutes=$(( (''$dep_epoch - ''$current_epoch) / 60 ))
            dep_formatted=$(date -d "@''$dep_epoch" +'%H:%M' --tz="Europe/Stockholm")
            day=$(LC_TIME=sv_SE.UTF-8 date -d "@''$dep_epoch" +'%A')

            bus=$(echo "''$product" | jq -r '.num')

            if [ "''$i" -eq 0 ]; then
                arr_time=$(echo "''$dest_info" | jq -r '.time')
                output+="\nNästa buss ''$bus från ''$origin till ''$destination avgår om ''$minutes minuter (''$dep_formatted) på ''$day, ankomst ''$arr_time."
            else
                output+="\nDärefter avgår buss ''$bus om ''$minutes minuter (''$dep_formatted)."
            fi
        done

        echo -e "''$output"
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
  
