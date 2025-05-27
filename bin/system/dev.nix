# dotfiles/bin/maintenance/health.nix
{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.scripts.dev = {
    description = "Start development enviorment";
    category = "🖥️ System Management";
#    aliases = [ "" ];
    parameters = [
      { name = "devShell"; description = "Development enviorment to open"; optional = false; default = "python"; }
    ];
    code = ''
      ${cmdHelpers}
      target_env="$devShell"
      run_cmd nix develop ${config.this.user.me.dotfilesDir}#"$devShell"
    '';  

  };}
     
