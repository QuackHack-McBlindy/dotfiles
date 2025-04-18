{ 
  config,
  self,
  lib,
  pkgs,
  modulesPath,
  ...
} : let
    hosts = [ "desktop" "laptop" "server" ]; 
    # Get hosts from flake outputs
    sysHosts = builtins.attrNames self.nixosConfigurations;
    isoHosts = builtins.attrNames (self.installerIsos or {});
    vmHosts = builtins.filter (host:
      self.nixosConfigurations.${host}.config.system.build ? vm
    ) sysHosts;
in {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix")
            ./modules/yo.nix
            ./modules
    ];
    
    networking.hostName = config.this.host.hostname;
    networking.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = config.this.host.system;
    
    yo.scripts = let
      commonHelpers = ''
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
      '';
    in {
    
#==================================#
#==== SWITCH REBUILD   #==================#
      switch = {
        description = "Rebuild and switch Nix OS system configuration";
        aliases = [ "rb" ];
        code = ''
          ${commonHelpers}
          parse_flags "$@"
          DOTFILES_DIR="${config.this.user.me.dotfilesDir}"
          run_cmd sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "$DOTFILES_DIR" --show-trace
        '';
      };



 #     deploy = {
#        description = "Remote deployment to specified host";
#        aliases = [ "d" ];
#        code = ''
#          ${commonHelpers}

#          parse_flags "$@"
#          if [ -z "$HOST" ]; then
#            echo "Error: Host required for deployment"
#            exit 1
#          fi

#          run_cmd ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch \
#            --flake ".#$HOST" \
#            --target-host "root@$HOST" \
#           --build-host "root@$HOST" \
#            "''${FLAGS[@]}"
#        '';
#      };



 #     deploy = {
#        description = "Deploy to host with live configuration";
#        code = ''
#          #!${pkgs.bash}/bin/bash
#          host="$1"
#          if [[ -z "$host" ]]; then
#            echo "Error: No host specified"
#            exit 1
#          fi

#          ip=$(${pkgs.nix}/bin/nix eval --raw ".#nixosConfigurations.$host.config.networking.host.ip" 2>/dev/null)
#          if [[ -z "$ip" ]]; then
#            echo "Error: Could not find IP for host $host"
#            exit 1
#          fi

#          echo "🚀 Deploying to $host ($ip)"
#          ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch \
#            --flake ".#$host" \
#            --target-host "root@$ip" \
#            --use-remote-sudo
#        '';
#      };

#      host-info = {
#        description = "Show host configuration details";
#        code = ''
          #!${pkgs.bash}/bin/bash
#          host="$1"
#          ${pkgs.nix}/bin/nix eval --json ".#nixosConfigurations.$host.config" \
#            | ${pkgs.jq}/bin/jq
#        '';
#      };

      encrypt-file = {
        description = "Encrypt file for specific host";
        code = ''
          #!${pkgs.bash}/bin/bash
          file="$1"
          host="$2"
          key=$(${pkgs.nix}/bin/nix eval --raw ".#nixosConfigurations.$host.config.this.host.keys.age")
          ${pkgs.sops}/bin/sops --encrypt --age "$key" -i "$file"
        '';
      };

      deploy-interactive = {
        description = "Interactive host selection";
        code = ''
          #!${pkgs.bash}/bin/bash
          host=$(${pkgs.nix}/bin/nix eval --raw --apply 'builtins.attrNames' .#nixosConfigurations \
            | ${pkgs.jq}/bin/jq -r '.[]' \
            | ${pkgs.fzf}/bin/fzf --prompt="Select host> ")
          yo deploy "$host"
        '';
      };
      
#==================================#
#==== BUILD    #==================#

      build = {
        description = "Build system configurations, installer ISOs, or VMs";
        aliases = [ "b" ];
        code = ''
          ${commonHelpers}

          # Define available host types as strings
          ALL_HOSTS="${sysHosts}"
          ISO_HOSTS="${isoHosts}"
          VM_HOSTS="${vmHosts}"

          show_build_help() {
            cat <<EOF | ${pkgs.glow}/bin/glow -
## 🛠️ Build Targets

System hosts: $ALL_HOSTS
ISO hosts:    $ISO_HOSTS
VM hosts:     $VM_HOSTS

Commands:
  system [HOST]  - Build system configuration
  iso [HOST]     - Create installation ISO
  vm [HOST]      - Build virtual machine

Examples:
  yo build system all     - Build all systems
  yo build iso my-iso     - Create ISO for my-iso
  yo build vm my-vm       - Build VM for my-vm
EOF
            exit 0
          }

          parse_flags "$@"

          if [ $# -eq 0 ]; then
            show_build_help
          fi

          TARGET_TYPE="''${1:-system}"
          HOST="''${2:-all}"
          shift 2>/dev/null

          case "$TARGET_TYPE" in
            system|s) ATTR_PREFIX="nixosConfigurations.%s.config.system.build.toplevel" ;;
            iso|i)    ATTR_PREFIX="installerIsos.%s" ;;
            vm|v)     ATTR_PREFIX="nixosConfigurations.%s.config.system.build.vm" ;;
            *)         echo "Invalid target: $TARGET_TYPE"; show_build_help; exit 1 ;;
          esac

          # Get valid hosts for target type
          case "$TARGET_TYPE" in
            system|s) VALID_HOSTS="$ALL_HOSTS" ;;
            iso|i)    VALID_HOSTS="$ISO_HOSTS" ;;
            vm|v)     VALID_HOSTS="$VM_HOSTS" ;;
          esac

          build_host() {
            host="$1"
            attr="$(printf "$ATTR_PREFIX" "$host")"
            echo "Building $TARGET_TYPE for $host..."
            ${pkgs.nix}/bin/nix build ".#$attr" $FLAGS
          }

          if [ "$HOST" = "all" ]; then
            for host in $VALID_HOSTS; do
              build_host "$host"
            done
          else
            # Check if host exists in valid hosts
            if ! echo " $VALID_HOSTS " | grep -q " $host "; then
              echo "Invalid host '$host' for target $TARGET_TYPE"
              echo "Valid options: $VALID_HOSTS"
              exit 1
            fi
            build_host "$HOST"
          fi
        '';
      };


#==================================#
#==== CLEAN GARBAGE   #==================#
      clean = {
        description = "Run garbage collection";
        aliases = [ "gc" ];
        code = ''
          ${commonHelpers}
          parse_flags "$@"
          run_cmd ${pkgs.nix}/bin/nix-collect-garbage -d
        '';
      };


#==================================#
#==== INFO    #==================#
      info = {
        description = "Show system info (JSON format)";
        aliases = [ "i" ];
        code = ''
          ${commonHelpers}
          parse_flags "$@"
          HOST=''${HOST:-${builtins.elemAt hosts 0}}
          run_cmd ${pkgs.nix}/bin/nix eval \
            --json ".#nixosConfigurations.$HOST.config.system.build" \
            "''${FLAGS[@]}"
        '';
      };


#==================================#
#==== GIT PULL    #==================#
      pull = {
        description = "Pull dotfiles repo from GitHub";
        code = ''
          ${commonHelpers}
          parse_flags "$@"
          DOTFILES_DIR="${config.this.user.me.dotfilesDir}"
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
        code = ''
          ${commonHelpers}
          parse_flags "$@"
          REPO="${config.this.user.me.repo}"
          DOTFILES_DIR="${config.this.user.me.dotfilesDir}"
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
          echo -e "\033[1;34m🚀 Pushing to $CURRENT_BRANCH branch...\033[0m"
          run_cmd git push -u origin "$CURRENT_BRANCH" || {
            echo -e "\033[1;31m❌ Push failed\033[0m"
            exit 1
          }
          # Fancy success message
          echo -e "\n\033[38;5;213m╔══════════════════════════════════════╗"
          echo -e "║  🎉  \033[1;32mSuccessfully pushed dotfiles!\033[0m  \033[38;5;213m ║"
          echo -e "╚══════════════════════════════════════╝\033[0m"
          echo -e "\033[38;5;87m🌍 Repository: $REPO\033[0m"
          echo -e "\033[38;5;154m🌿 Branch: $CURRENT_BRANCH\033[0m\n"
        '';
      };


#==================================#
#==== SOPS    #==================#
      sops = {
        description = "Encrypts a file with sops-nix";
       # aliases = [ "" ];
        code = ''
          ${commonHelpers}
          parse_flags "$@"
          if [[ $# -eq 0 ]]; then
            echo -e "\033[1;31m❌ Usage: yo i <input-file.yaml>\033[0m"
            exit 1
          fi
          INPUT_FILE="$1"
          OUTPUT_FILE="''${INPUT_FILE%.*}.enc.yaml"
          AGE_KEY="${config.this.host.keys.publicKeys.age}"
          if [[ ! -f "$INPUT_FILE" ]]; then
            echo -e "\033[1;31m❌ Error: Input file '$INPUT_FILE' not found!\033[0m"
            exit 1
          fi
          if [[ -z "$AGE_KEY" ]]; then
            echo -e "\033[1;31m❌ Error: Age public key not set in config.this.host.keys.publicKeys.age\033[0m"
            exit 1
          fi
          echo -e "\033[1;34m🔐 Encrypting '$INPUT_FILE' with Age key...\033[0m"
          run_cmd sops --encrypt --age "$AGE_KEY" --output "$OUTPUT_FILE" "$INPUT_FILE"
          echo -e "\033[1;32m✅ Encrypted: $INPUT_FILE → $OUTPUT_FILE\033[0m"
        '';
      };


#==================================#
#==== HELP    #==================#
      help = {
        description = "Show command documentation";
        aliases = [ "h" ];
        code = ''
          cat <<EOF
          NixOS Multi-Host Management System
          Usage: yo <command> [host] [?*] [!]
          Commands:
            sync|s [HOST] [?*] [!]  - Rebuild and switch configuration
            deploy|d [HOST] [?*] [!] - Remote deployment
            build|b [HOST] [?*] [!] - Build system configuration
            gc [?*] [!]             - Run garbage collection
            info|i [HOST] [?*] [!]  - Show system info (JSON)
            pull|p [?*] [!]         - Update flake inputs
            help|h                  - Show this help

          Options:
            ? - Increase verbosity (multiple allowed)
            ! - Dry run mode

          Available hosts: ${builtins.concatStringsSep " " hosts}
          EOF
        '';
      };
     
    };
       
}
