{ self, config, pkgs, cmdHelpers, ... }:
{
  yo = {
    bitch = {
      intents = {
        calendar = {
          data = [{
            sentences = [
              "(google|googla|sök) [efter|på|om] {search}"
            ];
            lists.search.wildcard = true;
          }];  
        };  
      };
    };  
    
    scripts = {
      google = {
        description = "Perform web search on google";
        category = "⚡ Productivity";
        aliases = [ "g" ];
        logLevel = "INFO";
        parameters = [
          { name = "search"; description = "What to search for"; optional = false; }
          { name = "apiKeyFile"; description = "Filepath containing your Google custom search engine API key"; optional = false; default = config.sops.secrets.googleSearch.path; }
          { name = "searchIDFile"; description = "Filepath containing your Google search engine ID"; optional = false; default = config.sops.secrets.googleSearchID.path; }
        ];
        code = ''
          ${cmdHelpers}
          GOOGLE_API_KEY=$(cat $apiKeyFile)
          SEARCH_ENGINE_ID=$(cat $searchIDFile)
          query=$(urlencode $search)
          
          response=$(curl -s "https://www.googleapis.com/customsearch/v1?key=$GOOGLE_API_KEY&cx=$SEARCH_ENGINE_ID&q=$query")
          dt_debug "$response"
          snippet0=$(echo "$response" | jq -r '.items[0].snippet // empty')
          echo "$response" | jq -r '
            .items[0:5][] 
            | "result \(input_line_number):\nTitle: \(.title // "N/A")\nLink: \(.link // "N/A")\nSnippet: \(.snippet // "No summary available.")\n"
          '   
        '';
      };
    };
  };

  sops.secrets = {
    googleSearch = {
      sopsFile = ./../../secrets/googleSearch.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
    googleSearchID = {
      sopsFile = ./../../secrets/googleSearcHID.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
  };}
