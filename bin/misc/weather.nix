# dotfiles/bin/misc/weather.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Weather forecast
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
  yo.scripts.weather = {
    description = "Weather Assistant. Ask anything weather related (3 day forecast)";
    category = "🌍 Localization";
    aliases = [ "weat" ];
    parameters = [
      { name = "location"; description = "Location to check (City, Country). Not required if using locationPath"; optional = true; }
      { name = "day"; description = "Search weather for a specified day"; optional = true; }
      { name = "condition"; description = "Check for a specific weather condition"; optional = true; }
      { name = "locationPath"; description = "File path contianing location to check (City, Country)"; default = config.sops.secrets."users/pungkula/homeCityCountry".path; }
    ];
    code = ''
      ${cmdHelpers}
      if [ -n "$location" ]; then
        :
      elif [ -f "$locationPath" ]; then
        location=$(cat "$locationPath")
      else
        dt_error "Error: No location is provided."
        exit 1
      fi
      # 🦆 says ⮞ get 3-day forecast
      weather_file="/home/pungkula/weather.json"
      cache_age=1800
      refresh_cache=true
      if [ -f "$weather_file" ]; then
        current_time=$(date +%s)
        file_time=$(stat -c %Y "$weather_file")
        if (( current_time - file_time < cache_age )); then
          refresh_cache=false
        fi
      fi
      if [ "$refresh_cache" = true ]; then
        curl -s "https://wttr.in/$location_param?format=j1" -o "$weather_file"
      fi
      weather=$(cat "$weather_file")

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

      kmh_to_ms() {
        awk "BEGIN { printf \"%.6f\n\", $1 / 3.6 }"
      }
      # 🦆 says ⮞ map condition > weather codes
      declare -A CONDITION_CODES=(
        ["sunny"]="113"
        ["partly cloudy"]="116"
        ["cloudy"]="119 122 143"
        ["rain"]="176 179 182 185 263 266 281 284 293 296 299 302 305 308 311 314 317 350 353 356 359 362 365 368 392"
        ["sleet"]="227 230 320 323 326 374 377 386 389"
        ["snow"]="329 332 335 338 371 395"
        ["thunderstorm"]="200"
        ["fog"]="248 260"
      )

      # 🦆 says ⮞ map condition > Swedish names
      declare -A CONDITION_SWEDISH=(
        ["sunny"]="soligt"
        ["partly cloudy"]="halvklart"
        ["cloudy"]="molnigt"
        ["rain"]="regn"
        ["sleet"]="snöblandat regn"
        ["snow"]="snö"
        ["thunderstorm"]="åska"
        ["fog"]="dimma"
        ["windy"]="blåsigt"
        ["hot"]="varmt"
        ["cold"]="kallt"
      )
      declare -A WEATHER_SWEDISH_DESC=(
        ["Clear"]="klart väder"
        ["Sunny"]="soligt"
        ["Partly Cloudy"]="delvis molnigt"
        ["partly cloudy"]="delvis molnigt"
        ["Patchy rain nearby"]="delvis regn i närheten"
        ["cloudy"]="molnigt"
        ["Overcast"]="mulet"
        ["Light Rain"]="lätt regn"
        ["Light rain shower"]="lätt regnskur"
        ["Moderate Rain"]="måttligt regn"
      )
      get_day_name_from_epoch() {
        local epoch=$1
        local days_sv=("söndag" "måndag" "tisdag" "onsdag" "torsdag" "fredag" "lördag")
        local day_index=$(date -d "@$epoch" +%w)  # +%w returns 0-6 (Sun-Sat)
        echo "''${days_sv[$day_index]}"
      }

      location_param=""
      if [ -n "$location" ]; then
          location_param="$location"
      fi
      day_param="$day"
      condition_param="$condition"



      # 🦆 says ⮞ get Swedish day name
      get_day_name() {
          local offset=$1
          local days_sv=("söndag" "måndag" "tisdag" "onsdag" "torsdag" "fredag" "lördag")
          local day_index=$(date -d "today + $offset days" +%w)
          echo "''${days_sv[$day_index]}"
      }

      # 🦆 says ⮞ find day offset
      get_day_offset() {
          case "$1" in
              "idag") echo 0 ;;
              "imorgon") echo 1 ;;
              "i övermorgon") echo 2 ;;
              *)
                  for i in {0..6}; do
                      if [ "$(get_day_name $i)" = "$1" ]; then
                          echo $i
                          return
                      fi
                  done
                  echo 0 # 🦆 says ⮞ default today
                  ;;
          esac
      }

      # 🦆 says ⮞ display weather in a table
      display_weather_table() {
        local processed_data=$1
        local title=$2

        markdown_table=$(
          echo "# Weather"
          echo "| Day | Min/Max | Wind | Precip | Conditions |"
          echo "|-----|---------|------|--------|------------|"

          local day_count=$(echo "$processed_data" | jq length)

          for ((i=0; i<day_count; i++)); do
            day_data=$(echo "$processed_data" | jq -r ".[$i]")

            date_epoch=$(date -d "$(echo "$day_data" | jq -r '.date')" +%s)
            day_name=$(get_day_name_from_epoch "$date_epoch")
            mintempC=$(echo "$day_data" | jq -r '.mintempC')
            maxtempC=$(echo "$day_data" | jq -r '.maxtempC')
            weather_code=$(echo "$day_data" | jq -r '.noonWeather.weatherCode')
            condition_emoji="''${WEATHER_CODES[$weather_code]:-❓}"
            condition_text=$(echo "$day_data" | jq -r '.noonWeather.weatherDesc')
            wind=$(echo "$day_data" | jq -r '.noonWeather.windspeedKmph')
            precip=$(echo "$day_data" | jq -r '.noonWeather.precipMM')

            echo "| $day_name | $mintempC-$maxtempC°C | $wind km/h | $precip mm | $condition_emoji $condition_text |"
          done
        )

        echo "$markdown_table" | ${pkgs.glow}/bin/glow -
      }

      # 🦆 says ⮞ display specific day forecast
      show_day_forecast() {
        local offset=$1

        local processed=$(jq --argjson offset "$offset" \
          '[.weather[$offset] | {
            date,
            mintempC,
            maxtempC,
            noonWeather: (.hourly[] | select(.time=="1200") | {
              weatherCode,
              weatherDesc: .weatherDesc[0].value,
              windspeedKmph,
              humidity,
              precipMM
            })
          }]' "$weather_file")

        case $offset in
            0) display_name="Idag" ;;
            1) display_name="Imorgon" ;;
            2) display_name="I övermorgon" ;;
            *) display_name="$(get_day_name $offset)" ;;
        esac

        day_data=$(echo "$processed" | jq -r '.[0]')
        weather_code=$(echo "$day_data" | jq -r '.noonWeather.weatherCode')
        condition_emoji="''${WEATHER_CODES[$weather_code]:-❓}"
        condition_text=$(echo "$day_data" | jq -r '.noonWeather.weatherDesc')
        mintempC=$(echo "$day_data" | jq -r '.mintempC')
        maxtempC=$(echo "$day_data" | jq -r '.maxtempC')
        display_weather_table "$processed" "Weather Forecast for $location_param ($display_name)"
        lookup_key=$(echo "$condition_text" | sed 's/.*/\L&/; s/\b\(.\)/\u\1/g')  # lowercase all, then capitalize first letters
        precipMM=$(echo "$day_data" | jq -r '.noonWeather.precipMM')
        lookup_key=$(echo "$condition_text" | sed -E 's/(^| )([a-z])/\1\u\2/g')
        dt_debug "condition_text=$condition_text, lookup_key=$lookup_key"
        swedish_condition="''${WEATHER_SWEDISH_DESC[$lookup_key]:-''${condition_text,,}}"
        local precip_text=""
        if (( $(echo "$precipMM > 0" | bc -l) )); then
          precip_text=", med $precipMM millimeter nederbörd"
        fi
        dt_info "$display_name: $swedish_condition. Min $mintempC grader, max $maxtempC grader$precip_text."
        yo-say "$display_name: $swedish_condition. Min $mintempC grader, max $maxtempC grader$precip_text."

      }

      # 🦆 says ⮞ display 3-day forecast
      show_5day_forecast() {
        local processed=$(jq '[.weather[] | {
          date,
          mintempC,
          maxtempC,
          noonWeather: (.hourly[] | select(.time=="1200") | {
            weatherCode,
            weatherDesc: .weatherDesc[0].value,
            windspeedKmph,
            humidity,
            precipMM
          })
        }]' "$weather_file")

        display_weather_table "$processed" "$location_param"
      }

      generate_tts_summary() {
          local processed=$(jq '[.weather[0], .weather[1], .weather[2] | {
              date,
              mintempC,
              maxtempC,
              noonWeather: (.hourly[] | select(.time=="1200") | {
                  weatherCode,
                  weatherDesc: .weatherDesc[0].value,
                  windspeedKmph,
                  humidity,
                  precipMM,
                  chanceofrain,
                  FeelsLikeC
              })
          }]' "$weather_file")

          local summary="Väderöversikt för nästa tre dagar. "

          for i in 0 1 2; do
              local day_data=$(echo "$processed" | jq -r ".[$i]")
              local date_epoch=$(date -d "$(echo "$day_data" | jq -r '.date')" +%s)
              local day_name=$(get_day_name_from_epoch "$date_epoch")

              local mintempC=$(echo "$day_data" | jq -r '.mintempC')
              local maxtempC=$(echo "$day_data" | jq -r '.maxtempC')
              local weather_code=$(echo "$day_data" | jq -r '.noonWeather.weatherCode')
              local condition_text=$(echo "$day_data" | jq -r '.noonWeather.weatherDesc')
              local precipMM=$(echo "$day_data" | jq -r '.noonWeather.precipMM')
              local chance_of_rain=$(echo "$day_data" | jq -r '.noonWeather.chanceofrain')
              local wind_speed=$(echo "$day_data" | jq -r '.noonWeather.windspeedKmph')

              local lookup_key=$(echo "$condition_text" | sed -E 's/(^| )([a-z])/\1\u\2/g')
              local swedish_condition="''${WEATHER_SWEDISH_DESC[$lookup_key]:-''${condition_text,,}}"

              case $i in
                  0) day_desc="Idag" ;;
                  1) day_desc="Imorgon" ;;
                  2) day_desc="I övermorgon" ;;
                  *) day_desc="På $day_name" ;;
              esac

              local temp_desc="mellan $mintempC och $maxtempC grader"

              local wind_desc=""
              if (( wind_speed > 20 )); then
                  local ms_speed=$(kmh_to_ms "$wind_speed")
                  wind_desc=", blåsigt med $wind_speed kilometer per timme"
              elif (( wind_speed > 10 )); then
                  wind_desc=", lätt bris på $wind_speed kilometer per timme"
              fi

              local precip_desc=""
              if (( $(echo "$precipMM > 0" | bc -l) )); then
                  if (( $(echo "$precipMM < 1" | bc -l) )); then
                      precip_desc=", lite nederbörd på $precipMM millimeter"
                  elif (( $(echo "$precipMM < 5" | bc -l) )); then
                      precip_desc=", nederbörd på $precipMM millimeter"
                  else
                      precip_desc=", kraftig nederbörd på $precipMM millimeter"
                  fi

                  if [ -n "$chance_of_rain" ] && [ "$chance_of_rain" != "null" ] && [ "$chance_of_rain" != "0" ]; then
                      precip_desc="$precip_desc med $chance_of_rain procents risk"
                  fi
              fi

              local humidity=$(echo "$day_data" | jq -r '.noonWeather.humidity')
              local humidity_desc=""
              if [ -n "$humidity" ] && [ "$humidity" != "null" ]; then
                  if (( humidity > 80 )); then
                      humidity_desc=", hög luftfuktighet på $humidity procent"
                  elif (( humidity < 40 )); then
                      humidity_desc=", torrt med $humidity procent luftfuktighet"
                  fi
              fi

              local feels_like=$(echo "$day_data" | jq -r '.noonWeather.FeelsLikeC')
              local feels_desc=""
              if [ -n "$feels_like" ] && [ "$feels_like" != "null" ] && [ "$feels_like" != "maxtempC" ]; then
                  local temp_diff=$((feels_like - maxtempC))
                  if (( temp_diff > 2 )); then
                      feels_desc=", känns som $feels_like grader på grund av hög luftfuktighet"
                  elif (( temp_diff < -2 )); then
                      feels_desc=", känns som $feels_like grader på grund av vinden"
                  fi
              fi

              summary="$summary $day_desc: $swedish_condition, $temp_desc$precip_desc$wind_desc$humidity_desc$feels_desc. "
          done

          local general_advice=""
          local first_day=$(echo "$processed" | jq -r '.[0]')
          local max_temp1=$(echo "$first_day" | jq -r '.maxtempC | tonumber')
          local precip1=$(echo "$first_day" | jq -r '.noonWeather.precipMM | tonumber')
          local wind1=$(echo "$first_day" | jq -r '.noonWeather.windspeedKmph | tonumber')

          if (( max_temp1 > 25 )); then
              general_advice=" Kom ihåg att dricka mycket vatten och skydda dig mot solen."
          elif (( max_temp1 < 5 )); then
              general_advice=" Se till att klä dig varmt."
          fi

          if (( $(echo "$precip1 > 5" | bc -l) )); then
              general_advice="$general_advice Ta med paraply eller regnkläder."
          fi

          if (( wind1 > 15 )); then
              general_advice="$general_advice Var försiktig ute i stark vinden."
          fi

          summary="$summary$general_advice"
          echo "$summary"
      }

      speak_weather_summary() {
          local summary=$(generate_tts_summary)
          summary=$(echo "$summary" | sed 's/  / /g' | sed 's/\. \././g')
          dt_debug "TTS Summary: $summary"
          yo-say "$summary"
      }

      # 🦆 says ⮞ check for specific condition
      check_condition() {
          local condition="$1"
          local offset="$2"
          local day_data=$(jq --argjson offset "$offset" \
            '.weather[$offset] | {
              mintempC: .mintempC,
              maxtempC: .maxtempC,
              noonWeather: (.hourly[] | select(.time=="1200") | {
                weatherCode,
                weatherDesc: .weatherDesc[0].value,
                windspeedKmph,
                humidity,
                precipMM,
                chanceofrain,
                FeelsLikeC
              })
            }' "$weather_file")

          local weather_code=$(echo "$day_data" | jq -r '.noonWeather.weatherCode')
          local condition_text=$(echo "$day_data" | jq -r '.noonWeather.weatherDesc' | tr '[:upper:]' '[:lower:]')
          local wind_speed=$(echo "$day_data" | jq -r '.noonWeather.windspeedKmph')
          local mintempC=$(echo "$day_data" | jq -r '.mintempC')
          local maxtempC=$(echo "$day_data" | jq -r '.maxtempC')
          local precipMM=$(echo "$day_data" | jq -r '.noonWeather.precipMM')
          local chance_of_rain=$(echo "$day_data" | jq -r '.noonWeather.chanceofrain')

          case $offset in
              0) display_name="idag" ;;
              1) display_name="imorgon" ;;
              2) display_name="i övermorgon" ;;
              *) display_name="$(get_day_name $offset)" ;;
          esac
          local swedish_condition="''${CONDITION_SWEDISH[$condition]}"
          case "$condition" in
            sunny|partly\ cloudy|cloudy|rain|sleet|snow|thunderstorm|fog)
                local codes="''${CONDITION_CODES[$condition]}"
                if [[ " $codes " =~ " $weather_code " ]]; then
                    dt_info "Ja, det blir $swedish_condition $display_name."
                    tts "Ja, det blir $swedish_condition $display_name."
                    return 0
                else
                    dt_info "Nej, det blir inte $swedish_condition $display_name."
                    tts "Nej, det blir inte $swedish_condition $display_name."
                    return 1
                fi
                ;;
            windy)
                local ms_speed=$(kmh_to_ms "$wind_speed")
                if (( wind_speed > 20 )); then
                    dt_info "Ja, det blir $swedish_condition $display_name ($wind_speed km/h ≈ ''${ms_speed} m/s)."
                    tts "Ja, det blir $swedish_condition $display_name. Vinden ligger runt $wind_speed kilometer per timme, alltså cirka ''${ms_speed} meter per sekund."
                    return 0
                else
                    dt_info "Nej, det blir inte särskilt $swedish_condition $display_name ($wind_speed km/h ≈ ''${ms_speed} m/s)."
                    tts "Nej, det blir inte särskilt $swedish_condition $display_name. Bara $wind_speed kilometer per timme, alltså ''${ms_speed} meter per sekund."
                    return 1
                fi
                ;;
            hot)
                if (( maxtempC > 28 )); then
                    dt_info "Ja, mycket varmt $display_name! Hetterekord på $maxtempC°C."
                    tts "Ja, mycket varmt $display_name! Hetterekord på $maxtempC grader."
                    return 0
                elif (( maxtempC > 25 )); then
                    dt_info "Ja, varmt $display_name med $maxtempC°C."
                    tts "Ja, varmt $display_name med $maxtempC grader."
                    return 0
                else
                    dt_info "Nej, inte särskilt varmt $display_name. Bara $maxtempC°C."
                    tts "Nej, inte särskilt varmt. Bara $maxtempC grader."
                    return 1
                fi
                ;;
            cold)
                if (( mintempC < 10 )); then
                    dt_info "Ja, det blir $swedish_condition $display_name ($mintempC°C)."
                    tts "Ja, det blir $swedish_condition $display_name med minst $mintempC grader."
                    return 0
                else
                    dt_info "Nej, det blir inte $swedish_condition $display_name ($mintempC°C)."
                    tts "Nej, det blir inte $swedish_condition $display_name. Minst $mintempC grader."
                    return 1
                fi
                ;;
            rain)
                if (( $(echo "$precipMM > 0" | bc -l) )); then
                    if (( $(echo "$precipMM < 1" | bc -l) )); then
                        dt_info "Ja, men bara lite regn $display_name. $precipMM mm nederbörd ($chance_of_rain% risk)."
                        tts "Ja, men bara lite. $precipMM millimeter nederbörd med $chance_of_rain procents risk."
                    elif (( $(echo "$precipMM < 5" | bc -l) )); then
                        dt_info "Ja, regn $display_name. $precipMM mm nederbörd ($chance_of_rain% risk)."
                        tts "Ja, det blir regn. $precipMM millimeter nederbörd med $chance_of_rain procents risk."
                    else
                        dt_info "Ja, kraftigt regn $display_name! $precipMM mm nederbörd ($chance_of_rain% risk)."
                        tts "Ja, kraftigt regn! $precipMM millimeter nederbörd med $chance_of_rain procents risk."
                    fi
                    return 0
                else
                    dt_info "Nej, inget regn $display_name. ($chance_of_rain% risk)"
                    tts "Nej, inget regn $display_name."
                    return 1
                fi
                ;;

            *)
                dt_info "Okänd väderförhållande: $condition"
                return 1
                ;;
        esac
      }

      if [ -n "$condition_param" ]; then
          if [ -z "$day_param" ]; then
              day_param="idag"
          fi
          offset=$(get_day_offset "$day_param")
          check_condition "$condition_param" "$offset"
      elif [ -n "$day_param" ]; then
          offset=$(get_day_offset "$day_param")
          show_day_forecast $offset
      else
          show_5day_forecast
          speak_weather_summary
      fi
    '';
    voice = {
      enabled = true;
      priority = 2;
      sentences = [
        # 🦆 says ⮞ 3 day weather cast
        "(vad|hur) (är|blir) [det] [för] (vädret|väder)"
        "vädret"
        # 🦆 says ⮞ Specify day
        "hur (blir|är) vädret [på] {day}"
        "hur (varmt|kallt) (blir|är) det [på] {day}"
        "vad blir det för väder [på] {day}"
        # 🦆 says ⮞ check condition
        "hur {condition} (är|blir) det på {day}"
        "(kommer|blir) det [att] {condition} [på] {day}"
        "hur {condition} är det"
        "kommer det att {condition} [på] {day}"
      ];
      lists = {
        day.values = [
          { "in" = "[ida|idag]"; out = "idag"; }
          { "in" = "imorgon"; out = "imorgon"; }
          { "in" = "i morgon"; out = "imorgon"; }
          { "in" = "i övermorgon"; out = "i övermorgon"; }
          { "in" = "övermorgon"; out = "i övermorgon"; }
          # 🦆 says ⮞ dayz
          { "in" = "måndag"; out = "måndag"; }
          { "in" = "tisdag"; out = "tisdag"; }
          { "in" = "onsdag"; out = "onsdag"; }
          { "in" = "torsdag"; out = "torsdag"; }
          { "in" = "fredag"; out = "fredag"; }
          { "in" = "lördag"; out = "lördag"; }
          { "in" = "söndag"; out = "söndag"; }
        ];
        condition.values = [
          # ☀️ Sunny / Clear
          { "in" = "[sol|soligt|klart]"; out = "sunny"; }
          # ⛅ Partly Cloudy
          { "in" = "[halvklart|delvis molnigt|växlande molnighet]"; out = "partly cloudy"; }
          # ☁️ Cloudy / Overcast
          { "in" = "[molnigt|mulet|övermulet]"; out = "cloudy"; }
          # 🌧️ Rain / Showers
          { "in" = "[regn|regna|regnar|skurar|duschregn]"; out = "rain"; }
          # 🌨️ Snow Showers
          { "in" = "[snöblandat regn|snöblask|blötsnö]"; out = "sleet"; }
          # ❄️ Snow
          { "in" = "[snö|snöa|snöar|snöfall]"; out = "snow"; }
          # ⛈️ Thunderstorm
          { "in" = "[åska|åskväder|åskregn|blixt]"; out = "thunderstorm"; }
          # 🌫️ Fog / Mist
          { "in" = "[dimma|dis|töcken]"; out = "fog"; }
          # 🌬️ Windy
          { "in" = "[blås|blåsa|blåsigt|vind|vindigt]"; out = "windy"; }
          # 🌡️ Heat / Warm
          { "in" = "[varm|varmt|hett|värme]"; out = "varmt"; }
          # ❄️ Cold
          { "in" = "[kallt|kyla|frost]"; out = "kallt"; }
        ];
      };
    };
  };

  sops.secrets."users/pungkula/homeCityCountry" = {
    sopsFile = ./../../secrets/users/pungkula/homeCityCountry.yaml;
    owner = config.this.user.me.name;
    group = config.this.user.me.name;
    mode = "0440";
  };}
