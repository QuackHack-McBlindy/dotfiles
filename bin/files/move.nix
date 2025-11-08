# dotfiles/bin/files/move.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ move files and directories 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞     

in {   
   
  yo.scripts.move = {
    description = "Move a file or directory to a new location";
    category = "📁 File Operations";
    aliases = [ "mv" ];
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "from"; type = "path"; description = "Current path"; optional = false; }
      { name = "to"; type = "path"; description = "New location"; optional = false; }  
    ];
    code = ''
      ${cmdHelpers}    
      from="$from"
      to="$to"

      if [ ! -e "$from" ]; then
        dt_error "Source '$from' does not exist"
        exit 1
      fi
      
      if [ "$(realpath "$from")" = "$(realpath "$to" 2>/dev/null || echo "$to")" ]; then
        dt_error "Source and destination are the same"
        exit 1
      fi
      
      if [ -e "$to" ]; then
        dt_warning "Target '$to' already exists"
        if ! log::confirm "Overwrite?"; then
          dt_info "Move cancelled"
          exit 0
        fi
        rm -rf -- "$to"
      fi
      
      mkdir -p "$(dirname "$to")"
      dt_info "Moving '$from' to '$to'"
      mv -- "$from" "$to"
      
      dt_success "Move completed successfully"
    '';
    voice = {
      enabled = true;
      fuzzy.enable = false;
      priority = 5;
      sentences = [
        # 🦆 says ⮞ simple sentence definitions
        "(move|mv|flytta) {from} (till|to) {to}"

      ];        
      lists = {
        from.wildcard = true;
        to.wildcard = true;
      };
    };  
    
  };}
