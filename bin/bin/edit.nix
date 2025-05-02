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
                ${pkgs.gum}/bin/gum style --foreground 212 "=== Building USB Installer ==="
                echo "nix build .#nixosConfigurations.$(hostname).self.config.system.build.isoImage" | ${pkgs.gum}/bin/gum format -t code
                ${pkgs.gum}/bin/gum confirm "Proceed with build?" && \
                  nix build .#nixosConfigurations.$(hostname).self.config.system.build.isoImage
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

                # Generate configuration content
                cat > "$host_dir/default.nix" <<EOF
{ 
  config,
  lib,
  pkgs,
  self,
  ...
} @ inputs: {
    
    boot = {
        loader = {
            systemd-boot.enable = true;
        };  
        initrd = {
            kernelModules = [
                "kvm-intel"
                "virtio_balloon"
                "virtio_console"
                "virtio_rng"
            ];
            availableKernelModules = [
                "9p"
                "9pnet_virtio"
                "ata_piix"
                "nvme"
                "sr_mod"
                "uhci_hcd"
                "virtio_blk"
                "virtio_mmio"
                "virtio_net"
                "virtio_pci"
                "virtio_scsi"
                "xhci_pci"
            ];
            systemd.enable = true;
        };
        kernelPackages = pkgs.linuxPackages_6_1; 
        extraModulePackages = [
            self.config.boot.kernelPackages.broadcom_sta
        ];
    };
    
    this = {
        user = {       
            enable = true;
            me.name = "pungkula";
        };
        host = {
            system = "x86_64-linux";
            hostname = "$hostname";
            autoPull = false;
            interface = [ "" ];
            ip = "";
            wgip = "10.0.0.1";
            modules = {
                hardware = [ "cpu/intel" "audio" ];
                system = [ "nix" "pkgs" ];
                networking = [ "default" "pool" ];
                services = [ "ssh" "backup" ];
                programs = [ ];
                virtualisation = [ "" ];
            };  
            keys.publicKeys = {
                host = "";
                ssh = "";
                age = "";
                wireguard = "BlpQEu1MJbNmx32zgTFO0Otnkb+4XA1pwVdhjHtJBiQ=";
                builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7c/AeIpmJS6cWQkHOe4ZEq3DXVRnjtTWuWfx6L46n";
                cache = "cache:/pbj1Agw2OoSSDZcClS69RHa1aNcwwTOX3GIEGKYwPc=";
                adb = "QAAAACEJNfsfRV4PQ9Ah87MbTVbMkbXC6CAMDOR+0K6mIpv/4TSzYMkc2qit3Kryc55IVOjwR3fJRjj/uL549gZ7nEemWtcd3AsYQBp0iIEor8nu1L/V6jfsTY6Xe/pl06xoroy6OwZRWuDbZ4wD2xQRRQjfPd+JtYnMAWneM6r1V15uR67w4ITvjk3ckyfgNeLZMUwahMRjC3wSjaU9sAdKNmg8yPd8uHZ+mK6mstxJFAGEpnnm1lE7Z2r0DF6h6MKY1++dwhU+WM5BRDNiBg+D4i6fDW4+Z1I9ENuFnjT17zAxZXch04SNlG3O94BANYP7jmKp60OvtDL6msfphntuIUzMCkndF9De0Kv4lJdQxe1d+wf+AFpmtd/xtrk45YdMV+eWCJf2OkidaHmSj4ffkAobpun0VrkZN2Z1JymmdsvUbyMjAsby3Zun0xr3EocUS8Jy5TcsK/dcpD6CB5dqzlHhsHSAWt2TDwPzZYXgV1xc+q+PqM09OVN1xActJu75UMkg5b84U15hwQvYdwB8UaopMWWk6p064c7gxYSfH7fSxwkW2Jy1CElgJa55Pp4SZG9b/3B+VcNL1WSf6v/lvJqPbrRvBqvS0+e9wcFMNZtQKTX3n5X0wW1/czZPCQX+hmM8Uu1qrtaz4rKViIEGf4YR0/9eUGYQVfuAxAh8ZmsroJlnAAEAAQA= pungkula@desktop";
            };
        };    
    };                

    fileSystems."/boot" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
    };

    fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
    };

    swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

    hardware.enableAllFirmware = true;

    system.stateVersion = "24.05";
}
EOF

                ${pkgs.gum}/bin/gum style --foreground 82 "✅ Host configuration created at:"
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
