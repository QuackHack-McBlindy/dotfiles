# dotfiles/bin/misc/chain.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
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
   yo.scripts.chain = {
    description = "Chain commands with 'samt'. Splits and dispatches each part sequentially.";
    category = "🧩 Miscellaneous";
    autoStart = false;
    logLevel = "WARNING";
    parameters = [
      { name = "a"; description = "First command"; type = "string"; optional = false; }
      { name = "b"; description = "Second command"; type = "string"; optional = false; }
    ];
    code = ''
      A="''${a:-}"
      B="''${b:-}"

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
        a = { wildcard = true; };
        b = { wildcard = true; };
      };
    };

  };}
