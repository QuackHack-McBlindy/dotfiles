# dotfiles/bin/misc/chain.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{
  config,
  lib,
  pkgs,
  cmdHelpers,
  swe,
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
      { name = "c"; description = "Optional third command"; type = "string"; optional = true; }
      { name = "d"; description = "Optional fourth command"; type = "string"; optional = true; }
    ];
    code = ''
      for part in "''${a:-}" "''${b:-}" "''${c:-}" "''${d:-}"; do
        [ -n "$part" ] && yo do "$part"
      done
    '';
    voice = {
      priority = 5;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;
      sentences = [
        "{a} samt {b} samt {c} samt {d}"
        "{a} samt {b} samt {c}"
        "{a} samt {b}"
      ];
      lists = {
        a.wildcard = true;
        b.wildcard = true;
        c.wildcard = true;
        d.wildcard = true;
      };
    };

  };}
