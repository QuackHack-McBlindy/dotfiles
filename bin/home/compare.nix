# dotfiles/bin/home/compare.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  self,
  lib,
  config,
  pkgs,
  swe,
  ...
} : let

in {

  yo.scripts.compare = {
    description = "Return true/false whether a device's numeric metric (power, battery, temperature, humidity, brightness, signal, lux) is above or below a threshold.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "device"; description = "Device to check"; optional = true;
          values = swe.allowFrom "device"; }
      { name = "scope";  description = "device (default) | any | all | none"; optional = true; default = "device";
          values = [ "device" "any" "all" "none" ]; }
      { name = "metric"; description = "Which metric to read"; optional = true; default = "power";
          values = swe.allowFrom "metric"; }
      { name = "above"; description = "Return true if metric > this value"; optional = true; }
      { name = "below"; description = "Return true if metric < this value"; optional = true; }
    ];
    code = ''
      ${swe.mkBashMap "DEVICE_LOOKUP" swe.deviceMap}

      SCOPE="''${scope:-device}"
      D="''${device:-}"
      METRIC="''${metric:-power}"

      [ -z "''${above:-}" ] && [ -z "''${below:-}" ] && {
        echo "false"; echo "❌ --above eller --below krävs" >&2; exit 1; }
      [ -n "''${above:-}" ] && [ -n "''${below:-}" ] && {
        echo "false"; echo "❌ ange --above ELLER --below, inte båda" >&2; exit 1; }

      STATE_JSON=$(zigduck-cli --state-json 2>/dev/null | jq -c 'with_entries(.key |= ascii_downcase)')
      [ -z "$STATE_JSON" ] && { echo "false"; echo "❌ zigduck-cli svarar inte" >&2; exit 1; }

      if [ "$SCOPE" = "device" ]; then
        [ -z "$D" ] && { echo "false"; echo "❌ --device krävs för scope=device" >&2; exit 1; }

        D_LOWER=$(printf '%s' "$D" | tr '[:upper:]' '[:lower:]')
        RESOLVED="''${DEVICE_LOOKUP[$D_LOWER]:-$D_LOWER}"

        EXISTS=$(printf '%s' "$STATE_JSON" | jq -r --arg d "$RESOLVED" '.[$d] != null')
        [ "$EXISTS" != "true" ] && {
          echo "false"; echo "❌ Okänd enhet: '$D'" >&2; exit 1; }

        VALUE=$(printf '%s' "$STATE_JSON" | jq -r --arg d "$RESOLVED" --arg m "$METRIC" '.[$d][$m] // empty' 2>/dev/null)
        [ -z "$VALUE" ] && { echo "false"; echo "❌ '$RESOLVED' saknar '$METRIC'" >&2; exit 1; }
        [[ "$VALUE" =~ ^-?[0-9.]+$ ]] || { echo "false"; echo "❌ Icke-numerisk $METRIC: '$VALUE'" >&2; exit 1; }

        if [ -n "''${above:-}" ]; then
          RESULT=$(awk -v v="$VALUE" -v t="$above" 'BEGIN{print (v>t)?"true":"false"}')
        else
          RESULT=$(awk -v v="$VALUE" -v t="$below" 'BEGIN{print (v<t)?"true":"false"}')
        fi
        echo "$RESULT"
        exit 0
      fi

      if [ -n "''${above:-}" ]; then DIR=gt; THRESHOLD="$above"
      else                        DIR=lt; THRESHOLD="$below"; fi

      COND=$(printf '%s' "$STATE_JSON" | jq -r \
        --arg m "$METRIC" --arg t "$THRESHOLD" --arg dir "$DIR" --arg scope "$SCOPE" '
        [ .[] | .[$m]? | select(. != null) | tonumber? // empty ] as $vals
        | if $dir == "gt" then
            { any:  (any($vals[]; . > ($t|tonumber))),
              all:  (($vals|length) > 0 and all($vals[]; . > ($t|tonumber))),
              none: (all($vals[]; . <= ($t|tonumber))) }
          else
            { any:  (any($vals[]; . < ($t|tonumber))),
              all:  (($vals|length) > 0 and all($vals[]; . < ($t|tonumber))),
              none: (all($vals[]; . >= ($t|tonumber))) }
          end
        | .[$scope]
      ')

      case "$COND" in
        true|false) echo "$COND" ;;
        *) echo "false"; echo "❌ Kunde inte utvärdera scope=$SCOPE" >&2; exit 1 ;;
      esac
    '';

    voice = {
      priority        = 3;
      fuzzy.enable    = true;
      fuzzy.threshold = 0.5;
      sentences = [
        "{scope} [batteridriven] (enhet|enheter|sensor|sensorer|grej|grejer|pryl|prylar) har mindre {metric} än {below}"
        "{scope} [batteridriven] (enhet|enheter|sensor|sensorer|grej|grejer|pryl|prylar) har mer {metric} än {above}"
        "{scope} [batteridriven] (enhet|enheter|sensor|sensorer|grej|grejer|pryl|prylar) har {metric} under {below}"
        "{scope} [batteridriven] (enhet|enheter|sensor|sensorer|grej|grejer|pryl|prylar) har {metric} över {above}"
        "är det {scope} [batteridriven] (enhet|enheter|sensor|sensorer) som har mindre {metric} än {below}"
        "är det {scope} [batteridriven] (enhet|enheter|sensor|sensorer) som har mer {metric} än {above}"
        "{device} (drar|använder|är) (mer|över) [än] {above} watt"
        "{device} (drar|använder|är) (mindre|under) [än] {below} watt"
        "{device} {metric} över {above}"
        "{device} {metric} under {below}"
        "{device} {metric} mer än {above}"
        "{device} {metric} mindre än {below}"
        "{metric} [på] {device} över {above}"
        "{metric} [på] {device} under {below}"
        "{metric} [på] {device} mer än {above}"
        "{metric} [på] {device} mindre än {below}"
        "{device} har {metric} över {above}"
        "{device} har {metric} under {below}"
        "{device} har {metric} mer än {above}"
        "{device} har {metric} mindre än {below}"
        "{device} har mer {metric} än {above}"
        "{device} har mindre {metric} än {below}"
        "är {device} {metric} över {above}"
        "är {device} {metric} under {below}"
        "är {metric} [på] {device} över {above}"
        "är {metric} [på] {device} under {below}"
        "har {device} {metric} över {above}"
        "har {device} {metric} under {below}"
        "har {device} mer {metric} än {above}"
        "har {device} mindre {metric} än {below}"
      ];
      lists = {
        device.values = swe.devices;
        scope.values  = [
          { "in" = "någon|nån|något|nått|några"; out = "any";  }
          { "in" = "alla|allt|all";              out = "all";  }
          { "in" = "ingen|inget|inga";           out = "none"; }
        ];
        metric.values = swe.metrics;
        above.values  = swe.numberFromZeroTo 200
                     ++ map (n: { "in" = toString n; out = toString n; })
                            [ 300 400 500 750 1000 1500 2000 3000 ];
        below.values  = swe.numberFromZeroTo 200
                     ++ map (n: { "in" = toString n; out = toString n; })
                            [ 300 400 500 750 1000 1500 2000 3000 ];
      };
    };

  };}
