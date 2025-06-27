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

      # 🦆 says ⮞ If no file is provided, let the user pick one
      if [[ -z "$LOGFILE" ]]; then
        cd "$DT_LOG_PATH" || exit 1
        FILES=(*)

        # 🦆 show preview using bat, glow, or cat
        PREVIEW_CMD='[[ $(file --mime-type --brief {}) == text/markdown ]] && command -v glow >/dev/null && glow {} || command -v bat >/dev/null && bat --style=plain --color=always {} || cat {}'

        LOGFILE=$(printf "%s\n" "''${FILES[@]}" | \
          fzf --preview "$PREVIEW_CMD" --preview-window=right:70%:wrap \
              --prompt="🦆 Pick a log: " --border)
      fi

    '';    
  };}
 
 
 
 

