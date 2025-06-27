# dotfiles/bin/misc/shopping.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {
  yo.bitch = {
    intents = {
      shopping_add = {
        data = [{
          sentences = [
            "lägg till {item} i inköpslistan"
            "lägg {item} till inköpslistan"
            "lägg till {item} på listan"
            "lägg till {item}"
            "sätt {item} på inköpslistan"
          ];
          lists = {
            item.wildcard = true;
          };
        }];
      };

      shopping_remove = {
        data = [{
          sentences = [
            "ta bort {item} från inköpslistan"
            "ta bort {item} från listan"
            "ta bort {item}"
            "radera {item} från listan"
          ];
          lists = {
            item.wildcard = true;
          };
        }];
      };

      shopping_view = {
        data = [{
          sentences = [
            "visa inköpslistan"
            "vad finns på inköpslistan"
            "visa listan"
            "vad är på listan"
          ];
        }];
      };
    };
  };

  yo.scripts.shopping_add = {
    description = "Lägg till en vara i inköpslistan";
    category = "🛒 Shopping";
    parameters = [
      { name = "item"; description = "Varan som ska läggas till"; }
    ];
    code = ''
      ${cmdHelpers}
      LIST_FILE="$HOME/.shopping_list.txt"
      echo "$item" >> "$LIST_FILE"
      echo "Lade till '$item' i inköpslistan."
    '';
  };

  yo.scripts.shopping_remove = {
    description = "Ta bort en vara från inköpslistan";
    category = "🛒 Shopping";
    parameters = [
      { name = "item"; description = "Varan som ska tas bort"; }
    ];
    code = ''
      ${cmdHelpers}
      LIST_FILE="$HOME/.shopping_list.txt"
      grep -v -i "^$item\$" "$LIST_FILE" > "$LIST_FILE.tmp" && mv "$LIST_FILE.tmp" "$LIST_FILE"
      echo "Tog bort '$item' från inköpslistan."
    '';
  };

  yo.scripts.shopping_view = {
    description = "Visa inköpslistan";
    category = "🛒 Shopping";
    parameters = [ ];
    code = ''
      ${cmdHelpers}
      LIST_FILE="$HOME/.shopping_list.txt"
      if [ -f "$LIST_FILE" ]; then
        echo "Inköpslistan:"
        cat "$LIST_FILE"
      else
        echo "Inköpslistan är tom."
      fi
    '';
    
  };}
