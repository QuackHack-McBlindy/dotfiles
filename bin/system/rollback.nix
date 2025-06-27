# dotfiles/bin/system/rollback.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles

{ config, pkgs, cmdHelpers, ... }:
{
    yo.scripts = {
      rollback = {
        description = "Rollback a host to a previous NixOS generation. Fetches Git tags and reverts system+config to a synced, tagged state.";
        category = "🖥️ System Management";
        parameters = [
          { name = "host"; description = "Host to rollback"; optional = false; }
          { name = "flake"; description = "Path to the directory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; } 
          { name = "user"; description = "SSH user"; optional = true; default = config.this.user.me.name; }
        ]; 
        helpFooter = ''

       '';
        code = ''
          DOTFILES_DIR="$flake"
          echo "🔄 Fetching tags for $host..."
          git -C "$DOTFILES_DIR" fetch --tags --force
        
          echo "📜 Available generations for $host:"
          git -C "$DOTFILES_DIR" tag -l "$host-generation-*" --sort=-v:refname | while read tag; do
            gen=''${tag#$host-generation-}
            commit=$(git -C "$DOTFILES_DIR" rev-list -n 1 "$tag")
            printf "%-15s %s %s\n" "Generation $gen:" \
              "($(date -d @$(git -C "$DOTFILES_DIR" show -s --format=%ct "$commit"))" \
              "$(git -C "$DOTFILES_DIR" show -s --format=%s "$commit" | head -1)"
          done
        
          read -p "🚦 Enter generation number: " GEN_NUM
          TAG_NAME="$host-generation-$GEN_NUM"
        
          echo "🔄 Rolling back $host to $TAG_NAME..."
        
          ssh -o StrictHostKeyChecking=no "$user@$host" bash -s -- "$flake" "$TAG_NAME" "$GEN_NUM" <<'EOF'
            set -e
        
            DOTFILES_DIR="$1"
            TAG_NAME="$2"
            GEN_NUM="$3"
        
            echo "🔄 Fetching tags on \$(hostname)..."
            git -C "$DOTFILES_DIR" fetch --tags --force
        
            if ! git -C "$DOTFILES_DIR" rev-parse "$TAG_NAME" >/dev/null 2>&1; then
              echo "❌ Tag $TAG_NAME not found on remote!"
              exit 1
            fi
        
            echo "🔙 Checking out $TAG_NAME on remote..."
            git -C "$DOTFILES_DIR" checkout "$TAG_NAME"
        
            echo "🔄 Switching to NixOS generation $GEN_NUM..."
#            sudo nix-env -p /nix/var/nix/profiles/system --switch-generation "$GEN_NUM"
#            sudo /nix/var/nix/profiles/system/"$GEN_NUM"/activate
#            sudo nix-env -p /nix/var/nix/profiles/system --switch-generation "$GEN_NUM"
#            sudo /nix/var/nix/profiles/system/"$GEN_NUM"/activate

            sudo /etc/profiles/per-user/pungkula/bin/rollback "$GEN_NUM"

  
            echo "✅ Remote rollback to generation $GEN_NUM complete!"
        EOF
        '';
        
     
      };
    };}  

