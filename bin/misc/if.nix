# dotfiles/bin/misc/if.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 duck say ⮞
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let


in {
  yo.scripts."if" = {
    description = "Run a command when a condition holds. Condition is any natural-language query that returns true/false.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "condition"; description = "Query that returns true/false"; optional = false; }
      { name = "then";      description = "Command to run when condition is true"; optional = false; }
      { name = "efter";     description = "Continuation after 'then'"; optional = true; }
      { name = "plus";     description = "Continuation after 'efter'"; optional = true; }
      { name = "annars";    description = "Command to run when condition is false"; optional = true; }
      #{ name = "reverse";    description = "Reverse the result"; type = "bool"; optional = true; }

    ];

    code = ''
      COND="$condition"
      THEN_CMD="$then"
      EFTER_CMD="$efter"
      PLUS_CMD="$plus"
      ELSE_CMD="$annars"

      [ -z "$COND" ]     && exit 1
      [ -z "$THEN_CMD" ] && exit 1

      if ! RESULT=$(yo do "$COND" 2>/dev/null); then
        echo "[if] condition '$COND' failed" >&2
        exit 1
      fi

      RESULT_BOOL=$(printf '%s\n' "$RESULT" \
        | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
        | grep -iE '^(true|false)$' \
        | tail -n1 \
        | tr '[:upper:]' '[:lower:]')

      if [ -z "$RESULT_BOOL" ]; then
        LAST_RAW=$(printf '%s\n' "$RESULT" | tail -n1 | tr -d '[:space:]')
        echo "[if] condition '$COND' returned no boolean (last line: '$LAST_RAW')" >&2
        exit 1
      fi

      STATE="$RESULT_BOOL"

      if [ "$STATE" = "true" ]; then
        yo do "$THEN_CMD"
        if [ -n "$EFTER_CMD" ]; then yo do "$EFTER_CMD"; fi
        if [ -n "$PLUS_CMD" ];  then yo do "$PLUS_CMD";  fi
      elif [ -n "$ELSE_CMD" ]; then
        yo do "$ELSE_CMD"
      fi

      exit 0
    '';
    voice = {
      priority = 2;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;

      sentences = [
        "om {condition} så {then} och {efter} plus {plus}"
        "om {condition} isåfall {then} och {efter} plus {plus}"
        "om {condition} så {then} och {efter}"
        "om {condition} isåfall {then} och {efter}"
        "om {condition} [så] {then}"
        "om {condition} isåfall {then}"
        "om {condition} gör {then}"
        "om {condition} så {then} annars {annars}"
        "kolla om {condition} isåfall {then}"
        "(varna|larma) mig om {condition} så {then} annars {annars}"
        "(varna|larma) mig om {condition} så {then}"
      ];

      lists = {
        condition.wildcard = true;
        "then".wildcard    = true;
        efter.wildcard     = true;
        plus.wildcard      = true;
        annars.wildcard    = true;
      };
    };

  };}
