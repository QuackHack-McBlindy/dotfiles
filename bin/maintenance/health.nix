# dotfiles/bin/maintenance/health.nix
{ self, config, pkgs, cmdHelpers, ... }:
{  
  yo.scripts.health = {
    description = "Check system health status across your machines";
    keywords = [ "healthcheck" "hälsa" "status" "temp" ];
    category = "🧹 Maintenance";
    aliases = [ "hc" ];
    parameters = [
      { name = "host"; description = "Target hostname for the health check"; optional = false; default = config.this.host.hostname; }
    ];
    code = ''
      ${cmdHelpers}
      target_host="$host"
      if [[ "$target_host" == "$(hostname)" ]]; then
        run_cmd sudo health | jq
      else
        run_cmd ssh "$target_host" sudo health
      fi
    '';  
  };
  
  yo.bitch = { 
    intents = {
      health = {
        data = [{
          sentences = [
            "health check"
            "system status"
            "check health"
            "how is my {host} doing"
            "run health check on {host}"
            "is {host} healthy"    
            "give me {host} health report"
            "show me {host} system stats"
            "check temps on {host}"
            "is {host} overheating"
          
            "kolla hälsan på {host}"
            "hur mår {host}"
            "visa status för {host}"
          ];
          lists = {
            host.values = [
              { "in" = "local"; out = config.this.host.hostname; }
              { "in" = "main"; out = "desktop"; }
              { "in" = "nas"; out = "nasty"; }
              { "in" = "laptop"; out = "laptop"; }
              { "in" = "homie"; out = "homie"; }
              { "in" = "desktop"; out = "desktop"; }
            ];
          };
        }];
      };
    };
  };}
     
