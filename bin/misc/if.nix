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
    description = "Run a command when a condition holds. Condition is any natural-language query that returns true/false (e.g. 'kolla om ytterdörren är öppen').";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "condition"; description = "Query that returns true/false"; optional = false; }
      { name = "then";      description = "Command to run when condition is true"; optional = false; }
      { name = "annars";    description = "Command to run when condition is false"; optional = true; }
    ];

    code = ''
      COND="''${condition:-}"
      THEN_CMD="''${then:-}"
      ELSE_CMD="''${annars:-}"

      COND="''${COND#kolla om }"
      COND="''${COND#kontrollera om }"

      QUERY="kolla om $COND"
      RESULT=$(yo do "$QUERY" 2>/dev/null | tail -1 | tr -d '[:space:]')

      case "$RESULT" in
        true|false) ;;
        *) RESULT=$(yo do "$COND" 2>/dev/null | tail -1 | tr -d '[:space:]') ;;
      esac

      case "$RESULT" in
        true|True|TRUE)  STATE=true ;;
        *)               STATE=false ;;
      esac

      if [ "$STATE" = "true" ]; then
        yo do "$THEN_CMD"
      elif [ -n "$ELSE_CMD" ]; then
        yo do "$ELSE_CMD"
      fi
    '';
    voice = {
      priority = 2;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;

      sentences = [
        "om {condition} så {then}"
        "om {condition} isåfall {then}"
        "om {condition} gör {then}"
        "om {condition} så {then} annars {annars}"
        "kolla om {condition} isåfall {then}"
      ];

      lists = {
        condition = { wildcard = true; values = []; };
        "then"    = { wildcard = true; values = []; };
        annars    = { wildcard = true; values = []; };
      };
    };

  };}
