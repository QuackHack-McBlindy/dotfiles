# dotfiles/bin/home/mqtt2history.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{
  self,
  lib,
  config,
  pkgs,
  swe,
  zigduck,
  ...
} : {
  yo.scripts.mqtt2history = {
    description = "Save an MQTT payload field into a JSON history file for the frontend.";
    category    = "🛖 Home Automation";
    autoStart   = false;
    logLevel    = "WARNING";

    parameters = [
      { name = "field"; description = "JSON field to store"; optional = false; }
      { name = "file";  description = "Target json filename"; optional = false; }
    ];

    code = ''
      FILE="${zigduck.stateDir}/''${file}"
      mkdir -p "$(dirname "$FILE")"

      VALUE=$(printf '%s' "''${MQTT_PAYLOAD:-}" | jq --arg k "''${field}" '.[$k] // empty' 2>/dev/null)
      if [ -z "$VALUE" ]; then
        echo "no '`''${field}`' in MQTT_PAYLOAD" >&2
        exit 1
      fi

      if [ -s "$FILE" ]; then
        CURRENT=$(jq --arg k "''${field}" '.[$k]' "$FILE" 2>/dev/null)
        [ "$CURRENT" = "$VALUE" ] && exit 0
      fi

      if [ ! -s "$FILE" ]; then
        jq -n --arg k "''${field}" --argjson v "$VALUE" \
          '{ ($k): $v, history: [$v] }' > "$FILE"
      else
        jq --arg k "''${field}" --argjson v "$VALUE" '
          .[$k] = $v
          | .history += [$v]
          | .history = (.history[-200:])
        ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
      fi
    '';

    voice = {
      priority         = 5;
      fuzzy.enable     = true;
      fuzzy.threshold  = 0.9;
      sentences        = [ "spara {field} i {file}" ];
      lists = {
        file.wildcard  = true;
        field.wildcard = true;
      };
    };

  };}
