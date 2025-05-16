# dotfiles/bin/utilities/echo.nix
{ self, config, pkgs, sysHosts, cmdHelpers, ... }:
{
  yo.scripts = {
    parse = {
      description = "Parse natural language plain text into yo script execution.";
      category = "🖥️ System Management";
      parameters = [
        { 
          name = "text";
          description = "Text to echo back";
          optional = false;
        }
      ];
      code = ''
        ${cmdHelpers}
        
        # Formatting for different message types
        run_cmd echo "\033[1;32m🦆📢 Echoed:\033[0m \033[1;36m''$text\033[0m"
        
      '';
    };
  };
}
