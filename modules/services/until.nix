# dotfiles/bin/home/until.nix
{ self, lib, config, pkgs, ... }: {
  yo.scripts.until = {
    description = "Repeat a command until a condition becomes true.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "condition"; description = "Query returning true/false"; }
      { name = "body";      description = "Command to repeat until condition is true"; }
      { name = "every";     description = "Seconds between iterations"; default = "5"; }
    ];

    code = ''
      COND="''${condition:-}"
      BODY="''${body:-}"
      EVERY="''${every:-5}"

      if [ -z "$COND" ] || [ -z "$BODY" ]; then
        echo "❌ yo until requires --condition and --body" >&2
        exit 1
      fi

      COND="''${COND#kolla om }"
      COND="''${COND#kontrollera om }"
      QUERY="kolla om $COND"

      until [ "$(yo do "$QUERY" 2>/dev/null | tail -1 | tr -d '[:space:]')" = "true" ]; do
        yo do "$BODY"
        sleep "$EVERY"
      done
    '';

    voice = {
      priority = 2;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;

      sentences = [
        "tills {condition} gör {body}"
        "loopa tills {condition} gör {body}"
        "upprepa {body} tills {condition}"
        "tills {condition} gör {body} var {every} sekund"
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
