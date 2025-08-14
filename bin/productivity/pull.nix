# dotfiles/bin/productivity/pull.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
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
    
  };}  
