# dotfiles/bin/system/rollback.nix
{ config, pkgs, cmdHelpers, ... }:
{
    yo.scripts = {
      rollback = {
        description = "Rollback a host to a previous NixOS generation. Fetches Git tags and reverts system+config to a synced, tagged state.";
        category = "🛠 System Management";
        parameters = [
          { name = "host"; description = "Host to rollback"; optional = false; }
          { name = "flake"; description = "Path to the directory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; } 
          { name = "user"; description = "SSH user"; optional = true; default = config.this.user.me.name; }
        ];  
        code = ''
          ${cmdHelpers}
          DOTFILES_DIR="$flake"
        
          # Validate flake directory
          if [ ! -d "$DOTFILES_DIR/.git" ]; then
            echo -e "\033[1;31m❌ Not a Git repository: $DOTFILES_DIR\033[0m"
            exit 1
          fi

          echo "🔄 Fetching latest tags..."
          run_cmd git -C "$DOTFILES_DIR" fetch --tags --force

          echo "📜 Available generations for $host:"
          git -C "$DOTFILES_DIR" tag -l "$host-generation-*" --sort=-v:refname | while read tag; do
            gen=''${tag#$host-generation-}
            commit=$(git -C "$DOTFILES_DIR" rev-list -n 1 $tag)
            printf "%-10s %s %s\n" "Generation $gen:" \
              "($(date -d @$(git -C "$DOTFILES_DIR" show -s --format=%ct $commit))" \
              "$(git -C "$DOTFILES_DIR" show -s --format=%s $commit | head -1)"
          done

          read -p "🚦 Enter generation number: " GEN_NUM
          TAG_NAME="$host-generation-$GEN_NUM"

          # Verify tag exists
          if ! git -C "$DOTFILES_DIR" rev-parse "$TAG_NAME" >/dev/null 2>&1; then
            echo -e "\033[1;31m❌ Tag $TAG_NAME not found!\033[0m"
            exit 1
          fi

          # Stash local changes to preserve work
          if ! git -C "$DOTFILES_DIR" diff --quiet; then
            echo "📦 Stashing local changes..."
            run_cmd git -C "$DOTFILES_DIR" stash push --include-untracked
          fi

          # Checkout tag in detached HEAD state
          echo "🔙 Checking out $TAG_NAME..."
          run_cmd git -C "$DOTFILES_DIR" checkout --detach "$TAG_NAME"

          # Sync to remote host
          echo "🔄 Synchronizing $host's repository..."
          run_cmd ssh "$user@$host" "
            cd '$DOTFILES_DIR'
            git fetch --tags --force
            git checkout --detach '$TAG_NAME'
          "

          # Activate system generation
          echo "⚡ Activating generation $GEN_NUM..."
          run_cmd ssh "$user@$host" \
            "sudo nix-env -p /nix/var/nix/profiles/system --switch-generation $GEN_NUM && 
             sudo /nix/var/nix/profiles/system/$GEN_NUM/activate"

          echo -e "\n\033[1;32m✅ Successfully rolled back $host to generation $GEN_NUM\033[0m"
          echo -e "\033[38;5;154m🔖 Tag: $TAG_NAME\033[0m"
          echo -e "\033[38;5;244m💡 Note: Local repository is in detached HEAD state. Use 'git checkout main' to resume development.\033[0m"
        '';
      };
    };}  

