# dotfiles/bin/home/state.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  self,
  lib,
  config,
  pkgs,
  sweSpeech,
  ...
} : let

in {
  yo.scripts.state = {
    description = "High-performance unified CLI for controlling all smart home devices.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "DEBUG";

    parameters = [
      { name = "device"; description = "Device to control"; optional = true; }
      { name = "room"; description = "Room to target"; optional = true; values = sweSpeech.roomNames; }
      { name = "state"; description = "State to verify (returns true/false)"; optional = true;
        values = [ "öppen" "stängd" "tänd" "släckt" "open" "closed" "on" "off" "rörelse" "motion" "aktiv" ]; }
      { name = "reverse"; description = "Invert the result"; type = "bool"; optional = true; }
    ];

    code = ''
      DEVICE="''${device:-}"
      INPUT_LOWER=$(printf '%s' "$DEVICE" | tr '[:upper:]' '[:lower:]')

      ${sweSpeech.mkBashMap "ROOM_ALIAS_MAP" sweSpeech.roomAliasMap}
      ${sweSpeech.mkBashMap "DEVICE_MAP"     sweSpeech.devicePatternMap}
      ${sweSpeech.mkBashMap "ROOM_MAP"       sweSpeech.roomBashMap}
      ${sweSpeech.mkBashMap "TYPE_MAP"       sweSpeech.typeMap}

      STATE_JSON=$(zigduck-cli --state-json 2>/dev/null)
      if [ -z "$STATE_JSON" ] || ! printf '%s' "$STATE_JSON" | jq -e . >/dev/null 2>&1; then
        echo "⚠️ Kunde inte hämta status från zigduck"
        exit 1
      fi

      if [ -n "$state" ]; then
        STATE_LOWER=$(printf '%s' "$state" | tr '[:upper:]' '[:lower:]')
        ROOM_LOWER=$(printf '%s' "''${room:-}" | tr '[:upper:]' '[:lower:]')

        [ -z "$INPUT_LOWER" ] && [ -z "$ROOM_LOWER" ] && { echo "false"; echo "❌ --state kräver --device eller --room" >&2; exit 1; }

        RESOLVED_ROOM=""
        if [ -n "$ROOM_LOWER" ]; then
          if   [ -n "''${ROOM_MAP[$ROOM_LOWER]+x}" ];       then RESOLVED_ROOM="$ROOM_LOWER"
          elif [ -n "''${ROOM_ALIAS_MAP[$ROOM_LOWER]+x}" ]; then RESOLVED_ROOM="''${ROOM_ALIAS_MAP[$ROOM_LOWER]}"
          fi
          if [ -z "$RESOLVED_ROOM" ]; then
            echo "false"; echo "❌ Okänt rum: $room" >&2; exit 1
          fi
        fi

        if [ -z "$INPUT_LOWER" ] && [ -n "$RESOLVED_ROOM" ]; then
          case "$STATE_LOWER" in
            rörelse|motion|rörlig|aktiv)
              ANY_MOTION=false
              IFS='|' read -ra ROOM_DEVS <<< "''${ROOM_MAP[$RESOLVED_ROOM]}"
              for rd in "''${ROOM_DEVS[@]}"; do
                rdl=$(printf '%s' "$rd" | tr '[:upper:]' '[:lower:]')
                rdtype="''${TYPE_MAP[$rdl]:-unknown}"
                if [ "$rdtype" = "motion" ]; then
                  occ=$(printf '%s' "$STATE_JSON" | jq -r --arg n "$rd" '.[$n].occupancy // "false"' | tr -d '"')
                  if [ "$occ" = "true" ] || [ "$occ" = "True" ] || [ "$occ" = "1" ]; then
                    ANY_MOTION=true
                    break
                  fi
                fi
              done
              if [ "''${reverse:-false}" = "true" ]; then
                if [ "$ANY_MOTION" = "true" ]; then ANY_MOTION=false; else ANY_MOTION=true; fi
              fi
              echo "$ANY_MOTION"
              exit 0
              ;;
            *)
              echo "false"
              echo "❌ Rum-fråga stöds bara för rörelse/motion" >&2
              exit 1
              ;;
          esac
        fi

        if [ -n "$RESOLVED_ROOM" ]; then
          CANDIDATES="''${ROOM_MAP[$RESOLVED_ROOM]}"
        else
          CANDIDATES="${sweSpeech.allDevicesStr}"
        fi

        MATCHED=""
        IFS='|' read -ra CAND <<< "$CANDIDATES"
        for c in "''${CAND[@]}"; do
          cl=$(printf '%s' "$c" | tr '[:upper:]' '[:lower:]')
          [ "$cl" = "$INPUT_LOWER" ] && { MATCHED="$c"; break; }
        done
        if [ -z "$MATCHED" ]; then
          for c in "''${CAND[@]}"; do
            cl=$(printf '%s' "$c" | tr '[:upper:]' '[:lower:]')
            if [[ "$cl" == *"$INPUT_LOWER"* ]] || [[ "$INPUT_LOWER" == *"$cl"* ]]; then
              MATCHED="$c"; break
            fi
          done
        fi
        [ -z "$MATCHED" ] && { echo "false"; echo "❌ Ingen enhet matchar '$DEVICE'" >&2; exit 1; }

        IFS='|' read -r _name dstate dcontact dpos dbri docc < <(
          printf '%s' "$STATE_JSON" | jq -r --arg n "$MATCHED" '
            (.[$n] // {}) as $d |
            [ $n,
              ($d.state      | if . == null then "" else tostring end),
              ($d.contact    | if . == null then "" else tostring end),
              ($d.position   | if . == null then "" else tostring end),
              ($d.brightness | if . == null then "" else tostring end),
              ($d.occupancy  | if . == null then "" else tostring end) ]
            | map(tostring) | join("|")
          '
        )

        RESULT=false
        case "$STATE_LOWER" in
          öppen|oppen|öppet|open)
            { [ "$dcontact" = "false" ] \
              || [ "$dstate" = "OPEN" ] || [ "$dstate" = "open" ] \
              || { [ -n "$dpos" ] && [ "$dpos" != "0" ]; }; } && RESULT=true ;;
          stängd|stangd|stängt|closed|close)
            { [ "$dcontact" = "true" ] \
              || [ "$dstate" = "CLOSE" ] || [ "$dstate" = "close" ] \
              || [ "$dstate" = "CLOSED" ] || [ "$dstate" = "closed" ] \
              || { [ -n "$dpos" ] && [ "$dpos" = "0" ]; }; } && RESULT=true ;;
          tänd|tand|tänt|on|på|pa)
            if [ -n "$dstate" ]; then
              { [ "$dstate" = "ON" ] || [ "$dstate" = "on" ]; } && RESULT=true
            else
              { [ -n "$dbri" ] && [ "$dbri" -gt 0 ] 2>/dev/null; } && RESULT=true
            fi ;;
          släckt|slakt|släkt|off|av)
            if [ -n "$dstate" ]; then
              { [ "$dstate" = "OFF" ] || [ "$dstate" = "off" ]; } && RESULT=true
            else
              { [ -n "$dbri" ] && [ "$dbri" = "0" ]; } && RESULT=true
            fi ;;
          rörelse|motion|rörlig|aktiv)
            { [ "$docc" = "true" ] || [ "$docc" = "True" ] || [ "$docc" = "1" ]; } && RESULT=true ;;
          *)
            echo "false"; echo "❌ Okänt tillstånd: $state" >&2; exit 1 ;;
        esac
        if [ "''${reverse:-false}" = "true" ]; then
          if [ "$RESULT" = "true" ]; then RESULT=false; else RESULT=true; fi
        fi
        echo "$RESULT"
        exit 0
      fi

      TARGET_LIST=""
      HEADER=""
      if [ -z "$INPUT_LOWER" ] || [ "$INPUT_LOWER" = "all" ] || [ "$INPUT_LOWER" = "every" ] \
         || [ "$INPUT_LOWER" = "alla" ] || [ "$INPUT_LOWER" = "allt" ]; then
        TARGET_LIST="${sweSpeech.allDevicesStr}"
        HEADER="Alla enheter"
      elif [ -n "''${ROOM_MAP[$INPUT_LOWER]+x}" ]; then
        TARGET_LIST="''${ROOM_MAP[$INPUT_LOWER]}"
        HEADER="$DEVICE"
      elif [ -n "''${DEVICE_MAP[$INPUT_LOWER]+x}" ]; then
        TARGET_LIST="''${DEVICE_MAP[$INPUT_LOWER]}"
      else
        for key in "''${!DEVICE_MAP[@]}"; do
          if [[ "$key" == *"$INPUT_LOWER"* ]]; then
            TARGET_LIST="''${DEVICE_MAP[$key]}"
            break
          fi
        done
        if [ -z "$TARGET_LIST" ]; then
          echo "❌ Ingen enhet matchar '$DEVICE'"
          exit 1
        fi
      fi

      IFS='|' read -ra TARGETS <<< "$TARGET_LIST"
      [ -n "$HEADER" ] && echo "$HEADER"
      if [ "''${#TARGETS[@]}" -gt 1 ]; then INDENT="  "; else INDENT=""; fi

      JQ_NAMES=$(printf '%s\n' "''${TARGETS[@]}" | jq -R . | jq -sc .)

      printf '%s' "$STATE_JSON" | jq -r --argjson names "$JQ_NAMES" '
        $names[] as $n |
        (.[$n] // {}) as $d |
        [
          $n,
          ($d.state          | if . == null then "" else tostring end),
          ($d.contact        | if . == null then "" else tostring end),
          ($d.position       | if . == null then "" else tostring end),
          ($d.brightness     | if . == null then "" else tostring end),
          ($d.battery        | if . == null then "" else tostring end),
          ($d.temperature    | if . == null then "" else tostring end),
          ($d.humidity       | if . == null then "" else tostring end),
          ($d.linkquality    | if . == null then "" else tostring end),
          ($d.occupancy      | if . == null then "" else tostring end),
          ($d.illuminance    | if . == null then "" else tostring end),
          ($d.power          | if . == null then "" else tostring end),
          ($d.smoke          | if . == null then "" else tostring end),
          ($d.water_leak     | if . == null then "" else tostring end),
          ($d.carbon_monoxide| if . == null then "" else tostring end),
          ($d.tamper         | if . == null then "" else tostring end)
        ] | map(tostring) | join("|")
      ' | while IFS='|' read -r name state contact position brightness battery \
            temperature humidity linkquality occupancy illuminance power \
            smoke water_leak carbon_monoxide tamper; do

        target_lower=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')
        dtype="''${TYPE_MAP[$target_lower]:-unknown}"
        parts=()

        if [ -n "$state" ]; then
          case "$state" in
            ON|on|true|True|1)
              if [ "$dtype" = "light" ]; then parts+=("tänd"); else parts+=("på"); fi ;;
            OFF|off|false|False|0)
              if [ "$dtype" = "light" ]; then parts+=("släckt"); else parts+=("av"); fi ;;
            OPEN|open)              parts+=("öppen") ;;
            CLOSE|close|CLOSED|closed) parts+=("stängd") ;;
            unavailable|offline)    parts+=("otillgänglig") ;;
            *)                      parts+=("$state") ;;
          esac
        fi

        if [ -n "$contact" ]; then
          case "$contact" in
            true|True|1)   parts+=("stängd") ;;
            false|False|0) parts+=("öppen") ;;
            *)             parts+=("kontakt: $contact") ;;
          esac
        fi

        if [ -n "$position" ]; then
          if   [ "$position" = "0" ];   then parts+=("stängd")
          elif [ "$position" = "100" ]; then parts+=("öppen")
          else                               parts+=("$position%")
          fi
        fi

        if [ -n "$brightness" ] && [ "$brightness" -gt 0 ] 2>/dev/null; then
          if [ -z "$state" ] || [ "$state" = "ON" ] || [ "$state" = "on" ] \
             || [ "$state" = "true" ] || [ "$state" = "True" ]; then
            if [ "$brightness" -gt 100 ] 2>/dev/null; then
              pct=$(( brightness * 100 / 254 ))
            else
              pct=$brightness
            fi
            parts+=("''${pct}%")
          fi
        fi

        [ -n "$battery" ]     && parts+=("batteri ''${battery}%")
        [ -n "$temperature" ] && parts+=("''${temperature}°C")
        [ -n "$humidity" ]    && parts+=("''${humidity}%")
        [ -n "$linkquality" ] && parts+=("signal $linkquality")

        if [ "$occupancy" = "true" ] || [ "$occupancy" = "True" ]; then
          parts+=("rörelse")
        fi

        [ -n "$illuminance" ] && parts+=("''${illuminance} lux")
        [ -n "$power" ]       && parts+=("''${power} W")

        { [ "$smoke" = "true" ] || [ "$smoke" = "True" ]; }                 && parts+=("🚨 RÖK")
        { [ "$water_leak" = "true" ] || [ "$water_leak" = "True" ]; }       && parts+=("💧 LÄCKA")
        { [ "$carbon_monoxide" = "true" ] || [ "$carbon_monoxide" = "True" ]; } && parts+=("☠️ CO")
        { [ "$tamper" = "true" ] || [ "$tamper" = "True" ]; }               && parts+=("⚠️ manipulerad")

        joined=""
        for p in "''${parts[@]}"; do
          [ -n "$joined" ] && joined+=", "
          joined+="$p"
        done
        [ -z "$joined" ] && joined="okänd"

        echo "''${INDENT}$name: $joined"
      done
    '';

    voice = {
      priority = 2;
      fuzzy = {
        enable = true;
        threshold = 0.5;
      };
      sentences = [
        "det {reverse} (är|finns) {state} i {room}"
        "det {reverse} (är|finns) {state} i {device}"
        "{device} {reverse} är {state}"
        "kolla om {device} är {state}"
        "kolla om {device} i {room} är {state}"
        "kontrollera om {device} är {state}"
        "kontrollera om {device} i {room} är {state}"
        "är det {state} i {room}"
        "kolla om det är {state} i {room}"
        "det är {state} i {room}"
        "det är {state} i {device}"
        "det finns {state} i {room}"
        "rörelse i {room}"
        "status [på] {device}"
        "status [i] {room}"
        "visa status [för] {device}"
        "visa status [i] {room}"
        "status [för] (alla|allt|all) (enheter|lampor)"
        "vilket läge är {device} i"
        "vilket tillstånd har {device}"
        "hur mycket batteri har {device}"
        "vilken position har {device}"
        "[är] {device} [är] {state}"
      ];
      lists = {
        state.values  = sweSpeech.queryStateValues;
        device.values = sweSpeech.deviceValues;
        room.values   = sweSpeech.roomValues;
        reverse.values = [
          { "in" = "inte"; out = "true"; }
        ];
      };
    };

  };}
