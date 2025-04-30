# bin/health.nix
{ self, config, pkgs, cmdHelpers, ... }:
{
  yo.scripts = {
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
              run_cmd echo -e "\n\033[38;5;213m╔══════════════════════════════════════╗"
              run_cmd echo -e "║  🎉 ✨✨ \033[1;32mSuccessfully pulled dotfiles!\033[0m  \033[38;5;213m ║"
              run_cmd echo -e "╚══════════════════════════════════════╝\033[0m"
              run_cmd echo -e "\033[38;5;87m🌍 Repository: $REPO\033[0m"
              run_cmd echo -e "\033[38;5;154m🌿 Branch: $CURRENT_BRANCH\033[0m\n"
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
          
           # Fixed version handling using Nix-provided version
          echo -e "\033[1;34m🔄 Updating README version badge...\033[0m"
          run_cmd update-readme

          # Generation number handling with improved error recovery
          echo -e "\033[1;34m🔍 Checking NixOS generation...\033[0m"
          GEN_NUMBER=$({
            sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null ||
            nix-env --list-generations -p "/nix/var/nix/profiles/per-user/$USER/home-manager" 2>/dev/null ||
            echo "unknown"
          } | tail -n 1 | awk '{print $1}')
#          GEN_NUMBER=$(sudo nix-env --list-generations -p /nix/var/nix/profiles/system | tail -n1 | awk '{print $1}')
          
          COMMIT_MSG="Autocommit: Generation $GEN_NUMBER"  
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

          # When committing changes - Change 2: Add detailed commit message
          echo -e "\033[1;34m📦 Staging changes...\033[0m"
          run_cmd git add .
          
          # Add these lines for detailed commit message
          echo -e "\033[1;34m📋 Generating change summary...\033[0m"
          DIFF_STAT=$(git diff --staged --stat)
          
          # Modified commit command
          echo -e "\033[1;34m💾 Committing changes: $COMMIT_MSG\033[0m"
          run_cmd git commit -m "$COMMIT_MSG" -m "Changed files:\n$DIFF_STAT"  # Replace existing commit line
          
          # Change 3: Add tagging after commit
          echo -e "\033[1;34m🏷  Tagging commit as gen-$GEN_NUMBER\033[0m"
          run_cmd git tag -fa "gen-$GEN_NUMBER" -m "NixOS generation $GEN_NUMBER"

          # Modify push command to include tags
          run_cmd echo -e "\033[1;34m🚀 Pushing to $CURRENT_BRANCH branch with tags...\033[0m"
          run_cmd git push -u origin "$CURRENT_BRANCH" --tags || {  # Add --tags to existing push command
            run_cmd echo -e "\033[1;31m❌ Push failed\033[0m"
            exit 1
          }
          
          # Fancy success message
          run_cmd echo -e "\n\033[38;5;213m╔══════════════════════════════════════╗"
          run_cmd echo -e "║  🎉  \033[1;32mSuccessfully pushed dotfiles!\033[0m  \033[38;5;213m ║"
          run_cmd echo -e "╚══════════════════════════════════════╝\033[0m"
          run_cmd echo -e "\033[38;5;87m🌍 Repository: $REPO\033[0m"
          run_cmd echo -e "\033[38;5;154m🌿 Branch: $CURRENT_BRANCH\033[0m\n"
        '';
      };};}
