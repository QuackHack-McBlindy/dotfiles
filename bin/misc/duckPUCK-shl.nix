# dotfiles/bin/misc/duckPUCK-shl.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ hockey assistant and analyzer (SHL)
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  shlUuid = "zg0pa4po75";

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
    SSGT_UUID = "${shlUuid}"

    def fetch_powerplay_data():
        url = f"https://www.shl.se/api/statistics-v2/stats-info/teams_powerplay?count=25&ssgtUuid={SSGT_UUID}&provider=statnet&state=active&moduleType=result"
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
        url = f"https://www.shl.se/api/statistics-v2/stats-info/teams_penaltyKilling?count=25&ssgtUuid={SSGT_UUID}&provider=statnet&state=active&moduleType=result"
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
            logger.error(f"Failed to fetch {url}: {e}")
            return None

    def scrape_table():
        """Scrape complete league table with all stats"""
        url = "https://sportstatistik.nu/hockey/shl/tabell"
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
                    # 🦆 says ⮞ SHL has 14 teams too
                    if team_count >= 14:
                        break
        logger.info(f"Extracted {len(table_data)} teams with complete stats")
        return table_data

    def main():
        logger.info("🏒 Starting SHL scraper...")
        logger.info("Scraping league table...")
        table_data = scrape_table()
        logger.info("Fetching special teams statistics...")
        powerplay_data = fetch_powerplay_data()
        boxplay_data = fetch_boxplay_data()
        # 🦆 says ⮞ table name (sportstatistik) -> API siteDisplayName (shl.se)
        team_name_mapping = {
          "IF Björklöven":   "Björklöven",
          "Djurgårdens IF":  "Djurgårdens IF",
          "Växjö Lakers":    "Växjö Lakers",
          "Rögle BK":        "Rögle BK",
          "Brynäs IF":       "Brynäs IF",
          "Skellefteå AIK":  "Skellefteå AIK",
          "Frölunda HC":     "Frölunda HC",
          "Örebro HK":       "Örebro Hockey",
          "Malmö Redhawks":  "Malmö Redhawks",
          "Luleå HF":        "Luleå Hockey",
          "Luleå Hockey":    "Luleå Hockey",
          "Färjestad BK":    "Färjestad BK",
          "HV71":            "HV71",
          "Leksands IF":     "Leksands IF",
          "Linköping HC":    "Linköping HC",
          "Timrå IK":        "Timrå IK",
          "Modo Hockey":     "Modo Hockey",
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

        logger.info("SHL scraping completed!")
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

  # 🦆 says ⮞ SHL official news
  hockeyNews = ''
    hockey_news() {
        response=$(curl -s -L \
            -H "Accept: application/json; charset=utf-8" \
            -H "User-Agent: HockeyNews/1.0" \
            "https://www.shl.se/api/articles/site-news/list?page=0&pagesize=10&orderByDate=desc")

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
    BASE_URL="https://www.shl.se/api"
    STATS_BASE="$BASE_URL/statistics-v2/stats-info"
    SSGT_UUID="${shlUuid}"

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
    BASE_URL="https://www.shl.se/api"
    STATS_BASE="$BASE_URL/statistics-v2/stats-info"
    SSGT_UUID="${shlUuid}"
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
      local team_data=$(jq -r ".[] | select(.team == \"$team_name\")" "$table_file")
      if [ -z "$team_data" ]; then
        dt_error "Team '$team_name' not found in table"
        return 1
      fi

      local position=$(echo "$team_data" | jq -r '.position')
      local points=$(echo "$team_data" | jq -r '.points')
      local wins=$(echo "$team_data" | jq -r '.wins')
      local losses=$(echo "$team_data" | jq -r '.losses')
      local ties=$(echo "$team_data" | jq -r '.ties')
      local goals_for=$(echo "$team_data" | jq -r '.goals_for')
      local goals_against=$(echo "$team_data" | jq -r '.goals_against')
      local goal_diff=$(echo "$team_data" | jq -r '.goal_difference')
      local games_played=$(echo "$team_data" | jq -r '.games_played')

      local points_text=$(number_to_text "$points")
      local wins_text=$(number_to_text "$wins")
      local losses_text=$(number_to_text "$losses")
      local ties_text=$(number_to_text "$ties")
      local goals_for_text=$(number_to_text "$goals_for")
      local goals_against_text=$(number_to_text "$goals_against")
      local goal_diff_text=$(number_to_text "$goal_diff")
      local games_played_text=$(number_to_text "$games_played")
      local position_text=$(position_to_text "$position")

      local competitors=$(jq -r ".[] | select(.position | tonumber >= $(($position - 1)) and .position | tonumber <= $(($position + 1)) and .team != \"$team_name\") | .team" "$table_file" | head -2)

      local analysis=""
      case $position in
        1)
          analysis="Det går jättebra för $team_name just nu! Dom leder SHL med $points_text poäng efter $games_played_text matcher. "
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

      if [ "$goal_diff" -gt 15 ]; then
        analysis+=" Dom har en imponerande målskillnad som visar att dom dominerar sina motståndare."
      elif [ "$goal_diff" -lt -10 ]; then
        analysis+=" Den stora negativa målskillnaden visar att dom har svårt att hålla jämna steg med topplagen."
      fi

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
        *[Dd]jur[gå]rden*)      echo "Djurgårdens IF"; return 0 ;;
        *[Vv][äa]xj[öo]*)       echo "Växjö Lakers"; return 0 ;;
        *[Rr][öo]gle*)          echo "Rögle BK"; return 0 ;;
        *[Bb]ryn[äa]s*)         echo "Brynäs IF"; return 0 ;;
        *[Ss]kellefte[åa]*)     echo "Skellefteå AIK"; return 0 ;;
        *[Ff]r[öo]lunda*)       echo "Frölunda HC"; return 0 ;;
        *[ÖO]rebro*)            echo "Örebro HK"; return 0 ;;
        *[Mm]alm[öo]*)          echo "Malmö Redhawks"; return 0 ;;
        *[Ll]ule[åa]*)          echo "Luleå HF"; return 0 ;;
        *[Ff][äa]rjestad*)      echo "Färjestad BK"; return 0 ;;
        *[Ll]ink[öo]ping*)      echo "Linköping HC"; return 0 ;;
        *[Tt]imr[åa]*)          echo "Timrå IK"; return 0 ;;
        *[Ll]eksand*)           echo "Leksands IF"; return 0 ;;
        *[Hh][Vv]71*|*[Hh]V71*) echo "HV71"; return 0 ;;
        *[Mm]odo*)              echo "Modo Hockey"; return 0 ;;
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
  yo.scripts.duckPUCK-shl = {
    description = "[🏒🦆] - Your Personal Hockey Assistant! - Expert commentary and analyzer specialized on Swedish Hockey League (SHL). Analyzing games, scraping scoreboards and keeping track of all dates and numbers.";
    category = "🧩 Miscellaneous";
    aliases = [ "puck" "shl" ];
    autoStart = false;
    logLevel = "INFO";
    parameters = [
      {
        name = "mode";
        description = "What to display: 'recent', 'table', or 'upcoming'";
        optional = false;
        values = [
          "recent"
          "upcoming"
          "table"
          "best"
          "worst"
        ];
        default = "table";
      }
      { name = "team"; description = "Team specific search with TTS"; optional = true; }
      {
        name = "stat";
        description = "Search for specific stats.";
        type = "string";
        optional = true;
        values = [
          "powerplay"
          "boxplay"
          "shorthanded_goals"
          "goalkeeper"
          "save_percentage"
          "penalty"
          "tallest"
          "shortest"
          "heaviest"
          "lightest"
          "goals"
          "assists"
          "oldest"
          "youngest"
          "shorthanded"
          "icetime"
          "points"
        ];
      }
      { name = "count"; description = "Optional number to fetch stats for"; optional = true; type = "int"; default = 3; }
      { name = "dataDir"; description = "Directory path to save data."; optional = false; default = "/home/" + config.this.user.me.name + "/.config/yo/hockey-shl"; }
    ];
    code = ''
      ${cmdHelpers}
      ${numberToText}
      ${analyzeTeam}
      ${fuzzyTeamMatch}
      ${hockeyNews}
      ${get_boxplay}
      ${get_powerplay}

      analyze_special_teams() {
          local query_type="$1"
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
                      echo "$team har SHLs bästa powerplay med $efficiency% i effektivitet."
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
                      echo "$team har SHLs sämsta powerplay med bara $efficiency% i effektivitet."
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
                      echo "$team har SHLs bästa boxplay med $efficiency% i effektivitet."
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
                      echo "$team har SHLs sämsta boxplay med bara $efficiency% i effektivitet."
                  else
                      echo "Kunde inte hitta data om boxplay."
                  fi
                  ;;
          esac
      }


      display_table_with_special_teams() {
          local table_file="$1"
          if [ ! -f "$table_file" ]; then
              dt_error "Table file not found"
              return 1
          fi

          # 🦆 says ⮞ main league table
          main_table=$(
              echo "# 🏆 SHL 25/26"
              echo "| Pos | Lag | M | V | X | F | ÖV | ÖF | + | - | +/- | P |"
              echo "|-----|-----|---|---|---|---|----|----|----|----|-----|---|"

              jq -r '.[] | "| \(.position) | \(.team) | \(.games_played) | \(.wins) | \(.ties) | \(.losses) | \(.overtime_wins) | \(.overtime_losses) | \(.goals_for) | \(.goals_against) | \(.goal_difference) | \(.points) |"' "$table_file"
          )

          # 🦆 says ⮞ special teams table
          special_table=$(
              echo "## ⚡ Special Teams"
              echo "| Pos | Lag | PP | BP |"
              echo "|-----|-----|-----|-----|"

              jq -r '.[] | "| \(.position) | \(.team) | \(.powerplay) | \(.boxplay) |"' "$table_file"
          )

          echo "$main_table" | ${pkgs.glow}/bin/glow -
          echo ""
          #echo "$special_table" | ${pkgs.glow}/bin/glow -
      }

      # 🦆 says ⮞ team name mapping between table and API (SHL)
      map_team_to_api() {
        local team="$1"
        case "$team" in
          "IF Björklöven")   echo "Björklöven" ;;
          "Djurgårdens IF")  echo "Djurgårdens IF" ;;
          "Växjö Lakers")    echo "Växjö Lakers" ;;
          "Rögle BK")        echo "Rögle BK" ;;
          "Brynäs IF")       echo "Brynäs IF" ;;
          "Skellefteå AIK")  echo "Skellefteå AIK" ;;
          "Frölunda HC")     echo "Frölunda HC" ;;
          "Örebro HK")       echo "Örebro Hockey" ;;
          "Örebro Hockey")   echo "Örebro Hockey" ;;
          "Malmö Redhawks")  echo "Malmö Redhawks" ;;
          "Luleå HF")        echo "Luleå Hockey" ;;
          "Luleå Hockey")    echo "Luleå Hockey" ;;
          "Färjestad BK")    echo "Färjestad BK" ;;
          "Linköping HC")    echo "Linköping HC" ;;
          "Timrå IK")        echo "Timrå IK" ;;
          "Leksands IF")     echo "Leksands IF" ;;
          "HV71")            echo "HV71" ;;
          "Modo Hockey")     echo "Modo Hockey" ;;
          *) echo "$team" ;;
        esac
      }

      get_player_stats() {
          local stat_type="$1"
          local count="$2"
          local sort_order="$3"

          dt_debug "Fetching player stats: type=$stat_type, count=$count, order=$sort_order"

          local endpoint="https://www.shl.se/api/statistics-v2/stats-info/players_point"
          local params="count=100&sortKey=TP&ssgtUuid=${shlUuid}&provider=statnet&state=active&moduleType=point"
          local response
          response=$(curl -s "''${endpoint}?''${params}")

          if [ $? -ne 0 ]; then
              dt_error "Failed to fetch player data"
              return 1
          fi

          case "$stat_type" in
              "tallest"|"shortest")
                  local sort_dir="desc"
                  [ "$stat_type" = "shortest" ] && sort_dir="asc"

                  echo "$response" | jq -r '
                      .[0].stats |
                      map(select(.info.height.value != null)) |
                      sort_by(.info.height.value) |
                      '"$( [ "$sort_dir" = "desc" ] && echo "reverse |" )"'
                      .[0:'$count'] |
                      .[] |
                      "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Längd: \(.info.height.value) \(.info.height.format)"
                  '
                  ;;
              "heaviest"|"lightest")
                  local sort_dir="desc"
                  [ "$stat_type" = "lightest" ] && sort_dir="asc"

                  echo "$response" | jq -r '
                      .[0].stats |
                      map(select(.info.weight.value != null)) |
                      sort_by(.info.weight.value) |
                      '"$( [ "$sort_dir" = "desc" ] && echo "reverse |" )"'
                      .[0:'$count'] |
                      .[] |
                      "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Vikt: \(.info.weight.value) \(.info.weight.format)"
                  '
                  ;;
              "oldest"|"youngest")
                  local sort_dir="asc"
                  [ "$stat_type" = "youngest" ] && sort_dir="desc"

                  echo "$response" | jq -r '
                      .[0].stats |
                      map(select(.info.birthDate != null)) |
                      sort_by(.info.birthDate) |
                      '"$( [ "$sort_dir" = "desc" ] && echo "reverse |" )"'
                      .[0:'$count'] |
                      .[] |
                      "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Född: \(.info.birthDate)"
                  '
                  ;;
              "goals"|"points"|"assists")
                  local sort_key
                  case "$stat_type" in
                      "goals") sort_key="G" ;;
                      "points") sort_key="TP" ;;
                      "assists") sort_key="A" ;;
                  esac

                  local endpoint="https://www.shl.se/api/statistics-v2/stats-info/players_point"
                  local params="count=$count&sortKey=$sort_key&ssgtUuid=${shlUuid}&provider=statnet&state=active&moduleType=point"
                  local response
                  response=$(curl -s "''${endpoint}?''${params}")

                  echo "$response" | jq -r --arg stat "$stat_type" --arg k "$sort_key" '
                      .[0].stats[] |
                      "\(.Rank). \(.info.fullName) (\(.info.team.name)) - \($stat): \(.[$k])"
                  '
                  ;;
              "icetime")
                  echo "$response" | jq -r '
                      .[0].stats
                      | map(select(.TOI_GP != null))
                      | sort_by(
                          (.TOI_GP | split(":") | (.[0]|tonumber)*60 + (.[1]|tonumber))
                        )
                      | reverse |
                      .[0:'$count'] |
                      .[] |
                      "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Istid: \(.TOI_GP) per match"
                  '
                  ;;
              "shorthanded")
                  echo "$response" | jq -r '
                      .[0].stats |
                      sort_by(-.SHTP) |
                      .[0:'$count'] |
                      .[] |
                      "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Boxplay poäng: \(.SHTP)"
                  '
                  ;;
              *)
                  dt_error "Unknown stat type: $stat_type"
                  return 1
                  ;;
          esac
      }

      get_goalie_stats() {
          local stat_type="$1"
          local count="$2"
          local endpoint="https://www.shl.se/api/statistics-v2/stats-info/goalkeepers_summary"
          local sort_key="svPct"
          local json_key="SVSPerc"
          local description="Räddningsprocent"

          case "$stat_type" in
              "save_percentage")
                  sort_key="svPct"
                  json_key="SVSPerc"
                  description="Räddningsprocent"
                  ;;
              "gaa")
                  sort_key="GAA"
                  json_key="GAA"
                  description="Insläppta mål i snitt"
                  ;;
          esac

          local params="count=$count&sortKey=$sort_key&ssgtUuid=${shlUuid}&provider=statnet&state=active&moduleType=goal"
          local response
          response=$(curl -s "''${endpoint}?''${params}")

          echo "$response" | jq -r --arg description "$description" --arg k "$json_key" '
              .[0].stats[] |
              "\(.Rank). \(.info.fullName) (\(.info.team.name)) - \($description): \(.[$k])"
          '
      }

      get_top_goalies_save_percentage() {
          local count=''${1}
          get_goalie_stats "save_percentage" "$count"
      }

      get_best_goalkeeper() {
          dt_info "Finding best goalkeeper in SHL..."
          local endpoint="https://www.shl.se/api/statistics-v2/stats-info/goalkeepers_summary"
          local params="count=1&sortKey=svPct&ssgtUuid=${shlUuid}&provider=statnet&state=active&moduleType=goal"
          local response
          response=$(curl -s "''${endpoint}?''${params}")

          if [ $? -ne 0 ]; then
              echo "NOT_FOUND"
              return 1
          fi

          echo "$response" | jq -r '
              .[0].stats[0] |
              "\(.info.fullName)|\(.info.team.name)|\(.SVSPerc)|\(.GP)|\(.GAA)|\(.SO)"
          '
      }

      get_most_shorthanded_goals() {
          local endpoint="https://www.shl.se/api/statistics-v2/stats-info/teams_penaltyKilling?count=25&ssgtUuid=${shlUuid}&provider=statnet&state=active&moduleType=result"
          local response
          response=$(curl -s -L -H "Accept: application/json; charset=utf-8" -H "User-Agent: HockeyStats/1.0" "$endpoint")

          if [ $? -ne 0 ]; then
              dt_error "Failed to fetch boxplay data"
              return 1
          fi

          echo "$response" | jq -r '
              .[0].stats |
              sort_by(.SHG|tonumber) | reverse |
              .[0] |
              "\(.info.siteDisplayName) - \(.SHG) boxplay mål"
          '
      }

      get_top_shorthanded_teams() {
          local count=''${1:-5}
          local endpoint="https://www.shl.se/api/statistics-v2/stats-info/teams_penaltyKilling?count=25&ssgtUuid=${shlUuid}&provider=statnet&state=active&moduleType=result"
          local response
          response=$(curl -s -L -H "Accept: application/json; charset=utf-8" -H "User-Agent: HockeyStats/1.0" "$endpoint")

          if [ $? -ne 0 ]; then
              dt_error "Failed to fetch boxplay data"
              return 1
          fi

          echo "$response" | jq -r '
              .[0].stats |
              sort_by(.SHG|tonumber) | reverse |
              .[0:'$count'] |
              "\(.Rank). \(.info.siteDisplayName) - \(.SHG) boxplay mål"
          '
      }

      handle_player_stat_query() {
          local stat="$1"
          local count="$2"

          dt_debug "Processing stat query: stat=$stat, count=$count"

          case "$stat" in
              "goals"|"points"|"assists"|"tallest"|"heaviest"|"oldest"|"youngest"|"icetime"|"shorthanded")
                  get_player_stats "$stat" "$count"
                  ;;
              "shortest")
                  get_player_stats "shortest" "$count"
                  ;;
              "lightest")
                  get_player_stats "lightest" "$count"
                  ;;
              "save_percentage"|"gaa")
                  get_goalie_stats "$stat" "$count"
                  ;;
              "penalty")
                  local endpoint="https://www.shl.se/api/statistics-v2/stats-info/players_penalty"
                  local params="count=$count&sortKey=PM&ssgtUuid=${shlUuid}&provider=statnet&state=active&moduleType=penalty"
                  local response
                  response=$(curl -s "''${endpoint}?''${params}")

                  echo "$response" | jq -r '
                      .[0].stats[] |
                      "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Utvisningsminuter: \(.PM)"
                  '
                  ;;
              *)
                  dt_error "Unknown stat: $stat"
                  echo "❌ Okänd statistik: $stat"
                  echo "Tillgängliga: goals, points, assists, tallest, shortest, heaviest, lightest, save_percentage, penalty"
                  echo "Extra stats: oldest, youngest, shorthanded, icetime"
                  ;;
          esac
      }

      dt_info "[🏒🦆] duckPUCK🏒🦆 SHL scraper!"
      ${scraper} --dataDir "$dataDir"
      status=$?
      if [ $status -ne 0 ]; then
        dt_error "duck say fuck failed with exit code $status"
        exit $status
      fi
      dt_debug "Scraping done, files updated in $dataDir"
      table_file="$dataDir/table.json"

      if [ "$stat" = "goalkeeper" ]; then
          if [ -n "$team" ]; then
              api_team=$(map_team_to_api "$team")
              dt_debug "Goalkeeper query - Team: $team, API Team: $api_team"

              if [ "$mode" = "best" ]; then
                  best_gk_data=$(get_best_goalkeeper)
                  if [ "$best_gk_data" != "NOT_FOUND" ]; then
                      IFS='|' read -r gk_name gk_team gk_save_percent gk_games gk_gaa gk_shutouts <<< "$best_gk_data"

                      analysis="SHLs bästa målvakt just nu är $gk_name från $gk_team med $gk_save_percent% i räddningsprocent."
                      analysis+=" Efter $gk_games matcher har $gk_name bara släppt in $gk_gaa mål i genomsnitt och hållit $gk_shutouts nollor."

                      if [ "$gk_team" = "$api_team" ]; then
                          analysis+=" DET ÄR EN $team MÅLVAKT SOM LEDER LIGAN! GRATTIS!"
                      fi

                      echo "$analysis"
                      yo say --text "$analysis"
                  else
                      dt_error "Kunde inte hitta data om SHLs bästa målvakt"
                  fi
              else
                  echo "Målvaktsstatistik för $team:"
                  get_top_goalies_save_percentage 25 | grep "$api_team" || echo "Ingen målvaktsdata hittades för $team"
              fi
          else
              if [ "$mode" = "best" ]; then
                  best_gk_data=$(get_best_goalkeeper)
                  if [ "$best_gk_data" != "NOT_FOUND" ] && [ -n "$best_gk_data" ]; then
                      IFS='|' read -r gk_name gk_team gk_save_percent gk_games gk_gaa gk_shutouts <<< "$best_gk_data"
                      analysis="SHLs bästa målvakt just nu är $gk_name från $gk_team med $gk_save_percent% i räddningsprocent."
                      analysis+=" Efter $gk_games matcher har $gk_name bara släppt in $gk_gaa mål i genomsnitt och hållit $gk_shutouts nollor."
                      echo "$analysis"
                      yo say --text "$analysis"
                  else
                      dt_error "Kunde inte hitta data om SHLs bästa målvakt"
                  fi
              else
                  get_top_goalies_save_percentage $count
              fi
          fi
          exit 0
      fi

      if [ -n "$stat" ] && [ -z "$team" ]; then
          if { [ "$stat" = "powerplay" ] || [ "$stat" = "boxplay" ] || [ "$stat" = "shorthanded_goals" ]; } && { [ "$mode" = "best" ] || [ "$mode" = "worst" ]; }; then
              dt_debug "Handling best/worst team stat query - mode: $mode, stat: $stat"
              if [ -f "$table_file" ]; then
                  if [ "$stat" = "shorthanded_goals" ]; then
                      if [ "$mode" = "best" ]; then
                          result=$(get_most_shorthanded_goals)
                          if [ $? -eq 0 ] && [ -n "$result" ]; then
                              analysis="$result är laget som gjort mest boxplay mål i SHL!"
                              echo "$analysis"
                              yo say --text "$analysis"
                          else
                              dt_error "Failed to get shorthanded goals data"
                          fi
                      else
                          result=$(get_top_shorthanded_teams 14 | tail -1)
                          if [ $? -eq 0 ] && [ -n "$result" ]; then
                              analysis="$result har gjort minst boxplay mål i SHL."
                              echo "$analysis"
                              yo say --text "$analysis"
                          else
                              dt_error "Failed to get shorthanded goals data"
                          fi
                      fi
                  else
                      query_type="$mode-$stat"
                      analysis=$(analyze_special_teams "$query_type" "$table_file")
                      echo "$analysis"
                      yo say --text "$analysis"
                  fi
              else
                  dt_error "No table data found for special teams analysis"
              fi
              exit 0
          else
              dt_debug "Handling player stat query - stat: $stat, count: ''${count:-10}"
              result=$(handle_player_stat_query "$stat" "''${count:-10}")
              if [ $? -eq 0 ] && [ -n "$result" ]; then
                  echo "$result"
                  speech_result=$(echo "$result" | head -5)
                  yo say --text "$speech_result"
              else
                  dt_error "Failed to get player stats"
              fi
              exit 0
          fi
      fi

      if [ -n "$mode" ] && [ -n "$stat" ] && { [ "$mode" = "best" ] || [ "$mode" = "worst" ]; }; then
          if [ -f "$table_file" ]; then
              query_type="$mode-$stat"
              analysis=$(analyze_special_teams "$query_type" "$table_file")
              echo "$analysis"
              yo say --text "$analysis"
          else
              dt_error "No table data found for special teams analysis"
          fi
      fi

      if [ -n "$team" ]; then

        if [ -f "$table_file" ]; then
          matched_team=$(fuzzy_match_team "$team" "$table_file")
          if [ $? -eq 0 ]; then
            dt_debug "Found team: $matched_team (from: $team)"
            team="$matched_team"
          else
            dt_warning "No fuzzy match found for '$team', using exact match"
          fi

          api_team=$(map_team_to_api "$team")
          dt_debug "API team name: $api_team (from: $team)"

          if [ "$stat" = "powerplay" ]; then
              dt_debug "Stat: $stat & Team: $api_team"
              pp_data=$(get_team_powerplay "$api_team")

              pp_perc_line=$(echo "$pp_data" | grep "Power Play Efficiency:")
              pp_perc=$(echo "$pp_perc_line" | awk '{print $4}' | sed 's/%//')

              pp_goals_line=$(echo "$pp_data" | grep "Power Play Goals:")
              pp_goals=$(echo "$pp_goals_line" | awk '{print $4}')

              pp_opp_line=$(echo "$pp_data" | grep "Power Play Opportunities:")
              pp_opp=$(echo "$pp_opp_line" | awk '{print $4}')

              pp_shots_line=$(echo "$pp_data" | grep "Power Play Shots on Goal:")
              pp_shots=$(echo "$pp_shots_line" | awk '{print $6}')

              echo "$pp_data" && echo ""

              rank_line=$(echo "$pp_data" | grep "Rank:")
              rank=$(echo "$rank_line" | awk '{print $2}')

              if [[ "$pp_perc" =~ ^[0-9.]+$ ]]; then
                  pp_analysis=""

                  case "$rank" in
                      1)
                          pp_analysis="JÄVLAR ANKA! $team har SHLs BÄSTA POWERPLAY på rank ''${rank} med ''${pp_perc}%! "
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

                  pp_analysis+="Dom har gjort $pp_goals mål på $pp_opp powerplaylägen"
                  if [ -n "$pp_shots" ] && [ "$pp_shots" != "0" ]; then
                      shot_efficiency=$(echo "scale=1; $pp_goals * 100 / $pp_shots" | bc -l 2>/dev/null || echo "0")
                      pp_analysis+=" med $pp_shots skott på mål (''${shot_efficiency}% träffsäkerhet)."
                  else
                      pp_analysis+="."
                  fi

                  if (( $(echo "$pp_perc > 35" | bc -l) )); then
                      pp_analysis+=" Med ''${pp_perc}% är powerplayet RENT AV LÄSKIGT bra!"
                  elif (( $(echo "$pp_perc < 10" | bc -l) )); then
                      pp_analysis+=" Bara ''${pp_perc}% är alarmerande lågt - dom måste lösa detta!"
                  fi

                  dt_info "🏒🦆duckPUCK🏒🦆 POWERPLAY ANALYS:"
                  echo "$pp_analysis"
                  yo say "$pp_analysis"
              else
                  dt_warning "Could not extract valid powerplay percentage from data"
              fi

          elif [ "$stat" = "boxplay" ]; then
              dt_debug "Stat: $stat & Team: $api_team"
              bp_data=$(get_team_boxplay "$api_team")

              bp_perc_line=$(echo "$bp_data" | grep "Boxplay Efficiency:")
              bp_perc=$(echo "$bp_perc_line" | awk '{print $3}' | sed 's/%//')

              ppga_line=$(echo "$bp_data" | grep "Power Play Goals Against:")
              ppga=$(echo "$ppga_line" | awk '{print $5}')

              shg_line=$(echo "$bp_data" | grep "Short-handed Goals:")
              shg=$(echo "$shg_line" | awk '{print $3}')

              ppopp_line=$(echo "$bp_data" | grep "Boxplay Opportunities:")
              ppopp=$(echo "$ppopp_line" | awk '{print $3}')

              echo "$bp_data"
              echo ""

              rank_line=$(echo "$bp_data" | grep "Rank:")
              rank=$(echo "$rank_line" | awk '{print $2}')
              dt_debug "Boxplay analysis - Team: $team, Rank: $rank, BP_Perc: $bp_perc"

              if [[ "$bp_perc" =~ ^[0-9.]+$ ]]; then
                  bp_analysis=""
                  case "$rank" in
                      1)
                          bp_analysis="HELT OTROLIGT! $team har SHLs BÄSTA BOXPLAY på rank ''${rank} med ''${bp_perc}%! "
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

                  bp_analysis+="Dom har släppt in $ppga mål på $ppopp boxplaylägen"
                  if [ "$shg" != "0" ] && [ -n "$shg" ]; then
                      bp_analysis+=" och till och med gjort $shg boxplay mål!"
                  else
                      bp_analysis+="."
                  fi

                  if (( $(echo "$bp_perc > 90" | bc -l) )); then
                      bp_analysis+=" Med ''${bp_perc}% i boxplay är dom NÄSTAN OGENOMTRÄNGLIGA!"
                  elif (( $(echo "$bp_perc < 65" | bc -l) )); then
                      bp_analysis+=" Bara ''${bp_perc}% i boxplay är ett ALLVARLIGT problem som måste åtgärdas!"
                  fi

                  dt_info "🏒🦆duckPUCK🏒🦆 BOXPLAY ANALYS:"
                  echo "$bp_analysis"
                  yo say "$bp_analysis"
              else
                  dt_warning "Could not extract valid boxplay percentage from data"
                  dt_debug "BP_Perc line was: $bp_perc_line"
                  dt_debug "Extracted BP_Perc: $bp_perc"
              fi

          else
              dt_debug "Doing general team analysis for: $team"
              team_analysis=$(analyze_team "$team" "$table_file")

              if [ $? -eq 0 ]; then
                  dt_info "🏒🦆duckPUCK🏒🦆 TEAM ANALYS:"
                  echo "$team_analysis"
                  yo say "$team_analysis"
              else
                  dt_error "Failed to analyze team $team"
              fi
          fi
        else
          dt_error "No table data found for analysis"
        fi
      else
        if [ -f "$table_file" ]; then
          team_count=$(jq length "$table_file" 2>/dev/null || echo "0")
          dt_debug "Found $team_count teams in table"

          echo "" && echo ""
          BOLD=1
          ${pkgs.gum}/bin/gum format "# 🗞️ **SHL NYHETER**"
          hockey_news | head -5 && echo "----------------------------" && echo ""

          display_table_with_special_teams "$table_file"

          echo "" && yo hockeyGames --league shl
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
        "visa shl tabellen"
        "visa shl"
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
        "ge mig {team} siffror"
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

        "vilken [målvakt|målvakten|goalie] är {mode}"
        "vem är {mode} [målvakt|goalie]"
        "vilken målvakt har {mode} [räddningsprocent|statistik]"

        # 🦆 says ⮞ schedule / recent / upcoming
        "visa {mode} matcher"
        "vilka matcher spelas {mode}"
        "visa matcher [för] {mode}"
        "när spelar {team} {mode} gång"
        "vilka möter {team} {mode}"
        "vilka matcher har {team} {mode}"
        "när är {team}s {mode} match"

        # 🦆 says ⮞ player stat sentences
        "{count} har {mode} {stat}"
        "visa topp {count} i {stat}"
        "{count} är {stat} i (serie|serien|liga|ligan)"

        # 🦆 says ⮞ single-player / leader queries
        "vilken spelare har gjort {mode} {stat}"
        "vilken spelare har {mode} {stat}"
        "vem har gjort {mode} {stat}"

        # 🦆 says ⮞ team shorthanded goals sentences
        "vilket lag har {mode} {stat}"
        "vem har {mode} {stat} i ligan"
        "vilka har {mode} {stat}"
        "vilket lag har gjort {mode} {stat}"
      ];
      lists = {
        mode.values = [
          { "in" = "[förra|senaste|igår]"; out = "recent"; }
          { "in" = "[idag|nästa|kommande|imorgon]"; out = "upcoming"; }
          { "in" = "[tabellen|ställningen|poängställning]"; out = "table"; }
          { "in" = "[bäst|bästa|best|mest|flest]"; out = "best"; }
          { "in" = "[sämst|sämsta|kassast]"; out = "worst"; }
        ];
        team.values = [
          { "in" = "[björklöven|bjorkloven|löven|bjk]"; out = "björklöven"; }
          { "in" = "[djurgården|djurgården|djurgårdens|dif]"; out = "djurgården"; }
          { "in" = "[växjö|vaxjo|lakers]"; out = "växjö"; }
          { "in" = "[rögle|rogle]"; out = "rögle"; }
          { "in" = "[brynäs|brynas]"; out = "brynäs"; }
          { "in" = "[skellefteå|skelleftea|skellefte|saik]"; out = "skellefteå"; }
          { "in" = "[frölunda|frolunda|fhc]"; out = "frölunda"; }
          { "in" = "[örebro|orebro]"; out = "örebro"; }
          { "in" = "[malmö|malmo|redhawks]"; out = "malmö"; }
          { "in" = "[luleå|lulea|lhf]"; out = "luleå"; }
          { "in" = "[färjestad|farjestad|fbk]"; out = "färjestad"; }
          { "in" = "[linköping|linkoping|lhc]"; out = "linköping"; }
          { "in" = "[timrå|timra]"; out = "timrå"; }
          { "in" = "[leksand|leksands]"; out = "leksand"; }
          { "in" = "[hv71|hv]"; out = "hv71"; }
          { "in" = "[modo|modos]"; out = "modo"; }
        ];
        stat.values = [
          { "in" = "[power|powerplay|pp|överläge|numerärt överläge]"; out = "powerplay"; }
          { "in" = "[box|boxplay|bp|box play|undertal|numerärt underläge]"; out = "boxplay"; }
          { "in" = "[underläge|shorthanded|boxmål|boxplay mål]"; out = "shorthanded_goals"; }
          { "in" = "[målvakt|målvakten|målvakter|goalie|goalkeeper]"; out = "goalkeeper"; }
          { "in" = "[räddningsprocent|räddningar|save percentage]"; out = "save_percentage"; }
          { "in" = "[straff|utvisning|penalty|pim]"; out = "penalty"; }
          { "in" = "[längd|längst|lång]"; out = "tallest"; }
          { "in" = "[kort|kortast]"; out = "shortest"; }
          { "in" = "[vikt|tyngst|tung|tjock|tjockast]"; out = "heaviest"; }
          { "in" = "[lätt|lättast]"; out = "lightest"; }
          { "in" = "[mål|skytter]"; out = "goals"; }
          { "in" = "[assist|passningar]"; out = "assists"; }
          { "in" = "[äldst|äldsta]"; out = "oldest"; }
          { "in" = "[yngst|yngsta]"; out = "youngest"; }
          { "in" = "[underläge|shorthanded|boxmål]"; out = "shorthanded"; }
          { "in" = "[istid|speltid|mest istid]"; out = "icetime"; }
          { "in" = "[poäng]"; out = "points"; }
        ];
        count.values = [
          { "in" = "[1|ett|en|bästa|vem|vilken]"; out = "1"; }
          { "in" = "[2|två|tvåan|näst]"; out = "2"; }
          { "in" = "[3|tre|vilka]"; out = "3"; }
          { "in" = "[5|fem]"; out = "5"; }
          { "in" = "[10|tio]"; out = "10"; }
        ];
      };
    };

  };}
