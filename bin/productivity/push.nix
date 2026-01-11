# dotfiles/bin/productivity/push.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {
  yo = {
    scripts = {
      push = {
        description = "Commit, tag, and push dotfiles and system state to GitHub. Tags based on host + generation, auto-updates README, and preserves history.";
        category = "⚡ Productivity";
        aliases = [ "ps" ];
        parameters = [
          { name = "flake"; description = "Path to the directory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; } 
          { name = "repo"; description = "User GitHub repo"; optional = false; default = config.this.user.me.repo; } 
          { name = "host"; description = "Target host (for tagging)"; optional = true; default = "$HOSTNAME"; }
          { name = "generation"; description = "Generation number to tag"; optional = true; default = ""; }
        ];
        code = ''
          ${cmdHelpers}
          REPO="$repo"
          DOTFILES_DIR="$flake"

          if [[ -n "''$host" ]]; then
            HOSTNAME="$host"
          else
            HOSTNAME=$(hostname -s)
            echo -e "\033[1;34m🖥️  Auto-detected hostname: $HOSTNAME\033[0m"
          fi

      
          echo -e "\033[1;34m🔍 Checking NixOS generation...\033[0m"
          if [[ -z "''${generation}" ]]; then
            # 🦆 says ⮞ Get numeric generation ID using nix-env
            GENERATION=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n1 | awk '{print $1}')
            echo -e "\033[1;34m📥 Automatically detected generation: $GENERATION\033[0m"
          else
            GENERATION="$generation"
            echo "📥 Passed generation: $GENERATION"
          fi

          # 🦆 says ⮞ validate generation format
          if ! [[ "$GENERATION" =~ ^[0-9]+$ ]]; then
            echo -e "\033[1;31m❌ Invalid generation: $GENERATION\033[0m"
            exit 1
          fi
          
          echo -e "\033[1;34m🔄 Updating README version badge...\033[0m"
          yo update-readme

          # 🦆 says ⮞ generation number
          if [[ -n "$generation" ]]; then
            GENERATION="$generation"
            echo "📥 Passed generation: $GENERATION"
          else 
            echo "📥 Using auto-detected generation: $GENERATION"
          fi
 
 
          if [[ "$GENERATION" =~ ^[0-9]+$ ]]; then
            GEN_NUMBER="$GENERATION"
          else
            echo -e "\033[1;31m❌ Invalid or missing generation number passed to push!\033[0m"
            exit 1
          fi
          
          HOSTNAME="$host"

          # 🦆 says ⮞ validate hostname
          if [[ -z "$HOSTNAME" ]]; then
            echo -e "\033[1;31m❌ Hostname not specified!\033[0m"
            exit 1
          fi

          # 🦆 says ⮞ Validate generation
          if ! [[ "$GEN_NUMBER" =~ ^[0-9]+$ ]]; then
            echo -e "\033[1;31m❌ Invalid generation: $GEN_NUMBER\033[0m"
            exit 1
          fi

#          if [[ ! "$HOSTNAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
#            echo -e "\033[1;31m❌ Invalid hostname: '$HOSTNAME'\033[0m"
#            exit 1
#          fi

          TAG_NAME="$HOSTNAME-generation-$GEN_NUMBER"
         
          COMMIT_MSG="Autocommit: Generation $GEN_NUMBER"  
          cd "$DOTFILES_DIR"
          
          if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo -e "\033[1;33m⚡ Initializing new Git repository\033[0m"
            git init
            if [ "$(git symbolic-ref --short -q HEAD)" != "main" ]; then
              git checkout -B main
            fi
          fi
          
          CURRENT_URL=$(git remote get-url origin 2>/dev/null || true)
          if [ -z "$CURRENT_URL" ]; then
            echo -e "\033[1;33m🌍 Adding remote origin: $REPO\033[0m"
            git remote add origin "$REPO"
          elif [ "$CURRENT_URL" != "$REPO" ]; then
            echo -e "\033[1;33m🔄 Updating remote origin URL to: $REPO\033[0m"
            git remote set-url origin "$REPO"
          fi
          
          if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
            if [ -z "$(git status --porcelain)" ]; then
              echo -e "\033[1;31m❌ Error: No files to commit in new repository\033[0m"
              exit 1
            fi
            echo -e "\033[1;33m✨ Creating initial commit\033[0m"
            git add .
            git commit -m "Initial commit"
          fi
          
          CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
          if [ "$CURRENT_BRANCH" = "HEAD" ]; then
            echo -e "\033[1;33m🌱 Creating new main branch from detached HEAD\033[0m"
            git checkout -b main
            CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
          fi
          
          if [ -z "$(git status --porcelain)" ]; then
            echo -e "\033[1;36m🎉 No changes to commit\033[0m"
            exit 0
          fi

          echo -e "\033[1;34m📦 Staging changes...\033[0m"
          git add .
          
          echo -e "\033[1;34m📋 Generating change summary...\033[0m"
          DIFF_STAT=$(git diff --staged --stat)
          
          echo -e "\033[1;34m💾 Committing changes: $COMMIT_MSG\033[0m"
          git commit -m "$COMMIT_MSG" -m "Changed files:\n$DIFF_STAT"
          

          echo -e "\033[1;34m🏷  Tagging commit as $TAG_NAME\033[0m"
          git tag -fa "$TAG_NAME" -m "NixOS generation $GEN_NUMBER ($HOSTNAME)"

          run_cmd echo -e "\033[1;34m🚀 Pushing to $CURRENT_BRANCH branch with tags...\033[0m"
          
          git push --force --follow-tags -u origin "$CURRENT_BRANCH"
#          run_cmd git push origin "$TAG_NAME"
          git push --force origin "$TAG_NAME"
                
          # 🦆 says ⮞ success message
          echo -e "\n\033[38;5;213m╔══════════════════════════════════════╗"
          echo -e "║  🎉  \033[1;32mSuccessfully pushed dotfiles!\033[0m  \033[38;5;213m ║"
          echo -e "╚══════════════════════════════════════╝\033[0m"
          echo -e "\033[38;5;87m🌍 Repository: $REPO\033[0m"
          echo -e "\033[38;5;154m🌿 Branch: $CURRENT_BRANCH\033[0m\n"
        '';
      };
    };
    
  };}
