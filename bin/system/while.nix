
{ self, lib, config, pkgs, ... }: {
  yo.scripts.while = {
    description = "Repeat a command while a condition holds.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "condition"; description = "Query returning true/false"; }
      { name = "body";      description = "Command to repeat while condition is true"; }
      { name = "every";     description = "Seconds between iterations"; default = "5"; }
    ];

    code = ''
      COND="''${condition:-}"
      BODY="''${body:-}"
      EVERY="''${every:-5}"

      if [ -z "$COND" ] || [ -z "$BODY" ]; then
        echo "❌ yo while requires --condition and --body" >&2
        exit 1
      fi

      COND="''${COND#kolla om }"
      COND="''${COND#kontrollera om }"
      QUERY="kolla om $COND"

      while [ "$(yo do "$QUERY" 2>/dev/null | tail -1 | tr -d '[:space:]')" = "true" ]; do
        yo do "$BODY"
        sleep "$EVERY"
      done
    '';

    voice = {
      priority = 2;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;

      sentences = [
        "medan {condition} gör {body}"
        "loopa medan {condition} gör {body}"
        "upprepa {body} medan {condition}"
        "medan {condition} gör {body} var {every} sekund"
      ];

      lists = {
        condition = { wildcard = true; values = []; };
        body      = { wildcard = true; values = []; };
        every.values = [
          { "in" = "1|en";      out = "1"; }
          { "in" = "5|fem";     out = "5"; }
          { "in" = "10|tio";    out = "10"; }
          { "in" = "15|femton"; out = "15"; }
          { "in" = "30|trettio"; out = "30"; }
          { "in" = "60|sextio"; out = "60"; }
        ];
      };
    };
  };
}
