# dotfiles/bin/productivity/calc.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ self, config, pkgs, cmdHelpers, ... }:
{
  yo = {
    scripts = {
      calendar = {
        description = "Calendar assistant";
        category = "⚡ Productivity";
        aliases = [ "kal" ];
        helpFooter = ''
          ${cmdHelpers}
          echo "## ──────⋆⋅☆⋅⋆────── ##"
          ${cmdHelpers}
          echo "## ──────⋆⋅☆⋅⋆────── ##"
          echo "## Calendar Assistant"
          echo "## ──────⋆⋅☆⋅⋆────── ##"
          echo "Usage:"
          echo "  kal add <event> [--date YYYY-MM-DD]"
          echo "  kal remove <id>"
          echo "  kal list [--today|--upcoming]"
          echo "  kal check <id>"
          echo ""
          echo "Examples:"
          echo "  kal add 'Team meeting' --date 2023-12-15"
          echo "  kal list --today"
          echo "  kal remove 3"
          echo "## ──────⋆⋅☆⋅⋆────── ##"        
        '';
        parameters = [{ name = "operation"; description = "Operational action. Can be add, remove, list."; optional = false; }];
        code = ''
          ${cmdHelpers}
          operation="$1"
          shift

          case "$operation" in
            add)
              item=""
              date=""
              while [[ $# -gt 0 ]]; do
                case "$1" in
                  --date)
                    date="$2"
                    shift 2
                    ;;
                  *)
                    item+="$1 "
                    shift
                    ;;
                esac
              done
              # Remove trailing space
              item="''${item%% }"
              
              if [[ -z "$item" ]]; then
                dt_error "Error: Missing event description"
                exit 1
              fi

              # Use today's date if none provided
              : "''${date:=$(date +%Y-%m-%d)}"
              
              # Generate unique ID
              id=$(${pkgs.coreutils}/bin/shuf -i 1000-9999 -n 1)
              
              ${pkgs.jq}/bin/jq \
                --arg id "$id" \
                --arg item "$item" \
                --arg date "$date" \
                '. + [{"id": $id, "event": $item, "date": $date}]' \
                "$dbPath" > tmp.json && mv tmp.json "$dbPath"
              
              echo "Added [$id] $item on $date"
              ;;
            
            remove)
              id="$1"
              ${pkgs.jq}/bin/jq "map(select(.id != \"$id\"))" "$dbPath" > tmp.json && mv tmp.json "$dbPath"
              echo "Removed event $id"
              ;;
            
            list)
              filter=""
              while [[ $# -gt 0 ]]; do
                case "$1" in
                  --today)
                    today=$(date +%Y-%m-%d)
                    filter="| map(select(.date == \"$today\"))"
                    shift
                    ;;
                  --upcoming)
                    filter="| map(select(.date >= \"$(date +%Y-%m-%d)\"))"
                    shift
                    ;;
                  *)
                    shift
                    ;;
                esac
              done
              
              ${pkgs.jq}/bin/jq -r "sort_by(.date) $filter | .[] | \"\(.id)\t\(.date)\t\(.event)\"" "$dbPath" \
                | ${pkgs.coreutils}/bin/column -t -s$'\t'
              ;;
            
            check)
              id="$1"
              ${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$id\") | \"[\(.id)] \(.date): \(.event)\"" "$dbPath"
              ;;
            
            *)
              echo "Invalid operation: $operation"
              exit 1
              ;;
          esac
        '';
      };
    };
    
    # 🦆 duck say ⮞ defined intents for calculations from voice commands 
    bitch = {
      intents = {
        calendar = {
          data = [{
            sentences = [
              "påminn mig om [att] {item}" 
              "kan du påminna mig om [att] {item}"
              # Viewing
              "vad händer [i dag|imorgon|nästa vecka]"
              "påminn mig om [att] {item}" 
              "kan du påminna mig om [att] {item}"
              "lägg till {item} [i kalendern]"
              "lista kalenderhändelser"
              "ta bort påminnelse {id}"
            ];
            lists.item.wildcard = true;
            lists.id.wildcard = true;
          }];  
        };  
      };
    };  
  };}
