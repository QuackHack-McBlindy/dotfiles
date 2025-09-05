# dotfiles/bin/misc/darkTime.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ sets the window of when motion sensors are triggering lights based on sunrise/sunset 
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
} : let  
  
in {
  yo.scripts.darkTime = {
    description = "Configures darkTime - the window of time where motion is triggering lights based upon sunrise/sunset.";
    category = "🌍 Localization";
    runEvery = "1440";
    logLevel = "DEBUG";
    parameters = [
      { name = "location"; description = "Location to fetch sunrise/sunset times for. (City, Country)"; optional = true; }
      { name = "locationPath"; description = "File path contianing location to fetch sunrise/sunset times for. (City, Country)"; default = config.sops.secrets."users/pungkula/homeCityCountry".path; }      
    ]; 
    code = ''
      ${cmdHelpers}
      LOCATION="$location"
      LOCATION_FILE="$locationPath"
      
      # 🦆 says ⮞ get location from file if provided
      if [[ -n "''${LOCATION_FILE:-}" && -f "$LOCATION_FILE" ]]; then
          LOCATION=$(cat "$LOCATION_FILE")
      fi
      
      get_coordinates() {
          local location="$1"
          local user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0"
          
          echo "Searching for: $location" >&2
          
          local response
          response=$(curl -s -f -G \
              --data-urlencode "q=$location" \
              -H "User-Agent: $user_agent" \
              "https://nominatim.openstreetmap.org/search?format=json&limit=1") || {
              echo "Error: HTTP request failed." >&2
              return 1
          }
          
          if [[ -z "$response" || "$response" == "[]" ]]; then
              echo "Location not found." >&2
              return 1
          fi
          
          local lat lon
          lat=$(echo "$response" | jq -r '.[0].lat')
          lon=$(echo "$response" | jq -r '.[0].lon')
          
          if [[ "$lat" == "null" || "$lon" == "null" ]]; then
              echo "Invalid response data." >&2
              return 1
          fi
          
          # 🦆 says ⮞ Add N/S and E/W indicators
          LATITUDE="''${lat}$( (( $(echo "$lat >= 0" | bc -l) )) && echo "N" || echo "S" )"
          LONGITUDE="''${lon}$( (( $(echo "$lon >= 0" | bc -l) )) && echo "E" || echo "W" )"
          
          echo "Using coordinates: $LATITUDE, $LONGITUDE" >&2
      }
      
      # 🦆 says ⮞ Get coordinates if location is provided
      if [[ -n "''${LOCATION:-}" ]]; then
          get_coordinates "$LOCATION"
      fi
      
      # 🦆 says ⮞ calculate sunrise and sunset times
      dt_debug "Calculating sunrise/sunset for $LATITUDE, $LONGITUDE" >&2
      
      SUNRISE=$(sunwait list rise civil "$LATITUDE" "$LONGITUDE" | awk '{print $2}' | cut -d: -f1-2)
      SUNSET=$(sunwait list set civil "$LATITUDE" "$LONGITUDE" | awk '{print $2}' | cut -d: -f1-2)
      
      # 🦆 says ⮞ apply offset if specified
      if [[ -n "''${OFFSET:-}" ]]; then
          SUNRISE=$(date -d "$SUNRISE today + $OFFSET minutes" +"%H:%M")
          SUNSET=$(date -d "$SUNSET today + $OFFSET minutes" +"%H:%M")
      fi
      
      echo "Sunrise: $SUNRISE, Sunset: $SUNSET" >&2
      
      # 🦆 says ⮞ create .conf file for zigduck to read
      cat > /etc/dark-time.conf <<EOF
DARK_TIME_START="$SUNSET"
DARK_TIME_END="$SUNRISE"
EOF
      
      dt_info "dark-time.conf created successfully" >&2
           
    '';         
  };  
 
 
  sops.secrets."users/pungkula/homeCityCountry" = {
    sopsFile = ./../../secrets/users/pungkula/homeCityCountry.yaml;
    owner = config.this.user.me.name;
    group = config.this.user.me.name;
    mode = "0440";
  };}
