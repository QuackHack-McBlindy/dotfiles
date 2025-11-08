# dotfiles/bin/files/remove.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ remove files and directories 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞     

in {   
   
  yo.scripts.remove = {
    description = "Remove files or directories safely";
    category = "📁 File Operations";
    aliases = [ "rm" "delete" ];
    autoStart = false;
    logLevel = "DEBUG";
    parameters = [
      { name = "target"; type = "path"; description = "File or directory to remove"; optional = false; }
    ];
    code = ''
      ${cmdHelpers}    
      target="$target"
      recursive="''${recursive:-false}"
      force="''${force:-false}"

      if [ ! -e "$target" ]; then
        dt_error "Target '$target' does not exist"
        exit 1
      fi
      
      dangerous_paths="/ /home /etc /bin /sbin /usr /var /opt /boot /root"
      for dangerous in $dangerous_paths; do
        if [ "$(realpath "$target" 2>/dev/null)" = "$dangerous" ]; then
          dt_error "Refusing to remove critical system path: $target"
          exit 1
        fi
      done
      
      if [ -d "$target" ] && [ "$recursive" = "false" ]; then
        dt_error "'$target' is a directory. Use -r/--recursive to remove directories"
        exit 1
      fi
      
      if [ "$force" = "false" ]; then
        if [ -d "$target" ]; then
          item_type="directory"
          action="recursively remove"
        else
          item_type="file"
          action="remove"
        fi
        
        dt_warning "You are about to $action $item_type: $target"
        if ! log::confirm "Are you sure?"; then
          dt_info "Removal cancelled"
          exit 0
        fi
      fi
      
      if [ -d "$target" ]; then
        dt_info "Removing directory '$target'"
        rm -rf -- "$target"
      else
        dt_info "Removing file '$target'"
        rm -f -- "$target"
      fi
      
      if [ ! -e "$target" ]; then
        dt_success "Removal completed successfully"
      else
        dt_error "Failed to remove '$target'"
        exit 1
      fi
    '';
    voice = {
      enabled = true;
      fuzzy.enable = false;
      priority = 3;
      sentences = [
        # 🦆 says ⮞ simple sentence definitions
        "(remove|rm|delete|radera) {target}"
        "(remove|rm|delete|radera) (recursive|-r) {target}"

      ];        
      lists = {
        target.wildcard = true;
      };
    };  
    
  };}
