# dotfiles/bin/misc/until.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 duck say ⮞
  self,
  config,
  pkgs,
  cmdHelpers,
  sweSpeech,
  ...
} : let

in {
  yo.scripts.until = {
    description = "Repeat a command until a condition becomes true.";
    category = "🧩 Miscellaneous";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "condition"; description = "Query returning true/false"; }
      { name = "body";      description = "Command to repeat until condition is true"; }
      { name = "every";       description = "Seconds between iterations";    default = "5"; }
      { name = "max_minutes"; description = "Hard ceiling on loop duration"; default = "30"; }
    ];

    code = ''
      COND="''${condition:-}"
      BODY="''${body:-}"
      EVERY="''${every:-5}"
      MAX="''${max_minutes:-30}"

      [ -z "$COND" ] && { echo "❌ until requires --condition" >&2; exit 1; }
      [ -z "$BODY" ] && { echo "❌ until requires --body" >&2; exit 1; }

      COND="''${COND#kolla om }"
      COND="''${COND#kontrollera om }"
      QUERY="kolla om $COND"

      START=$(date +%s)
      LIMIT=$(( MAX * 60 ))

      while true; do
        [ $(( $(date +%s) - START )) -ge "$LIMIT" ] && break

        RESULT=$(yo do "$QUERY" 2>/dev/null | tail -1 | tr -d '[:space:]')
        case "$RESULT" in
          true|false) ;;
          *) RESULT=$(yo do "$COND" 2>/dev/null | tail -1 | tr -d '[:space:]') ;;
        esac
        [ "$RESULT" = "true" ] && break

        timeout 10 yo do "$BODY" 2>/dev/null || true
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
        "tills {condition} gör {body} max {max_minutes} minuter"
      ];

      lists = {
        condition = { wildcard = true; values = []; };
        body      = { wildcard = true; values = []; };
        every.values = [
          { "in" = "1|en";       out = "1"; }
          { "in" = "5|fem";      out = "5"; }
          { "in" = "10|tio";     out = "10"; }
          { "in" = "15|femton";  out = "15"; }
          { "in" = "30|trettio"; out = "30"; }
          { "in" = "60|sextio";  out = "60"; }
        ];
        max_minutes.values = [
          { "in" = "1|en";       out = "1"; }
          { "in" = "5|fem";      out = "5"; }
          { "in" = "10|tio";     out = "10"; }
          { "in" = "15|femton";  out = "15"; }
          { "in" = "30|trettio"; out = "30"; }
          { "in" = "60|sextio";  out = "60"; }
        ];
      };
    };

  };}
