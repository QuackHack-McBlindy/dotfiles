# dotfiles/bin/maintenance/health.nix
{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.scripts.health = {
    description = "Check system health status across your machines";
    category = "🧹 Maintenance";
    aliases = [ "hc" ];
    parameters = [
      { name = "host"; description = "Target hostname for the health check"; optional = true; default = config.this.host.hostname; }
    ];
    code = ''
      ${cmdHelpers}
      target_host="''${host:-$(hostname)}"
      if [[ "$target_host" == "$(hostname)" ]]; then
        run_cmd sudo health | jq
      else
        run_cmd ssh "$target_host" sudo health
      fi
    '';
  };}
     
