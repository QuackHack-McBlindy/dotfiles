# dotfiles/bin/home/state.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  self,
  lib,
  config,
  pkgs,
  ...
} : let
  zigbeeDevices = config.house.zigbee.devices;
  scenes = config.house.zigbee.scenes;
  sceneNames = builtins.attrNames scenes;

  swedishNumbers = [
    "noll" "ett" "två" "tre" "fyra" "fem" "sex" "sju" "åtta" "nio" "tio"
    "elva" "tolv" "tretton" "fjorton" "femton" "sexton" "sjutton" "arton" "nitton"
    "tjugo" "tjugoett" "tjugotvå" "tjugotre" "tjugofyra" "tjugofem" "tjugosex" "tjugosju" "tjugoåtta" "tjugonio"
    "trettio" "trettioett" "trettiotvå" "trettiotre" "trettiofyra" "trettiofem" "trettiosex" "trettiosju" "trettioåtta" "trettionio"
    "fyrtio" "fyrtioett" "fyrtiotvå" "fyrtiotre" "fyrtiofyra" "fyrtiofem" "fyrtiosex" "fyrtiosju" "fyrtioåtta" "fyrtionio"
    "femtio" "femtioett" "femtiotvå" "femtiotre" "femtiofyra" "femtiofem" "femtiosex" "femtiosju" "femtioåtta" "femtionio"
    "sextio" "sextioett" "sextiotvå" "sextiotre" "sextiofyra" "sextiofem" "sextiosex" "sextiosju" "sextioåtta" "sextionio"
    "sjuttio" "sjuttioett" "sjuttiotvå" "sjuttiotre" "sjuttiofyra" "sjuttiofem" "sjuttiosex" "sjuttiosju" "sjuttioåtta" "sjuttionio"
    "åttio" "åttioett" "åttiotvå" "åttiotre" "åttiofyra" "åttiofem" "åttiosex" "åttiosju" "åttioåtta" "åttionio"
    "nittio" "nittioett" "nittiotvå" "nittiotre" "nittiofyra" "nittiofem" "nittiosex" "nittiosju" "nittioåtta" "nittionio"
    "etthundra"
  ];

  swedishNumber = n: builtins.elemAt swedishNumbers n;
  brightnessValues = builtins.map (n: toString n) (lib.range 0 100);

  deviceNames = map (d: d.friendly_name) (lib.attrValues zigbeeDevices);
  roomNames = if (builtins.hasAttr "rooms" config.house) then
    builtins.attrNames config.house.rooms
  else
    lib.unique (map (d: d.room) (lib.attrValues zigbeeDevices));

  lightDevices = lib.filterAttrs (_: device: device.type == "light") zigbeeDevices;

  normalizedDeviceMap = lib.mapAttrs' (id: device:
    lib.nameValuePair (lib.toLower device.friendly_name) device.friendly_name
  ) zigbeeDevices;

  roomDevicesMap = let
    grouped = lib.groupBy (device: device.room) (lib.attrValues zigbeeDevices);
  in lib.mapAttrs (room: devices:
      map (d: d.friendly_name) devices
    ) grouped;

  allDevicesList = lib.attrValues normalizedDeviceMap;
  deviceList = builtins.attrNames normalizedDeviceMap;

  roomBashMap = lib.mapAttrs' (room: devices:
    lib.nameValuePair room (lib.concatStringsSep "|" devices)
  ) roomDevicesMap;

  allDevicesStr = lib.concatStringsSep "|" allDevicesList;

  deviceAliases = {
    "Door Sensor Hall" = [
      "ytterdörr" "ytterdörren"
      "entrédörr" "entrédörren"
      "dörren" "dörr"
    ];
  };

  aliasMap = lib.foldl' (acc: device:
    let
      fn    = device.friendly_name;
      names = [ fn ] ++ (deviceAliases.${fn} or []);
    in lib.foldl' (a: n: a // { "${lib.toLower n}" = fn; }) acc names
  ) {} (lib.attrValues zigbeeDevices);

  roomAliases = [
    { aliases = "kök|köket|kitchen";          canonical = "kitchen"; }
    { aliases = "vardagsrum|vardagsrummet";   canonical = "livingroom"; }
    { aliases = "sovrum|sovrummet|bedroom";   canonical = "bedroom"; }
    { aliases = "badrum|badrummet|wc|toilet"; canonical = "WC"; }
    { aliases = "hall|hallen|hallway";        canonical = "hallway"; }
  ];

  roomAliasMap = lib.foldl' (acc: entry:
    let ins = lib.splitString "|" entry.aliases;
    in lib.foldl' (a: i: a // { "${lib.toLower i}" = entry.canonical; }) acc ins
  ) {} roomAliases;

in {
  yo.scripts.state = {
    description = "High-performance unified CLI for controlling all smart home devices.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "DEBUG";

    parameters = [
      { name = "device"; description = "Device to control"; optional = true; }
      { name = "room"; description = "Room to target"; optional = true; values = roomNames; }
      { name = "state"; description = "State to verify (returns true/false)"; optional = true;
        values = [ "öppen" "stängd" "tänd" "släckt" "open" "closed" "on" "off" ]; }
    ];

    code = ''
      DEVICE="''${device:-}"
      INPUT_LOWER=$(printf '%s' "$DEVICE" | tr '[:upper:]' '[:lower:]')

      declare -A ROOM_ALIAS_MAP=(
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v:
        "  [${lib.escapeShellArg k}]=${lib.escapeShellArg v}") roomAliasMap)}
      )

      declare -A DEVICE_MAP=(
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (lower: orig:
        "  [${lib.escapeShellArg lower}]=${lib.escapeShellArg orig}") aliasMap)}
      )
      declare -A ROOM_MAP=(
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (room: devs:
        "    [${lib.escapeShellArg (lib.toLower room)}]=${lib.escapeShellArg (lib.concatStringsSep "|" devs)}") roomDevicesMap)}
      )
      declare -A TYPE_MAP=(
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (_id: d:
        "    [${lib.escapeShellArg (lib.toLower d.friendly_name)}]=${lib.escapeShellArg (d.type or "unknown")}") zigbeeDevices)}
      )

      STATE_JSON=$(zigduck-cli --state-json 2>/dev/null)
      if [ -z "$STATE_JSON" ] || ! printf '%s' "$STATE_JSON" | jq -e . >/dev/null 2>&1; then
        echo "⚠️ Kunde inte hämta status från zigduck"
        exit 1
      fi

      # ── CHECK MODE ──────────────────────────────────────────────
      if [ -n "$state" ]; then
        STATE_LOWER=$(printf '%s' "$state" | tr '[:upper:]' '[:lower:]')
        ROOM_LOWER=$(printf '%s' "''${room:-}" | tr '[:upper:]' '[:lower:]')

        [ -z "$INPUT_LOWER" ] && { echo "false"; echo "❌ --state kräver --device" >&2; exit 1; }

        RESOLVED_ROOM=""
        if [ -n "$ROOM_LOWER" ]; then
          if   [ -n "''${ROOM_MAP[$ROOM_LOWER]+x}" ];       then RESOLVED_ROOM="$ROOM_LOWER"
          elif [ -n "''${ROOM_ALIAS_MAP[$ROOM_LOWER]+x}" ]; then RESOLVED_ROOM="''${ROOM_ALIAS_MAP[$ROOM_LOWER]}"
          fi
          if [ -z "$RESOLVED_ROOM" ]; then
            echo "false"; echo "❌ Okänt rum: $room" >&2; exit 1
          fi
        fi

        if [ -n "$RESOLVED_ROOM" ]; then
          CANDIDATES="''${ROOM_MAP[$RESOLVED_ROOM]}"
        else
          CANDIDATES="${allDevicesStr}"
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

        # non-whitespace delimiter survives empty fields
        IFS='|' read -r _name dstate dcontact dpos dbri < <(
          printf '%s' "$STATE_JSON" | jq -r --arg n "$MATCHED" '
            (.[$n] // {}) as $d |
            [ $n,
              ($d.state      | if . == null then "" else tostring end),
              ($d.contact    | if . == null then "" else tostring end),
              ($d.position   | if . == null then "" else tostring end),
              ($d.brightness | if . == null then "" else tostring end) ]
            | map(tostring) | join("|")
          '
        )

        RESULT=false
        case "$STATE_LOWER" in
          öppen|oppen|öppet|open)
            # contact="true" means magnet present = CLOSED on this sensor
            { [ "$dcontact" = "false" ] \
              || [ "$dstate" = "OPEN" ] || [ "$dstate" = "open" ] \
              || { [ -n "$dpos" ] && [ "$dpos" != "0" ]; }; } && RESULT=true ;;
          stängd|stangd|stängt|closed|close)
            { [ "$dcontact" = "true" ] \
              || [ "$dstate" = "CLOSE" ] || [ "$dstate" = "close" ] \
              || [ "$dstate" = "CLOSED" ] || [ "$dstate" = "closed" ] \
              || { [ -n "$dpos" ] && [ "$dpos" = "0" ]; }; } && RESULT=true ;;
          tänd|tand|tänt|on)
            { [ "$dstate" = "ON" ] || [ "$dstate" = "on" ] \
              || { [ -n "$dbri" ] && [ "$dbri" -gt 0 ] 2>/dev/null; }; } && RESULT=true ;;
          släckt|slakt|släkt|off)
            { [ "$dstate" = "OFF" ] || [ "$dstate" = "off" ] \
              || { [ -n "$dbri" ] && [ "$dbri" = "0" ]; }; } && RESULT=true ;;
          *)
            echo "false"; echo "❌ Okänt tillstånd: $state" >&2; exit 1 ;;
        esac

        echo "$RESULT"
        exit 0
      fi
      # ── END CHECK MODE ──────────────────────────────────────────

      # --- resolve target: all / room / device (fuzzy) ---
      TARGET_LIST=""
      HEADER=""
      if [ -z "$INPUT_LOWER" ] || [ "$INPUT_LOWER" = "all" ] || [ "$INPUT_LOWER" = "every" ] \
         || [ "$INPUT_LOWER" = "alla" ] || [ "$INPUT_LOWER" = "allt" ]; then
        TARGET_LIST="${allDevicesStr}"
        HEADER="📊 Alla enheter"
      elif [ -n "''${ROOM_MAP[$INPUT_LOWER]+x}" ]; then
        TARGET_LIST="''${ROOM_MAP[$INPUT_LOWER]}"
        HEADER="📊 $DEVICE"
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

        # contact: "true" = magnet present = CLOSED (this sensor's convention)
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
        "kolla om {device} är {state}"
        "kolla om {device} i {room} är {state}"
        "kontrollera om {device} är {state}"
        "kontrollera om {device} i {room} är {state}"
        "status [på] {device}"
        "status [i] {room}"
        "visa status [för] {device}"
        "visa status [i] {room}"
        "status [för] (alla|allt|all) (enheter|lampor)"
        "är {device} (tänd|släckt|på|av|öppen|stängd)"
        "vilket läge är {device} i"
        "vilket tillstånd har {device}"
        "hur mycket batteri har {device}"
        "vilken position har {device}"
        "är {device} {state}"
      ];
      lists = {
        state.values = [
          { "in" = "öppen|öppet|oppen|open";       out = "öppen"; }
          { "in" = "stängd|stängt|stangd|closed";  out = "stängd"; }
          { "in" = "tänd|tänt|tand|on|på|pa";      out = "tänd"; }
          { "in" = "släckt|släkt|slackt|off|av";   out = "släckt"; }
        ];

        device.values = let
          reservedNames = [ "hall" "kitchen" "bedroom" "bathroom" "wc" "livingroom" "switch" "all" "every" ];
          sanitize = str:
            lib.replaceStrings [ "/" " " ] [ "" "_" ] str;

          swedishPatterns = base: baseRaw: [
            base
            "${baseRaw}n"
            "${baseRaw}t"
            "${baseRaw}en"
            "${baseRaw}et"
            "${baseRaw}ar"
            "${baseRaw}or"
            "${baseRaw}er"
            "${baseRaw}na"
            "${baseRaw}orna"
            "${baseRaw}erna"
            "${baseRaw}lampan"
            "${baseRaw}lampor"
            "${baseRaw}lamporna"
            "${baseRaw}ljus"
            "${baseRaw}lamp"
          ];

          buildVariants = raw:
            let
              baseRaw    = lib.toLower raw;
              base       = sanitize baseRaw;
              baseWords  = lib.splitString " " base;
              isAmbiguous = lib.any (word: lib.elem word reservedNames) baseWords;
              swedishVariations = lib.unique (swedishPatterns base baseRaw);
              englishVariants = [ "${base}s" "${base} light" ];
              variants = lib.unique (
                [
                  base
                  (sanitize (lib.replaceStrings [ " " ] [ "" ] base))
                  (lib.replaceStrings [ "_" ] [ " " ] base)
                ] ++ swedishVariations ++ englishVariants
              );
            in { inherit isAmbiguous variants; };

        in lib.filter (x: x != null) (
          lib.mapAttrsToList (_: device:
            let
              aliases    = deviceAliases.${device.friendly_name} or [];
              main       = buildVariants device.friendly_name;
              aliasPats  = map buildVariants aliases;
              valid      = lib.filter (p: !p.isAmbiguous) ([ main ] ++ aliasPats);
              variations = lib.unique (lib.concatMap (p: p.variants) valid);
            in if variations == [] then null else {
              "in" = lib.concatStringsSep "|" variations;
              out = device.friendly_name;
            }
          ) zigbeeDevices
        );

        room.values = map (r: { "in" = r.aliases; out = r.canonical; }) roomAliases;
      };
    };
  };
}
