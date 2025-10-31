# dotfiles/bin/misc/duckPUCK.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ hockey assistant and analyzer 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let
  pyEnv = pkgs.python3.withPackages (ps: [ ps.requests ]);
  scraper = pkgs.writeScript "hockey-scraper.py" ''
    #!${pyEnv}/bin/python
    import os, re, json, logging, argparse, tempfile, shutil
    from datetime import datetime, timedelta
    import requests

    parser = argparse.ArgumentParser()
    parser.add_argument("--dataDir", type=str, required=True, help="Directory to store data")
    args = parser.parse_args()
    os.makedirs(args.dataDir, exist_ok=True)
    table_path = os.path.join(args.dataDir, "table.json")
    logging.basicConfig(level=logging.INFO, format="[🦆🏒] %(levelname)s - %(message)s")
    logger = logging.getLogger()       
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5",
    }
    def fetch_powerplay_data():
        url = "https://www.hockeyallsvenskan.se/api/statistics-v2/stats-info/teams_powerplay?count=25&ssgtUuid=uy2zvu6xaa&provider=statnet&state=active&moduleType=result"
        html = fetch(url)
        if not html:
            logger.error("Failed to fetch powerplay data")
            return {}
    
        try:
            data = json.loads(html)
            powerplay_dict = {}
            for team_data in data[0]['stats']:
                team_name = team_data['info']['siteDisplayName']
                efficiency = team_data.get('PPPerc', '?')
                powerplay_dict[team_name] = efficiency
            return powerplay_dict
        except Exception as e:
            logger.error(f"Failed to parse powerplay data: {e}")
            return {}

    def fetch_boxplay_data():
        url = "https://www.hockeyallsvenskan.se/api/statistics-v2/stats-info/teams_penaltyKilling?count=25&ssgtUuid=uy2zvu6xaa&provider=statnet&state=active&moduleType=result"
        html = fetch(url)
        if not html:
            logger.error("Failed to fetch boxplay data")
            return {}    
        try:
            data = json.loads(html)
            boxplay_dict = {}
            for team_data in data[0]['stats']:
                team_name = team_data['info']['siteDisplayName']
                efficiency = team_data.get('PKPerc', '?')
                boxplay_dict[team_name] = efficiency
            return boxplay_dict
        except Exception as e:
            logger.error(f"Failed to parse boxplay data: {e}")
            return {}

    def fetch(url):
        logger.info(f"Fetching {url}")
        try:
            r = requests.get(url, headers=headers, timeout=15)
            r.raise_for_status()
            return r.text
        except Exception as e:
            dt_error(f"Failed to fetch {url}: {e}")
            return None

    def scrape_table():
        """Scrape complete league table with all stats"""
        url = "https://sportstatistik.nu/hockey/hockeyallsvenskan/tabell"
        html = fetch(url)
        if not html:
            logger.error("Failed to fetch table")
            return []   
        logger.info("Parsing table data...")
        table_data = []    
        # 🦆 says ⮞ main table come here plx
        table_match = re.search(r'<table[^>]*class="[^"]*table[^"]*"[^>]*>(.*?)</table>', html, re.DOTALL)
        if not table_match:
            logger.warning("No table found with class 'table', trying any table")
            table_match = re.search(r'<table[^>]*>(.*?)</table>', html, re.DOTALL)

        if not table_match:
            logger.error("No table found at all")
            return []    
        table_html = table_match.group(1)
        rows = re.findall(r'<tr[^>]*>(.*?)</tr>', table_html, re.DOTALL)
        logger.info(f"Found {len(rows)} table rows")    
        seen_teams = set()  # 🦆 says ⮞ duplicates - no thnx
        team_count = 0 
        for row in rows:
            cells = re.findall(r'<t[dh][^>]*>(.*?)</t[dh]>', row, re.DOTALL)
            if len(cells) >= 11:
                clean_cells = []
                for cell in cells:
                    clean = re.sub(r'<[^>]*>', "", cell)
                    clean = re.sub(r'&nbsp;', ' ', clean)
                    clean = re.sub(r'\s+', ' ', clean).strip()
                    clean_cells.append(clean)
                if clean_cells[0].isdigit() and len(clean_cells[1]) > 0:
                    team_name = clean_cells[1]
                    if team_name in seen_teams:
                        continue
                    seen_teams.add(team_name)    
                    table_data.append({
                        "position": clean_cells[0],
                        "team": team_name,
                        "games_played": clean_cells[2],
                        "wins": clean_cells[3],
                        "ties": clean_cells[4],
                        "losses": clean_cells[5],
                        "overtime_wins": clean_cells[6],
                        "overtime_losses": clean_cells[7],
                        "goals_for": clean_cells[8],
                        "goals_against": clean_cells[9],
                        "goal_difference": clean_cells[10],
                        "points": clean_cells[11] if len(clean_cells) > 11 else "0"
                    })
                    team_count += 1        
                    # 🦆 says ⮞ HA only has 14 teams
                    if team_count >= 14:
                        break
        logger.info(f"Extracted {len(table_data)} teams with complete stats")
        return table_data

    def main():
        logger.info("🏒 Starting hockey scraper...")     
        logger.info("Scraping league table...")
        table_data = scrape_table()
        logger.info("Fetching special teams statistics...")
        powerplay_data = fetch_powerplay_data()
        boxplay_data = fetch_boxplay_data()
        team_name_mapping = {
            "IF Björklöven": "Björklöven",
            "MoDo Hockey": "MoDo", 
            "BIK Karlskoga": "Karlskoga",
            "Nybro Vikings IF": "Nybro",
            "Kalmar HC": "Kalmar",
            "IK Oskarshamn": "Oskarshamn",
            "Almtuna IS": "Almtuna",
            "AIK": "AIK",
            "Mora IK": "Mora",
            "Södertälje SK": "Södertälje",
            "Östersunds IK": "Östersund",
            "IF Troja-Ljungby": "Troja-Ljungby",
            "Västerås IK": "Västerås",
            "Vimmerby HC": "Vimmerby"
        }
    
        for team in table_data:
            api_team_name = team_name_mapping.get(team['team'], team['team'])
            team['powerplay'] = powerplay_data.get(api_team_name, '?')
            team['boxplay'] = boxplay_data.get(api_team_name, '?')
    
        if table_data:
            try:
                with open(table_path, 'w') as f:
                    json.dump(table_data, f, ensure_ascii=False, indent=2)
                logger.info(f"Saved {len(table_data)} teams to {table_path}")
            except Exception as e:
                logger.error(f"Failed to save table: {e}")
        else:
            logger.warning("No table data to save")

        logger.info("Hockey scraping completed!")
    if __name__ == "__main__":
        main()
  '';
  
  # 🦆 says ⮞ number to text conversion for Swedish
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
    
    position_to_text() {
      local pos=$1
      case $pos in
        1) echo "första" ;;
        2) echo "andra" ;;
        3) echo "tredje" ;;
        4) echo "fjärde" ;;
        5) echo "femte" ;;
        6) echo "sjätte" ;;
        7) echo "sjunde" ;;
        8) echo "åttonde" ;;
        9) echo "nionde" ;;
        10) echo "tionde" ;;
        11) echo "elfte" ;;
        12) echo "tolfte" ;;
        13) echo "trettonde" ;;
        14) echo "fjortonde" ;;
        *) echo "$pos" ;;
      esac
    }
  '';

  # 🦆 says ⮞ Hockey Allsvenskan official news
  hockeyNews = ''
    hockey_news() {
        response=$(curl -s -L \
            -H "Accept: application/json; charset=utf-8" \
            -H "User-Agent: HockeyNews/1.0" \
            "https://hockeyallsvenskan.se/api/articles/site-news/list?page=0&pagesize=10&orderByDate=desc")
      
        if [ $? -ne 0 ]; then
            dt_error "Failed to fetch news"
            return 1
        fi
  
        if command -v jq >/dev/null 2>&1; then
            echo "$response" | jq -r '.data.articleItems[] | "\(.header)"' 2>/dev/null | head -5
        else
            dt_error "Failed to get news."
            return 1
        fi
    }
  '';

  # 🦆 says ⮞ get a teams powerplay
  get_powerplay = ''
    BASE_URL="https://www.hockeyallsvenskan.se/api"
    STATS_BASE="$BASE_URL/statistics-v2/stats-info"
    SSGT_UUID="uy2zvu6xaa"
    
    list_teams() {  
        local endpoint="$STATS_BASE/teams_powerplay?count=25&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=result"
        curl -s -L -H "Accept: application/json; charset=utf-8" -H "User-Agent: HockeyStats/1.0" "$endpoint" | \
        jq -r '.[0].stats[] | "\(.info.siteDisplayName)"' | sort
    }
    
    get_team_powerplay_percentage() {
      local team_name="$1"
      local endpoint="$STATS_BASE/teams_powerplay?count=25&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=result"  
      local response
      response=$(curl -s -L -H "Accept: application/json; charset=utf-8" -H "User-Agent: HockeyStats/1.0" "$endpoint")
      if [ $? -ne 0 ]; then
        dt_error "Failed to get team powerplay."
        return 1
      fi

      local efficiency
      efficiency=$(echo "$response" | jq -r --arg team "$team_name" '
        .[0].stats[] | 
        select(.info.siteDisplayName == $team) | 
        .PPPerc')
  
      if [ -n "$efficiency" ] && [ "$efficiency" != "null" ]; then
        echo "$efficiency"
      else
        echo "?"
        return 1
      fi
    }
    
    get_team_powerplay() {
        local team_name="$1" 
        if [ -z "$team_name" ]; then
            dt_error "Please specify a team name"
            return 1
        fi
    
        local endpoint="$STATS_BASE/teams_powerplay?count=25&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=result"
        
        local response
        response=$(curl -s -L -H "Accept: application/json; charset=utf-8" -H "User-Agent: HockeyStats/1.0" "$endpoint")
        
        if [ $? -ne 0 ]; then
            dt_error "Failed to fetch data from API"
            return 1
        fi
    
        local team_data
        team_data=$(echo "$response" | jq -r --arg team "$team_name" '
            .[0].stats[] | 
            select(.info.siteDisplayName == $team) |
            "\(.info.siteDisplayName)|\(.Rank)|\(.GP)|\(.PPG)|\(.PPPerc)|\(.PPOpp)|\(.PPSOG)|\(.PPTime)"')
        
        if [ -z "$team_data" ]; then
            team_data=$(echo "$response" | jq -r --arg team "$team_name" '
                .[0].stats[] | 
                select(.info.siteDisplayName | test($team; "i")) |
                "\(.info.siteDisplayName)|\(.Rank)|\(.GP)|\(.PPG)|\(.PPPerc)|\(.PPOpp)|\(.PPSOG)|\(.PPTime)"' | head -1)
        fi
        
        if [ -z "$team_data" ]; then
            dt_error "Team '$team_name' not found"
            return 1
        fi
        
        IFS='|' read -r name rank gp ppg efficiency ppopp ppsog pptime <<< "$team_data"
        
        echo "Rank: $rank"
        echo "Games Played: $gp"
        echo "Power Play Goals: $ppg"
        echo "Power Play Opportunities: $ppopp"
        echo "Power Play Efficiency: $efficiency%"
        echo "Power Play Shots on Goal: $ppsog"
        echo "Power Play Time: $pptime"
    }
    
    if [ "$#" -eq 1 ]; then
        case "$1" in
            "teams"|"list")
                list_teams
                ;;
            *)
                get_team_powerplay "$1"
                ;;
        esac
    fi
  '';

  # 🦆 says ⮞ get a teams boxplay
  get_boxplay = ''
    BASE_URL="https://www.hockeyallsvenskan.se/api"
    STATS_BASE="$BASE_URL/statistics-v2/stats-info"
    SSGT_UUID="uy2zvu6xaa"    
    list_teams() {  
        local endpoint="$STATS_BASE/teams_penaltyKilling?count=25&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=result"
        curl -s -L -H "Accept: application/json; charset=utf-8" -H "User-Agent: HockeyStats/1.0" "$endpoint" | \
        jq -r '.[0].stats[] | "\(.info.siteDisplayName)"' | sort
    }    
    get_team_boxplay() {
        local team_name="$1"       
        if [ -z "$team_name" ]; then
            dt_error "Please specify a team name"
            return 1
        fi
        local endpoint="$STATS_BASE/teams_penaltyKilling?count=25&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=result"    
        local response
        response=$(curl -s -L -H "Accept: application/json; charset=utf-8" -H "User-Agent: HockeyStats/1.0" "$endpoint") 
        if [ $? -ne 0 ]; then
            dt_error "Failed to fetch data"
            return 1
        fi
    
        local team_data
        team_data=$(echo "$response" | jq -r --arg team "$team_name" '
            .[0].stats[] | 
            select(.info.siteDisplayName == $team) |
            "\(.info.siteDisplayName)|\(.Rank)|\(.GP)|\(.SHG)|\(.PPGA)|\(.PKOpp)|\(.PKPerc)|\(.PPSOGA)|\(.PKTime)"')
        
        if [ -z "$team_data" ]; then
            team_data=$(echo "$response" | jq -r --arg team "$team_name" '
                .[0].stats[] | 
                select(.info.siteDisplayName | test($team; "i")) |
                "\(.info.siteDisplayName)|\(.Rank)|\(.GP)|\(.SHG)|\(.PPGA)|\(.PKOpp)|\(.PKPerc)|\(.PPSOGA)|\(.PKTime)"' | head -1)
        fi
    
        if [ -z "$team_data" ]; then
            dt_error "Team '$team_name' not found"
            return 1
        fi
    
        IFS='|' read -r name rank gp shg ppga pkopp pkperc ppsoga pktime <<< "$team_data"
    
        echo "$name BoxPlay"
        echo "Rank: $rank"
        echo "Games Played: $gp"
        echo "Short-handed Goals: $shg"
        echo "Power Play Goals Against: $ppga"
        echo "Boxplay Opportunities: $pkopp"
        echo "Boxplay Efficiency: $pkperc%"
        echo "Power Play Shots on Goal Against: $ppsoga"
        echo "Boxplay tid: $pktime"
    }
    
    get_boxplay_stats() {
        local endpoint="$STATS_BASE/teams_penaltyKilling?count=25&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=result"  
        local response
        response=$(curl -s -L -H "Accept: application/json; charset=utf-8" -H "User-Agent: HockeyStats/1.0" "$endpoint")   
        if [ $? -ne 0 ]; then
            dt_error "Failed to fetch data"
            return 1
        fi
        
        echo "=== BoxPlay (Penalty Kill) Statistics ==="
        echo "$response" | jq -r '
        .[0].stats[] | 
        "\(.Rank) | \(.info.siteDisplayName) | \(.GP) | \(.PPGA) | \(.PKPerc)%"' | 
        column -t -N "Rank,Team,GP,PPGA,PK%"
    }
    
    get_team_boxplay_percentage() {
        local team_name="$1"
        local endpoint="$STATS_BASE/teams_penaltyKilling?count=25&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=result"        
        local response
        response=$(curl -s -L -H "Accept: application/json; charset=utf-8" -H "User-Agent: HockeyStats/1.0" "$endpoint")
        
        if [ $? -ne 0 ]; then
            echo "ERROR"
            return 1
        fi
    
        local efficiency
        efficiency=$(echo "$response" | jq -r --arg team "$team_name" '
            .[0].stats[] | 
            select(.info.siteDisplayName == $team) | 
            .PKPerc')
        
        if [ -n "$efficiency" ] && [ "$efficiency" != "null" ]; then
            echo "$efficiency"
        else
            echo "NOT_FOUND"
            return 1
        fi
    }
    
    if [ "$#" -eq 1 ]; then
        case "$1" in
            "teams"|"list")
                list_teams
                ;;
            "table"|"all")
                get_boxplay_stats
                ;;
            *)
                get_team_boxplay "$1"
                ;;
        esac
    elif [ "$#" -eq 2 ] && [ "$1" = "percentage" ]; then
        get_team_boxplay_percentage "$2"
    fi
  '';
  
  # 🦆 says ⮞ team analysis with text numbers
  analyzeTeam = '' 
    analyze_team_with_special_teams() {
      local team_name="$1"
      local table_file="$2"
      local basic_analysis=$(analyze_team "$team_name" "$table_file")
      local pp_perc=$(get_team_powerplay_percentage "$team_name" 2>/dev/null || echo "?")
      local pk_perc=$(get_team_boxplay_percentage "$team_name" 2>/dev/null || echo "?")
      local special_teams_analysis=""
      if [[ "$pp_perc" =~ ^[0-9.]+$ ]]; then
        if (( $(echo "$pp_perc > 20" | bc -l) )); then
          special_teams_analysis+="Powerplayet är starkt på $pp_perc%. "
        elif (( $(echo "$pp_perc < 15" | bc -l) )); then
          special_teams_analysis+="Powerplayet behöver förbättras med bara ''${pp_perc}%. "
        else
          special_teams_analysis+="Powerplayet håller måttet på ''${pp_perc}%. "
        fi
      fi  
      # 🦆 says ⮞ letz analyze da box yo
      if [[ "$pk_perc" =~ ^[0-9.]+$ ]]; then
        if (( $(echo "$pk_perc > 85" | bc -l) )); then
          special_teams_analysis+="Boxplayet är exceptionellt bra på ''${pk_perc}%. "
        elif (( $(echo "$pk_perc < 75" | bc -l) )); then
          special_teams_analysis+="Boxplayet är ett bekymmer med ''${pk_perc}%. "
        else
          special_teams_analysis+="Boxplayet är stabilt på ''${pk_perc}%. "
        fi
      fi  
      echo "$basic_analysis $special_teams_analysis"
    }
          
    analyze_team() {
      local team_name="$1"
      local table_file="$2"     
      dt_debug "Analyzing team: $team_name"
      # 🦆 says ⮞ extract team data
      local team_data=$(jq -r ".[] | select(.team == \"$team_name\")" "$table_file")
      if [ -z "$team_data" ]; then
        dt_error "Team '$team_name' not found in table"
        return 1
      fi
      
      # 🦆 says ⮞ parse team stats
      local position=$(echo "$team_data" | jq -r '.position')
      local points=$(echo "$team_data" | jq -r '.points')
      local wins=$(echo "$team_data" | jq -r '.wins')
      local losses=$(echo "$team_data" | jq -r '.losses')
      local ties=$(echo "$team_data" | jq -r '.ties')
      local goals_for=$(echo "$team_data" | jq -r '.goals_for')
      local goals_against=$(echo "$team_data" | jq -r '.goals_against')
      local goal_diff=$(echo "$team_data" | jq -r '.goal_difference')
      local games_played=$(echo "$team_data" | jq -r '.games_played')
      
      # 🦆 says ⮞ convert numbers to text
      local points_text=$(number_to_text "$points")
      local wins_text=$(number_to_text "$wins")
      local losses_text=$(number_to_text "$losses")
      local ties_text=$(number_to_text "$ties")
      local goals_for_text=$(number_to_text "$goals_for")
      local goals_against_text=$(number_to_text "$goals_against")
      local goal_diff_text=$(number_to_text "$goal_diff")
      local games_played_text=$(number_to_text "$games_played")
      local position_text=$(position_to_text "$position")
      
      # 🦆 says ⮞ find close competitors
      local competitors=$(jq -r ".[] | select(.position | tonumber >= $(($position - 1)) and .position | tonumber <= $(($position + 1)) and .team != \"$team_name\") | .team" "$table_file" | head -2)
      
      # 🦆 says ⮞ generate analysis with text numbers
      local analysis=""    
      case $position in
        1)
          analysis="Det går jättebra för $team_name just nu! Dom leder serien med $points_text poäng efter $games_played_text matcher. "
          analysis+="Med $wins_text vinster och bara $losses_text förluster är dom klara serieledare. "
          analysis+="Dom har överlägset bäst målskillnad på $goal_diff_text och släpper sällan in mål med bara $goals_against_text insläppta."
          ;;
        2|3)
          analysis="$team_name ligger bra till på $position_text plats med $points_text poäng. "
          analysis+="Med $wins_text vinster och $losses_text förluster är dom med och kämpar i toppen. "
          if [ -n "$competitors" ]; then
            analysis+="Dom ligger precis bredvid $(echo "$competitors" | head -1) i tabellen."
          fi
          ;;
        4|5|6)
          analysis="$team_name håller sig stabilt i mitten på $position_text plats med $points_text poäng. "
          analysis+="Med $wins_text vinster och $losses_text förluster har dom en bra bas att bygga på. "
          analysis+="Målskillnaden på $goal_diff_text visar att dom kan prestera bra."
          ;;
        7|8|9|10)
          analysis="$team_name ligger i nedre halvan på $position_text plats med $points_text poäng. "
          analysis+="Med $wins_text vinster och $losses_text förluster behöver dom ta fler poäng. "
          analysis+="Dom har gjort $goals_for_text mål men släppt in $goals_against_text, vilket visar att försvaret behöver skärpas."
          ;;
        11|12|13)
          analysis="Det går lite trögt för $team_name som ligger på $position_text plats med bara $points_text poäng. "
          analysis+="Med $losses_text förluster och bara $wins_text vinster behöver dom vända trenden snart. "
          analysis+="Målskillnaden på $goal_diff_text indikerar att det behövs förbättring både framåt och bakåt."
          ;;
        14)
          analysis="Tyvärr går det väldigt dåligt för $team_name som ligger sist i tabellen med bara $points_text poäng. "
          analysis+="Med $losses_text förluster och bara $wins_text vinster ser det ut att bli en tuff säsong. "
          analysis+="Dom har släppt in $goals_against_text mål vilket är mest i serien och behöver skärpa försvaret rejält."
          ;;
        *)
          analysis="$team_name ligger på $position_text plats med $points_text poäng efter $games_played_text matcher."
          ;;
      esac
      
      # 🦆 says ⮞ goal analysis
      if [ "$goal_diff" -gt 15 ]; then
        analysis+=" Dom har en imponerande målskillnad som visar att dom dominerar sina motståndare."
      elif [ "$goal_diff" -lt -10 ]; then
        analysis+=" Den stora negativa målskillnaden visar att dom har svårt att hålla jämna steg med topplagen."
      fi
      
      # 🦆 says ⮞ overtime analysis
      local ot_wins=$(echo "$team_data" | jq -r '.overtime_wins')
      local ot_losses=$(echo "$team_data" | jq -r '.overtime_losses')
      local ot_wins_text=$(number_to_text "$ot_wins")
      local ot_losses_text=$(number_to_text "$ot_losses")
      
      if [ "$ot_wins" -gt 2 ]; then
        analysis+=" Laget är tuffa i övertid med $ot_wins_text övertidsvinster."
      elif [ "$ot_losses" -gt 2 ]; then
        analysis+=" Dom har haft otur i övertid med $ot_losses_text övertidsförluster."
      fi   
      echo "$analysis"
    }
  '';
  
  fuzzyTeamMatch = ''
    fuzzy_match_team() {
      local input_team="$1"
      local table_file="$2"   
      dt_debug "Fuzzy matching team: $input_team"
      # 🦆 says ⮞ first try exact match with voice aliases
      case "$input_team" in
        *[Ll]öven*|*[Bb]jörklöven*|*bjorkloven*) echo "IF Björklöven"; return 0 ;;
        *[Mm]odo*) echo "MoDo Hockey"; return 0 ;;  # Map "modo" back to "MoDo Hockey"
        *[Kk]arlskoga*|*[Bb]IK*) echo "BIK Karlskoga"; return 0 ;;
        *[Nn]ybro*|*[Vv]ikings*) echo "Nybro Vikings IF"; return 0 ;;
        *[Kk]almar*) echo "Kalmar HC"; return 0 ;;
        *[Oo]skarshamn*) echo "IK Oskarshamn"; return 0 ;;
        *[Aa]lmtuna*) echo "Almtuna IS"; return 0 ;;
        *[Aa]IK*) echo "AIK"; return 0 ;;
        *[Mm]ora*) echo "Mora IK"; return 0 ;;
        *[Ss]ödertälje*|*sodertalje*) echo "Södertälje SK"; return 0 ;;
        *[Öö]stersund*|*ostersund*) echo "Östersunds IK"; return 0 ;;
        *[Tt]roja*|*[Ll]jungby*) echo "IF Troja-Ljungby"; return 0 ;;
        *[Vv]ästerås*|*vasteras*) echo "Västerås IK"; return 0 ;;
        *[Vv]immerby*) echo "Vimmerby HC"; return 0 ;;
      esac 
      # 🦆 says ⮞ get all teams from table
      local -a teams
      mapfile -t teams < <(jq -r '.[].team' "$table_file")
      local best_match=""
      local best_score=0
      local normalized_input=$(normalize_string "$input_team")
      for team in "''${teams[@]}"; do
        local normalized_team=$(normalize_string "$team")
        if [[ "$normalized_team" == *"$normalized_input"* ]] || [[ "$normalized_input" == *"$normalized_team"* ]]; then
          echo "$team"
          return 0
        fi
      
        local tri_score=$(trigram_similarity "$normalized_input" "$normalized_team")
        local lev_score=$(levenshtein_similarity "$normalized_input" "$normalized_team")
      
        if (( lev_score > best_score )); then
          best_score=$lev_score
          best_match="$team"
          dt_debug "New best match: $team ($lev_score%)"
        fi
      done
    
      if (( best_score >= 30 )); then
        echo "$best_match"
        return 0
      else
        dt_debug "No good fuzzy match found (best: $best_match, score: $best_score%)"
        return 1
      fi
    }
  '';
  
in {
  yo.scripts.duckPUCK = {
    description = "duckPUCK is your personal hockey assistant - Expert commentary and analyzer specialized on Hockey Allsvenskan (SWE). Analyzing games, scraping scoreboard and keeping track of all dates annd numbers.";
    category = "🧩 Miscellaneous";
    aliases = [ "puck" ];
    autoStart = false;    
    logLevel = "DEBUG";
    parameters = [
      { name = "mode"; description = "What to display: 'recent', 'table', or 'upcoming'"; optional = false; default = "table"; }
      { name = "team"; description = "Team specific search with TTS"; optional = true; }
      { name = "stat"; description = "Search for specific stats. Available values: powerplay, boxplay "; optional = true; }
      { name = "dataDir"; description = "Directory path to save data in."; optional = false; default = "/home/" + config.this.user.me.name + "/.config/yo/hockey"; }
    ];
    code = ''
      ${cmdHelpers}
      ${numberToText}
      ${analyzeTeam}
      ${fuzzyTeamMatch}
      ${hockeyNews}
      ${get_boxplay}
      ${get_powerplay}
      
      # 🦆 says ⮞ analyze best/worst special teams
      analyze_special_teams() {
          local query_type="$1"  # "best-powerplay", "worst-powerplay", "best-boxplay", "worst-boxplay"
          local table_file="$2"
          
          if [ ! -f "$table_file" ]; then
              dt_error "Table file not found: $table_file"
              return 1
          fi
      
          case "$query_type" in
              "best-powerplay")
                  local best_team=$(jq -r '[
                      .[] | select(.powerplay != "?" and .powerplay != null) 
                      | {team: .team, efficiency: (.powerplay | sub("%"; "") | tonumber)}
                  ] | sort_by(.efficiency) | reverse | .[0] | "\(.team)|\(.efficiency)"' "$table_file")
                  
                  if [ -n "$best_team" ] && [ "$best_team" != "null" ]; then
                      IFS='|' read -r team efficiency <<< "$best_team"
                      echo "$team har ligans bästa powerplay med $efficiency% i effektivitet."
                  else
                      echo "Kunde inte hitta data om powerplay."
                  fi
                  ;;
                  
              "worst-powerplay")
                  local worst_team=$(jq -r '[
                      .[] | select(.powerplay != "?" and .powerplay != null) 
                      | {team: .team, efficiency: (.powerplay | sub("%"; "") | tonumber)}
                  ] | sort_by(.efficiency) | .[0] | "\(.team)|\(.efficiency)"' "$table_file")
                  
                  if [ -n "$worst_team" ] && [ "$worst_team" != "null" ]; then
                      IFS='|' read -r team efficiency <<< "$worst_team"
                      echo "$team har ligans sämsta powerplay med bara $efficiency% i effektivitet."
                  else
                      echo "Kunde inte hitta data om powerplay."
                  fi
                  ;;
                  
              "best-boxplay")
                  local best_team=$(jq -r '[
                      .[] | select(.boxplay != "?" and .boxplay != null) 
                      | {team: .team, efficiency: (.boxplay | sub("%"; "") | tonumber)}
                  ] | sort_by(.efficiency) | reverse | .[0] | "\(.team)|\(.efficiency)"' "$table_file")
                  
                  if [ -n "$best_team" ] && [ "$best_team" != "null" ]; then
                      IFS='|' read -r team efficiency <<< "$best_team"
                      echo "$team har ligans bästa boxplay med $efficiency% i effektivitet."
                  else
                      echo "Kunde inte hitta data om boxplay."
                  fi
                  ;;
                  
              "worst-boxplay")
                  local worst_team=$(jq -r '[
                      .[] | select(.boxplay != "?" and .boxplay != null) 
                      | {team: .team, efficiency: (.boxplay | sub("%"; "") | tonumber)}
                  ] | sort_by(.efficiency) | .[0] | "\(.team)|\(.efficiency)"' "$table_file")
                  
                  if [ -n "$worst_team" ] && [ "$worst_team" != "null" ]; then
                      IFS='|' read -r team efficiency <<< "$worst_team"
                      echo "$team har ligans sämsta boxplay med bara $efficiency% i effektivitet."
                  else
                      echo "Kunde inte hitta data om boxplay."
                  fi
                  ;;
          esac
      }
      
      # 🦆 says ⮞ display table with special teams
      display_table_with_special_teams() {
          local table_file="$1"
          
          if [ ! -f "$table_file" ]; then
              dt_error "Table file not found"
              return 1
          fi
      
          markdown_table=$(
              echo "# 🏆 HOCKEYALLSVENSKAN 25/26 - SPECIAL TEAMS" 
              echo "| Pos | Lag | M | V | X | F | ÖV | ÖF | + | - | +/- | P | PP% | BP% |"
              echo "|-----|-----|---|---|---|---|----|----|----|----|-----|---|-----|-----|"
              
              jq -r '.[] | "| \(.position) | \(.team) | \(.games_played) | \(.wins) | \(.ties) | \(.losses) | \(.overtime_wins) | \(.overtime_losses) | \(.goals_for) | \(.goals_against) | \(.goal_difference) | \(.points) | \(.powerplay) | \(.boxplay) |"' "$table_file"
          )
          
          echo "$markdown_table" | ${pkgs.glow}/bin/glow -
      }
          
      # 🦆 says ⮞ team name mapping between table and API
      map_team_to_api() {
        local team="$1"
        case "$team" in
          "IF Björklöven") echo "Björklöven" ;;
          "MoDo Hockey") echo "MoDo" ;;
          "BIK Karlskoga") echo "Karlskoga" ;;
          "Nybro Vikings IF") echo "Nybro" ;;
          "Kalmar HC") echo "Kalmar" ;;
          "IK Oskarshamn") echo "Oskarshamn" ;;
          "Almtuna IS") echo "Almtuna" ;;
          "AIK") echo "AIK" ;;
          "Mora IK") echo "Mora" ;;
          "Södertälje SK") echo "Södertälje" ;;
          "Östersunds IK") echo "Östersund" ;;
          "IF Troja-Ljungby") echo "Troja-Ljungby" ;;
          "Västerås IK") echo "Västerås" ;;
          "Vimmerby HC") echo "Vimmerby" ;;
          *) echo "$team" ;;
        esac
      }
      
 
  
      dt_info "🏒🦆duckPUCK🏒🦆 hockey scraper i choose you!"    
      ${scraper} --dataDir "$dataDir"
      status=$?     
      if [ $status -ne 0 ]; then
        dt_error "duck say fuck failed with exit code $status"
        exit $status
      fi    
      dt_debug "Scraping done, files updated in $dataDir"      
      table_file="$dataDir/table.json"     
      
      # 🦆 says ⮞ handle best/worst special teams queries
      if [ -n "$mode" ] && [ -n "$stat" ] && { [ "$mode" = "best" ] || [ "$mode" = "worst" ]; }; then
          if [ -f "$table_file" ]; then
              query_type="$mode-$stat"
              analysis=$(analyze_special_teams "$query_type" "$table_file")
              echo "$analysis"
              yo say "$analysis" --silence "0.8"
          else
              dt_error "No table data found for special teams analysis"
          fi
          exit 0
      fi
           
      # 🦆 says ⮞ handle team analysis
      if [ -n "$team" ]; then
      
        if [ -f "$table_file" ]; then
          # 🦆 says ⮞ fuzzy match team name
          matched_team=$(fuzzy_match_team "$team" "$table_file")
          if [ $? -eq 0 ]; then
            dt_info "Found team: $matched_team (from: $team)"
            team="$matched_team"
          else
            dt_warning "No fuzzy match found for '$team', using exact match"
          fi
          
          # 🦆 says ⮞ map team name for API calls
          api_team=$(map_team_to_api "$team")
          dt_debug "API team name: $api_team (from: $team)"     
          
          # 🦆 says ⮞ handle special teams with analysis
          if [ "$stat" = "powerplay" ]; then
              dt_debug "Stat: $stat & Team: $api_team"  
              pp_data=$(get_team_powerplay "$api_team")
              
              # 🦆 says ⮞ extract percentage directly from the data instead of separate API call
              pp_perc_line=$(echo "$pp_data" | grep "Power Play Efficiency:")
              pp_perc=$(echo "$pp_perc_line" | awk '{print $4}' | sed 's/%//')
              
              # 🦆 says ⮞ extract other stats for richer analysis
              pp_goals_line=$(echo "$pp_data" | grep "Power Play Goals:")
              pp_goals=$(echo "$pp_goals_line" | awk '{print $4}')
              
              pp_opp_line=$(echo "$pp_data" | grep "Power Play Opportunities:")
              pp_opp=$(echo "$pp_opp_line" | awk '{print $4}')
              
              pp_shots_line=$(echo "$pp_data" | grep "Power Play Shots on Goal:")
              pp_shots=$(echo "$pp_shots_line" | awk '{print $6}')
              
              # 🦆 says ⮞ analyziz pp go!
              echo "$pp_data" && echo ""
              
              # 🦆 says ⮞ get the rank from pp_data for proper analysis
              rank_line=$(echo "$pp_data" | grep "Rank:")
              rank=$(echo "$rank_line" | awk '{print $2}')
              
              if [[ "$pp_perc" =~ ^[0-9.]+$ ]]; then
                  pp_analysis=""
                  
                  # 🦆 says ⮞ rank-based analysis is way more exciting!
                  case "$rank" in
                      1)
                          pp_analysis="JÄVLAR ANKA! $team har SERIENS BÄSTA POWERPLAY på rank ''${rank} med ''${pp_perc}%! "
                          ;;
                      2|3)
                          pp_analysis="$team har ett ELIT powerplay på rank ''${rank} med ''${pp_perc}%. "
                          ;;
                      4|5|6)
                          pp_analysis="$team har ett SOLITT powerplay på rank ''${rank} med ''${pp_perc}%. "
                          ;;
                      7|8|9)
                          pp_analysis="$team har ett OK powerplay på rank ''${rank} med ''${pp_perc}%. "
                          ;;
                      *)
                          if (( $(echo "$pp_perc > 20" | bc -l) )); then
                              pp_analysis="$team har ett BRA powerplay på ''${pp_perc}% trots rank ''${rank}. "
                          elif (( $(echo "$pp_perc < 15" | bc -l) )); then
                              pp_analysis="$team behöver jobba på powerplayet. Bara ''${pp_perc}% och rank ''${rank} är inte tillräckligt bra. "
                          else
                              pp_analysis="$team har ett powerplay på ''${pp_perc}% som placerar dom på rank ''${rank}. "
                          fi
                          ;;
                  esac
                  
                  # 🦆 says ⮞ add goal and opportunity analysis for richer content
                  pp_analysis+="Dom har gjort $pp_goals mål på $pp_opp powerplaylägen"
                  if [ -n "$pp_shots" ] && [ "$pp_shots" != "0" ]; then
                      shot_efficiency=$(echo "scale=1; $pp_goals * 100 / $pp_shots" | bc -l 2>/dev/null || echo "0")
                      pp_analysis+=" med $pp_shots skott på mål (''${shot_efficiency}% träffsäkerhet)."
                  else
                      pp_analysis+="."
                  fi
                  
                  # 🦆 says ⮞ spicy comparisons for extreme values
                  if (( $(echo "$pp_perc > 35" | bc -l) )); then
                      pp_analysis+=" Med ''${pp_perc}% är powerplayet RENT AV LÄSKIGT bra!"
                  elif (( $(echo "$pp_perc < 10" | bc -l) )); then
                      pp_analysis+=" Bara ''${pp_perc}% är alarmerande lågt - dom måste lösa detta!"
                  fi
                  
                  dt_info "🏒🦆duckPUCK🏒🦆 POWERPLAY ANALYS:"
                  echo "$pp_analysis"
                  yo say "$pp_analysis" --silence "0.8"
              else
                  dt_warning "Could not extract valid powerplay percentage from data"
              fi
          
          elif [ "$stat" = "boxplay" ]; then 
              dt_debug "Stat: $stat & Team: $api_team"
              bp_data=$(get_team_boxplay "$api_team")
              
              # 🦆 says ⮞ extract percentage and stats directly from displayed data
              bp_perc_line=$(echo "$bp_data" | grep "Boxplay Efficiency:")
              bp_perc=$(echo "$bp_perc_line" | awk '{print $3}' | sed 's/%//')
              
              # 🦆 says ⮞ extract other boxplay stats for richer analysis
              ppga_line=$(echo "$bp_data" | grep "Power Play Goals Against:")
              ppga=$(echo "$ppga_line" | awk '{print $5}')
              
              shg_line=$(echo "$bp_data" | grep "Short-handed Goals:")
              shg=$(echo "$shg_line" | awk '{print $3}')
              
              ppopp_line=$(echo "$bp_data" | grep "Boxplay Opportunities:")
              ppopp=$(echo "$ppopp_line" | awk '{print $3}')
              
              # 🦆 says ⮞ analyziz dat bp go!
              echo "$bp_data"
              echo ""
              
              # 🦆 says ⮞ get rank
              rank_line=$(echo "$bp_data" | grep "Rank:")
              rank=$(echo "$rank_line" | awk '{print $2}') 
              dt_debug "Boxplay analysis - Team: $team, Rank: $rank, BP_Perc: $bp_perc"
              
              if [[ "$bp_perc" =~ ^[0-9.]+$ ]]; then
                  bp_analysis=""
                  # 🦆 says ⮞ rank based analyziz exciting yo
                  case "$rank" in
                      1)
                          bp_analysis="HELT OTROLIGT! $team har SERIENS BÄSTA BOXPLAY på rank ''${rank} med ''${bp_perc}%! "
                          ;;
                      2|3)
                          bp_analysis="$team har ett FENOMENALT boxplay på rank ''${rank} med ''${bp_perc}%. "
                          ;;
                      4|5|6)
                          bp_analysis="$team har ett STABILT boxplay på rank ''${rank} med ''${bp_perc}%. "
                          ;;
                      7|8|9)
                          bp_analysis="$team har ett OK boxplay på rank ''${rank} med ''${bp_perc}%. "
                          ;;
                      *)
                          if (( $(echo "$bp_perc > 85" | bc -l) )); then
                              bp_analysis="$team har ett FANTASTISKT boxplay på ''${bp_perc}% trots rank ''${rank}. "
                          elif (( $(echo "$bp_perc < 70" | bc -l) )); then
                              bp_analysis="$team har problem i boxplay med bara ''${bp_perc}% på rank ''${rank}. "
                          else
                              bp_analysis="$team har ett boxplay på ''${bp_perc}% som placerar dom på rank ''${rank}. "
                          fi
                          ;;
                  esac
                  
                  # 🦆 says ⮞ add goals analysis for richer content
                  bp_analysis+="Dom har släppt in $ppga mål på $ppopp boxplaylägen"
                  if [ "$shg" != "0" ] && [ -n "$shg" ]; then
                      bp_analysis+=" och gjort till och med $shg kortnummermål!"
                  else
                      bp_analysis+="."
                  fi
                  
                  # 🦆 says ⮞ extreme values
                  if (( $(echo "$bp_perc > 90" | bc -l) )); then
                      bp_analysis+=" Med ''${bp_perc}% i boxplay är dom NÄSTAN OGENOMTRÄNGLIGA!"
                  elif (( $(echo "$bp_perc < 65" | bc -l) )); then
                      bp_analysis+=" Bara ''${bp_perc}% i boxplay är ett ALLVARLIGT problem som måste åtgärdas!"
                  fi
                  
                  dt_info "🏒🦆duckPUCK🏒🦆 BOXPLAY ANALYS:"
                  echo "$bp_analysis"
                  yo say "$bp_analysis" --silence "0.8"
              else
                  dt_warning "Could not extract valid boxplay percentage from data"
                  dt_debug "BP_Perc line was: $bp_perc_line"
                  dt_debug "Extracted BP_Perc: $bp_perc"
              fi
          
          else
              # 🦆 says ⮞ GENERAL TEAM ANALYSIS
              dt_debug "Doing general team analysis for: $team"
              team_analysis=$(analyze_team "$team" "$table_file")
        
              if [ $? -eq 0 ]; then
                  dt_info "🏒🦆duckPUCK🏒🦆 TEAM ANALYS:"
                  echo "$team_analysis"
                  yo say "$team_analysis" --silence "0.8"
              else
                  dt_error "Failed to analyze team $team"
              fi
          fi
        else
          dt_error "No table data found for analysis"
        fi
      else
        # 🦆 says ⮞ glow table when no team specified
        if [ -f "$table_file" ]; then
          team_count=$(jq length "$table_file" 2>/dev/null || echo "0")
          dt_debug "Found $team_count teams in table"        
          
          # 🦆 says ⮞ display HA news
          echo "  🗞️ NYHETER"     
          hockey_news | head -5 && echo ""
          
          # 🦆 says ⮞ display table with special teams
          display_table_with_special_teams "$table_file"
          
          # 🦆 says ⮞ display todays/tomorrows games
          echo "" && yo hag
        else
          dt_error "No table data found at $table_file"
        fi
      fi
      
  

    '';
    voice = {
      enabled = true;															
      priority = 4;
      sentences = [
        # 🦆 says ⮞ no parameters
        "hockey tabellen"
        "visa hockeytabellen"
        "hur ser tabellen ut"
        "visa allsvenska tabellen"
        "hur ligger lagen till"
        "vad är ställningen i tabellen"
    
        # 🦆 says ⮞ team specific sentences
        "vad ligger {team} i tabellen"
        "visa {team} statistik"
        "var ligger {team} i tabellen"
        "vilken plats har {team}"
        "hur går det för {team}"
        "hur ligger {team} till"
        "är {team} på slutspelsplats"
        "är {team} på kvalplats"
        "hur många poäng har {team}"
        "visa {team}s statistik"
        "visa statistik för {team}"
        "hur ser {team}s statistik ut"
        "vad har {team} för statistik"
        "ge mig {team}s siffror"
        "hur går det för {team} den {mode} tiden"
        "analysera {team}"
        "ge en analys av {team}"
        "analysera [laget] {team}"
        "analysera {team}s {mode} matcher"
        "hur presterade {team} i {mode} matchen"
        "vilka trender har {team}"
            
        # 🦆 says ⮞ stat specific sentences
        "vad har {team} (för|i) {stat} (statistik|stats)"
        "analysera {team} {stat}"
        "hur (bra|dåliga|effektiva) är {team} [i] {stat}"
        "hur presterar {team} [i] {stat}"
        "hur ser {team}s {stat} ut"
        "visa {team}s {stat}"
        "analysera {team}s {stat}"
        "ge en analys av {team}s {stat}"        

        # 🦆 says ⮞ best/worse teams queries
        "vem har [ligan|ligans] {mode} {stat}"
        "vilket lag har [ligan|ligans] {mode} {stat}"
           
        # 🦆 says ⮞ schedule / recent / upcoming
        "visa {mode} matcher"
        "vilka matcher spelas {mode}"
        "visa matcher [för] {mode}"
        "när spelar {team} {mode} gång"
        "vilka möter {team} {mode}"
        "vilka matcher har {team} {mode}"
        "när är {team}s {mode} match"
      ];
      lists = {
        mode.values = [
          { "in" = "[förra|senaste|igår]"; out = "recent"; }   
          { "in" = "[idag|nästa|kommande|imorgon]"; out = "upcoming"; }   
          { "in" = "[tabellen|ställningen|poängställning]"; out = "table"; }
          { "in" = "[bäst|bästa|best]"; out = "best"; }
          { "in" = "[sämst|sämsta|kassast]"; out = "worst"; }
        ];  
        team.values = [
          { "in" = "[björklöven|björklövens|löven|vi]"; out = "björklöven"; }   
          { "in" = "[modo|modos]"; out = "modo"; }  # CHANGED from "MoDo Hockey" to "modo"
          { "in" = "[karlskoga|bik|bofors]"; out = "karlskoga"; }
          { "in" = "[nybro|nybros|vikings]"; out = "nybro"; }
          { "in" = "[kalmar|kalmars]"; out = "kalmar"; }
          { "in" = "[oskarshamn]"; out = "oskarshamn"; }
          { "in" = "[almtuna]"; out = "almtuna"; }
          { "in" = "[aik|aiks]"; out = "aik"; }
          { "in" = "[mora]"; out = "mora"; }
          { "in" = "[södertälje|sodertalje]"; out = "södertälje"; }
          { "in" = "[östersund|ostersund]"; out = "östersund"; }
          { "in" = "[troja]"; out = "troja"; }
          { "in" = "[västerås|vasteras]"; out = "västerås"; }
          { "in" = "[vimmerby]"; out = "vimmerby"; }
        ];
        stat.values = [
          { "in" = "[power|powerplay|pp|överläge|numerärt överläge]"; out = "powerplay"; }   
          { "in" = "[box|boxplay|bp|box play|undertal|numerärt underläge]"; out = "boxplay"; }       
        ];  
      };  
    };
    
  };}
