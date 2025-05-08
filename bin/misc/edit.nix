# dotfiles/bin/misc/edit.nix
{ self, config, pkgs, cmdHelpers, ... }:
{
    yo.scripts = {
      edit = {
        description = "yo CLI configuration mode";
        aliases = [ "config" ];
        code = ''
          ${cmdHelpers}
        
          export GUM_CHOOSE_CURSOR="🦆 ➤ "  
          export GUM_CHOOSE_CURSOR_FOREGROUND="214" 
          export GUM_CHOOSE_HEADER="❄️ yo CLI Tool" 

          validate_ssh_key() {
            ${pkgs.openssh}/bin/ssh-keygen -l -f /dev/stdin <<< "$1" &>/dev/null
          }

          validate_ip() {
            echo "$1" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$'
          }

                                                                                
          validate_host() {
            if [[ ! " $sysHosts " =~ " $1 " ]]; then
              echo -e "\033[1;31m❌ Unknown host: $1\033[0m" >&2
              echo "Available hosts: $sysHosts" >&2
              exit 1
            fi
          }
          
          
          edit_host() {
            selected_host=$(nix flake show "${config.this.user.me.dotfilesDir}" --json 2>/dev/null | jq -r '.nixosConfigurations | keys[]' | ${pkgs.gum}/bin/gum choose --header "Select host:")
            [ -n "$selected_host" ] && $EDITOR "${config.this.user.me.dotfilesDir}/hosts/$selected_host/default.nix"
          }

  
          edit_yo_scripts() {
            DOTFILES_DIR="${config.this.user.me.dotfilesDir}"
            current_dir="$DOTFILES_DIR/bin"
  
            while true; do
              options=()
              # Add parent directory option if not in root
              if [ "$current_dir" != "$DOTFILES_DIR/bin" ]; then
                options+=("../")
              fi
  
              # Collect directory contents
              while IFS= read -r entry; do
                if [ -d "$current_dir/$entry" ]; then
                  options+=("$entry/")
                else
                  options+=("$entry")
                fi
              done < <(ls -1p "$current_dir" | grep -v '^\.')
  
              # Show selection interface
              selected=$(printf "%s\n" "󰌑 Back to main menu" "󰅚 Open current directory" "󰆴 Create new file" "󰆴 Create new directory" "󰗼 Quit" "─────────" "󰉋 Files/Directories:" "''${options[@]}" | 
                ${pkgs.gum}/bin/gum filter --header "📂 $current_dir" --placeholder "Browse yo scripts..." --indicator "➤")
  
              case "$selected" in
                "󰌑 Back to main menu")
                  return
                  ;;
                "󰅚 Open current directory")
                  xdg-open "$current_dir" >/dev/null 2>&1
                  ;;
                "󰆴 Create new file")
                  new_file=$(${pkgs.gum}/bin/gum input --placeholder "File name")
                  [ -n "$new_file" ] && touch "$current_dir/$new_file"
                  ;;
                "󰆴 Create new directory")
                  new_dir=$(${pkgs.gum}/bin/gum input --placeholder "Directory name")
                  [ -n "$new_dir" ] && mkdir -p "$current_dir/$new_dir"
                  ;;
                "󰗼 Quit")
                  exit 0
                  ;;
                "─────────"|"󰉋 Files/Directories:")
                  continue
                  ;;
                *)
                  if [[ "$selected" == */ ]]; then
                    current_dir="$current_dir/''${selected%/}"
                  elif [ -n "$selected" ]; then
                    [ -z "$EDITOR" ] && EDITOR="vim"
                    "$EDITOR" "$current_dir/$selected"
                    return
                  fi
                  ;;
              esac
            done
          }
  

          edit_menu() {
            while true; do
              selection=$(${pkgs.gum}/bin/gum choose \
                "Edit hosts" \
                "Edit flake" \
                "Edit yo CLI scripts" \
                "🚫 Exit")
             case "$selection" in
                "Edit hosts") edit_host ;;
                "Edit flake") $EDITOR "${config.this.user.me.dotfilesDir}/flake.nix" ;;
                "Edit yo CLI scripts") edit_yo_scripts ;;  
                "🚫 Exit") exit 0 ;;
              esac
            done
          }

          edit_menu
        '';
      };
    };}
