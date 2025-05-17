# dotfiles/bin/system/weather.nix

{ config, lib, pkgs, cmdHelpers, ...  }:
{
  yo.scripts.stores = {
    description = "Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours.";
#    category = "🧩 Miscellaneous";
    category = "🌍 Localization";
    aliases = [ "store" "open" ];
    parameters = [
      { 
        name = "store_name"; 
        description = "Name of store to search for (supports fuzzy matching)"; 
        optional = false; 
      }
      { 
        name = "location"; 
        description = "Base location for search, example: City, Country"; 
        default = config.sops.secrets."users/pungkula/homeCity".path;
      }
      { 
        name = "radius"; 
        description = "Search radius in meters"; 
        default = "5000"; 
      }
    ];
#    helpFooter = ''
#    '';
    code = ''
        ${cmdHelpers}
    '';
  };
  sops = {
      secrets = {
          "users/pungkula/homeCity" = {
              sopsFile = ./../../secrets/users/pungkula/homeCity.yaml;
              owner = config.this.user.me.name;
              group = config.this.user.me.name;
              mode = "0440"; # Read-only for owner and group
          };
      };    
      
  };}
