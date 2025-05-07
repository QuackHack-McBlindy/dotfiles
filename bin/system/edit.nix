# bin/edit.nix
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


          new_host() {
           # Initial choice between installer and host config
            local action=$(${pkgs.gum}/bin/gum choose \
              --cursor="🦆 ➤ " \
              --header="Create a flash drive auto installer if you dont have NixOS on that machine:" \
              "Build USB auto installer" \
              "Add new host config")

            case "$action" in
              "Build USB auto installer")
                # Improved USB disk detection
                list_usb_disks() {
                  lsblk -d -o NAME,TRAN,SIZE | grep usb | awk '{print $1,$3}'
                }
  
                # Build ISO first
                selected_host=$(nix flake show "${config.this.user.me.dotfilesDir}" --json 2>/dev/null | 
                  jq -r '.nixosConfigurations | keys[]' | 
                  ${pkgs.gum}/bin/gum choose --header "Select host:")
  
                if [ -n "$selected_host" ]; then
                  if ! nix build ".#packages.x86_64-linux.\"auto-installer.$selected_host\""; then
                    ${pkgs.gum}/bin/gum style --foreground 196 "❌ Failed to build ISO for $selected_host"
                    return 1
                  fi
                fi
  
                # Select USB disk with proper filtering
                while :; do
                  echo "Available USB Disks:"
                  disk_list=$(list_usb_disks)
                  if [ -z "$disk_list" ]; then
                    ${pkgs.gum}/bin/gum style --foreground 196 "No USB disks detected!"
                    return 1
                  fi
  
                  selected_disk=$(echo -e "$disk_list\nExit" | 
                    ${pkgs.gum}/bin/gum choose --header="Choose USB disk:")
                  
                  [[ "$selected_disk" == "Exit" ]] && return 0
                  selected_disk=$(echo "$selected_disk" | cut -d' ' -f1)
                  break
                done
  
                # ISO selection with validation
                iso_path="./result/iso/"
                iso_list=$(find "$iso_path" -maxdepth 1 -name '*.iso' -exec basename {} \; | sort)
                if [ -z "$iso_list" ]; then
                  ${pkgs.gum}/bin/gum style --foreground 196 "No ISO files found in $iso_path"
                  return 1
                fi
  
                selected_iso=$(echo -e "$iso_list\nExit" | 
                  ${pkgs.gum}/bin/gum choose --header="Choose ISO file:")
                [[ "$selected_iso" == "Exit" ]] && return 0
  
                # Wiping and flashing with safety checks
                if ${pkgs.gum}/bin/gum confirm "ERASE ALL DATA on /dev/$selected_disk?"; then
                  sudo dd if=/dev/zero of=/dev/$selected_disk bs=1M status=progress
                  
                  if ${pkgs.gum}/bin/gum confirm "Reconnect USB and press Enter when ready"; then
                    echo "Detecting new device..."
                    sleep 2
                    sudo udevadm settle
                    
                    new_disk=$(list_usb_disks | cut -d' ' -f1)
                    if [ -z "$new_disk" ]; then
                      ${pkgs.gum}/bin/gum style --foreground 196 "Failed to detect reconnected USB!"
                      return 1
                    fi
  
                    echo "Flashing to /dev/$new_disk..."
                    sudo dd if="$iso_path/$selected_iso" of="/dev/$new_disk" bs=4M status=progress && {
                      ${pkgs.gum}/bin/gum style --foreground 82 "✅ Flash successful!"
                      sudo sync
                    }
                  fi
                fi
                ;;
  
              "Add new host config")
                ${pkgs.gum}/bin/gum style --foreground 212 "=== New Host Configuration ==="
      
                # Get hostname with validation
                local hostname=""
                while [[ -z "$hostname" ]]; do
                  hostname=$(${pkgs.gum}/bin/gum input --prompt "Hostname: " --placeholder "my-nixos")
                  [[ -z "$hostname" ]] && ${pkgs.gum}/bin/gum style --foreground 196 "Hostname cannot be empty!"
                done

                # Create host directory
                local host_dir="${config.this.user.me.dotfilesDir}/hosts/$hostname"
                mkdir -p "$host_dir"

                template_path="$PWD/home/Templates/new-host"

                # Generate configuration from template
                export HOSTNAME="$hostname"  # Make the variable available to envsubst
                envsubst < "$template_path" > "$host_dir/default.nix"

                # Success message
                ${pkgs.gum}/bin/gum style --foreground 82 "✅ Host configuration created from template:"
                echo "$host_dir/default.nix" | ${pkgs.gum}/bin/gum format -t code
                ;;
            esac
          }                                                                                     

          validate_host() {
            if [[ ! " $sysHosts " =~ " $1 " ]]; then
              echo -e "\033[1;31m❌ Unknown host: $1\033[0m" >&2
              echo "Available hosts: $sysHosts" >&2
              exit 1
            fi
          }
          
          remove_host() {
            local host_to_remove=$(nix flake show "${config.this.user.me.dotfilesDir}" --json 2>/dev/null | 
              jq -r '.nixosConfigurations | keys[]' | 
              ${pkgs.gum}/bin/gum choose --header "Select host to remove:")
            if [ -n "$host_to_remove" ]; then
              # First confirmation
              ${pkgs.gum}/bin/gum confirm "🚨 Permanently remove $host_to_remove?" || return 0  
              ${pkgs.gum}/bin/gum style --foreground 196 --bold "THIS WILL DELETE ALL CONFIGURATION FOR $host_to_remove!"
              ${pkgs.gum}/bin/gum style --foreground 214 "You have 10 seconds to cancel..."
              sleep 10
              ${pkgs.gum}/bin/gum confirm "⚠️  LAST CHANCE: Really remove $host_to_remove?" || return 0
              if rm -rf "${config.this.user.me.dotfilesDir}/hosts/$host_to_remove"; then
                ${pkgs.gum}/bin/gum style --foreground 82 "✅ Successfully removed $host_to_remove"
              else
                ${pkgs.gum}/bin/gum style --foreground 196 "❌ Failed to remove $host_to_remove"
              fi
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
                "Add new host" \
                "❌ Remove host" \
                "🚫 Exit")
             case "$selection" in
                "Edit hosts") edit_host ;;
                "Edit flake") $EDITOR "${config.this.user.me.dotfilesDir}/flake.nix" ;;
                "Edit yo CLI scripts") $EDITOR "${config.this.user.me.dotfilesDir}/default.nix" ;;
                "Add new host") new_host ;;
                "❌ Remove host") remove_host ;;        
                "🚫 Exit") exit 0 ;;
              esac
            done
          }

          edit_menu
        '';
      };
    };}
