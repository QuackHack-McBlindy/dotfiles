# dotfiles/bin/maintenance/duckTrace.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ bringing logs back to da cool table  
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ get hosts 
  sysHosts = builtins.attrNames self.nixosConfigurations;
  vmHosts = builtins.filter (host:
    self.nixosConfigurations.${host}.self.config.system.build ? vm
  ) sysHosts;  
in {   
  yo.scripts.duckTrace = {
    description = "View duckTrace logs quick and quack, unified logging system";
    aliases = [ "log" ];    
    category = "🖥️ System Management";
#    helpFooter = '' # 🦆 says ⮞ display log file in markdown with Glow
#    '';
    parameters = [ 
      { name = "script"; description = "View specified yo scripts logs"; optional = true; } 
      { name = "host"; description = "Specify optional host to browse the logs from"; optional = true; }
    ]; 
    code = ''
      ${cmdHelpers} # 🦆 says ⮞ load default helper functions 
      LOGFILE="$file"
      unset BOLD ITALIC UNDERLINE    
      PAGER=''${PAGER:-less -R}
      export GUM_CHOOSE_CURSOR="🦆 ➤ "  
      export GUM_CHOOSE_CURSOR_FOREGROUND="214" 
      export GUM_CHOOSE_HEADER="[🦆📜] duckTrace" 

      if [[ ! " ${toString sysHosts} " =~ " $host " ]]; then
        say_duck "fuck ❌ Invalid host: $host"
        echo "Available hosts: ${toString sysHosts}" >&2
        dt_error "Invalid host: $host"
        exit 1
      fi

      get_service_name() {
        local log_base
        log_base=$(basename "$LOGFILE" .log)
        # 🦆 says ⮞ remove yo.scripts prefix if present
        if [[ "$log_base" == yo.scripts.* ]]; then
          echo "yo-''${log_base#yo.scripts.}.service"
        else
          echo "yo-$log_base.service"
        fi
      }

      systemd_log() {
        local service
        service=$(get_service_name)
        ${pkgs.systemd}/bin/journalctl -u "$service" -f
      }

      restart_service() {
        local service
        service=$(get_service_name)
        ${pkgs.systemd}/bin/systemctl restart "$service"
        ${pkgs.gum}/bin/gum spin --spinner line --title "Restarting $service" -- sleep 2
        ${pkgs.gum}/bin/gum format --theme=pink "# Service restarted!" 
      }

      start_service() {
        local service
        service=$(get_service_name)
        ${pkgs.systemd}/bin/systemctl start "$service"
        ${pkgs.gum}/bin/gum spin --spinner line --title "Starting $service" -- sleep 2
        ${pkgs.gum}/bin/gum format --theme=green "# Service started!"
      }

      stop_service() {
        local service
        service=$(get_service_name)
        ${pkgs.systemd}/bin/systemctl stop "$service"
        ${pkgs.gum}/bin/gum spin --spinner line --title "Stopping $service" -- sleep 2
        ${pkgs.gum}/bin/gum format --theme=red "# Service stopped!"
      }

      edit_script() {
        local script_name
        script_name=$(basename "$LOGFILE" .log)

        script_name=''${script_name#yo.scripts.}
        local script_path="$HOME/dotfiles/bin/$script_name.nix"
        
        if [[ -f "$script_path" ]]; then
          ${pkgs.gum}/bin/gum format "# Editing $script_path"
          ${pkgs.vim}/bin/vim "$script_path"
        else
          ${pkgs.gum}/bin/gum format --theme=red "# Script not found!"
          ${pkgs.gum}/bin/gum format "Couldn't find: $script_path"
        fi
      }

      menu() {
        while true; do
          selection=$(${pkgs.gum}/bin/gum choose \
            "View systemd log" \
            "Restart service" \
            "Start service" \
            "Stop service" \
            "Print log" \
            "Edit yo script" \
            "🚫 Exit")
         case "$selection" in
            "View systemd log") systemd_log ;;            
            "Restart service") restart_service ;;
            "Start service") start_service ;;                 
            "Stop service") stop_service ;;
            "Print log") cat "$LOGFILE" ;;
            "Edit yo script") edit_script ;;
            "🚫 Exit") exit 0 ;;
          esac
        done
      }


      if [[ -z "$LOGFILE" ]]; then
        cd "$DT_LOG_PATH" || exit 1
        FILES=($(${pkgs.findutils}/bin/find . -type f -size +0c -printf '%f\n'))
        if [[ ''${#FILES[@]} -eq 0 ]]; then
          dt_error "No log files found in $DT_LOG_PATH"
          exit 1
        fi

        LOGFILE=$(printf "%s\n" "''${FILES[@]}" | \
          fzf --preview="tac {}" --preview-window=right:70%:wrap \
              --prompt="🦆 Pick a log: " --border)

        if [[ -z "$LOGFILE" ]]; then
          dt_info "No log file selected."
          exit 0
        fi
        LOGFILE="$DT_LOG_PATH/$LOGFILE"
      else
        if [[ ! -f "$LOGFILE" ]]; then
          if [[ -f "$DT_LOG_PATH/$LOGFILE" ]]; then
            LOGFILE="$DT_LOG_PATH/$LOGFILE"
          else
            dt_error "Log file not found: $LOGFILE"
            exit 1
          fi
        fi
      fi
      
      if [[ -n "$FILTER" ]]; then
        grep --color=always "$FILTER" "$LOGFILE"
      else
        menu
      fi

    '';    
    voice = {
      enabled = true;
      priority = 5;
      sentences = [
        "sök [i] {service}[s] [log|loggar|loggen] efter fel på {host}"      
        "sök [i] {service}[s] [log|loggar|loggen] efter fel"
        "sök [efter] error på {host}"        
        "sök [efter] error"
        "ducktrace {service}"
        "kolla [i] [log|loggen|loggar|loggarna)]"
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
