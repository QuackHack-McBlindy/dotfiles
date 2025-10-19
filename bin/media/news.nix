# dotfiles/bin/media/news.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ latest news from SR
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {  
  yo.scripts.news = {
    description = "API caller and playlist manager for latest Swedish news from SR.";
    category = "🎧 Media Management";
    autoStart = false;
    logLevel = "INFO";
    parameters = [  
      { name = "apis"; description = "Comma seperated list of API's to fetch data form."; default = builtins.concatStringsSep "," [
        "http://api.sr.se/api/v2/news/episodes?format=json"           # 🦆 says ⮞ Ekot
        "http://api.sr.se/api/v2/podfiles?programid=178&format=json"  # 🦆 says ⮞ Ekonomiekot
        "http://api.sr.se/api/v2/podfiles?programid=4916&format=json" # 🦆 says ⮞ Radiosporten
        "http://api.sr.se/api/v2/podfiles?programid=478&format=json"  # 🦆 says ⮞ P4 Västerbotten
        "http://api.sr.se/api/v2/podfiles?programid=3992&format=json" # 🦆 says ⮞ Radio Västerbotten
      ]; }
      { name = "clear"; type = "bool"; description = "Clears the playedFile before playing"; optional = true; }
      { name = "playedFile"; type = "path"; description = "Path to location where to write played news metadata"; default = "/home/" + config.this.user.me.name + "/played_news"; } 
    ];
    code = ''
      ${cmdHelpers}     
      APIS="$apis"
      PLAYED_NEWS_FILE="$playedFile"
      MAX_PLAYED_NEWS_ENTRIES="350"
      PLAYED_NEWS_FILE="$playedFile"
      MAX_PLAYED_NEWS_ENTRIES=350
      PLAYLIST_FILE="/tmp/news_playlist.m3u"
      
      # 🦆 says ⮞ --clear cleans played news file 
      if [ -n "$clear" ]; then
        rm -rf "$playedFile"
      fi
      
      mkdir -p "$(dirname "$PLAYED_NEWS_FILE")"
      touch "$PLAYED_NEWS_FILE"

      declare -A played_episodes
      while IFS= read -r episode_id; do
        played_episodes["$episode_id"]=1
      done < <(head -n "$MAX_PLAYED_NEWS_ENTRIES" "$PLAYED_NEWS_FILE")

      new_episodes=()
      while IFS= read -r api; do
        [[ -z "$api" ]] && continue
        
        response=$(curl -f -s "$api") || continue
        episodes=$(echo "$response" | jq -c '.episodes[]?' 2>/dev/null) || continue

        while IFS= read -r episode; do
          episode_id=$(echo "$episode" | jq -r '.id')
          [[ -z "$episode_id" || -n ''${played_episodes["$episode_id"]} ]] && continue

          audio_url=$(
            echo "$episode" | jq -r '
              if .broadcast?.broadcastfiles? and (.broadcast.broadcastfiles | length) > 0 then
                .broadcast.broadcastfiles[0].url
              else
                .listenpodfile.url // .downloadpodfile.url // empty
              end
            '
          )
          [[ -z "$audio_url" ]] && continue

          new_episodes+=("$audio_url")
          played_episodes["$episode_id"]=1
          echo "$episode_id" >> "$PLAYED_NEWS_FILE"
        done <<< "$episodes"
      done < <(tr ',' '\n' <<< "$APIS")

      tail -n "$MAX_PLAYED_NEWS_ENTRIES" "$PLAYED_NEWS_FILE" > "$PLAYED_NEWS_FILE.tmp"
      mv "$PLAYED_NEWS_FILE.tmp" "$PLAYED_NEWS_FILE"

      if [[ ''${#new_episodes[@]} -gt 0 ]]; then
        dt_debug "Playing news..."
        if_voice_say "Jag fixish det dära brorsaan kompis"
        printf '%s\n' "''${new_episodes[@]}" > "$PLAYLIST_FILE"
        vlc --play-and-exit "$PLAYLIST_FILE" &>/dev/null &
      else
        dt_info "No new news items found"
        if_voice_say "Inga nya nyheter."
      fi
    '';
    voice = {
      priority = 2;
      sentences = [
        "(senast|senaste) (myt|nyt|nytt)"
        
      ];  
    };
    
  };}  
