# bin/switch.nix
{ pkgs, cmdHelpers, ... }:
{
    yo.scripts = {
      switch = {
        description = "Rebuild and switch Nix OS system configuration";
        aliases = [ "rb" ];
        parameters = [
          { name = "flake"; description = "Path to the irectory containing your flake.nix"; optional = false; default = config.this.user.me.dotfilesDir; } 
          { name = "autoPull"; description = "Wether dotfiles should be re-pulled before rebuilding the system configuration"; optional = true; default = builtins.toString config.this.host.autoPull; } 
        ];
        code = ''
          ${cmdHelpers}
          if [ "$autoPull" = "true" ] && [ -d "$flake/.git" ]; then
            run_cmd yo pull
          fi
          run_cmd sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ''$flake --show-trace
        '';
      };
    };}
