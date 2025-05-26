# dotfiles/bin/system/weather.nix

{ config, lib, pkgs, cmdHelpers, ...  }:
{
  yo.scripts.stores = {
    description = "Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours.";
#    category = "🧩 Miscellaneous";
    category = "🌍 Localization";
    aliases = [ "store" "open" ];
    parameters = [
      { 
        name = "store_name"; 
        description = "Name of store to search for (supports fuzzy matching)"; 
        optional = false; 
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
#    helpFooter = ''
#    '';
    code = ''
        ${cmdHelpers}
        DEFAULT_LOCATION=$(cat "$location")
        echo "default location: $DEFAULT_LOCATION"
        store="$store_name"
        radius="10000"
        location="$DEFAULT_LOCATION"   
        echo "location: $location"
        echo "radius: $radius" 
          
        get_location_lat_lon() {
            location="$1"
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0" 
            echo "=== Nominatim Request ===" >&2
            echo "Searching for: $location" >&2
            
            response=$(curl -s -f -G \
                --data-urlencode "q=$location" \
                -H "User-Agent: $user_agent" \
                "https://nominatim.openstreetmap.org/search?format=json&limit=1") || {
                echo "Error: HTTP request failed." >&2
                return 1
            }
        
            echo "=== Nominatim Response ===" >&2
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
        
            echo "=== Coordinates ===" >&2
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
            echo "=== Overpass Request ===" >&2
            echo "Query: $query" >&2   
            temp_file=$(mktemp)
            response=$(curl -s -f -G \
                -H "User-Agent: $user_agent" \
                --data-urlencode "data=''${query}" \
                "$base_url" 2>"$temp_file") || {
                echo "=== Curl Error ===" >&2
                cat "$temp_file" >&2
                rm "$temp_file"
                echo "Error: Overpass API request failed." >&2
                return 1
            }
            rm "$temp_file"
        
            echo "$response"
        }
        
        fuzzy_search_shops() {
            shops_data="$1"
            store_name="$2"
            
            echo "=== Fuzzy Search ===" >&2
            echo "Pattern: $store_name" >&2
            result=$(echo "$shops_data" | jq --arg pattern "$store_name" '
                .elements[] | 
                select(.tags.name != null) |
                select(.tags.name | test($pattern; "i"))
            ')
            
            echo "=== Matched Shops ===" >&2
            echo "$result" | jq . >&2
            echo "$result"
        }   
        echo "=== Script Start ===" >&2
        echo "Store: $store_name | Location: $location | Radius: ''${radius}m" >&2
        if ! coords=$(get_location_lat_lon "$location"); then
            exit 1
        fi
        lat=$(echo "$coords" | awk '{print $1}')
        lon=$(echo "$coords" | awk '{print $2}')
        
        echo "=== Main Execution ===" >&2
        echo "Fetching shops near Latitude: $lat, Longitude: $lon, Radius: $radius" >&2
        if ! shops_data=$(get_shops_near_location "$lat" "$lon" "$radius"); then
            exit 1
        fi
        
        matched_shops=$(fuzzy_search_shops "$shops_data" "$store") 
        if [[ -n "$matched_shops" ]]; then
            echo "Matched Shops for '$store':"
            echo "$matched_shops" | jq -r '.tags.name'
            echo "$matched_shops" | jq -s '.' > "matched_shops_''${store// /_}.json"
        else
            echo "No shops found matching '$store'."
        fi
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
