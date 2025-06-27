# dotfiles/bin/system/switch.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ self, config, pkgs, cmdHelpers, ... }:
{
    yo.scripts = {
      switch = {
        description = "Rebuild and switch Nix OS system configuration";
        category = "🖥️ System Management";
        aliases = [ "rb" ];
        parameters = [
          { name = "flake"; description = "Path to the irectory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; } 
          { name = "!"; description = "Test mode (does not save new NixOS generation)"; optional = true; }
        ];
        code = ''
          ${cmdHelpers}      
          if $DRY_RUN; then
            echo "❗ Test run: reboot will revert activation"
          fi
  
          if $DRY_RUN; then
            rebuild_command="test"
          else
            rebuild_command="switch"
          fi
          cmd=(
            sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild
            $rebuild_command
              --flake "$flake"
              --show-trace
          )
          
          if "''${cmd[@]}"; then
            if $DRY_RUN; then
              say_duck " ⚠️ Rebuild Test completed! - No system generation created!"
            else
              say_duck " ✅ Created new system generation!"
              play_win
            fi
          else
            say_duck "fuck ❌ System rebuild failed!"
            play_fail
            exit 1
          fi 
        '';
      };
    };
    
    
    yo.bitch = { 
      intents = {
        switch = {
          data = [{
            sentences = [
              "rebuild system"    
              "bygg om systemet"
            ];
            lists = {
             # mode.values = [
                # Direct matches
               # { "in" = "on"; out = "on"; }
          #    ];
            };
          }];
        };
      };
      
    };}
