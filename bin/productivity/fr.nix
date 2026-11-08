# dotfiles/bin/productivity/fr.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  self,
  lib,
  config,
  pkgs,
  swe,
  ...
} : let

in {
  yo.scripts.fr = {
    description = "find and replace in .nix files and subdirs";
    category = "⚡ Productivity";
    logLevel = "WARNING";
    parameters = [
      { name = "find"; type = "string"; description = "Word to find."; optional = false; }
      { name = "replace"; type = "string"; description = "Word to replace."; optional = false; }
    ];
    code = ''
      set -euo pipefail

      [[ $# -eq 2 ]] || { echo "usage: $0 <find> <replace>"; exit 1; }
      python3 - "$find" "$replace" <<'PY'
      import pathlib
      import sys
      old, new = sys.argv[1:3]
      for file in pathlib.Path(".").rglob("*.nix"):
          content = file.read_text()
          updated = content.replace(old, new)
          if updated != content:
              file.write_text(updated)
              print(f"{file}")
      PY
    '';
    voice  = {
      priority        = 2;
      fuzzy.enable    = true;
      fuzzy.threshold = 0.5;
      sentences       = [ "ersätt {find} med {replace}" ];
      lists.find.wildcard    = true;
      lists.replace.wildcard = true;
    };

  };}
