# bin/rollback.nix
{ pkgs, cmdHelpers, ... }:
{
    yo.scripts = {
      rollback = {
        description = "Synchronized system+config rollback";
#        aliases = [ "rb" ];
        code = ''
          ${cmdHelpers}
    
          echo "🔄 Listing synchronized generations:"
          git -C /etc/nixos tag -l 'generation-*' | while read tag; do
            gen=''${tag#generation-}
            commit=$(git -C /etc/nixos rev-list -n 1 $tag)
            printf "%-10s %s %s\n" "Generation $gen:" "($(date -d @$(git -C /etc/nixos show -s --format=%ct $commit)))" "$(git -C /etc/nixos show -s --format=%s $commit | head -1)"
          done

          read -p "🚦 Enter generation number to rollback: " GEN_NUM
    
          # Nix rollback
          if ! ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --switch-generation $GEN_NUM; then
            echo "❌ Nix rollback failed!"
            exit 1
          fi
    
          # Git rollback
          TAG="generation-$GEN_NUM"
          if ! git -C /etc/nixos checkout $TAG -- .; then
            echo "❌ Git rollback failed! Restoring Nix generation..."
            ${pkgs.nix}/bin/nix-env --switch-generation previous
            exit 1
          fi
    
          echo "✅ Dual rollback complete! Rebuilding system..."
          ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch
        '';
      };
    };}  

