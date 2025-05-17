# dotfiles/bin/system/transport.nix
{ 
  config,
  lib,
  pkgs,
  cmdHelpers,
  ...
} : let

in {
  yo.scripts.transport = {
      description = "Public transportation helper. Fetches current airplane, bus, boats and train departure and arrival times. (Sweden)";
#      keywords = [ ];
      category = "🌍 Localization";
      aliases = [ "buss" "trafiklab" ];
      parameters = [
        { 
          name = "arrival"; 
          description = "Name of City or stop for the arrival"; 
          optional = false; 
        }
        { 
          name = "departure"; 
          description = "Name of City or stop for the departure "; 
          default = config.sops.secrets."users/pungkula/homeStop".path;  # Setting default value makes param optional
        }
        { 
          name = "apikey"; 
          description = "Trafiklab API key. Can be optained from https://trafiklab.se"; 
          default = config.sops.secrets.resrobot.path; 
        }
      ];
#      helpFooter = ''    
#      '';
      code = ''
          ${cmdHelpers}
          
      '';
      
  };
  sops = {
      secrets = {
          resrobot = {
              sopsFile = ./../../secrets/resrobot.yaml;
              owner = config.this.user.me.name;
              group = config.this.user.me.name;
              mode = "0440"; # Read-only for owner and group
          };
          "users/pungkula/homeStop" = {
              sopsFile = ./../../secrets/users/pungkula/homeStop.yaml;
              owner = config.this.user.me.name;
              group = config.this.user.me.name;
              mode = "0440"; # Read-only for owner and group
          };      
      };
      
  };}
  
