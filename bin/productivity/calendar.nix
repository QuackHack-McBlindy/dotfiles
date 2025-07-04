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
        code = let 
          dbPath = "\${XDG_DATA_HOME:-$HOME/.local/share}/kalendar/events.json";
        in ''
          ${cmdHelpers}
          operation="$1"
          shift

          # Initialize database if missing
          mkdir -p "$(dirname "${dbPath}")"
          if [ ! -f "${dbPath}" ]; then
            echo "[]" > "${dbPath}"
          fi

          case "$operation" in
            add)
              item=""
              date=""
              while [[ $# -gt 0 ]]; do
                case "$1" in
                  --date)
                    if [ -z "$2" ]; then
                      dt_error "Error: --date requires value"
                      exit 1
                    fi
                    date="$2"
                    shift 2
                    ;;
                  *)
                    item+="$1 "
                    shift
                    ;;
                esac
              done
              item="''${item%% }"
              
              if [[ -z "$item" ]]; then
                dt_error "Error: Missing event description"
                exit 1
              fi

              : "''${date:=$(date +%Y-%m-%d)}"
              id=$(${pkgs.coreutils}/bin/shuf -i 1000-9999 -n 1)
              
              ${pkgs.jq}/bin/jq \
                --arg id "$id" \
                --arg item "$item" \
                --arg date "$date" \
                '. + [{"id": $id, "event": $item, "date": $date}]' \
                "${dbPath}" > tmp.json && mv tmp.json "${dbPath}"
              
              echo "Added [$id] $item on $date"
              ;;
            
            remove)
              if [ -z "$1" ]; then
                dt_error "Error: Missing event ID"
                exit 1
              fi
              if ! ${pkgs.jq}/bin/jq -e ".[] | select(.id == \"$1\")" "${dbPath}" >/dev/null; then
                dt_error "Error: Event $1 not found"
                exit 1
              fi
              ${pkgs.jq}/bin/jq "map(select(.id != \"$1\"))" "${dbPath}" > tmp.json && mv tmp.json "${dbPath}"
              echo "Removed event $1"
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
              
              result=$(${pkgs.jq}/bin/jq -r "sort_by(.date) $filter | .[] | \"\(.id)\t\(.date)\t\(.event)\"" "${dbPath}")
              if [ -n "$result" ]; then
                echo "$result" | ${pkgs.coreutils}/bin/column -t -s$'\t'
              else
                echo "No events found"
              fi
              ;;
            
            check)
              if [ -z "$1" ]; then
                dt_error "Error: Missing event ID"
                exit 1
              fi
              if ! ${pkgs.jq}/bin/jq -e ".[] | select(.id == \"$1\")" "${dbPath}" >/dev/null; then
                dt_error "Error: Event $1 not found"
                exit 1
              fi
              ${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$1\") | \"[\(.id)] \(.date): \(.event)\"" "${dbPath}"
              ;;
            
            *)
              dt_error "Invalid operation: $operation"
              exit 1
              ;;
          esac
        '';
      };
    };
    
    bitch = {
      intents = {
        calendar = {
          data = [{
            sentences = [
              "påminn mig om [att] {item}" 
              "kan du påminna mig om [att] {item}"
              "vad händer [i dag|imorgon|nästa vecka]"
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
  };
}
