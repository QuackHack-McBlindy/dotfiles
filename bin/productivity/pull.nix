# dotfiles/bin/productivity/pull.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ git pull simplified
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let

  sysHosts = builtins.attrNames self.nixosConfigurations;
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.self.config.system.build ? vm
  ) sysHosts;  

in {
  yo.scripts = {
    pull = {
      description = "Pull the latest changes from your dotfiles repo. Resets tracked files to origin/main but keeps local extras.";
      category = "⚡ Productivity";
      parameters = [ 
        { name = "flake"; description = "Path to the directory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; } 
        { name = "host"; description = "Specify host to pull on. Omitting will pull on local machine"; optional = true; }         
      ];
      code = ''
          ${cmdHelpers}
          
          DOTFILES_DIR=''$flake
 
          cd "$DOTFILES_DIR"
          # git checkout -- .
          # checkout_status=$?
          # git pull origin main
          # pull_status=$?

          # 🦆 says ⮞ fetch latest remote changes
          git fetch origin main
          # 🦆 says ⮞ reset tracked files to exactly match repo
          git reset --hard origin/main
          # 🦆 says ⮞ clean untracked files that conflict
          # git clean -fd

          if ! $DRY_RUN; then
              echo " "
              echo " "
              echo "🚀🚀🚀🚀 ✨ "
              echo -e "\n\033[38;5;213m╔══════════════════════════════════════╗"
              echo -e "║  🎉 ✨✨ \033[1;32mSuccessfully pulled dotfiles!\033[0m  \033[38;5;213m ║"
              echo -e "╚══════════════════════════════════════╝\033[0m"
              echo -e "\033[38;5;87m🌍 Repository: $REPO\033[0m"
              echo -e "\033[38;5;154m🌿 Branch: $CURRENT_BRANCH\033[0m\n"       
          else
              echo -e "\033[1;31m [ WARNING! ] \033[0m"
              echo -e "\033[1;31mAn error occurred while pulling the latest changes.\033[0m"
          fi

          #if ! $DRY_RUN; then
          #  if [ $checkout_status -eq 0 ] && [ $pull_status -eq 0 ]; then
          #    echo " "
          #    echo " "
          #    echo "🚀🚀🚀🚀 ✨ "
          #    echo -e "\n\033[38;5;213m╔══════════════════════════════════════╗"
          #    echo -e "║  🎉 ✨✨ \033[1;32mSuccessfully pulled dotfiles!\033[0m  \033[38;5;213m ║"
          #    echo -e "╚══════════════════════════════════════╝\033[0m"
          #    echo -e "\033[38;5;87m🌍 Repository: $REPO\033[0m"
          #    echo -e "\033[38;5;154m🌿 Branch: $CURRENT_BRANCH\033[0m\n"
          #  else
          #    echo -e "\033[1;31m [ WARNING! ] \033[0m"
          #    echo -e "\033[1;31mAn error occurred while pulling the latest changes.\033[0m"
          #  fi
          #fi
      '';      
      voice = { # 🦆 says ⮞ low priority = faser execution? wtf
        enabled = true;
        priority = 5; # 🦆 says ⮞ 1 to 5
        sentences = [
          "(pull|pulla) [på] {host}"
          "(pull|pulla)"          
        ]; # 🦆 says ⮞ lists are in word > out word
        lists = {
          host.values = [          
            { "in" = "[desktop]"; out = "desktop"; }
            { "in" = "[nasty]"; out = "nasty"; }
            { "in" = "[laptop]"; out = "laptop"; }     
            { "in" = "[homie]"; out = "homie"; }     
          ]; # 🦆 says ⮞ search can be anything            
        };
      };
    };  
    
  };}  
