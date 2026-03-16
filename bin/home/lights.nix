{
  config,
  pkgs,
  ...
} : let   
in {
  yo.scripts.lights = {
    description = "Lights toggle";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "DEBUG";
    parameters = [   
      { name = "state"; type = "string"; description = "On or off"; } 
    ];
    code = ''
      if [ "$state" = "ON" ]; then
        zigduck-cli --all-lights --state on
      else
        zigduck-cli --all-lights --state off
      fi      
    '';
    voice = {
      priority = 1;
      sentences = [
	"{state} allt"
        "{state} alla (lampor|lamporna)"
      ];        
      lists = {
        state.values = [
	  { "in" = "tänd"; out = "ON"; }             
	  { "in" = "släck"; out = "OFF"; } 
        ];
      };
    };
    
  };}
