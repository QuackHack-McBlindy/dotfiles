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
    category = "🧹 Maintenance";
#    helpFooter = '' # 🦆 says ⮞ display log file in markdown with Glow
#    '';
    parameters = [ 
      { name = "script"; description = "View specified yo scripts logs"; optional = true; } 
      { name = "host"; description = "Specify optional host to browse the logs from"; optional = true; values = [ "desktop" "homie" "laptop" "nasty" ]; }       
      { name = "errors"; type = "bool"; description = "Show error states across hosts"; optional = true; default = false; }
      { name = "monitor"; type = "bool"; description = "Continuously monitor for errors"; optional = true; default = false; }
    ]; 
    code = ''
      ${cmdHelpers} # 🦆 says ⮞ load default helper functions 
      DT_MONITOR_HOSTS="desktop,laptop,homie,nasty";
      DT_MONITOR_PORT="9999";
      LOGFILE="$file"
      unset BOLD ITALIC UNDERLINE    
      PAGER=''${PAGER:-less -R}
      export GUM_CHOOSE_CURSOR="🦆 ➤ "  
      export GUM_CHOOSE_CURSOR_FOREGROUND="214" 
      export GUM_CHOOSE_HEADER="[🦆📜] duckTrace" 
      
      announce_error() {
        local file="$DT_LOG_PATH/error_state"
        [[ ! -f "$file" ]] && { echo "Filen $file finns inte."; return 1; }
        local ERROR_STATE LEVEL MESSAGE TIMESTAMP HOSTNAME LAST_UPDATE
        while IFS='=' read -r key value; do
          case "$key" in
            ERROR_STATE) ERROR_STATE="$value" ;;
            LEVEL) LEVEL="$value" ;;
            MESSAGE) MESSAGE="$value" ;;
            TIMESTAMP) TIMESTAMP="$value" ;;
            HOSTNAME) HOSTNAME="$value" ;;
            LAST_UPDATE) LAST_UPDATE="$value" ;;
          esac
        done < "$file"
      
        # 🦆 says ⮞  convert time to secondz
        local last_epoch
        last_epoch=$(date -d "$LAST_UPDATE" +%s 2>/dev/null)
        local now_epoch
        now_epoch=$(date +%s)
        local diff=$(( now_epoch - last_epoch ))
        # 🦆 says ⮞ time diff 
        local days=$(( diff / 86400 ))
        local hours=$(( (diff % 86400) / 3600 ))
        local minutes=$(( (diff % 3600) / 60 ))
        local seconds=$(( diff % 60 ))
      
        local elapsed_text=""
        if (( days > 0 )); then
          elapsed_text="''${days} dagar, ''${hours} timmar"
        elif (( hours > 0 )); then
          elapsed_text="''${hours} timmar, ''${minutes} minuter"
        elif (( minutes > 0 )); then
          elapsed_text="''${minutes} minuter, ''${seconds} sekunder"
        else
          elapsed_text="''${seconds} sekunder"
        fi
      
        # 🦆 says ⮞ calc severity
        local severity
        if (( diff < 300 )); then
          severity="kritisk"
        elif (( diff < 1800 )); then
          severity="hög"
        else
          severity="måttlig"
        fi
      
        local text="Varning — ett ''${LEVEL,,} inträffade på värddatorn ''${HOSTNAME}. \
      Vid tidpunkten ''${TIMESTAMP} uppstod felet: ''${MESSAGE}. \
      Det har gått ''${elapsed_text} sedan händelsen. \
      Allvarlighetsgraden bedöms som ''${severity}."
        # 🦆 says ⮞ say it!
        echo "$text"
        say "$text"
      }
            
      get_service_name() {
        local log_base
        log_base=$(basename "$LOGFILE" .log)

        if [[ "$log_base" == yo.scripts.* ]]; then
          echo "yo-''${log_base#yo.scripts.}.service"
        elif [[ "$log_base" == yo-* ]]; then
          echo "''${log_base}.service"
        else
          echo "yo-$log_base.service"
        fi
      }

      systemd_log() {
        local service
        service=$(get_service_name)
        ${pkgs.systemd}/bin/journalctl -u "$service" -f
      }

      run_systemctl() {
        local action="$1"
        local service="$2"

        if [[ "$service" != *.service ]]; then
          service="''${service}.service"
        fi

        if ${pkgs.systemd}/bin/systemctl --user status "$service" >/dev/null 2>&1; then
          ${pkgs.systemd}/bin/systemctl --user "$action" "$service"
          return 0
        fi

        if ${pkgs.systemd}/bin/systemctl status "$service" >/dev/null 2>&1; then
          ${pkgs.systemd}/bin/systemctl "$action" "$service"
          return 0
        fi

        echo "Service '$service' not found"
        return 1
      }

      restart_service() {
        local service
        service=$(get_service_name)

        run_systemctl restart "$service" || return 1

        ${pkgs.gum}/bin/gum spin --spinner line --title "Restarting $service" -- sleep 2
        ${pkgs.gum}/bin/gum format --theme=pink "# Service restarted!"
      }

      start_service() {
        local service
        service=$(get_service_name)

        run_systemctl start "$service" || return 1

        ${pkgs.gum}/bin/gum spin --spinner line --title "Starting $service" -- sleep 2
        ${pkgs.gum}/bin/gum format --theme=green "# Service started!"
      }

      stop_service() {
        local service
        service=$(get_service_name)

        run_systemctl stop "$service" || return 1

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

      check_errors_across_hosts() {
        local hosts=(${lib.concatStringsSep " " sysHosts})
        for host in "''${hosts[@]}"; do
          dt_check_error_state "$host"
        done
      }

      continuous_monitor() {
        ${pkgs.gum}/bin/gum format --theme=yellow "# Starting Continuous Error Monitoring"
        ${pkgs.gum}/bin/gum format "Press Ctrl+C to stop monitoring"
    
        while true; do
          clear
          dt_monitor_hosts
          sleep 30
        done
      }

      if [[ "''${errors:-false}" == "true" ]]; then
        check_errors_across_hosts
        exit 0
      fi

      if [[ "''${monitor:-false}" == "true" ]]; then
        continuous_monitor
        exit 0
      fi

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

      dt_check_error_state() {
        local host="$1"
        local error_state_file="$HOME/.config/duckTrace/error_state"  
        if [[ "$host" == "$(hostname)" ]]; then
          # 🦆 says ⮞ local host
          if [[ -f "$error_state_file" ]]; then
            source "$error_state_file"
            if [[ "$ERROR_STATE" == "1" ]]; then
              echo "❌ $host: $MESSAGE (at $TIMESTAMP)"
              return 1
            else
              echo "✅ $host: No errors"
              return 0
            fi
          else
            echo "✅ $host: No error state file found (clean)"
            return 0
          fi
        else
          # 🦆 says ⮞ remote host - use SSH
          local result
          if result=$(ssh "$host" "[[ -f '$error_state_file' ]] && source '$error_state_file' && echo \"ERROR_STATE=''$ERROR_STATE' MESSAGE=''$MESSAGE' TIMESTAMP=''$TIMESTAMP'\"" 2>/dev/null); then
            if [[ "$result" == *"ERROR_STATE='1'"* ]]; then
              local message=$(echo "$result" | grep -o "MESSAGE='[^']*'" | sed "s/MESSAGE='//" | sed "s/'//")
              local timestamp=$(echo "$result" | grep -o "TIMESTAMP='[^']*'" | sed "s/TIMESTAMP='//" | sed "s/'//")
              echo "❌ $host: $message (at $timestamp)"
              return 1
            else
              echo "✅ $host: No errors"
              return 0
            fi
          else
            echo "❓ $host: Unable to check (SSH failed or no error state)"
            return 2
          fi
        fi
      }

      # 🦆 says ⮞ monitor all hosts for errors
      dt_monitor_hosts() {
        local hosts=("desktop" "laptop" "homie" "nasty")
        local any_errors=0
        
        echo "🦆 Checking error states across hosts..."
        echo "────────────────────────────────────"
        
        for host in "''${hosts[@]}"; do
          if ! dt_check_error_state "$host"; then
            any_errors=1
          fi
        done
        
        echo "────────────────────────────────────"
        if [[ $any_errors -eq 0 ]]; then
          echo "✅ All hosts are error-free!"
        else
          echo "❌ Some hosts have errors. Check above for details."
        fi
        
        return $any_errors
      }

      # 🦆 says ⮞ search for errors in specific service logs on a host
      search_errors_in_service() {
        local service="$1"
        local host="$2"
        local log_pattern="*error*"
        
        if [[ "$host" == "$(hostname)" ]]; then
          # 🦆 says ⮞ local search
          local log_files=($(find "$DT_LOG_PATH" -name "*$service*" -type f))
          if [[ ''${#log_files[@]} -eq 0 ]]; then
            dt_error "No log files found for service: $service"
            return 1
          fi
          
          for log_file in "''${log_files[@]}"; do
            echo "🔍 Searching $log_file for errors..."
            grep -i -E "error|fail|critical" "$log_file" | head -20
          done
        else
          echo "🔍 Searching $service logs on $host..."
          ssh "$host" "find '$DT_LOG_PATH' -name '*$service*' -type f -exec grep -i -E 'error|fail|critical' {} + | head -20"
        fi
      }


      check_errors_across_hosts() {
        local host_filter="$1"
        if [[ -n "$host_filter" ]]; then
          dt_check_error_state "$host_filter"
        else
          dt_monitor_hosts
        fi
      }

      continuous_monitor() {
        ${pkgs.gum}/bin/gum format --theme=yellow "# Starting Continuous Error Monitoring"
        ${pkgs.gum}/bin/gum format "Press Ctrl+C to stop monitoring"
    
        while true; do
          clear
          dt_monitor_hosts
          sleep 30
        done
      }

      # 🦆 says ⮞ handle voice commands for error search
      if [[ -n "$script" && -n "$host" ]]; then
        # 🦆 says ⮞ voice command: "sök i {service} log efter fel på {host}"
        search_errors_in_service "$script" "$host"
        exit 0
      fi

      if [[ -n "$script" && -z "$host" ]]; then
        # 🦆 says ⮞ voice command: "sök i {service} log efter fel"
        search_errors_in_service "$script" "$(hostname)"
        exit 0
      fi

      if [[ -z "$script" && -n "$host" ]]; then
        # 🦆 says ⮞ voice command: "sök efter error på {host}"
        dt_check_error_state "$host"
        exit 0
      fi

      if [[ "''${errors:-false}" == "true" ]]; then
        check_errors_across_hosts "''${host:-}"
        exit 0
      fi

      if [[ "''${monitor:-false}" == "true" ]]; then
        continuous_monitor
        exit 0
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
        "kolla [efter] fel [på|hos] {host}"
        "är {host} felfri"
        "visa alla fel"
        "check [for] error[s] [on] {host}"
      ];
      lists = {
        host.wildcard = true;
        host.values = [
          { "in" = "[desktop|datorn]"; out = "desktop"; }
          { "in" = "nas"; out = "nasty"; }
          { "in" = "laptop"; out = "laptop"; }
          { "in" = "homie"; out = "homie"; }
        ];
      };   
    };  
    
  };}
