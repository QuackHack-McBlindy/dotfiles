# dotfiles/bin/system/weather.nix
{ 
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
} : {  
  yo.bitch.intents = {
    stores = {
      data = [{
        sentences = [
          "var är närmaste {store_name}"
          "var är närmaste {store_name}"
          "var är närmaste {store_name}"
          "finns det någon {store_name} i närheten"
          "visa närliggande {store_name}"
          "öppna {store_name} nära mig"
          "jag letar efter en {store_name} i {location}"
          "finns det öppna {store_name} i {location}"
          "visa {store_name} nära {location}"
          "var kan jag hitta en {store_name} i {location}"
          "letar efter {store_name} i {location}"
          "jag behöver en {store_name} i närheten"
          "vilka {store_name} är öppna i {location}"
          "öppna butiker som heter {store_name}"
          "visa butiker som liknar {store_name}"
          "jag vill hitta {store_name}"
          "hitta {store_name} nära {location}"
          "hitta närmaste {store_name}"
          "vilken {store_name} är närmast"
          "butiker som heter {store_name} i {location}"
        ];          
        lists = {
          store_name.wildcard = true;
          store_name.values = [
            { "in" = "ica"; out = "ICA"; } 
            { "in" = "I C A"; out = "ICA"; }
          ];
        };  
      }];
    };   
  };

  yo.scripts.stores = {
    description = "Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours.";
    category = "🌍 Localization";
    aliases = [ "store" "open" ];
    parameters = [
      { 
        name = "store_name"; 
        description = "Name of store to search for (supports fuzzy matching)"; 
        optional = false; 
        default = "";
      }
      { 
        name = "location"; 
        description = "Base location for search, example: City, Country"; 
        default = config.sops.secrets."users/pungkula/homeCity".path;
      }
      { 
        name = "radius"; 
        description = "Search radius in meters"; 
        default = "10000"; 
      }
    ];
    code = ''
        ${cmdHelpers}
        DEFAULT_LOCATION=$(cat "$location")
        echo "default location: $DEFAULT_LOCATION"
        store="$store_name"
        store_name="$(echo "$store_name" | tr '[:upper:]' '[:lower:]')"
        radius="10000"
        location="$DEFAULT_LOCATION"   
        echo "location: $location"
        echo "radius: $radius" 
          
        get_location_lat_lon() {
            location="$1"
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0" 
            echo "Searching for: $location" >&2
            
            response=$(curl -s -f -G \
                --data-urlencode "q=$location" \
                -H "User-Agent: $user_agent" \
                "https://nominatim.openstreetmap.org/search?format=json&limit=1") || {
                echo "Error: HTTP request failed." >&2
                return 1
            }
        
            echo "$response" | jq . >&2
            
            if [[ -z "$response" || "$response" == "[]" ]]; then
                echo "Location not found." >&2
                return 1
            fi
        
            lat=$(echo "$response" | jq -r '.[0].lat')
            lon=$(echo "$response" | jq -r '.[0].lon')
        
            if [[ "$lat" == "null" || "$lon" == "null" ]]; then
                echo "Invalid response data." >&2
                return 1
            fi
        
            echo "Lat: $lat | Lon: $lon" >&2
            echo "$lat $lon"
        }
        
        get_shops_near_location() {
            lat="$1"
            lon="$2"
#            radius="$3"
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0"
            base_url="https://overpass-api.de/api/interpreter"
            query="[out:json];node[\"shop\"](around:''${radius},''${lat},''${lon});out;"

            echo "Query: $query" >&2   
            temp_file=$(mktemp)
            response=$(curl -s -f -G \
                -H "User-Agent: $user_agent" \
                --data-urlencode "data=''${query}" \
                "$base_url" 2>"$temp_file") || {
                cat "$temp_file" >&2
                rm "$temp_file"
                echo "Error: Overpass API request failed." >&2
                return 1
            }
            rm "$temp_file" 
            echo "$response"
        }
   
        # Convert OSM opening_hours to Swedish
        convert_opening_hours_to_speech() {
            local hours="$1"
            hours=$(echo "$hours" |
                sed -E 's/Mo/Måndag/g; s/Tu/Tisdag/g; s/We/Onsdag/g; s/Th/Torsdag/g; s/Fr/Fredag/g; s/Sa/Lördag/g; s/Su/Söndag/g')
            hours=$(echo "$hours" | sed -E 's/([a-zåäöÅÄÖ]+)-([a-zåäöÅÄÖ]+)/\1 till \2/g')
            hours=$(echo "$hours" |
                sed -E 's/([0-9]{2}:[0-9]{2})-([0-9]{2}:[0-9]{2})/från \1 till \2/g')
            hours=$(echo "$hours" | sed 's/; /. /g')
            echo "$hours."
        }   
   
        fuzzy_search_shops() {
            shops_data="$1"
            store_name="$2"
            
            echo "Pattern: $store_name" >&2
            result=$(echo "$shops_data" | jq --arg pattern "$store_name" '
                .elements[] | 
                select(.tags.name != null) |
                select(.tags.name | test($pattern; "i"))
            ')
            
            echo "$result" | jq . >&2
            echo "$result"
        }   
        echo "Store: $store_name | Location: $location | Radius: ''${radius}m" >&2
        if ! coords=$(get_location_lat_lon "$location"); then
            exit 1
        fi
        lat=$(echo "$coords" | awk '{print $1}')
        lon=$(echo "$coords" | awk '{print $2}')
        
        echo "Fetching shops near Latitude: $lat, Longitude: $lon, Radius: $radius" >&2
        if ! shops_data=$(get_shops_near_location "$lat" "$lon" "$radius"); then
            exit 1
        fi
        
        matched_shops=$(fuzzy_search_shops "$shops_data" "$store")

        if [[ -z "$matched_shops" ]]; then
            echo "No shops found matching '$store'."
            exit 0
        fi

        # Wrap all matches into JSON
        wrapped_matches=$(echo "$matched_shops" | jq -s '.')

        # Get total number of matched shops
        count=$(echo "$wrapped_matches" | jq 'length')
        
        say " .. Hittade flera butiker .. Vilken butik menade du"
        
        if [[ "$count" -gt 5 ]]; then
            echo "which store did you mean?"
            for i in $(seq 0 $((count - 1))); do
                shop_name=$(echo "$wrapped_matches" | jq -r ".[$i].tags.name")
                shop_addr=$(echo "$wrapped_matches" | jq -r ".[$i].tags[\"addr:street\"] // \"Ingen adress\"")
                say "$((i + 1))) $shop_name på $shop_addr"
                echo "$((i + 1))) $shop_name - $shop_addr"
            done

            spoken=$(mic_input)
            # Try interpreting as number
            if [[ "$spoken" =~ ^[0-9]+$ ]]; then
              choice_index=$((spoken - 1))
            else
              # Fuzzy match name
              choice_index=-1
              for i in $(seq 0 $((count - 1))); do
                name=$(echo "$wrapped_matches" | jq -r ".[$i].tags.name" | tr '[:upper:]' '[:lower:]')
                if echo "$spoken" | tr '[:upper:]' '[:lower:]' | grep -qi "$name"; then
                  choice_index=$i
                  break
                fi
              done
            fi

            if [[ "$choice_index" -lt 0 || "$choice_index" -ge "$count" ]]; then
              say "Kompis du pratar japanska jag fattar ingenting"
              echo "Det låter som du har en köttebulle i munnen. Tugga klart middagen och försök sedan igen."
              exit 1
            fi

        else
            # If 5 or fewer, auto-select the first one
            choice=1
        fi

        choice_index=$((choice - 1))
        selected=$(echo "$wrapped_matches" | jq ".[$choice_index]")

        if [[ "$selected" == "null" ]]; then
            say "Det låter som du har en köttebulle i munnen. Tugga klart middagen och försök sedan igen."
            echo "Ogiltigt val."
            exit 1
        fi

        # Extract and display full details
        name=$(echo "$selected" | jq -r '.tags.name')
        lat=$(echo "$selected" | jq -r '.lat')
        lon=$(echo "$selected" | jq -r '.lon')
        hours=$(echo "$selected" | jq -r '.tags.opening_hours // "Öppettider okända"')
        addr=$(echo "$selected" | jq -r '.tags["addr:street"] // "okänd adress"')
        city=$(echo "$selected" | jq -r '.tags["addr:city"] // "okänd stad"')

        natural_hours=$(convert_opening_hours_to_speech "$hours")
        say "$name på $addr i $city har öppet: $natural_hours"
        echo "🛒 $name"
        echo "📍 $addr, $city"
        echo "🕒 $hours"
        echo "🌐 https://www.openstreetmap.org/?mlat=$lat&mlon=$lon#map=18/$lat/$lon"
    '';
  };
  sops = {
      secrets = {
          "users/pungkula/homeCity" = {
              sopsFile = ./../../secrets/users/pungkula/homeCity.yaml;
              owner = config.this.user.me.name;
              group = config.this.user.me.name;
              mode = "0440"; # Read-only for owner and group
          };
      };    
      
  };}
  
