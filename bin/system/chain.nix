{ self, lib, config, pkgs, ... }: {
  yo.scripts.chain = {
    description = "Chain commands with 'samt'. Splits and dispatches each part sequentially.";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "a"; description = "First command"; }
      { name = "b"; description = "Second command"; }
    ];

    code = ''
      A="''${a:-}"
      B="''${b:-}"

      if [ -z "$A" ] || [ -z "$B" ]; then
        echo "❌ chain requires two non-empty parts (got a='$A' b='$B')" >&2
        exit 1
      fi

      yo do "$A"
      yo do "$B"
    '';

    voice = {
      priority = 5;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;

      sentences = [
        "{a} samt {b}"
      ];

      lists = {
        a = { wildcard = true; values = []; };
        b = { wildcard = true; values = []; };
      };
    };
  };
}
