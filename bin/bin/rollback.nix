# bin/rollback.nix
{ pkgs, cmdHelpers, ... }:
{
    yo.scripts = {
      rollback = {
        description = "Synchronized system+config rollback";
#        aliases = [ "rb" ];
        code = ''
          ${cmdHelpers}
        
          DOTFILES_DIR="/etc/nixos"  # Should match your push target
         
          echo "🔄 Fetching latest tags from remote..."
          git -C "$DOTFILES_DIR" fetch --tags --force
        
          echo "📜 Listing synchronized generations:"
          git -C "$DOTFILES_DIR" tag -l 'generation-*' --sort=-v:refname | while read tag; do
            gen=''${tag#generation-}
            commit=$(git -C "$DOTFILES_DIR" rev-list -n 1 $tag)
            printf "%-10s %s %s\n" "Generation $gen:" \
              "($(date -d @$(git -C "$DOTFILES_DIR" show -s --format=%ct $commit)))" \
              "$(git -C "$DOTFILES_DIR" show -s --format=%s $commit | head -1)"
          done

          read -p "🚦 Enter generation number to rollback: " GEN_NUM
        
          # Verify tag exists
          if ! git -C "$DOTFILES_DIR" rev-parse "generation-$GEN_NUM" >/dev/null 2>&1; then
            echo "❌ No tag found for generation $GEN_NUM"
            exit 1
          fi

          # Atomic rollback sequence
          {
            # System rollback
            ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --switch-generation "$GEN_NUM" &&
          
            # Config rollback
            git -C "$DOTFILES_DIR" checkout "generation-$GEN_NUM" -- . &&
          
            # Rebuild
            echo "🔨 Rebuilding system..."
            ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch
          } || {
            echo "❌ Rollback failed! Restoring previous generation..."
            ${pkgs.nix}/bin/nix-env --switch-generation previous
            git -C "$DOTFILES_DIR" reset --hard HEAD
            exit 1
          }
        
          echo "✅ Dual rollback complete!"
        '';
      };
    };}  

