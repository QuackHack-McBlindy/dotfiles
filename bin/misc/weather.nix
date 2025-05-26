# dotfiles/bin/system/weather.nix
{ config, pkgs, cmdHelpers, ... } : 
let 
  WEATHER_CODES = {
    "113" = "☀️";  "116" = "⛅";  "119" = "☁️";  "122" = "☁️";  "143" = "☁️";
    "176" = "🌧️";  "179" = "🌧️";  "182" = "🌧️";  "185" = "🌧️";  "200" = "⛈️";
    "227" = "🌨️";  "230" = "🌨️";  "248" = "☁️";  "260" = "☁️";  "263" = "🌧️";
    "266" = "🌧️";  "281" = "🌧️";  "284" = "🌧️";  "293" = "🌧️";  "296" = "🌧️";
    "299" = "🌧️";  "302" = "🌧️";  "305" = "🌧️";  "308" = "🌧️";  "311" = "🌧️";
    "314" = "🌧️";  "317" = "🌧️";  "320" = "🌨️";  "323" = "🌨️";  "326" = "🌨️";
    "329" = "❄️";  "332" = "❄️";  "335" = "❄️";  "338" = "❄️";  "350" = "🌧️";
    "353" = "🌧️";  "356" = "🌧️";  "359" = "🌧️";  "362" = "🌧️";  "365" = "🌧️";
    "368" = "🌧️";  "371" = "❄️";  "374" = "🌨️";  "377" = "🌨️";  "386" = "🌨️";
    "389" = "🌨️";  "392" = "🌧️";  "395" = "❄️";
  };
  
in {
  yo.scripts.weather = {
    description = "Tiny Weather Report.";
#    category = "🧩 Miscellaneous";
    category = "🌍 Localization";
    aliases = [ "weat" ];
    parameters = [{
      name = "location"; 
      description = "Location to check (e.g., 'London' or 'New+York')"; 
      optional = true; 
      default = "Stockholm, Sweden"; 
    }]; 
#    packages = [ pkgs.curl pkgs.jq pkgs.gnused ];
    code = ''
      declare -A WEATHER_CODES=(
        ["113"]="☀️"  ["116"]="⛅"  ["119"]="☁️"  ["122"]="☁️"  ["143"]="☁️"
        ["176"]="🌧️"  ["179"]="🌧️"  ["182"]="🌧️"  ["185"]="🌧️"  ["200"]="⛈️"
        ["227"]="🌨️"  ["230"]="🌨️"  ["248"]="☁️"  ["260"]="☁️"  ["263"]="🌧️"
        ["266"]="🌧️"  ["281"]="🌧️"  ["284"]="🌧️"  ["293"]="🌧️"  ["296"]="🌧️"
        ["299"]="🌧️"  ["302"]="🌧️"  ["305"]="🌧️"  ["308"]="🌧️"  ["311"]="🌧️"
        ["314"]="🌧️"  ["317"]="🌧️"  ["320"]="🌨️"  ["323"]="🌨️"  ["326"]="🌨️"
        ["329"]="❄️"  ["332"]="❄️"  ["335"]="❄️"  ["338"]="❄️"  ["350"]="🌧️"
        ["353"]="🌧️"  ["356"]="🌧️"  ["359"]="🌧️"  ["362"]="🌧️"  ["365"]="🌧️"
        ["368"]="🌧️"  ["371"]="❄️"  ["374"]="🌨️"  ["377"]="🌨️"  ["386"]="🌨️"
        ["389"]="🌨️"  ["392"]="🌧️"  ["395"]="❄️"
      )
    

      # Fetch weather data
      weather=$(curl -s "https://wttr.in/?format=j1")

      # Parse current weather data
      current_condition=$(echo "$weather" | jq '.current_condition[0]')
      weather_code=$(echo "$current_condition" | jq -r '.weatherCode')
      temp_feels_like=$(echo "$current_condition" | jq -r '.FeelsLikeC')
      weather_desc=$(echo "$current_condition" | jq -r '.weatherDesc[0].value')
      windspeed=$(echo "$current_condition" | jq -r '.windspeedKmph')
      humidity=$(echo "$current_condition" | jq -r '.humidity')

      # Format the current weather output
      text=" ''${WEATHER_CODES[''$weather_code]} ''${temp_feels_like}°"
      tooltip="<b>''${weather_desc} ''${temp_feels_like}°</b>\n"
      tooltip+="Wind: ''${windspeed} km/h\n"
      tooltip+="Humidity: ''${humidity}%\n"
  
      # Output cleaned up result
      echo "$text"
      echo "$tooltip"


    '';
  };
}
