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

      { name = "service"; description = "View specified yo scripts logs"; optional = true; wildcard = true; }
      { name = "host"; description = "Specify optional host"; optional = true; 
        values = lib.genList (i: {
          "in" = "host" + toString i;
          out = "host" + toString i;
        }) 50; }  # 50 host values!
      { name = "errors"; type = "bool"; description = "Show errors"; optional = true; }
      { name = "monitor"; type = "bool"; description = "Monitor continuously"; optional = true; }
      { name = "severity"; description = "Error severity level"; optional = true;
        values = [
          { "in" = "[critical|kritisk|fatal|emergency]"; out = "CRITICAL"; }
          { "in" = "[error|fel|problem|fail]"; out = "ERROR"; }
          { "in" = "[warning|varning|alert|caution]"; out = "WARNING"; }
          { "in" = "[info|information|status]"; out = "INFO"; }
          { "in" = "[debug|debugging|verbose]"; out = "DEBUG"; }
        ]; }
      { name = "timeframe"; description = "Time period"; optional = true;
        values = [
          { "in" = "[last|previous|past|recent] hour"; out = "1h"; }
    
          { "in" = "[last|previous|past|recent] 6 hours"; out = "6h"; }
          { "in" = "[last|previous|past|recent] 12 hours"; out = "12h"; }
          { "in" = "[last|previous|past|recent] day"; out = "24h"; }
          { "in" = "[last|previous|past|recent] week"; out = "7d"; }
          { "in" = "[last|previous|past|recent] month"; out = "30d"; }
          { "in" = "[today|todays|current]"; out = "today"; }
          { "in" = "[yesterday|yesterdays]"; out = "yesterday"; }
        ]; }
      { name = "format"; description = "Output format"; optional = true;
        values = [
          { "in" = "[json|json format|as json]"; out = "json"; }
          { "in" = "[yaml|yaml format|as yaml]"; out = "yaml"; }
          { "in" = "[text|plain|human readable]"; out = "text"; }
          { "in" = "[table|tabular|as table]"; out = "table"; }
          { "in" = "[csv|comma separated]"; out = "csv"; }
        ]; }
      { name = "sort"; description = "Sort order"; optional = true;
        values = [
          { "in" = "[by time|chronological|oldest first]"; out = "time_asc"; }
          { "in" = "[newest first|reverse chronological]"; out = "time_desc"; }
          { "in" = "[by severity|most critical first]"; out = "severity_desc"; }
          { "in" = "[alphabetical|by name]"; out = "name_asc"; }
        ]; }
      { name = "limit"; description = "Result limit"; optional = true; type = "int";
        values = lib.genList (i: {
          "in" = toString (i + 1);
          out = toString (i + 1);
        }) 100; }  # Limit from 1 to 100
    ];    
    
#      { name = "script"; description = "View specified yo scripts logs"; optional = true; } 
      #{ name = "host"; description = "Specify optional host to browse the logs from"; optional = true; } 
#      { name = "host"; description = "Specify optional host to browse the logs from"; optional = true; values = [ "desktop" "homie" "laptop" "nasty" ]; }       
#      { name = "errors"; type = "bool"; description = "Show error states across hosts"; optional = true; default = false; }
#      { name = "monitor"; type = "bool"; description = "Continuously monitor for errors"; optional = true; default = false; }
#    ]; 
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
        "[(please|could you|can you|would you|kindly)] [show|display|list|get|fetch|retrieve] [(all|the|any|some)] [(recent|latest|current|previous|past)] [(error|errors|warning|warnings|log|logs|entry|entries)] [from|on|at|for] [(service|script|program|application)] {service} [on|at|for|from] [(host|machine|server|computer|device)] {host} [with|having|showing] [(severity|level|type)] {severity} [from|during|in] [(time|period|duration|timeframe)] {timeframe} [in|as|using|with] [(format|output)] {format} [sorted|ordered|arranged] [(by|according to)] {sort} [(limited to|showing only|maximum of)] {limit} [(results|entries|lines)] [(and|also|plus)] [(monitor|watch|follow|track)] {monitor} [(errors only|just errors)] {errors}"
    
        "(check|view|examine|analyze|scan|review|inspect|audit) [(the|my|our)] [(system|application|service|script)] {service} [(logs|log files|log entries|log data|logging information)] [(on|at|for|from)] [(host|server|machine)] {host} [(for|looking for|searching for|seeking)] [(errors|problems|issues|failures|warnings|alerts)] {errors} [(with|having)] [(severity|criticality|level)] {severity} [(during|in|over|for)] [(time period|duration|interval|timeframe)] {timeframe} [(in|using|as)] [(output format|display format|report format)] {format} [(sorted|ordered|organized)] [(by|according to|based on)] {sort} [(limited to|showing only|maximum)] {limit} [(and|while also|plus)] [(monitoring|watching|tracking)] {monitor}"
    

        "(i want|i need|can i get|show me|display for me|let me see) [(all|some|any|the latest|the recent|the past)] [(error messages|warnings|log entries|system logs|application logs|debug logs)] [(from|coming from|generated by|produced by)] {service} [(running on|hosted on|located on|executing on)] {host} [(that are|which are|with)] {severity} [(severity|level|priority)] [(occurred|happened|were logged) (during|in|over|within)] {timeframe} [(presented|formatted|displayed) (as|in)] {format} [(arranged|sorted|organized) (by|according to)] {sort} [(showing only|limited to|maximum of)] {limit} [(items|results|entries)] [(and|while|also) (continuously|constantly|in real-time) (monitoring|watching|tracking)] {monitor} [(for|to catch) (errors|problems)] {errors}"
    

        "(log|logs|logging) [(for|of|from)] {service} [(on|at)] {host} [(show|display|list|get)] [(errors|warnings|all entries)] {errors} [(with|having)] {severity} [(from|during)] {timeframe} [(format|as)] {format} [(sort|order)] {sort} [(limit|max)] {limit} [(monitor|watch)] {monitor}"
    

        "(what are|show me|tell me|list|display) [(the|any|some|all)] [(recent|latest|current|previous|past)] [(errors|warnings|log messages|log entries)] [(for|from|in)] {service} [(on|at|for)] {host} [(with|having)] {severity} [(severity|level)] [(from|during|in)] {timeframe} [(in|as)] {format} [(format|output)] [(sorted|ordered) (by|according to)] {sort} [(limited to|showing only)] {limit} [(and|while) (monitoring|watching)] {monitor} [(for errors|for problems)] {errors} [please] [?]"
    

        "(get|fetch|retrieve|pull|download) [(all|the|any)] [(log data|logging information|system logs)] [(from|of)] {service} [(hosted on|running on|located at)] {host} [(filtered by|showing only)] {severity} [(from time|during period)] {timeframe} [(output as|formatted as)] {format} [(ordered by|sorted by)] {sort} [(maximum results|limit to)] {limit} [(while monitoring|and monitor)] {monitor} [(errors only|just errors)] {errors}"
    
        "(display|show|present|render) [(a|an|the)] [(log|logs|logging) (view|report|summary|overview)] [(for|of)] {service} [(at|on)] {host} [(with|including)] {severity} [(severity|level)] [(during|from)] {timeframe} [(in|using)] {format} [(format|style)] [(sorted|arranged) (by|per)] {sort} [(limited to|max)] {limit} [(and|plus) (live monitoring|real-time watching)] {monitor} [(for errors|error checking)] {errors}"
    
        "(check|verify|examine) [(the|any)] [(error log|warning log|system log|application log)] [(entries|messages|records)] [(from|for)] {service} [(on server|on host|on machine)] {host} [(having|with)] {severity} [(priority|level)] [(within|during)] {timeframe} [(presented in|output in)] {format} [(format|layout)] [(organized by|grouped by)] {sort} [(showing only|limited to)] {limit} [(items|entries)] [(while also|and) (monitoring|watching)] {monitor} [(errors|error states)] {errors}"
    
       "(analyze|scan|review) [(all|the|any)] [(recent|past|historical)] [(log entries|log messages|log records)] [(generated by|from)] {service} [(executing on|running on)] {host} [(with|showing)] {severity} [(severity level|criticality)] [(over|during)] {timeframe} [(in format|as)] {format} [(sorted according to|ordered by)] {sort} [(maximum of|up to)] {limit} [(and|while) (continuously monitoring|live tracking)] {monitor} [(for error conditions|for failures)] {errors}"
    
        "(provide|give|generate|create) [(a|an|the)] [(log report|error summary|warning overview)] [(for|about)] {service} [(on|at)] {host} [(featuring|including)] {severity} [(level|type)] [(from|during)] {timeframe} [(in|using)] {format} [(format|presentation)] [(arranged by|sorted by)] {sort} [(limited to|showing only)] {limit} [(entries|results)] [(and|also) (monitoring in real-time|watching live)] {monitor} [(for errors|error detection)] {errors}"
      ];
      lists = {
        host.wildcard = true;
        host.values = let
          baseHosts = [
            { "in" = "[desktop|datorn|workstation|pc]"; out = "desktop"; }
            { "in" = "[nas|nasty|storage|server]"; out = "nasty"; }
            { "in" = "[laptop|notebook|portable|mobile]"; out = "laptop"; }
            { "in" = "[homie|home|raspberry|pi]"; out = "homie"; }
          ];
          numberedHosts = lib.genList (i: {
            "in" = "host" + toString i;
            out = "host" + toString i;
          }) 46;  # Total 50 hosts
        in baseHosts ++ numberedHosts;
    
        service.wildcard = true;
        service.values = lib.genList (i: {
          "in" = "service" + toString i;
          out = "service" + toString i;
        }) 100;  # 100 common service names
      };   

  
    };  
    
  };}
