# dotfiles/bin/files/list.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ list directory contents 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞     

in {   
   
  yo.scripts.list = {
    description = "List directory contents with details";
    category = "📁 File Operations";
    aliases = [ "ls" ];
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "path"; type = "path"; description = "Directory to list"; optional = true; default = "."; }
    ];
    code = ''
      ${cmdHelpers}    
      path="''${path:-.}"
      all="''${all:-false}"
      long="''${long:-false}"

      if [ ! -e "$path" ]; then
        dt_error "Path '$path' does not exist"
        exit 1
      fi
      
      if [ ! -d "$path" ]; then
        dt_error "'$path' is not a directory"
        exit 1
      fi
      
      ls_cmd="ls"
      if [ "$long" = "true" ]; then
        ls_cmd="$ls_cmd -lh"
      else
        ls_cmd="$ls_cmd -1"
      fi
      
      if [ "$all" = "true" ]; then
        ls_cmd="$ls_cmd -A"
      fi
      
      dt_info "Contents of '$path':"
      $ls_cmd -- "$path"
    '';
    voice = {
      enabled = true;
      fuzzy.enable = false;
      priority = 5;
      sentences = [
        # 🦆 says ⮞ simple sentence definitions
        "list {path}"
        "ls {path}"
        "show (files|contents|directory) {path}"

      ];        
      lists = {
        path.wildcard = true;
      };
    };  
    
  };}
