# dotfiles/bin/misc/while.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{
  config,
  lib,
  pkgs,
  cmdHelpers,
  sweSpeech,
  ...
} : let

in {
  yo.scripts.while = {
    description = "Repeat a command while a condition holds.";
    category = "🧩 Miscellaneous";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "condition"; description = "Query returning true/false"; optional = false; }
      { name = "body";      description = "Command to repeat while condition is true"; optional = false; }
      { name = "every";       description = "Seconds between iterations";     default = "5"; }
      { name = "max_minutes"; description = "Hard ceiling on loop duration";  default = "30"; }
    ];

    code = ''
      COND="''${condition:-}"
      BODY="''${body:-}"
      EVERY="''${every:-5}"
      MAX="''${max_minutes:-30}"

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
        [ "$RESULT" = "true" ] || break

        timeout 10 yo do "$BODY" 2>/dev/null || true
        sleep "$EVERY"
      done
    '';

    voice = {
      priority = 2;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;

      sentences = [
        "(medan|medans) {condition} (så|gör) {body}"
        "loopa (medan|medans) {condition} (så|gör) {body}"
        "upprepa {body} (medan|medans) {condition}"
        "(medan|medans) {condition} (så|gör) {body} var {every} sekund"
        "(medan|medans) {condition} (så|gör) {body} max {max_minutes} minuter"
      ];

      lists = {
        condition   = sweSpeech.wildcard;
        body        = sweSpeech.wildcard;
        every.values = sweSpeech.everyValues;
        max_minutes.values = sweSpeech.everyValues;   # reuse: 1, 5, 10, 15, 30, 60 min ceiling
      };
    };

  };}
