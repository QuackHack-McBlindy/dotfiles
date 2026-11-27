# dotfiles/bin/misc/sed.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ extract voice
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  zigduck,
  ...
}: {
  yo.scripts.extract = {
    description = "Extract the value between two segments in MQTT_TOPIC and overwrite it.";
    category = "🧩 Miscellaneous";
    parameters = [
      {
        name = "x";
        description = "Starting segment";
        default = "duckTrace";
        optional = false;
      }
      {
        name = "y";
        description = "Ending segment";
        default = "error";
        optional = false;
      }
      {
        name = "variable";
        description = "Variable to extract and overwrite from";
        default = "MQTT_TOPIC";
        optional = false;
      }
    ];
    code = ''
      VARIABLE="$variable"
      BASE_TOPIC="${zigduck.baseTopic}/"

      FIRST="''${BASE_TOPIC}''${x}/"
      SECOND="/''${y}"

      VALUE="''${!VARIABLE}"

      if [[ "$VALUE" != *"$FIRST"* ]]; then
        echo "ERROR: Prefix not found: $FIRST" >&2
        exit 1
      fi

      VALUE="''${VALUE#*"$FIRST"}"

      if [[ "$VALUE" != *"$SECOND"* ]]; then
        echo "ERROR: Suffix not found: $SECOND" >&2
        exit 1
      fi

      VALUE="''${VALUE%%"$SECOND"*}"

      printf -v "$VARIABLE" '%s' "$VALUE"
      export "$VARIABLE"

      echo "Extracted $VARIABLE=$VALUE"
    '';

    voice = {
      enabled = true;
      priority = 5;
      sentences = [
        "(plocka|extrakt|extract|extrahera) [ut] värdet mellan {x} och {y} i [mqtt|mosquitto|mygga] (mqtt-ämnet|mqtt-topic|topic|ämnet) och spara variabeln"
        "(plocka|extrakt|extract|extrahera) [ut] värdet mellan {x} och {y} (från|i) variabeln {variable}"
      ];
      lists = {
        x.wildcard        = true;
        y.wildcard        = true;
        variable.wildcard = true;
      };
    };

  };}
