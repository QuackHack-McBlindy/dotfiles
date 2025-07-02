# dotfiles/bin/system/duckTrace.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ bringing logs back to da cool table  
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let   
in { # 🦆 says ⮞  
  yo.scripts.duckTrace = {
    description = "View duckTrace logs quick and quack.";
    aliases = [ "log" ];    
    category = "🖥️ System Management";
#    helpFooter = '' # 🦆 says ⮞ display log file in markdown with Glow
#    '';
    parameters = [ { name = "file"; description = "Logfile/service name to view, if not provided a list of all logs will be shown"; optional = true; } ];
    code = ''
      ${cmdHelpers} # 🦆 says ⮞ load default helper functions 
      LOGFILE="$file"
      PAGER=''${PAGER:-less -R}

      if [[ -z "$LOGFILE" ]]; then
        cd "$DT_LOG_PATH" || exit 1
        FILES=(*)
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
        cat "$LOGFILE"
      fi

    '';    
  };}
