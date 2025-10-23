# dotfiles/bin/maintenance/health.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ systemwide health checks  
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let   
in { # 🦆 says ⮞  
  yo.scripts.health = {
    description = "Check system health status across your machines. Returns JSON structured responses.";
    category = "🧹 Maintenance";
    aliases = [ "hc" ];
    parameters = [
      { name = "host"; description = "Target hostname for the health check"; optional = false; default = config.this.host.hostname; }
    ];
    code = ''
      ${cmdHelpers}
      target_host="$host"
      if [[ "$target_host" == "$(hostname)" ]]; then
        sudo health | jq
      else
        ssh "$target_host" sudo health | jq
      fi
    '';  
    voice = {
      priority = 4;
      sentences = [
        "kolla hälsan på {host}"
        "hur mår {host}"
        "mår {host} okej"
        "visa status för {host}"
      ];
      lists = {
        host.values = [
          { "in" = "[desktop|datorn]"; out = "desktop"; }
          { "in" = "nas"; out = "nasty"; }
          { "in" = "laptop"; out = "laptop"; }
          { "in" = "homie"; out = "homie"; }
        ];
      };   
    };  
  };}
     
