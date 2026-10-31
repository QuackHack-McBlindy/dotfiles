# dotfiles/bin/home/power.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
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

  yo.scripts.power = {
    description = "Check whether a device's power is above or below a threshold. Returns true/false.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "device"; description = "Device to check"; values = sweSpeech.deviceValuesFlat; }
      { name = "above";  description = "Return true if power > this many watts"; optional = true; }
      { name = "below";  description = "Return true if power < this many watts"; optional = true; }
    ];
    code = ''
      ${sweSpeech.mkBashMap "DEVICE_LOOKUP" sweSpeech.devicePatternMap}

      D="''${device:-}"
      [ -z "$D" ] && { echo "false"; echo "❌ --device krävs" >&2; exit 1; }

      D_LOWER=$(printf '%s' "$D" | tr '[:upper:]' '[:lower:]')
      RESOLVED="''${DEVICE_LOOKUP[$D_LOWER]:-}"
      [ -z "$RESOLVED" ] && RESOLVED="$D"

      STATE_JSON=$(zigduck-cli --state-json 2>/dev/null)
      if [ -z "$STATE_JSON" ]; then
        echo "false"; echo "❌ zigduck-cli svarar inte" >&2; exit 1
      fi

      EXISTS=$(printf '%s' "$STATE_JSON" | jq -r --arg d "$RESOLVED" '.[$d] != null')
      if [ "$EXISTS" != "true" ]; then
        echo "false"; echo "❌ Okänd enhet: '$D' (resolved '$RESOLVED')" >&2
        printf '%s' "$STATE_JSON" | jq -r 'keys[]' | head -40 >&2
        exit 1
      fi

      POWER=$(printf '%s' "$STATE_JSON" | jq -r --arg d "$RESOLVED" '.[$d].power // "0"' 2>/dev/null)
      [[ "$POWER" =~ ^[0-9.]+$ ]] || POWER=0

      if [ -n "''${above:-}" ] && [ -n "''${below:-}" ]; then
        echo "false"; echo "❌ ange --above ELLER --below, inte båda" >&2; exit 1
      fi
      if [ -z "''${above:-}" ] && [ -z "''${below:-}" ]; then
        echo "false"; echo "❌ --above eller --below krävs" >&2; exit 1
      fi

      RESULT=false
      if [ -n "''${above:-}" ]; then
        [ "$(awk -v p="$POWER" -v a="$above" 'BEGIN{print (p>a)?1:0}')" = "1" ] && RESULT=true
      else
        [ "$(awk -v p="$POWER" -v b="$below" 'BEGIN{print (p<b)?1:0}')" = "1" ] && RESULT=true
      fi
      echo "$RESULT"
    '';

    voice = {
      priority = 2;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;
      sentences = [
        "{device} (drar|använder|är) (mer|över) [än] {above} watt"
        "{device} (drar|använder|är) (mindre|under) [än] {below} watt"
      ];
      lists = {
        device.values = sweSpeech.deviceValues;
        above.values  = sweSpeech.numberValuesOneBased 100 ++ [
          { "in" = "150|hundrafemtio|etthundrafemtio"; out = "150"; }
          { "in" = "200|tvåhundra";                     out = "200"; }
          { "in" = "250|tvåhundrafemtio";               out = "250"; }
          { "in" = "300|trehundra";                     out = "300"; }
          { "in" = "400|fyrahundra";                    out = "400"; }
          { "in" = "500|femhundra";                     out = "500"; }
          { "in" = "750|sjuhundrafemtio";               out = "750"; }
          { "in" = "1000|ettusen|tusen";                out = "1000"; }
          { "in" = "1500|ettusenfemhundra";             out = "1500"; }
          { "in" = "2000|tvåtusen";                     out = "2000"; }
          { "in" = "3000|tretusen";                     out = "3000"; }
        ];
        below.values  = sweSpeech.numberValuesOneBased 100;
      };
    };

  };}
