# dotfiles/bin/system/switch.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let

in {
  yo = {
    scripts = {
      switch = {
        description = "Rebuild and switch Nix OS system configuration. ('!' to test)";
        category = "🖥️ System Management";
#        aliases = [ "rb" ];
        parameters = [
          { name = "flake"; description = "Path to the irectory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; } 
          { name = "!"; description = "Test mode (does not save new NixOS generation)"; optional = true; }
        ];
        code = ''
          ${cmdHelpers}      
          if $DRY_RUN; then
            echo "❗ Test run: reboot will revert activation"
          fi

          FAIL_COUNT_FILE="/tmp/nixos_rebuild_fail_count"
          
          if [[ -f "$FAIL_COUNT_FILE" ]]; then
            FAIL_COUNT=$(cat "$FAIL_COUNT_FILE")
          else
            FAIL_COUNT=0
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
            if [[ $FAIL_COUNT -ge 11 ]]; then
              dt_info "🦆🎉 ! Rebuild sucessful! $FAIL_COUNT noob fails!"
              play_relax
            elif [[ $FAIL_COUNT -ge 5 ]]; then
              dt_info "😅 phew! $FAIL_COUNT noob fails!"
              play_win
            else
              if $DRY_RUN; then
                say_duck " ⚠️ Rebuild Test completed! - No system generation created!"
              else
                say_duck " ✅ Created new system generation!"
              fi
              play_win
            fi
            echo 0 > "$FAIL_COUNT_FILE"
          else
            FAIL_COUNT=$((FAIL_COUNT + 1))
            echo "$FAIL_COUNT" > "$FAIL_COUNT_FILE"
            
            if [[ $FAIL_COUNT -ge 5 ]]; then
              say_duck "fuck ❌ System rebuild failed!"
              play_fail3
            elif [[ $FAIL_COUNT -ge 3 ]]; then
              say_duck "fuck ❌ System rebuild failed!"
              play_fail2
            else
              say_duck "fuck ❌ System rebuild failed!"
              play_fail
            fi
            exit 1
          fi
        ''; 
        voice = {
          enabled = true;
          priority = 5;
          fuzzy.enable = false;
          sentences = [
            "bygg om systemet"
          ];        
        };
      };
    }; 
    
  };}
