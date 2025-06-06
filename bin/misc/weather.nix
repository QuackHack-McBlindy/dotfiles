# dotfiles/bin/system/weather.nix
{ 
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
} : let  
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
  yo.bitch.intents = {
    stores = {
      data = [{
        sentences = [
          "hur är vädret"
          "vad är det för temperatur ute"
          "vad är det för väder"
          "utomhus temperatur"
          "vädret"
        ];
      }];
    };   
  };

  yo.scripts.weather = {
    description = "Tiny Weather Report.";
    category = "🌍 Localization";
    aliases = [ "weat" ];
    parameters = [{
      name = "location"; 
      description = "Location to check (e.g., 'London' or 'New+York')"; 
      optional = true; 
      default = "Stockholm, Sweden"; 
    }]; 
    code = ''
      ${cmdHelpers}
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
      weather=$(curl -s "https://wttr.in/?format=j1")

      current_condition=$(echo "$weather" | jq '.current_condition[0]')
      weather_code=$(echo "$current_condition" | jq -r '.weatherCode')
      temp_feels_like=$(echo "$current_condition" | jq -r '.FeelsLikeC')
      weather_desc=$(echo "$current_condition" | jq -r '.weatherDesc[0].value')
      windspeed=$(echo "$current_condition" | jq -r '.windspeedKmph')
      humidity=$(echo "$current_condition" | jq -r '.humidity')

      text=" ''${WEATHER_CODES[''$weather_code]} ''${temp_feels_like}° .. "
      tooltip="Weather right now is! ''${weather_desc} ''${temp_feels_like}° .. "
      tooltip+="Wind is currently: ''${windspeed} kilometers per hour .. "
      tooltip+="Air Humidity right now is: ''${humidity} procent .."
  
      echo "$text"
      echo "$tooltip"
      say "$tooltip"
    '';
  };
}
