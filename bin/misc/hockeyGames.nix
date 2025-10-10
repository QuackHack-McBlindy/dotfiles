# dotfiles/bin/misc/hockey-games.nix
{ 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
}: let

  # 🦆 says ⮞ game analyzer yo
  analyzeGame = ''
    analyze_game() {
      local game_data="$1"   
      local home_team=$(echo "$game_data" | jq -r '.home_team')
      local away_team=$(echo "$game_data" | jq -r '.away_team')
      local result=$(echo "$game_data" | jq -r '.result')
      local overtime=$(echo "$game_data" | jq -r '.overtime')
      local date=$(echo "$game_data" | jq -r '.date')
      local home_status=$(echo "$game_data" | jq -r '.home_status')
      local away_status=$(echo "$game_data" | jq -r '.away_status')
      local venue=$(echo "$game_data" | jq -r '.venue')
      
      # 🦆 says ⮞ parse score
      if [[ "$result" =~ ([0-9]+)-([0-9]+) ]]; then
        home_score="''${BASH_REMATCH[1]}"
        away_score="''${BASH_REMATCH[2]}"
      else
        home_score=0
        away_score=0
      fi
      
      local home_text=$(number_to_text "$home_score")
      local away_text=$(number_to_text "$away_score")
      
      # 🦆 says ⮞ determine winner
      local winner=""
      if [ "$home_status" = "WIN" ]; then
        winner="$home_team"
      else
        winner="$away_team"
      fi
      
      # 🦆 says ⮞ generate analysis
      local analysis=""
      local score_diff=$((home_score - away_score))
      local abs_diff=$((score_diff > 0 ? score_diff : -score_diff)) 
      analysis="I $venue spelade $home_team mot $away_team. "
      analysis+="Matchen slutade $home_text-$away_text "     
      if [ "$overtime" = "OT" ]; then
        analysis+="efter övertid. "
      elif [ "$overtime" = "SO" ]; then
        analysis+="efter straffläggning. "
      else
        analysis+="i ordinarie tid. "
      fi     
      analysis+="$winner tog hem segern. "  
      
      # 🦆 says ⮞ game type analysis
      if [ $abs_diff -ge 4 ]; then
        analysis+="Det var en övertygande seger med $abs_diff målskillnad."
      elif [ $abs_diff -eq 1 ]; then
        analysis+="Det var en jämn match som kunde gått vilket hull som helst."
      elif [ $abs_diff -eq 2 ] || [ $abs_diff -eq 3 ]; then
        analysis+="Det var en bra match med spännande strid."
      fi     
      # 🦆 says ⮞ overtime drama for close games
      if [ "$overtime" = "OT" ] && [ $abs_diff -eq 1 ]; then
        analysis+=" En riktig dramamatch som avgjordes i övertid!"
      elif [ "$overtime" = "SO" ]; then
        analysis+=" Efter straffar fick $winner äran av den tuffa matchen."
      fi
      
      echo "$analysis"
    }
  '';

  # 🦆 says ⮞ format date to Swedish style
  formatSwedishDate = ''
    format_swedish_date() {
      local date_str="$1"
      local year=$(echo "$date_str" | cut -d'-' -f1)
      local month=$(echo "$date_str" | cut -d'-' -f2)
      local day=$(echo "$date_str" | cut -d'-' -f3)
      day=$((10#$day))
      # 🦆 says ⮞ swe months
      case $month in
        "01") month_name="Januari" ;;
        "02") month_name="Februari" ;;
        "03") month_name="Mars" ;;
        "04") month_name="April" ;;
        "05") month_name="Maj" ;;
        "06") month_name="Juni" ;;
        "07") month_name="Juli" ;;
        "08") month_name="Augusti" ;;
        "09") month_name="September" ;;
        "10") month_name="Oktober" ;;
        "11") month_name="November" ;;
        "12") month_name="December" ;;
        *) month_name="$month" ;;
      esac
      
      echo "$day $month_name"
    }
  '';

  analyzeRecentGames = ''
    analyze_recent_games() {
      local games_file="$1"
      local team_filter="$2"   
      if [ ! -f "$games_file" ]; then
        dt_error "No games data found at $games_file"
        return 1
      fi   
      local games_count=$(jq length "$games_file")
      dt_debug "Anal yzing $games_count games..."
      local games_json=$(cat "$games_file")     
      if [ "$games_count" -eq 0 ]; then
        echo "Inga matcher hittades för den valda perioden."
        return 0
      fi
           
      # 🦆 says ⮞ sort 'em up or down or anyway u like it🦆don't judge 
      local dates=$(echo "$games_json" | jq -r '.[].date' | sort -u)
       
      while IFS= read -r date; do
        [ -z "$date" ] && continue
        local swedish_date=$(format_swedish_date "$date")
        
        # 🦆 says ⮞ head
        echo "🗓️  $swedish_date:"
        echo "----------------------------"
        # 🦆 says ⮞ can games come out play
        echo "$games_json" | jq -r --arg date "$date" '
          [.[] | select(.date == $date)] | .[] | 
          "  \(.home_team) - \(.away_team)"
        ' | while IFS= read -r matchup; do
          echo "  • $matchup"
        done
        echo ""
      done <<< "$dates"
      
      if [ "$type" = "recent" ]; then      
        echo "$games_json" | jq -c '.[]' | while IFS= read -r game_data; do
          local analysis=$(analyze_game "$game_data")
          echo "💬 $analysis"
          echo ""
        done
      fi
    }
  '';

  # 🦆 says ⮞ convert numbers to text for better TTS
  numberToText = ''
    number_to_text() {
      local num=$1
      case $num in
        0) echo "noll" ;;
        1) echo "ett" ;;
        2) echo "två" ;;
        3) echo "tre" ;;
        4) echo "fyra" ;;
        5) echo "fem" ;;
        6) echo "sex" ;;
        7) echo "sju" ;;
        8) echo "åtta" ;;
        9) echo "nio" ;;
        10) echo "tio" ;;
        11) echo "elva" ;;
        12) echo "tolv" ;;
        13) echo "tretton" ;;
        14) echo "fjorton" ;;
        15) echo "femton" ;;
        16) echo "sexton" ;;
        17) echo "sjutton" ;;
        18) echo "arton" ;;
        19) echo "nitton" ;;
        20) echo "tjugo" ;;
        *) echo "$num" ;;
      esac
    }
  '';

in {
  yo.scripts.hockeyGames = {
    description = "Hockey Assistant. Provides Hockey Allsvenskan data and deliver analyzed natural language responses (TTS).";
    category = "🧩 Miscellaneous";
    aliases = [ "hag" ];
    autoStart = false;    
    logLevel = "INFO";
    parameters = [
      { name = "type"; description = "Game type: recent or upcoming"; optional = true; default = "upcoming"; }
      { name = "days"; description = "Number of past days to show"; optional = true; default = "1"; }
      { name = "team"; description = "Filter games for specific team"; optional = true; }
      { name = "dataDir"; description = "Directory path to save data in."; optional = false; default = "/home/" + config.this.user.me.name + "/.config/yo/hockey"; }
      { name = "debug"; description = "Enable debug mode for API calls"; optional = true; default = "false"; }
    ];
    code = ''
      ${cmdHelpers}
      ${numberToText}
      ${formatSwedishDate}
      ${analyzeGame}
      ${analyzeRecentGames}
      
      fetch_games() {
        local url="https://www.hockeyallsvenskan.se/api/sports-v2/game-schedule?seasonUuid=xs4m9qupsi&seriesUuid=qQ9-594cW8OWD&gameTypeUuid=qQ9-af37Ti40B&gamePlace=all&played=all"   
        dt_debug "Fetching $type games..." 
        # 🦆 says ⮞ determine state filter based on type
        local state_filter="post-game"
        if [ "$type" = "upcoming" ]; then
          state_filter="pre-game"
        fi
        
        curl -s -H "User-Agent: Mozilla/5.0" "$url" | \
        jq --arg state "$state_filter" '
          [.gameInfo[] | 
            select(.state == $state) |
            {
              date: (.rawStartDateTime | sub("T.*"; "")),
              home_team: .homeTeamInfo.names.short,
              away_team: .awayTeamInfo.names.short,
              result: "\(.homeTeamInfo.score)-\(.awayTeamInfo.score)",
              overtime: (if .shootout then "SO" elif .overtime then "OT" else "" end),
              home_score: .homeTeamInfo.score,
              away_score: .awayTeamInfo.score,
              home_status: .homeTeamInfo.status,
              away_status: .awayTeamInfo.status,
              venue: .venueInfo.name
            }
          ]
        '
      }

      # 🦆 says ⮞ fetch PP/PK stats for each finished game 
      fetch_team_stats() {
        local game_uuid="$1"
        local url="https://www.hockeyallsvenskan.se/api/gameday/team-stats?gameUuid=$game_uuid"
        curl -s -H "User-Agent: Mozilla/5.0" "$url" | jq '{
          home_team: .homeTeam.names.short,
          away_team: .awayTeam.names.short,
          home_power_play: (.homeTeamStats.powerPlayGoals|tostring + "/" + (.homeTeamStats.powerPlayOpportunities|tostring) + " (" + (.homeTeamStats.powerPlayPercentage|tostring) + "%)"),
          away_power_play: (.awayTeamStats.powerPlayGoals|tostring + "/" + (.awayTeamStats.powerPlayOpportunities|tostring) + " (" + (.awayTeamStats.powerPlayPercentage|tostring) + "%)"),
          home_penalty_kill: (.homeTeamStats.penaltyKillPercentage|tostring + "%"),
          away_penalty_kill: (.awayTeamStats.penaltyKillPercentage|tostring + "%")
        }'
      }
     
      filter_games_by_days() {
        local games_data="$1"
        local days="$2"
        local type="$3" 
        # 🦆 says ⮞ get date YYYY-MM-DD format
        local cutoff_date=""
        if [ "$type" = "recent" ]; then
          cutoff_date=$(date -d "$days days ago" +%Y-%m-%d)
        else
          cutoff_date=$(date -d "$days days" +%Y-%m-%d)
        fi
        
        dt_debug "Filtering games from: $cutoff_date"
        echo "$games_data" | jq --arg cutoff "$cutoff_date" --arg type "$type" '
          [.[] | 
            if $type == "recent" then
              select(.date >= $cutoff)
            else
              select(.date <= $cutoff)
            end
          ] | sort_by(.date) | 
          if $type == "recent" then reverse else . end
        '
      }      
      mkdir -p "$dataDir"
      games_file="$dataDir/recent_games.json"      
      dt_debug "🏒🦆says⮞ PUCK!"
      games_data=$(fetch_games)
      if [ -z "$games_data" ] || [ "$games_data" = "null" ] || [ "$games_data" = "[]" ]; then
        dt_error "No games data received from API"
        exit 1
      fi
      filtered_games=$(filter_games_by_days "$games_data" "$days" "$type")
      games_count=$(echo "$filtered_games" | jq length)  
      if [ "$games_count" -eq 0 ]; then
        dt_error "No games found for the specified criteria"
        exit 1
      fi
      
      # 🦆 says ⮞ save da quackin' data yo 
      echo "$filtered_games" > "$games_file"
      dt_debug "Found $games_count $type games"      

      # 🦆 says ⮞ analyze and display
      analysis_output=$(analyze_recent_games "$games_file" "$team")
      echo "$analysis_output"
      
      # 🦆 says ⮞ TTS yo for recent games yo with
      if [ "$type" = "recent" ]; then
        tts_text=$(echo "$analysis_output" | grep "💬" | sed 's/.*💬 //')       
        if [ -n "$tts_text" ]; then
          echo "$tts_text" | while IFS= read -r line; do
            if [ -n "$line" ]; then
              yo say "$line" --blocking "true"
              sleep 1
            fi
          done
        fi
      fi      
    '';
    # 🦆 says ⮞ vwe'll wanna quack diz with voice yo 
    voice = {
      sentences = [
        "senaste hockymatcherna"
        "vad hände i hockyn igår" 
        "visa senaste matcherna i hockeyallsvenskan"
        "hur gick det för {team} senast"
        "berätta om {team} senaste match"
        "vilka matcher spelades senaste {days} dagarna"
        "hockey resultat"
        "allsvenskan matcher"
      ];
      lists = {
        team.values = [
          { "in" = "[björklöven|löven]"; out = "Björklöven"; }
          { "in" = "[modo]"; out = "MoDo"; }
          { "in" = "[karlskoga|bik]"; out = "Karlskoga"; }
          { "in" = "[nybro|vikings]"; out = "Nybro"; }
          { "in" = "[kalmar]"; out = "Kalmar"; }
          { "in" = "[oskarshamn]"; out = "Oskarshamn"; }
          { "in" = "[almtuna]"; out = "Almtuna"; }
          { "in" = "[aik]"; out = "AIK"; }
          { "in" = "[mora]"; out = "Mora"; }
          { "in" = "[södertälje]"; out = "Södertälje"; }
          { "in" = "[östersund]"; out = "Östersund"; }
          { "in" = "[troja]"; out = "Troja"; }
          { "in" = "[västerås]"; out = "Västerås"; }
          { "in" = "[vimmerby]"; out = "Vimmerby"; }
        ];
        days.values = [
          { "in" = "[igår|en]"; out = "1"; }
          { "in" = "[senaste två|två]"; out = "2"; }
          { "in" = "[senaste tre|tre]"; out = "3"; }
          { "in" = "[senaste veckan|sju]"; out = "7"; }
        ];
      };
    };
  };}
