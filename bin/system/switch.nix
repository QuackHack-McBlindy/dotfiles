# dotfiles/bin/system/switch.nix
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
          
          "''${cmd[@]}"
          
          if $DRY_RUN; then
            echo "⚠️ Rebuild Test completed! - No system generation created!"
          else
            echo "✅ Created new system generation!"
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
