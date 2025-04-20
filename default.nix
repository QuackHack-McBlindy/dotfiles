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
        requiresHost = true;
        code = ''
          ${commonHelpers}
          parse_flags "$@"
          DOTFILES_DIR="${config.this.user.me.dotfilesDir}"
          run_cmd sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "$DOTFILES_DIR" --show-trace
        '';
      };

#==================================#
#==== CLEAN GARBAGE   #==================#
      clean = {
        description = "Run garbage collection";
        aliases = [ "gc" ];
        requiresHost = false;
        code = ''
          ${commonHelpers}
          parse_flags "$@"
          run_cmd ${pkgs.nix}/bin/nix-collect-garbage -d
        '';
      };

#==================================#
#==== GIT PULL    #==================#
      pull = {
        description = "Pull dotfiles repo from GitHub";
        aliases = [ "pl" ];
        requiresHost = false;
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
        aliases = [ "ps" ];
        requiresHost = false;
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
        aliases = [ "" ];
        requiresHost = false;
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
#==== HEALTH    #==================#
#      health = {
#        description = "Check system health status across hosts";
#        aliases = [ "hc" ];
#        requiresHost = false;
#        code = ''
#          ${commonHelpers}
#          parse_flags "$@"
#          target_host="''${HOST:-${config.networking.hostName}}"
#          valid_hosts=" ${toString sysHosts} "
#          if [[ ! "$valid_hosts" =~ " $target_host " ]]; then
#            echo "Invalid host: $target_host"
#            echo "Available hosts: ${toString sysHosts}"
#            exit 1
#          fi
#          if [[ "$target_host" == "${config.networking.hostName}" ]]; then
            # Local host
#            echo "PATH: $PATH"
#            run_cmd health
#          else
            # Remote host
#            echo "PATH: $PATH"
#            run_cmd ssh "$target_host" health
#          fi | ${pkgs.jq}/bin/jq --color-output .
#        '';
#      };  


      health = {
        description = "Check system health status across hosts";
        aliases = [ "hc" ];
        requiresHost = false;
        parameters = [
          { name = "host"; description = "Target hostname or host alias"; }
        ];
        code = ''
          ${commonHelpers}
          parse_flags "$@"

          target_host="''${host:-${config.networking.hostName}}"
          valid_hosts=" ${toString sysHosts} "

          if [[ ! "$valid_hosts" =~ " $target_host " ]]; then
            echo "Invalid host: $target_host"
            echo "Available hosts: ${toString sysHosts}"
            exit 1
          fi

          echo "PATH: $PATH"
          echo "Running on host: $target_host"

          if [[ "$target_host" == "${config.networking.hostName}" ]]; then
            output=$(run_cmd health 2>&1)
          else
            output=$(run_cmd ssh -tt -o "LogLevel=ERROR" "$target_host" health 2>&1)
          fi

          # Optional: If you want to log the raw output for debugging, you can include this
          # echo "RAW OUTPUT:"
          # echo "$output"

          json_output=$(echo "$output" | sed -n '/^{/,/^}$/p')

          # Only print the formatted output
          echo "$json_output" | ${pkgs.jq}/bin/jq --color-output .
        '';
      };
#==================================#
#==== DEPLOY    #==================#

      deploy = {
        description = "Deploy NixOS configurations to remote hosts";
        aliases = [ "d" ];
        requiresHost = true;
        parameters = [
          { name = "host"; description = "SSH host/IP"; optional = false; }
          { name = "machine"; description = "Target machine name"; optional = true; }
          { name = "user"; description = "SSH username"; optional = true; }
          { name = "hermetic"; description = "Use hermetic activation"; optional = true; }
          { name = "remote"; description = "Use remote build"; optional = true; }
        ];
        code = ''
          echo "🚀 Deploying nixosConfigurations.''$machine"
          echo "👤 SSH User: ''$user"
          echo "🌐 SSH Host: ''$host"
          if [[ -n "''$remote" ]]; then
            echo "🚀 Sending flake to ''$machine via nix copy..."
            ${pkgs.nix}/bin/nix copy .#nixosConfigurations.''$machine.config.system.build.toplevel --to ssh://''$user@''$host
          fi
          if [[ -n "''$hermetic" ]]; then
            echo "🤞 Activating hermetically..."
            ${pkgs.openssh}/bin/ssh $NIX_SSHOPTS -t ''$user@''$host "sudo nixos-rebuild switch --flake .#''$machine"
          else
            echo "🔨 Building locally and activating remotely..."
            ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .#''$machine --target-host ''$user@''$host --use-remote-sudo
          fi
        '';
      };
    };}

    
