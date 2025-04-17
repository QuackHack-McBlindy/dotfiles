{ 
  config,
  lib,
  pkgs,
  modulesPath,
  ...
} : let
    hosts = [ "desktop" "laptop" "server" ]; 
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
      rebuild = {
        description = "Rebuild and switch configuration";
        aliases = [ "rb" ];
        code = ''
          ${commonHelpers}

          parse_flags "$@"
          DOTFILES_DIR="${config.this.user.me.dotfilesDir}"
          run_cmd cd "$DOTFILES_DIR"
          run_cmd sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake . --show-trace
        '';
      };

      deploy = {
        description = "Remote deployment to specified host";
        aliases = [ "d" ];
        code = ''
          ${commonHelpers}

          parse_flags "$@"
          if [ -z "$HOST" ]; then
            echo "Error: Host required for deployment"
            exit 1
          fi

          run_cmd ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch \
            --flake ".#$HOST" \
            --target-host "root@$HOST" \
            --build-host "root@$HOST" \
            "''${FLAGS[@]}"
        '';
      };

      build = {
        description = "Build system configuration";
        aliases = [ "b" ];
        code = ''
          ${commonHelpers}

          parse_flags "$@"
          HOST=''${HOST:-${builtins.elemAt hosts 0}}

          run_cmd ${pkgs.nix}/bin/nix build \
            ".#nixosConfigurations.$HOST.config.system.build.toplevel" \
            "''${FLAGS[@]}"
        '';
      };

      clean = {
        description = "Run garbage collection";
        aliases = [ "gc" ];
        code = ''
          ${commonHelpers}
          parse_flags "$@"
          run_cmd ${pkgs.nix}/bin/nix-collect-garbage -d
        '';
      };

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


      # New push script
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
          echo -e "║  🎉  \033[1;32mSuccessfully pushed dotfiles!\033[0m  \033[38;5;213m║"
          echo -e "╚══════════════════════════════════════╝\033[0m"
          echo -e "\033[38;5;87m🌍 Repository: $REPO\033[0m"
          echo -e "\033[38;5;154m🌿 Branch: $CURRENT_BRANCH\033[0m\n"
        '';
      };

      sopse = {
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
