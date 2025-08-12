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
            "{operation} till {item} i inköpslistan"
            "{operation} {item} till inköpslistan"
            "{operation} till {item} på listan"
            "{operation} till {item}"
            "{operation} {item} på inköpslistan"

            "{operation} [bort] {item} från inköpslistan"
            "{operation} [bort] {item} från listan"
            "{operation} bort {item}"
            "{operation} {item} från listan"
            
            "visa inköpslistan"
            "vad finns på inköpslistan"
            "visa listan"
            "vad är på listan"
          ];
          lists = {
            operation.values = [
              { "in" = "[lägg]"; out = "add"; }
              { "in" = "[ta|ta bort|radera]"; out = "remove"; }  
              { "in" = "[visa]"; out = "view"; }      
            ];
            item.wildcard = true;
          };
        }];
      };
    };
  };  

  yo.scripts.shopping_list = {
    description = "Shopping list management";
    category = "🧩 Miscellaneous";
    parameters = [
      { name = "operation"; description = "add, remove, or view"; default = "view"; }
      { name = "item"; description = "Item that will be managed"; }
    ];
    code = ''
      ${cmdHelpers}
      LIST_FILE="$HOME/.shopping_list.txt"
      
      case "$operation" in
        add)
          echo "$item" >> "$LIST_FILE"
          echo "Lade till '$item' i inköpslistan."
          ;;
        remove)
          grep -v -i -- "^$item\$" "$LIST_FILE" > "$LIST_FILE.tmp"
          mv "$LIST_FILE.tmp" "$LIST_FILE"
          echo "Tog bort '$item' från inköpslistan."
          ;;
        view)
          if [[ -f "$LIST_FILE" ]]; then
            echo "Inköpslistan:"
            cat "$LIST_FILE"
          else
            echo "Inköpslistan är tom."
          fi
          ;;
        *)
          echo "Ogiltig operation: '$operation'. Använd add, remove, eller view."
          exit 1
          ;;
      esac
    '';
  };}
