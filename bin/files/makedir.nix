# dotfiles/bin/files/makedir.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ create directories 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞     

in {   
   
  yo.scripts.makedir = {
    description = "Create a new directory with parents if needed";
    category = "📁 File Operations";
    aliases = [ "mkd" ];
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "path"; type = "path"; description = "Directory path to create"; optional = false; }
    ];
    code = ''
      ${cmdHelpers}    
      path="$path"
      parents="''${parents:-false}"

      if [ -e "$path" ]; then
        if [ -d "$path" ]; then
          dt_info "Directory '$path' already exists"
          exit 0
        else
          dt_error "'$path' exists but is not a directory"
          exit 1
        fi
      fi
      
      if [ "$parents" = "true" ]; then
        dt_info "Creating directory with parents: '$path'"
        mkdir -p -- "$path"
      else
        dt_info "Creating directory: '$path'"
        mkdir -- "$path"
      fi
      
      if [ -d "$path" ]; then
        dt_success "Directory created successfully"
      else
        dt_error "Failed to create directory '$path'"
        exit 1
      fi
    '';
    voice = {
      enabled = true;
      fuzzy.enable = false;
      priority = 5;
      sentences = [
        # 🦆 says ⮞ simple sentence definitions
        "(create|make) directory {path}"
        "mkdir {path}"

      ];        
      lists = {
        path.wildcard = true;
      };
    };  
    
  };}
