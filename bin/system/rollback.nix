# dotfiles/bin/system/rollback.nix
{ config, pkgs, cmdHelpers, ... }:
{
    yo.scripts = {
      rollback = {
        description = "Synchronized system+config rollback";
        parameters = [
          { name = "flake"; description = "Path to the directory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; } 
        ];  
        code = ''
          ${cmdHelpers}
        
          DOTFILES_DIR="$flake"
          echo "🔄 Fetching latest tags from remote..."
          sudo git -C "$DOTFILES_DIR" fetch --tags --force
        
          echo "📜 Listing generations:"
          sudo git -C "$DOTFILES_DIR" tag -l 'generation-*' --sort=-v:refname | while read tag; do
            gen=''${tag#generation-}
            commit=$(sudo git -C "$DOTFILES_DIR" rev-list -n 1 $tag)
            printf "%-10s %s %s\n" "Generation $gen:" \
              "($(date -d @$(sudo git -C "$DOTFILES_DIR" show -s --format=%ct $commit)))" \
              "$(sudo git -C "$DOTFILES_DIR" show -s --format=%s $commit | head -1)"
          done

          read -p "🚦 Enter generation number: " GEN_NUM
        
          if ! sudo git -C "$DOTFILES_DIR" rev-parse "generation-$GEN_NUM" >/dev/null 2>&1; then
            echo "❌ No tag found for generation $GEN_NUM"
            exit 1
          fi
 
          {
            # System rollback
            echo "🔧 Rolling back system..."
            sudo ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --switch-generation "$GEN_NUM" &&
          
            # Config rollback
            echo "📁 Rolling back config..."
            sudo git -C "$DOTFILES_DIR" checkout "generation-$GEN_NUM" -- . &&
          
            # Rebuild
            echo "🔨 Rebuilding..."
            sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch
          } || {
            echo "❌ Rollback failed! Restoring..."
            sudo ${pkgs.nix}/bin/nix-env --switch-generation previous
            sudo git -C "$DOTFILES_DIR" reset --hard HEAD
            exit 1
          }
        
          echo "✅ Dual rollback complete!"
        '';
      };
    };}  

