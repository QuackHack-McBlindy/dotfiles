# dotfiles/bin/productivity/hitta.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ people finder
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
}: let
in {
  yo = {
    scripts = {
      hitta = {
        description = "Locate a persons address with help of Hitta.se";
        category = "⚡ Productivity";
        logLevel = "INFO";
        parameters = [
          { name = "search"; type = "string"; description = "Who to search for"; optional = false; }
        ];
        code = ''
          ${cmdHelpers}
          search_clean=$(echo "$search" | tr -d '\n\r' | sed 's/ *$//')
          search_encoded=$(echo -n "$search_clean" | ${pkgs.jq}/bin/jq -s -R -r @uri)
          SEARCH_URL="https://www.hitta.se/s%C3%B6k?vad=$search_encoded"
          
          dt_info "Searching for: $search_clean"
          curl -s -L "$SEARCH_URL" -o /tmp/hitta_response.html
          dt_info "Saved response to /tmp/hitta_response.html"
  
          if [ -f /tmp/hitta_response.html ]; then            
            ${pkgs.gnugrep}/bin/grep -o '"addressLine":"[^"]*"' /tmp/hitta_response.html | \
              ${pkgs.gnused}/bin/sed 's/"addressLine":"//g; s/"//g' | \
              uniq | head -3 | while read addr; do
              echo "$search Har adressen $addr"
              if_voice_say "$search Har adressen $addr" --blocking true
            done

          else
            dt_error "Failed to save response file"
          fi
        '';
        voice = {
          sentences = [
            "vad har {search} för adress"
            "ta reda på {search} adress"
            "(säg|berätta|hämta) {search} adress"
            "sök efter {search} på hitta"
          ];
          lists.search.wildcard = true;
        };
      };
    };
    
  };}
