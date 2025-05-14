# dotfiles/bin/system/weather.nix


{ config, lib, pkgs, cmdHelpers, ...  }:
{
  yo.scripts.stores = {
    description = "Finds nearby stores using OpenStreetMap data with fuzzy name matching. Returns results with opening hours.";
    category = "";
    aliases = [ "store" "open" ];
    parameters = [
      { 
        name = "store_name"; 
        description = "Name of store to search for (supports fuzzy matching)"; 
        optional = false; 
      }
      { 
        name = "location"; 
        description = "Base location for search"; 
        optional = true; 
        default = "Paris, France"; 
      }
      { 
        name = "radius"; 
        description = "Search radius in meters"; 
        optional = true; 
        default = "5000"; 
      }
    ];
#    helpFooter = ''
#      ${pkgs.bat}/bin/bat --language json "$output_file""
#    '';
#    packages = [ pkgs.curl pkgs.jq pkgs.python3 ];
#    code = ''
#    helpFooter = ''
#      bat --language json "$output_file"
#    '';
#    packages = [ pkgs.curl pkgs.jq pkgs.grep pkgs.coreutils ];
#    code = ''
    code = ''

    '';
  };}
