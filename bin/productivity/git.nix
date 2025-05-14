# dotfiles/bin/productivity/git.nix
{ self, config, pkgs, cmdHelpers, ... }:
{
  yo.scripts = {
    pull = {
      description = "Pull the latest changes from your dotfiles repo. Safely resets local state and syncs with origin/main cleanly.";
      category = "⚡ Productivity";
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
              echo -e "\n\033[38;5;213m╔══════════════════════════════════════╗"
              echo -e "║  🎉 ✨✨ \033[1;32mSuccessfully pulled dotfiles!\033[0m  \033[38;5;213m ║"
              echo -e "╚══════════════════════════════════════╝\033[0m"
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
        description = "Commit, tag, and push dotfiles and system state to GitHub. Tags based on host + generation, auto-updates README, and preserves history.";
        category = "⚡ Productivity";
        aliases = [ "ps" ];
        parameters = [
          { name = "flake"; description = "Path to the directory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; } 
          { name = "repo"; description = "User GitHub repo"; optional = false; default = config.this.user.me.repo; } 
          { name = "host"; description = "Target host (for tagging)"; optional = true; }
          { name = "generation"; description = "Generation number to tag"; optional = true; }
        ];
        code = ''
          ${cmdHelpers}
          REPO="$repo"
          DOTFILES_DIR="$flake"
#          generation=""
          
          # Fixed version handling using Nix-provided version
          echo -e "\033[1;34m🔄 Updating README version badge...\033[0m"
          run_cmd update-readme

          # Generation number handling with improved error recovery
          echo -e "\033[1;34m🔍 Checking NixOS generation...\033[0m"
          GENERATION="$generation"  
          echo "📥 Passed generation: $GENERATION"  
  
          if [[ "$GENERATION" =~ ^[0-9]+$ ]]; then
            GEN_NUMBER="$GENERATION"
          else
            echo -e "\033[1;31m❌ Invalid or missing generation number passed to push!\033[0m"
            exit 1
          fi
          
          HOSTNAME="$host"

          # Validate hostname
          if [[ -z "$HOSTNAME" ]]; then
            echo -e "\033[1;31m❌ Hostname not specified!\033[0m"
            exit 1
          fi

          # Validate generation
          if ! [[ "$GEN_NUMBER" =~ ^[0-9]+$ ]]; then
            echo -e "\033[1;31m❌ Invalid generation: $GEN_NUMBER\033[0m"
            exit 1
          fi

          if [[ ! "$HOSTNAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
            echo -e "\033[1;31m❌ Invalid hostname: '$HOSTNAME'\033[0m"
            exit 1
          fi

          TAG_NAME="$HOSTNAME-generation-$GEN_NUMBER"
         
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
          

          echo -e "\033[1;34m🏷  Tagging commit as $TAG_NAME\033[0m"
          run_cmd git tag -fa "$TAG_NAME" -m "NixOS generation $GEN_NUMBER ($HOSTNAME)"

          # Modify push command to include tags
          run_cmd echo -e "\033[1;34m🚀 Pushing to $CURRENT_BRANCH branch with tags...\033[0m"
          
          run_cmd git push --follow-tags -u origin "$CURRENT_BRANCH"
#          run_cmd git push origin "$TAG_NAME"
          run_cmd git push --force origin "$TAG_NAME"
                
          # Fancy success message
          run_cmd echo -e "\n\033[38;5;213m╔══════════════════════════════════════╗"
          run_cmd echo -e "║  🎉  \033[1;32mSuccessfully pushed dotfiles!\033[0m  \033[38;5;213m ║"
          run_cmd echo -e "╚══════════════════════════════════════╝\033[0m"
          run_cmd echo -e "\033[38;5;87m🌍 Repository: $REPO\033[0m"
          run_cmd echo -e "\033[38;5;154m🌿 Branch: $CURRENT_BRANCH\033[0m\n"
        '';
      };};}
