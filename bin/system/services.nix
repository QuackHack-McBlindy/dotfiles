# dotfiles/bin/system/services.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ systemd service handler
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
    services = {
      description = "Systemd service handler.";
      category = "🖥️ System Management";
      parameters = [
        { name = "operation"; description = "Operational mode of the service. (start, stop, restart)"; optional = false; } 
        { name = "service"; description = "Service name to manage"; optional = false; }           
        { name = "host"; description = "Host machine to build and activate"; optional = false; }
        { name = "user"; description = "SSH username"; optional = true; default = config.this.user.me.name; } 
        { name = "port"; type = "int"; description = "SSH port"; optional = true; default = 2222; }
        { name = "!"; description = "Test mode (does not save new NixOS generation)"; optional = true; }
      ];
      code = ''   
        ${cmdHelpers}

        if [[ ! " ${toString sysHosts} " =~ " $host " ]]; then
          say_duck "fuck ❌ Unknown host: $host" >&2
          echo "Available hosts: ${toString sysHosts}" >&2
          exit 1
        fi
       
        get_services() {
          ssh $host 'systemctl list-unit-files --type=service --no-pager --no-legend | awk "{print \$1}" | sed "s/\.service$//"'
        }
       
        # 🦆 duck say ⮞ 1: get service names
        mapfile -t services < <(get_services)
       
        # 🦆 duck say ⮞ 2: fuzzy match input against services
        best=""
        best_score=0
        for s in "''${services[@]}"; do
          score=$(levenshtein_similarity "$(normalize_string "$service")" "$(normalize_string "$s")")
          (( score > best_score )) && { best_score=$score; best=$s; }
        done

        if [[ -z "$best" ]]; then
          dt_error "No service match found for '$service' on $host"
          exit 1
        fi

        dt_info "Closest match: $best ($best_score%)"
        [[ "$best_score" -lt 50 ]] && dt_info "Low confidence ($best_score) - continuing anyway..."
    
        # 🦆 duck say ⮞ 3: start/stop/restart best matched service on specified host
        ssh "$host" "sudo systemctl $operation $best.service"
        dt_info "'$best' $operation issued on $host"              
 
      '';
      voice = {
        enabled = false;
        priority = 4;
        sentences = [
          "{operation} {service} på {host}"
        ];
        lists = {
          operation.values = [
            { "in" = "[start|starta]"; out = "start"; }
            { "in" = "[stop|stoppa]"; out = "stop"; }  
            { "in" = "[restart|restarta|omstart|omstarta]"; out = "restart"; }      
          ];
          host.values = [
            { "in" = "[desktop]"; out = "desktop"; }
            { "in" = "[homie]"; out = "homie"; }  
            { "in" = "[nasty]"; out = "nasty"; }      
          ];         
          service.wildcard = true;
        };
      };  
    };  
     
  };}
