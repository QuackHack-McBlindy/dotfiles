# dotfiles/bin/media/tv-scrape.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 duck say ⮞ scrape TV-guide and save EPG/HTML/XML for frontend
  config,
  lib,
  swe,
  pkgs,
  zigduck,
  ...
} : let
  defaultDir = zigduck.stateDir;
in {
  yo.scripts.tv-scrape = {
    description = "Scrape the web for TV-guide data and save data for frontend.";
    category    = "🎧 Media Management";
    autoStart   = false;
    logLevel    = "WARNING";

    parameters = [
      { name = "dir"; description = "Output directory (defaults to zigduck state dir)"; optional = true;
          default = defaultDir; }
      { name = "wildcard"; description = "Nothing to see here...."; type = "string"; optional = true; }
    ];
    code = ''
      OUT="$dir"
      mkdir -p "$OUT"

      tv-scraper \
        --json-out "$OUT/epg.json" \
        --html-out "$OUT/tv.html" \
        --xml-out  "$OUT/epg.xml"
    '';

    voice = {
      priority        = 3;
      fuzzy.enable    = true;
      fuzzy.threshold = 0.5;
      sentences = [
        "skrapa webben efter tv guiden och spara [den] i {wildcard}"
      ];
      lists.dir.wildcard = true;
      lists.wildcard.wildcard = true;

    };

  };}
