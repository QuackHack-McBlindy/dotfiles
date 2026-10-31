# dotfiles/bin/misc/yo.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 duck say ⮞
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let


in {
  yo.scripts.yo = {
    description = "Say after me";
    category = "🧩 Miscellaneous";
    autoStart = false;
    logLevel = "WARNING";
    parameters = [
      { name = "phrase"; type = "string"; description = "phrase to say"; optional = false; }
    ];
    code = ''
      PHRASE=$phrase
      yo say --text "$PHRASE"
    '';
    voice = {
      priority = 2;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;

      sentences = [
        "säg {phrase}"
      ];

      lists = {
        phrase = { wildcard = true; };
      };
    };

  };}
