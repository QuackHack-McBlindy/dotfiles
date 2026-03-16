# dotfiles/bin/productivity/search.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Search the Web using Kagi with Quick Answer
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {  
  yo = {   
    scripts = {
      search = {
        description = "Perform web search using Kagi with Quick Answer";
        category = "⚡ Productivity";
        logLevel = "INFO";
        parameters = [
          { name = "search"; description = "What to search for"; optional = false; }
          { name = "token-file"; description = "Filepath containing Kagi session token"; optional = false; default = config.sops.secrets.kagi.path; }
          { name = "num-results"; description = "Number of results to display. Displaying zero results will only show Qucik Answer"; optional = false; type = "int"; default = 0; }
        ];
        code = ''
          ${cmdHelpers}
          SEARCH="$search"
          TOKEN_FILE=$token-file
          NUM_RESULTS=$num-results

          # 🦆 says ⮞ build the command
          CMD="kagi --search \"$SEARCH\" --num-results $NUM_RESULTS --token-file \"$TOKEN_FILE\""

          if [ "$NUM_RESULTS" -eq 0 ]; then
            # 🦆 says ⮞ capture output to both display and speak
            OUTPUT=$(eval $CMD)
            echo "$OUTPUT"
            yo say "$OUTPUT"
          else
            # 🦆 says ⮞ just run command normally (output goes to terminal)
            eval $CMD
          fi
        '';
        voice = {
          sentences = [
            "sök [efter|på|om] {search} på (internet|webben|nätet)"
            "(google|googl) [efter|på|om] {search}"
          ];
          lists.search.wildcard = true;
        };
      };
    };
  };

  sops.secrets = {
    kagi = {
      sopsFile = ./../../secrets/kagi.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };
    
  };}
