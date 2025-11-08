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
   
  yo.scripts.nano = {
    description = "Write content to filepath";
    category = "📁 File Operations";
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      { name = "file"; type = "path"; description = "File path for the file"; optional = false; }
      { name = "content"; type = "string"; description = "Content to insert into the file"; optional = false; }  
    ];
    code = ''
      ${cmdHelpers}    
      file="$file"
      content="$content"

 
      dt_success "File created with content successfully "
    '';
    voice = {
      enabled = true;
      fuzzy.enable = false;
      priority = 5;
      sentences = [
        # 🦆 says ⮞ simple sentence definitions
        "(skapa|gör|create|insert) [en] fil på {file} med (innehåll|innehållet) {content}"

      ];        
      lists = {
        file.wildcard = true;
        content.wildcard = true;
        #from.values = [ { "in" = "[tänd|tända|tänk|start|starta|på|tönd|tömd]"; out = "ON"; } ];
      };
    };  
    
  };}  
