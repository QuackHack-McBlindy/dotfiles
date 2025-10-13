# dotfiles/bin/misc/stores.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
} : {
  yo.scripts.stores = {
    description = "Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours.";
    category = "🌍 Localization";
    aliases = [ "store" "shop" ];
    autoStart = false;
    parameters = [
      { name = "store_name"; description = "Name of store to search for (supports fuzzy matching)"; optional = false; }
      { name = "location"; description = "Filepath containing base location for search, example: City, Country"; default = config.sops.secrets."users/pungkula/homeCity".path; }
      { name = "radius"; description = "Search radius in meters"; default = "10000"; }
    ];
    logLevel = "INFO";
    code = ''
      ${cmdHelpers}
      DEFAULT_LOCATION=$(cat "$location")
      dt_debug "default location: $DEFAULT_LOCATION"
      store="$store_name"
      store_name="$(echo "$store_name" | tr '[:upper:]' '[:lower:]')"
      radius="10000"
      location="$DEFAULT_LOCATION"   
      dt_debug "location: $location"
      dt_debug "radius: $radius" 
      
      TMP_STORES=$(mktemp)
       
      get_location_lat_lon() {
          location="$1"
          user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0" 
          dt_debug "Searching for: $location" >&2
            
          response=$(curl -s -f -G \
              --data-urlencode "q=$location" \
              -H "User-Agent: $user_agent" \
              "https://nominatim.openstreetmap.org/search?format=json&limit=1") || {
              dt_error "Error: HTTP request failed." >&2
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
          radius="$3"
          user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0"
          base_url="https://overpass-api.de/api/interpreter"
          query="[out:json];node[\"shop\"](around:''${radius},''${lat},''${lon});out;"

          dt_debug "Query: $query" >&2   
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
      fuzzy_match_shops() {
        BEST_SCORE=-1
        BEST_STORE=""
        NORMALIZED_SEARCH=$(normalize_string "$store_name")

        while IFS= read -r store_json; do
          STORE_NAME=$(echo "$store_json" | jq -r '.tags.name')
          NORMALIZED_NAME=$(normalize_string "$STORE_NAME")
          SCORE=$(trigram_similarity "$NORMALIZED_SEARCH" "$NORMALIZED_NAME")
          if (( SCORE > BEST_SCORE )); then
            BEST_SCORE=$SCORE
            BEST_STORE="$store_json"
          fi
        done < <(jq -c '.elements[] | select(.tags.name)' "$TMP_STORES")
        if [[ -n "$BEST_STORE" ]]; then
          echo "$BEST_STORE"
        else
          echo "No match found."
        fi
      }
     
      dt_debug "Store: $store_name | Location: $location | Radius: ''${radius}m" >&2
      if ! coords=$(get_location_lat_lon "$location"); then
          exit 1
      fi
      lat=$(echo "$coords" | awk '{print $1}')
      lon=$(echo "$coords" | awk '{print $2}')      
      dt_debug "Fetching shops near Latitude: $lat, Longitude: $lon, Radius: $radius" >&2
      if ! shops_data=$(get_shops_near_location "$lat" "$lon" "$radius"); then
          exit 1
      fi   
      echo "$shops_data" > $TMP_STORES
      dt_debug "Saved shops data to $TMP_STORES"
      FOUND_STORES=$(jq '.elements[] | select(.tags.name) | .tags.name' $TMP_STORES)
      matched_json=$(fuzzy_match_shops)

      if [[ "$matched_json" == *"No match found."* ]]; then
        yo say "Jag hittade inga butiker som matchar '$store_name'."
        dt_error "Jag hittade inga butiker som matchar '$store_name'."
        exit 0
      fi

      selected=$(echo "$matched_json" | jq -c 'select(type == "object")')
      name=$(echo "$selected" | jq -r '.tags.name')
      lat=$(echo "$selected" | jq -r '.lat')
      lon=$(echo "$selected" | jq -r '.lon')
      hours=$(echo "$selected" | jq -r '.tags.opening_hours // "Öppettider okända"')
      addr=$(echo "$selected" | jq -r '.tags["addr:street"] // "okänd adress"')
      city=$(echo "$selected" | jq -r '.tags["addr:city"] // "okänd stad"')
      natural_hours=$(convert_opening_hours_to_speech "$hours")
      dt_info "$name på $addr i $city har öppet: $natural_hours"
      dt_info "$name"
      dt_info "$addr, $city"
      dt_info "$hours"
      dt_info "https://www.openstreetmap.org/?mlat=$lat&mlon=$lon#map=18/$lat/$lon"
      yo say "$name på $addr i $city har öppet: $natural_hours"
    '';
    voice = {
      sentences = [
        "vilken tid (öppnar|stänger) {store_name}"
        "vad har {store_name} för öppettider"          
        "var är närmaste {store_name}"
        "finns det någon {store_name} i närheten"
        "när stänger {store_name}"
        "när öppnar {store_name}"
      ];          
      lists = {
        store_name.wildcard = true;
      };  
    };   
   
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
  

