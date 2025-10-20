# dotfiles/bin/productivity/google.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ custom google search
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
      google = {
        description = "Perform web search on google";
        category = "⚡ Productivity";
        aliases = [ "g" ];
        logLevel = "DEBUG";
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
          
          error=$(echo "$response" | jq -r '.error.message // empty')
          if [ -n "$error" ]; then
            dt_error "Google search error: $error"
            exit 1
          fi
          
          if [ "$(echo "$response" | jq -r '.items | length')" -eq 0 ]; then
            dt_info "No results found for $search."
            exit 0
          fi
          
          results=()
          while IFS= read -r line; do
            results+=("$line")
          done < <(echo "$response" | jq -c '.items[0:5][]')
          

          echo ""
          # 🦆 says ⮞ display
          for i in "''${!results[@]}"; do
            echo "Search results for: $search"
            if_voice_say "Hittade dessa resultat när jag ssökte på: $search"
            item="''${results[$i]}"
            
            title=$(echo "$item" | jq -r '.title // "Untitled"' | sed 's/ - Google Search$//')
            link=$(echo "$item" | jq -r '.link // ""')
            snippet=$(echo "$item" | jq -r '.snippet // ""')
            
            # 🦆 says ⮞ 1st result
            if [ $i -eq 0 ]; then
              echo "  ''${title}"
              [ -n "$link" ] && echo "  ''${link}"
              if [ -n "$snippet" ]; then
                echo "  ''${snippet}" | fold -s -w 80 | sed 's/^/  /'
              fi
              echo ""
              echo "OTHER RESULTS"
            else
              echo "$((i+1)). ''${title}"
              [ -n "$link" ] && echo "   ''${link}"
              echo ""
            fi
          done
          
          # 🦆 says ⮞ interactive mode
          if [ -t 0 ]; then
            echo "———————————————————————————————————————"
            echo "Navigate: [1-5] Open result | [q] Quit"
            while true; do
              read -p "❯ " choice
              case $choice in
                [1-5])
                  idx=$((choice-1))
                  if [ $idx -lt ''${#results[@]} ]; then
                    link=$(echo "''${results[$idx]}" | jq -r '.link')
                    w3m -dump "$link"
                  else
                    say_duck "fuck ❌"
                  fi
                  ;;
                q)
                  exit 0
                  ;;
                *)
                  say_duck "fuck ❌ Use 1-5 or q"
                  ;;
              esac
            done
          fi

          if [ "$VOICE_MODE" = "1" ]; then
            if_voice_say "Hittade $item_count resultat för $search"
            
            for idx in "''${!results[@]}"; do
              item="''${results[$idx]}"
              title=$(echo "$item" | jq -r '.title' | sed 's/ - Google Search$//')
              snippet=$(echo "$item" | jq -r '.snippet')
              link=$(echo "$item" | jq -r '.link')
              
              yo-say "Resultat $((idx+1)): $title. $snippet"
              yo-say "Är detta relevant för dig?"

              confirmed=false
              for _ in {1..2}; do  # Retry loop
                response=$(mic_input)
                case "''${response,,}" in
                  ja|yes|japp|yep|sure|absolut)
                    if_voice_say "Öppnar resultat"
                    echo "$link"
                    confirmed=true
                    break
                    ;;
                  nej|no|nope|next|nästa)
                    break  # Move to next result
                    ;;
                  *)
                    if_voice_say "Förlåt jag hörde inte, säg ja eller nej"
                    ;;
                esac
              done
              
              $confirmed && exit 0
            done
            
            if_voice_say "Hittade inga fler matchande resultat"
            exit 0
          fi
        '';
        voice = {
          sentences = [
            "sök [efter|på|om] {search} på google"
            "(google|googl) [efter|på|om] {search}"
          ];
          lists.search.wildcard = true;
        };
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
