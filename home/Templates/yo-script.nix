# dotfiles/bin/<CATEGORY>/<SCRIPT>.nix
# yo.bitch.intents.<name> = { data = [{ sentences = [ ]; lists = { }; }]; };  # 🦆 says ⮞ single line intent
# yo.scripts.<name>.description = "Description of the script."; code = "${cmdHelpers}"; }; # 🦆 says ⮞ single line script

{ 
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
} : let

in {
  yo.scripts.<SCRIPT> = {
      description = "Description of the script.";
#      keywords = [ ];
#      category = "🧩 Miscellaneous";
      category = "🌍 Localization";
      aliases = [ "" ];
      parameters = [
        { 
          name = ""; 
          description = "Description of the parameter"; 
          optional = false; # Always required prameters first
        }
        { 
          name = ""; 
          description = "Description of the parameter"; 
          default = config.sops.secrets.homeStop.path; # Default value makes param optional
        }
      ]; # For displaying anything  special 
      # in --help command 
      helpFooter = ''
    
      '';
      code = ''
          ${cmdHelpers}
          
      '';      
  };
  sops = {
      secrets = {
          <SECRET> = {
              sopsFile = ./../../secrets/<SECRET>.yaml;
              owner = config.this.user.me.name;
              group = config.this.user.me.name;
              mode = "0440"; # Read-only for owner and group
          }; 
      };
      
  };}
  
