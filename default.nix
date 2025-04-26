{ 
  config,
  self,
  lib,
  pkgs,
  modulesPath,
  ...
} : let

    sysHosts = builtins.attrNames self.nixosConfigurations;
    isoHosts = builtins.attrNames (self.installerIsos or {});
    vmHosts = builtins.filter (host:
      self.nixosConfigurations.${host}.config.system.build ? vm
    ) sysHosts;
in {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix")
            ./modules
            ./modules/yo.nix
            ./home
    ];
    
    networking.hostName = config.this.host.hostname;
    networking.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = config.this.host.system;
    
    yo.scripts = let
      cmdHelpers = ''
        # Generation-commit synchronization
        tag_generation() {
          CURRENT_GEN=$(${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --list-generations | grep "(current)" | awk '{print $1}')
          COMMIT_HASH=$(git -C /etc/nixos rev-parse HEAD)
          git -C /etc/nixos tag -f "generation-$CURRENT_GEN" "$COMMIT_HASH"
          echo "🔖 Tagged generation $CURRENT_GEN → commit $COMMIT_HASH"
        }

        parse_flags() {
          VERBOSE=0
          DRY_RUN=false
          HOST=""

          for arg in "$@"; do
            case "$arg" in
              '?') ((VERBOSE++)) ;;
              '!') DRY_RUN=true ;;
              *) HOST="$arg" ;;
            esac
          done

          FLAGS=()
          (( VERBOSE > 0 )) && FLAGS+=(--show-trace "-v''${VERBOSE/#0/}")
        }

        run_cmd() {
          if $DRY_RUN; then
            echo "[DRY RUN] Would execute:"
            echo "  ''${@}"
          else
            if (( VERBOSE > 0 )); then
              echo "Executing: ''${@}"
            fi
            "''${@}"
          fi
        }
      
        rainbow_text() {
          local text="$1"
          local colors=(
            "\033[38;5;196m"  # Red
            "\033[38;5;202m"  # Orange
            "\033[38;5;226m"  # Yellow
            "\033[38;5;46m"   # Green
            "\033[38;5;51m"   # Cyan
            "\033[38;5;189m"  # Blue
            "\033[38;5;99m"   # Purple
          )
         local colored_text=""
          local color_index=0
          local text_length=$${#text}

          for ((i = 0; i < text_length; i++)); do
            colored_text+="$${colors[$$((color_index % $${#colors[@]}))]}$${text:$$i:1}\033[0m"
            ((color_index++))
          done
          echo -e "$${colored_text}"
        }
      
#        git_safe_checkout() {
#          local repo_path="$1"
#          cd "$repo_path" || exit 1 
#          if ! git rev-parse --is-inside-work-tree >/dev/null; then
#            echo "Initializing new repository"
#            git init
#            git checkout -B main
#          fi
#        }  
        
        fail() {
          echo -e "\033[1;31m❌ $1\033[0m" >&2
          exit 1
        }
        validate_flags() {
          verbosity_level=$(grep -o '?' <<< "$@" | wc -l)
          DRY_RUN=$(grep -q '!' <<< "$@" && echo true || echo false)
        }  
        validate_host() {
          if [[ ! " ${toString sysHosts} " =~ " $host " ]]; then
            echo -e "\033[1;31m❌ $1\033[0m Unknown host: $host" >&2
            echo "Available hosts: ${toString sysHosts}" >&2
            exit 1
          fi
        }    
      '';
    in {   
#==================================#
#==== SWITCH REBUILD   #==================#
      switch = {
        description = "Rebuild and switch Nix OS system configuration";
        aliases = [ "rb" ];
        parameters = [
          { name = "flake"; description = "Path to the irectory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; } 
          { name = "autoPull"; description = "Wether dotfiles should be re-pulled before rebuilding the system configuration"; optional = true; default = builtins.toString config.this.host.autoPull; } 
        ];
        code = ''
          ${cmdHelpers}
          if ''$autoPull && [ -d "$flake/.git" ]; then
            run_cmd yo pull
          fi
          run_cmd sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ''$flake --show-trace
        '';
      };





#==================================#
#==== EDIT HOSTS   #==================#
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
              --header=" Select Configuration Action:" \
              "Build USB auto installer" \
              "Add new host config")

            case "$action" in
              "Build USB auto installer")
                ${pkgs.gum}/bin/gum style --foreground 212 "=== Building USB Installer ==="
                echo "nix build .#nixosConfigurations.$(hostname).config.system.build.isoImage" | ${pkgs.gum}/bin/gum format -t code
                ${pkgs.gum}/bin/gum confirm "Proceed with build?" && \
                  nix build .#nixosConfigurations.$(hostname).config.system.build.isoImage
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
            config.boot.kernelPackages.broadcom_sta
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
 
          edit_host() {
            selected_host=$(nix flake show "${config.this.user.me.dotfilesDir}" --json 2>/dev/null | jq -r '.nixosConfigurations | keys[]' | ${pkgs.gum}/bin/gum choose --header "Select host:")
            [ -n "$selected_host" ] && $EDITOR "${config.this.user.me.dotfilesDir}/hosts/$selected_host/default.nix"
          }



          edit_menu() {
            while true; do
              selection=$(${pkgs.gum}/bin/gum choose \
                "Edit hosts" \
                "Edit yo CLI scripts" \
                "Edit flake" \
                "Add new host" \
                "🚫 Exit")
             case "$selection" in
                "Edit hosts") edit_host ;;
                "Edit yo CLI scripts") $EDITOR "${config.this.user.me.dotfilesDir}/default.nix" ;;
                "Edit flake") $EDITOR "${config.this.user.me.dotfilesDir}/flake.nix" ;;
                "Add new host") new_host ;;
                "🚫 Exit") exit 0 ;;
              esac
            done
          }

          edit_menu
        '';
      };
      
#==================================#
#==== ROLLBACK   #==================#      
      rollback = {
        description = "Synchronized system+config rollback";
#        aliases = [ "rb" ];
        code = ''
          ${cmdHelpers}
    
          echo "🔄 Listing synchronized generations:"
          git -C /etc/nixos tag -l 'generation-*' | while read tag; do
            gen=''${tag#generation-}
            commit=$(git -C /etc/nixos rev-list -n 1 $tag)
            printf "%-10s %s %s\n" "Generation $gen:" "($(date -d @$(git -C /etc/nixos show -s --format=%ct $commit)))" "$(git -C /etc/nixos show -s --format=%s $commit | head -1)"
          done

          read -p "🚦 Enter generation number to rollback: " GEN_NUM
    
          # Nix rollback
          if ! ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --switch-generation $GEN_NUM; then
            echo "❌ Nix rollback failed!"
            exit 1
          fi
    
          # Git rollback
          TAG="generation-$GEN_NUM"
          if ! git -C /etc/nixos checkout $TAG -- .; then
            echo "❌ Git rollback failed! Restoring Nix generation..."
            ${pkgs.nix}/bin/nix-env --switch-generation previous
            exit 1
          fi
    
          echo "✅ Dual rollback complete! Rebuilding system..."
          ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch
        '';
      };
      
#==================================#
#==== CLEAN GARBAGE   #==================#
      clean = {
        description = "Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune";
        aliases = [ "gc" ];
        code = ''
              ${cmdHelpers}   
              # 1. Nix OS garbage collection
              run_cmd ${pkgs.nix}/bin/nix-collect-garbage -d
              run_cmd sudo ${pkgs.nix}/bin/nix-collect-garbage
              
              # 2. Empty user trash (adjust for each user if needed)
              # run_cmd rm -rf ~/.local/share/Trash/*
              
              # 3. Flush /tmp (be cautious if apps are using it)
              # run_cmd sudo rm -rf /tmp/*
             
              # 4. Wipe Nix store cache
              run_cmd sudo nix-store --gc
              run_cmd sudo nix-store --verify --check-contents --repair # optional but thorough
              run_cmd sudo ${pkgs.nix}/bin/nix-collect-garbage -d

              # 5. Remove unused Docker data
              # ANSI escape codes for bold and red text
              BOLD=$(tput bold)
              RED=$(tput setaf 1)
              GREEN=$(tput setaf 2)
              RESET=$(tput sgr0)

              # Docker prune Step 1: Remove dangling images, unused volumes (but keep running containers intact)
              run_cmd echo "Cleaning up dangling images and unused volumes..."
              run_cmd docker image prune -f
              run_cmd docker volume prune -f

              # Step 2: Retrieve all image IDs
              all_images=$(docker images -q)

              if [ -z "$all_images" ]; then
                  run_cmd echo "No images found after cleanup."
                  run_cmd exit 0
              fi

              # Step 3: Try to remove all images (without force) but only if they are NOT in use by containers
              run_cmd echo "Attempting to remove all unused images without force..."
              run_cmd docker rmi $(docker images -q --filter "dangling=true") 2>/dev/null

              # Step 4: Retrieve all image IDs again (after first removal attempt)
              remaining_images=$(docker images -q)
              if [ -z "$remaining_images" ]; then
                  run_cmd echo "No images remain after initial removal."
                  run_cmd exit 0
              fi
              # Initialize a flag for 'Remove All' option
              remove_all=false

              # Step 5: Loop through remaining images
              for image_id in $remaining_images; do
                  # Get the stopped containers using the image
                  containers=$(docker ps -a -q --filter "ancestor=$image_id")
                  if [ -n "$containers" ]; then
                      container_names=$(docker ps -a --filter "ancestor=$image_id" --format "{{.Names}}")

                      # Step 6: Prompt user (with existing prompt style)
                      if [ "$remove_all" = false ]; then
                          run_cmd echo "The following containers are using image $image_id:"
                          run_cmd echo "''${BOLD}''${RED}$container_names''${RESET}"  # Escaped for Nix interpolation
                          run_cmd echo "Do you want to forcefully remove this image and its containers? (Y/N/A)"
                          run_cmd read -rp "(Y = Yes, N = No, A = Remove all remaining images with force): " choice
                      fi
                      # Handle user choice (case-insensitive)
                      case "$choice" in
                          [Yy]*)  # Handle Y or y as "Yes"
                              run_cmd docker rm $containers
                              run_cmd docker rmi -f $image_id
                              run_cmd echo -e "\nRemoved image $image_id and its containers.\n"
                              ;;
                          [Aa]*)  # Handle A or a as "Remove all remaining images with force"
                              remove_all=true
                              run_cmd docker rm $containers
                              run_cmd docker rmi -f $image_id
                              run_cmd echo -e "\nForcefully removed image $image_id and its containers.\n"
                              ;;
                          *)  # Handle any other input (N or invalid) as "No"
                              run_cmd echo -e "\nSkipping image $image_id.\n"
                              ;;
                      esac
                  else
                      run_cmd echo "No containers found for image $image_id. Attempting to remove..."
                      run_cmd docker rmi $image_id
                      if [ $? -eq 0 ]; then
                          run_cmd echo "Image $image_id removed successfully."
                      else
                          run_cmd echo "Failed to remove image $image_id."
                      fi
                  fi
              done
              run_cmd echo "Process completed."
              # Run docker system df to display current Docker disk usage
              run_cmd echo -e "\nCurrent Docker disk usage:"
              run_cmd docker system df
              # Prompt user if they want to prune the build cache
              run_cmd read -rp "Do you want to prune the Docker build cache? This will free up build cache layers (Y/N): " prune_choice
              # If the user chooses 'Y' or 'y', run docker builder prune -a -f
              if [[ "$prune_choice" =~ ^[Yy]$ ]]; then
                  run_cmd echo "Pruning Docker build cache..."
                  run_cmd docker builder prune -a -f
                  run_cmd echo "Build cache pruned."
              fi
              # Run docker system df again to show the new disk usage
              run_cmd echo -e "\nUpdated Docker disk usage after pruning:"
              run_cmd docker system df
              # Display free space and percentage in /home with color coding
              run_cmd df -h ~ | awk 'NR==2 {
                  free_space=$4;
                  used_percent=$5;
                  gsub("%", "", used_percent);
                  green="\033[32m";
                  red="\033[31m";
                  reset="\033[0m";
                  if (used_percent > 65) {
                      color=red;
                  } else {
                      color=green;
                  }
                  printf "Free space: %s, Used: %s%s%s\n", free_space, color, $5, reset;
              }'
            '';
          };
#==================================#
#==== GIT PULL    #==================#
      pull = {
        description = "Pull dotfiles repo from GitHub";
        aliases = [ "pl" ];
        parameters = [ 
          { name = "flake"; description = "Path to the directory containing your flake.nix"; optional = true; default = config.this.user.me.dotfilesDir; } 
        ];
        code = ''
          ${cmdHelpers}
          DOTFILES_DIR=''$flake
          run_cmd cd "$DOTFILES_DIR"
          run_cmd git checkout -- .
          checkout_status=$?
          run_cmd git pull origin main
          pull_status=$?
          if ! $DRY_RUN; then
            if [ $checkout_status -eq 0 ] && [ $pull_status -eq 0 ]; then
              echo " "
              echo " "
              echo "🚀🚀🚀🚀 ✨ "
              echo "✨✨ Successfully pulled the latest dotfiles repository!"
            else
              echo -e "\033[1;31m [ WARNING! ] \033[0m"
              echo -e "\033[1;31mAn error occurred while pulling the latest changes.\033[0m"
            fi
          fi
        '';
      };

#==================================#
#==== GIT PUSH    #==================#
      push = {
        description = "Push dotfiles to GitHub";
        aliases = [ "ps" ];
        parameters = [
          { name = "flake"; description = "Path to the directory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; } 
          { name = "repo"; description = "User GitHub repo"; optional = false; default = config.this.user.me.repo; } 
        ];
        code = ''
          ${cmdHelpers}
          REPO="$repo"
          DOTFILES_DIR="$flake"
          COMMIT_MSG=''${HOST:-"Updated files"}
          run_cmd cd "$DOTFILES_DIR"
          if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo -e "\033[1;33m⚡ Initializing new Git repository\033[0m"
            run_cmd git init
            if [ "$(git symbolic-ref --short -q HEAD)" != "main" ]; then
              run_cmd git checkout -B main
            fi
          fi
          # Configure remote with forced URL update
          CURRENT_URL=$(git remote get-url origin 2>/dev/null || true)
          if [ -z "$CURRENT_URL" ]; then
            echo -e "\033[1;33m🌍 Adding remote origin: $REPO\033[0m"
            run_cmd git remote add origin "$REPO"
          elif [ "$CURRENT_URL" != "$REPO" ]; then
            echo -e "\033[1;33m🔄 Updating remote origin URL to: $REPO\033[0m"
            run_cmd git remote set-url origin "$REPO"
          fi
          # Create initial commit if repository is empty
          if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
            if [ -z "$(git status --porcelain)" ]; then
              echo -e "\033[1;31m❌ Error: No files to commit in new repository\033[0m"
              exit 1
            fi
            echo -e "\033[1;33m✨ Creating initial commit\033[0m"
            run_cmd git add .
            run_cmd git commit -m "Initial commit"
          fi
          # Ensure we're on a valid branch (handle detached HEAD)
          CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
          if [ "$CURRENT_BRANCH" = "HEAD" ]; then
            echo -e "\033[1;33m🌱 Creating new main branch from detached HEAD\033[0m"
            run_cmd git checkout -b main
            CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
          fi
          # Check for changes
          if [ -z "$(git status --porcelain)" ]; then
            echo -e "\033[1;36m🎉 No changes to commit\033[0m"
            exit 0
          fi
          # Commit and push changes
          echo -e "\033[1;34m📦 Staging changes...\033[0m"
          run_cmd git add .
          echo -e "\033[1;34m💾 Committing changes: $COMMIT_MSG\033[0m"
          run_cmd git commit -m "$COMMIT_MSG"
          run_cmd echo -e "\033[1;34m🚀 Pushing to $CURRENT_BRANCH branch...\033[0m"
          run_cmd git push -u origin "$CURRENT_BRANCH" || {
            run_cmd echo -e "\033[1;31m❌ Push failed\033[0m"
            exit 1
          }
          
          # Fancy success message
          run_cmd echo -e "\n\033[38;5;213m╔══════════════════════════════════════╗"
          run_cmd echo -e "║  🎉  \033[1;32mSuccessfully pushed dotfiles!\033[0m  \033[38;5;213m ║"
          run_cmd echo -e "╚══════════════════════════════════════╝\033[0m"
          run_cmd echo -e "\033[38;5;87m🌍 Repository: $REPO\033[0m"
          run_cmd echo -e "\033[38;5;154m🌿 Branch: $CURRENT_BRANCH\033[0m\n"
          rainbow_text ╔══════════════════════════════════════╗
          rainbow_text ║  🎉 Successfully pushed dotfiles!!   ║
          rainbow_text ╚══════════════════════════════════════╝
          
        '';
      };


#==================================#
#==== yubi    #==================#
      yubi = {
        description = "Encrypts and decrypts files using a Yubikey and AGE";
        aliases = [ "yk" ];
        parameters = [
          { name = "operation"; description = "Operation to perform (encrypt|decrypt)"; optional = false; type = "string"; }
          { name = "input"; description = "Input file to process"; optional = false; type = "path"; }
        ];
        code = ''
          ${cmdHelpers}
          # Validate operation
          if [[ "$operation" != "encrypt" && "$operation" != "decrypt" ]]; then
            echo -e "\033[1;31m❌ Invalid operation: $operation\033[0m"
            echo "Valid operations: encrypt, decrypt"
            exit 1
          fi

          # Safety checks
          if [[ ! -f "$input" ]]; then
            echo -e "\033[1;31m❌ Input file not found: $input\033[0m"
            exit 1
          fi

          temp_file="$(mktemp)"

          case "$operation" in
            encrypt)
              # Original behavior: Encrypt -> same filename
              run_cmd echo -e "\033[1;34m🔒 Encrypting $input in-place\033[0m"
              mv "$input" "$temp_file"
        
              if rage -r "age1yubikey1q0ek47e26sg9eej2xlvxj308fgw8h8ajgx6ucagjzlm9tzgxtckdw35eg0m" \
                   -o "$input" "$temp_file"; then
                echo -e "\033[1;32m✅ Successfully encrypted file\033[0m"
                rm -f "$temp_file"
              else
                echo -e "\033[1;31m❌ Encryption failed - restoring original file\033[0m"
                mv "$temp_file" "$input"
                exit 1
              fi
              ;;

            decrypt)
              # Original behavior: Decrypt -> same filename
              run_cmd echo -e "\033[1;34m🔓 Decrypting $input in-place\033[0m"
              age-plugin-yubikey --identity --slot 1 > /tmp/yubikey-identity.txt 2>/dev/null
        
              if rage -d -i /tmp/yubikey-identity.txt -o "$temp_file" "$input"; then
                mv "$temp_file" "$input"
                echo -e "\033[1;32m✅ Successfully decrypted file\033[0m"
                rm -f /tmp/yubikey-identity.txt
              else
                echo -e "\033[1;31m❌ Decryption failed - original file preserved\033[0m"
                rm -f "$temp_file"
                exit 1
              fi
              ;;
          esac
        '';
      };


#==================================#
#==== SOPS    #==================#
      sops = {
        description = "Encrypts a file with sops-nix";
        aliases = [ "" ];
        parameters = [
          { name = "input"; description = "Input file to encrypt"; optional = false; } 
          { name = "agePub"; description = "The AGE public key used for encrypting the file"; optional = false; default = config.this.host.keys.publicKeys.age; } 
        ];
        code = ''
          ${cmdHelpers}
          if [[ $# -eq 0 ]]; then
            run_cmd echo -e "\033[1;31m❌ Usage: yo sops <input-file.yaml>\033[0m"
            exit 1
          fi
          INPUT_FILE="$input"
          OUTPUT_TMP="''${INPUT_FILE%.*}.enc.yaml"
          if [[ ! -f "$INPUT_FILE" ]]; then
            echo -e "\033[1;31m❌ Error: Input file '$INPUT_FILE' not found!\033[0m"
            exit 1
          fi
          if [[ -z "$agePub" ]]; then
             run_cmd echo -e "\033[1;31m❌ Error: Age public key not set in config.this.host.keys.publicKeys.age\033[0m"
             run_cmd echo -e "\033[1;31m❌ $EDITOR /${config.this.user.me.dotfilesDir}\033[0m"
            exit 1
          fi
          run_cmd echo -e "\033[1;34m🔐 Encrypting '$INPUT_FILE' with sops-nix using Age key...\033[0m"
          run_cmd sops --encrypt --age "$agePub" --output "$OUTPUT_FILE" "$INPUT_FILE"
          run_cmd echo -e "\033[1;32m✅ Encrypted: $INPUT_FILE → $OUTPUT_FILE\033[0m"
        '';
      };

#==================================#
#==== REBOOT    #==================#
      reboot = {
        description = "Force reboot and wait for host";
        aliases = [ "" ];
        parameters = [
          { name = "host"; description = "Target hostname for the reboot"; optional = true; default = config.this.host.hostname; }
        ];
        code = ''
          # Ensure sysHosts is defined elsewhere in your config
          if [[ ! " ${toString sysHosts} " =~ " $host " ]]; then
            echo -e "\033[1;31m❌ Invalid host: $host\033[0m" >&2
            echo "Available hosts: ${toString sysHosts}" >&2
            exit 1
          fi

          echo "Initiating reboot sequence for $host"
    
          # Immediate reboot without backgrounding
          ssh "$host" 'sudo reboot -f'
    
          echo "Waiting for $host to go offline..."
          while ping -c 1 -W 1 "$host" &> /dev/null; do
            sleep 1
          done
    
          echo "Host offline. Waiting for reboot..."
          until ping -c 1 -W 1 "$host" &> /dev/null; do
            sleep 1
          done
    
          echo "Host back online. Waiting for SSH..."
          until ssh -q "$host" 'exit'; do
            sleep 1
          done
    
          echo "Reboot completed successfully"
        '';
      };
#==================================#
#==== HEALTH    #==================#
      health = {
        description = "Check system health status across your machines";
        aliases = [ "hc" ];
        parameters = [
          { name = "host"; description = "Target hostname for the health check"; optional = true; default = config.this.host.hostname; }
        ];
        code = ''
          ${cmdHelpers}
          target_host="''${host:-$(hostname)}"
          if [[ "$target_host" == "$(hostname)" ]]; then
            run_cmd sudo health | jq
          else
            run_cmd ssh "$target_host" sudo health
          fi
        '';
      };
      
#==================================#
#==== DEPLOY    #==================#
      deploy = {
        description = "Deploy NixOS system configurations to your remote servers";
        aliases = [ "d" ];
        parameters = [
          { name = "host"; description = "Host machine to build and activate"; optional = false; }
          { name = "flake"; description = "Path to the directory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; }
          { name = "user"; description = "SSH username"; optional = true; default = config.this.user.me.name; }
          { name = "repo"; description = "Repository containing containing your NixOS configuration files"; optional = true; default = config.this.user.me.repo; }    
          { name = "!"; description = "Test mode (does not save new NixOS generation)"; optional = true; }
        ];
        code = ''   
          ${cmdHelpers}
          if [[ ! " ${toString sysHosts} " =~ " $host " ]]; then
            echo -e "\033[1;31m❌ $1\033[0m Unknown host: $host" >&2
            echo "Available hosts: ${toString sysHosts}" >&2
            exit 1
          fi
          if $DRY_RUN; then
            echo "❗ Test run: reboot will revert activation"
          fi

          AUTO_PULL=(run_cmd nix eval ''$flake#nixosConfigurations.''$host.config.this.host.autoPull) 
          # check if deplyed host should be autoPulled
          if [[ "$AUTO_PULL" == "true" ]]; then
            run_cmd echo "$host has autoPull activated!"
            # Check if deployed hosts dotfiles directory should be pulled or cloned
            result=( $(run_cmd ssh "$host" "[ -d \$flake/.git ] && echo true || echo false" 2>/dev/null | grep -Eo 'true|false') )
            if [ "$result" = "true" ]; then
              # if dotfiles exist, update it
              run_cmd yo pull
            else
              # Otherwise clone it to $flake parameter
              run_cmd echo "🚀 Bootstrap: Cloning dotfiles repo to ''$flake on ''$host"
              run_cmd git clone ''$repo ''$flake || fail "❌  Clone failed"
            fi
          fi

          echo "👤 SSH User: ''$user"
          echo "🌐 SSH Host: ''$host"
          echo "❄️ Nix flake: ''$flake"
          echo "🚀 Deploying ''$flake#nixosConfigurations.''$host"
          echo "🔨 Building locally and activating remotely..."

          if $DRY_RUN; then
            rebuild_command="test"
          else
            rebuild_command="switch"
          fi
          cmd=(
            ${pkgs.nixos-rebuild}/bin/nixos-rebuild
            $rebuild_command
            --flake "$flake#$host"
            --target-host "$user@$host"
            --use-remote-sudo
            --show-trace
          )
          
          "''${cmd[@]}"
          
          if $DRY_RUN; then
            echo "🧪 Test deployment completed - No system generation saved!"
          else
            echo "✅ Deployment complete!"
          fi
  
        '';
      };
       
    };}

    
