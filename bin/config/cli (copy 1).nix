# dotfiles/bin/config/cli.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {
    yo.scripts = {
      edit = {
        description = "yo CLI configuration mode";
        category = "⚙️ Configuration";
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
                "Edit yo CLI scripts") exit 0 ;;  
                "🚫 Exit") exit 0 ;;
              esac
            done
          }

          edit_menu
        '';
      };
      
    };}
