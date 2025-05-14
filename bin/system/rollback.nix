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
          DOTFILES_DIR="$flake"
          echo "🔄 Fetching tags for $host..."
          sudo git -C "$DOTFILES_DIR" fetch --tags --force

          echo "📜 Available generations for $host:"
          sudo git -C "$DOTFILES_DIR" tag -l "$host-generation-*" --sort=-v:refname | while read tag; do
            gen=''${tag#$host-generation-}
            commit=$(sudo git -C "$DOTFILES_DIR" rev-list -n 1 $tag)
            printf "%-10s %s %s\n" "Generation $gen:" \
              "($(date -d @$(sudo git -C "$DOTFILES_DIR" show -s --format=%ct $commit))" \
              "$(sudo git -C "$DOTFILES_DIR" show -s --format=%s $commit | head -1)"
          done

          read -p "🚦 Enter generation number: " GEN_NUM
          TAG_NAME="$host-generation-$GEN_NUM"

          if ! sudo git -C "$DOTFILES_DIR" rev-parse "$TAG_NAME" >/dev/null 2>&1; then
            echo "❌ Tag $TAG_NAME not found!"
            exit 1
          fi

          # Checkout tagged configuration
          echo "🔙 Checking out $TAG_NAME..."
          sudo git -C "$DOTFILES_DIR" checkout "$TAG_NAME" -- .

          # Switch system generation on host
          echo "🔄 Switching to generation $GEN_NUM on $host..."
          ssh -o StrictHostKeyChecking=no "$user@$host" \
            "sudo nix-env -p /nix/var/nix/profiles/system --switch-generation $GEN_NUM && sudo /nix/var/nix/profiles/system/$GEN_NUM/activate"

          echo "✅ Rollback to generation $GEN_NUM complete!"
        '';
      };
    };}  

