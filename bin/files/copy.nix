# dotfiles/bin/files/copy.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ copy files and directories 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞     

in {   
   
  yo.scripts.copy = {
    description = "Copy a file or directory to a new location";
    category = "📁 File Operations";
    aliases = [ "cp" ];
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
      
      if [ -d "$to" ]; then
        dest_path="$to/$(basename "$from")"
        if [ -e "$dest_path" ]; then
          dt_warning "Target '$dest_path' already exists"
          if ! log::confirm "Overwrite?"; then
            dt_info "Copy cancelled"
            exit 0
          fi
        fi
        dt_info "Copying '$from' to directory '$to'"
        cp -r -- "$from" "$to"
      else
        if [ -e "$to" ]; then
          dt_warning "Target '$to' already exists"
          if ! log::confirm "Overwrite?"; then
            dt_info "Copy cancelled"
            exit 0
          fi
        fi
        dt_info "Copying '$from' to '$to'"
        cp -r -- "$from" "$to"
      fi
      
      dt_success "Copy completed successfully"
    '';
    voice = {
      enabled = true;
      fuzzy.enable = false;
      priority = 5;
      sentences = [
        # 🦆 says ⮞ simple sentence definitions
        "(kopiera|copy|cp) {from} (till|to) {to}"

      ];        
      lists = {
        from.wildcard = true;
        to.wildcard = true;
        #from.values = [ { "in" = "[tänd|tända|tänk|start|starta|på|tönd|tömd]"; out = "ON"; } ];
      };
    };  
    
  };}  
