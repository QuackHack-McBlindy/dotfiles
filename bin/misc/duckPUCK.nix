# dotfiles/bin/misc/duckPUCK.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ hockey assistant and analyzer - SHL + HockeyAllsvenskan
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  swe,
  ...
}:
let
  teamsByLeague = {
    ha = {
      "IF Björklöven"     = { apiName = "Björklöven";    aliases = [ "björklöven" "bjorkloven" "löven" "bjk" ]; };
      "MoDo Hockey"       = { apiName = "MoDo";          aliases = [ "modo" "modos" ]; };
      "BIK Karlskoga"     = { apiName = "Karlskoga";     aliases = [ "karlskoga" "bik" "bofors" ]; };
      "Nybro Vikings IF"  = { apiName = "Nybro";         aliases = [ "nybro" "nybros" "vikings" ]; };
      "Kalmar HC"         = { apiName = "Kalmar";        aliases = [ "kalmar" "kalmars" ]; };
      "IK Oskarshamn"     = { apiName = "Oskarshamn";    aliases = [ "oskarshamn" ]; };
      "Almtuna IS"        = { apiName = "Almtuna";       aliases = [ "almtuna" ]; };
      "AIK"               = { apiName = "AIK";           aliases = [ "aik" "aiks" ]; };
      "Mora IK"           = { apiName = "Mora";          aliases = [ "mora" ]; };
      "Södertälje SK"     = { apiName = "Södertälje";    aliases = [ "södertälje" "sodertalje" ]; };
      "Östersunds IK"     = { apiName = "Östersund";     aliases = [ "östersund" "ostersund" ]; };
      "IF Troja-Ljungby"  = { apiName = "Troja-Ljungby"; aliases = [ "troja" "ljungby" "troja-ljungby" ]; };
      "Västerås IK"       = { apiName = "Västerås";      aliases = [ "västerås" "vasteras" ]; };
      "Vimmerby HC"       = { apiName = "Vimmerby";      aliases = [ "vimmerby" ]; };
    };
    shl = {
      "Djurgårdens IF"    = { apiName = "Djurgårdens IF";   aliases = [ "djurgården" "djurgarden" "djurgårdens" "dif" ]; };
      "Växjö Lakers"      = { apiName = "Växjö Lakers";     aliases = [ "växjö" "vaxjo" "lakers" ]; };
      "Rögle BK"          = { apiName = "Rögle BK";         aliases = [ "rögle" "rogle" ]; };
      "Brynäs IF"         = { apiName = "Brynäs IF";        aliases = [ "brynäs" "brynas" ]; };
      "Skellefteå AIK"    = { apiName = "Skellefteå AIK";   aliases = [ "skellefteå" "skelleftea" "skellefte" "saik" ]; };
      "Frölunda HC"       = { apiName = "Frölunda HC";      aliases = [ "frölunda" "frolunda" "fhc" ]; };
      "Örebro HK"         = { apiName = "Örebro Hockey";    aliases = [ "örebro" "orebro" ]; };
      "Malmö Redhawks"    = { apiName = "Malmö Redhawks";   aliases = [ "malmö" "malmo" "redhawks" ]; };
      "Luleå HF"          = { apiName = "Luleå Hockey";     aliases = [ "luleå" "lulea" "lhf" ]; };
      "Färjestad BK"      = { apiName = "Färjestad BK";     aliases = [ "färjestad" "farjestad" "fbk" ]; };
      "Linköping HC"      = { apiName = "Linköping HC";     aliases = [ "linköping" "linkoping" "lhc" ]; };
      "Timrå IK"          = { apiName = "Timrå IK";         aliases = [ "timrå" "timra" ]; };
      "Leksands IF"       = { apiName = "Leksands IF";      aliases = [ "leksand" "leksands" ]; };
      "HV71"              = { apiName = "HV71";             aliases = [ "hv71" "hv" ]; };
      "Modo Hockey"       = { apiName = "Modo Hockey";      aliases = [ "modo" "modos" ]; };
    };
  };


  leagues = {
    ha = {
      key         = "ha";
      name        = "HockeyAllsvenskan";
      displayName = "Hockey Allsvenskan (SWE)";
      title       = "HOCKEYALLSVENSKAN";
      speakLeague = "allsvenskan";
      apiBase     = "https://www.hockeyallsvenskan.se/api";
      siteHost    = "www.hockeyallsvenskan.se";
      ssgtUuid    = "uy2zvu6xaa";
      tableUrl    = "https://sportstatistik.nu/hockey/hockeyallsvenskan/tabell";
      dataDirName = "hockey";
      logLevel    = "DEBUG";
      aliases     = [ "puck-ha" ];
      voicePrefix = "hockey allsvenskan";
      # 🦆 says ⮞ game-schedule API identifiers (used by duckPUCK-games)
      seasonUuid   = "xs4m9qupsi";
      seriesUuid   = "qQ9-594cW8OWD";
      gameTypeUuid = "qQ9-af37Ti40B";
      teams       = teamsByLeague.ha;
    };
    shl = {
      key         = "shl";
      name        = "SHL";
      displayName = "Swedish Hockey League (SHL)";
      title       = "SHL";
      speakLeague = "SHL";
      apiBase     = "https://www.shl.se/api";
      siteHost    = "www.shl.se";
      ssgtUuid    = "zg0pa4po75";
      tableUrl    = "https://sportstatistik.nu/hockey/shl/tabell";
      dataDirName = "hockey-shl";
      logLevel    = "INFO";
      aliases     = [ "puck" "shl" ];
      voicePrefix = "shl";
      # 🦆 says ⮞ game-schedule API identifiers (used by duckPUCK-games)
      seasonUuid   = "ndcf81nlb3";
      seriesUuid   = "qQ9-bb0bzEWUk";
      gameTypeUuid = "qQ9-af37Ti40B";
      teams       = teamsByLeague.shl;
    };
  };

  numberToText = ''
    number_to_text() {
      local num=$1
      case $num in
        0) echo "noll" ;; 1) echo "ett" ;; 2) echo "två" ;; 3) echo "tre" ;;
        4) echo "fyra" ;; 5) echo "fem" ;; 6) echo "sex" ;; 7) echo "sju" ;;
        8) echo "åtta" ;; 9) echo "nio" ;; 10) echo "tio" ;;
        11) echo "elva" ;; 12) echo "tolv" ;; 13) echo "tretton" ;;
        14) echo "fjorton" ;; 15) echo "femton" ;; 16) echo "sexton" ;;
        17) echo "sjutton" ;; 18) echo "arton" ;; 19) echo "nitton" ;;
        20) echo "tjugo" ;;
        *) echo "$num" ;;
      esac
    }

    position_to_text() {
      local pos=$1
      case $pos in
        1) echo "första" ;; 2) echo "andra" ;; 3) echo "tredje" ;;
        4) echo "fjärde" ;; 5) echo "femte" ;; 6) echo "sjätte" ;;
        7) echo "sjunde" ;; 8) echo "åttonde" ;; 9) echo "nionde" ;;
        10) echo "tionde" ;; 11) echo "elfte" ;; 12) echo "tolfte" ;;
        13) echo "trettonde" ;; 14) echo "fjortonde" ;;
        *) echo "$pos" ;;
      esac
    }
  '';

  pyEnv = pkgs.python3.withPackages (ps: [ ps.requests ]);
  mkScraper = league:
    let
      teamMappingJson = builtins.toJSON (lib.mapAttrs (name: team: team.apiName) league.teams);
    in pkgs.writeScript "hockey-scraper-${league.key}.py" ''
      #!${pyEnv}/bin/python
      import os, re, json, logging, argparse
      import requests

      parser = argparse.ArgumentParser()
      parser.add_argument("--dataDir", type=str, required=True)
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
      SSGT_UUID = "${league.ssgtUuid}"
      API_BASE  = "${league.apiBase}"
      TABLE_URL = "${league.tableUrl}"

      TEAM_MAPPING = ${teamMappingJson}

      def fetch(url):
          logger.info(f"Fetching {url}")
          try:
              r = requests.get(url, headers=headers, timeout=15)
              r.raise_for_status()
              return r.text
          except Exception as e:
              logger.error(f"Failed to fetch {url}: {e}")
              return None

      def fetch_powerplay_data():
          url = f"{API_BASE}/statistics-v2/stats-info/teams_powerplay?count=25&ssgtUuid={SSGT_UUID}&provider=statnet&state=active&moduleType=result"
          html = fetch(url)
          if not html:
              return {}
          try:
              data = json.loads(html)
              return {t['info']['siteDisplayName']: t.get('PPPerc', '?') for t in data[0]['stats']}
          except Exception as e:
              logger.error(f"Failed to parse powerplay: {e}")
              return {}

      def fetch_boxplay_data():
          url = f"{API_BASE}/statistics-v2/stats-info/teams_penaltyKilling?count=25&ssgtUuid={SSGT_UUID}&provider=statnet&state=active&moduleType=result"
          html = fetch(url)
          if not html:
              return {}
          try:
              data = json.loads(html)
              return {t['info']['siteDisplayName']: t.get('PKPerc', '?') for t in data[0]['stats']}
          except Exception as e:
              logger.error(f"Failed to parse boxplay: {e}")
              return {}

      def scrape_table():
          html = fetch(TABLE_URL)
          if not html:
              return []
          table_match = re.search(r'<table[^>]*class="[^"]*table[^"]*"[^>]*>(.*?)</table>', html, re.DOTALL)
          if not table_match:
              table_match = re.search(r'<table[^>]*>(.*?)</table>', html, re.DOTALL)
          if not table_match:
              return []
          rows = re.findall(r'<tr[^>]*>(.*?)</tr>', table_match.group(1), re.DOTALL)
          table_data, seen = [], set()
          for row in rows:
              cells = re.findall(r'<t[dh][^>]*>(.*?)</t[dh]>', row, re.DOTALL)
              if len(cells) < 11:
                  continue
              clean = []
              for cell in cells:
                  c = re.sub(r'<[^>]*>', "", cell)
                  c = re.sub(r'&nbsp;', ' ', c)
                  c = re.sub(r'\s+', ' ', c).strip()
                  clean.append(c)
              if not clean[0].isdigit() or not clean[1] or clean[1] in seen:
                  continue
              seen.add(clean[1])
              table_data.append({
                  "position":        clean[0],
                  "team":            clean[1],
                  "games_played":    clean[2],
                  "wins":            clean[3],
                  "ties":            clean[4],
                  "losses":          clean[5],
                  "overtime_wins":   clean[6],
                  "overtime_losses": clean[7],
                  "goals_for":       clean[8],
                  "goals_against":   clean[9],
                  "goal_difference": clean[10],
                  "points":          clean[11] if len(clean) > 11 else "0",
              })
              if len(table_data) >= 14:
                  break
          return table_data

      def main():
          logger.info("🏒 Starting ${league.name} scraper...")
          table_data = scrape_table()
          pp = fetch_powerplay_data()
          bp = fetch_boxplay_data()
          for team in table_data:
              api_name = TEAM_MAPPING.get(team['team'], team['team'])
              team['powerplay'] = pp.get(api_name, '?')
              team['boxplay']   = bp.get(api_name, '?')
          if table_data:
              with open(table_path, 'w') as f:
                  json.dump(table_data, f, ensure_ascii=False, indent=2)
              logger.info(f"Saved {len(table_data)} teams to {table_path}")
          else:
              logger.warning("No table data to save")
          logger.info("${league.name} scraping completed!")

      if __name__ == "__main__":
          main()
    '';



  mkFuzzyMatch = league:
    let
      teamCases = lib.concatStringsSep "\n"
        (lib.mapAttrsToList (name: team:
          "            ${lib.concatMapStringsSep "|" (a: "*${a}*") team.aliases}) echo \"${name}\"; return 0 ;;"
        ) league.teams);
    in ''
      fuzzy_match_team() {
        local input_team="$1"
        local table_file="$2"
        dt_debug "Fuzzy matching team: $input_team"
        local lowered
        lowered=$(echo "$input_team" | tr '[:upper:]' '[:lower:]')
        case "$lowered" in
          ${teamCases}
        esac

        # 🦆 says ⮞ fall back to fuzzy match against table teams
        local -a teams
        mapfile -t teams < <(jq -r '.[].team' "$table_file")
        local best_match=""
        local best_score=0
        local normalized_input
        normalized_input=$(normalize_string "$input_team")
        for team in "''${teams[@]}"; do
          local normalized_team
          normalized_team=$(normalize_string "$team")
          if [[ "$normalized_team" == *"$normalized_input"* ]] || [[ "$normalized_input" == *"$normalized_team"* ]]; then
            echo "$team"
            return 0
          fi
          local lev_score
          lev_score=$(levenshtein_similarity "$normalized_input" "$normalized_team")
          if (( lev_score > best_score )); then
            best_score=$lev_score
            best_match="$team"
          fi
        done
        if (( best_score >= 30 )); then
          echo "$best_match"
          return 0
        else
          dt_debug "No good fuzzy match (best: $best_match, score: $best_score%)"
          return 1
        fi
      }
    '';


  mkTeamApiMap = league:
    let
      cases = lib.concatStringsSep "\n"
        (lib.mapAttrsToList (name: team:
          "          \"${name}\") echo \"${team.apiName}\" ;;"
        ) league.teams);
    in ''
      map_team_to_api() {
        local team="$1"
        case "$team" in
      ${cases}
          *) echo "$team" ;;
        esac
      }
    '';


  mkVoiceTeamValues = league:
    lib.mapAttrsToList (name: team: {
      "in"  = "[" + lib.concatStringsSep "|" team.aliases + "]";
      out = name;
    }) league.teams;


  sharedSentenceBodies = [
    # generic table
    "tabellen"
    "visa tabellen"
    "hur ser tabellen ut"
    "hur ligger lagen till"
    "vad är ställningen"

    # team-specific
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
    "hur går det för {team} {mode}"
    "analysera {team}"
    "ge en analys av {team}"
    "analysera laget {team}"
    "analysera {team}s {mode} matcher"
    "hur presterade {team} i {mode} matchen"
    "vilka trender har {team}"

    # stat-specific
    "vad har {team} för {stat} statistik"
    "analysera {team} {stat}"
    "hur bra är {team} i {stat}"
    "hur presterar {team} i {stat}"
    "hur ser {team}s {stat} ut"
    "visa {team}s {stat}"
    "analysera {team}s {stat}"
    "ge en analys av {team}s {stat}"

    # heaviest / tallest / other player attributes
    "vem är ligans {stat} spelare"
    "vilken spelare är ligans {stat}"
    "visa ligans {stat} spelare"
    "vem har ligans {mode} {stat}"

    # best / worst leaders
    "vem har ligans {mode} {stat}"
    "vilket lag har ligans {mode} {stat}"
    "vilken målvakt är {mode}"
    "vem är {mode} målvakt"

    # schedule / recent / upcoming
    "visa {mode} matcher"
    "vilka matcher spelas {mode}"
    "när spelar {team} {mode}"
    "vilka möter {team} {mode}"
    "vilka matcher har {team} {mode}"
    "när är {team}s {mode} match"

    # player leaderboards
    "visa topp {count} i {stat}"
    "{count} är {stat} i ligan"

    # single-player queries
    "vilken spelare har gjort {mode} {stat}"
    "vem har gjort {mode} {stat}"

    # team shorthanded goals
    "vilket lag har {mode} {stat}"
    "vem har {mode} {stat} i ligan"
    "vilka har {mode} {stat}"
    "vilket lag har gjort {mode} {stat}"
  ];



  mkDuckPUCKGames = args:
    let
      inherit self lib config pkgs cmdHelpers swe;

      # 🦆 says ⮞ single-game result analyzer
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
          local year=$(echo "$date" | cut -d'-' -f1)
          local month=$(echo "$date" | cut -d'-' -f2)
          local day=$(echo "$date" | cut -d'-' -f3)
          day=$((10#$day))

          local weekday=""
          if command -v date >/dev/null 2>&1; then
            weekday=$(LANG=C ${pkgs.coreutils}/bin/date -d "$date" "+%A" 2>/dev/null || echo "")
          fi

          case $weekday in
            "Monday"|"monday") weekday="Måndag" ;;
            "Tuesday"|"tuesday") weekday="Tisdag" ;;
            "Wednesday"|"wednesday") weekday="Onsdag" ;;
            "Thursday"|"thursday") weekday="Torsdag" ;;
            "Friday"|"friday") weekday="Fredag" ;;
            "Saturday"|"saturday") weekday="Lördag" ;;
            "Sunday"|"sunday") weekday="Söndag" ;;
            "måndag") weekday="Måndag" ;;
            "tisdag") weekday="Tisdag" ;;
            "onsdag") weekday="Onsdag" ;;
            "torsdag") weekday="Torsdag" ;;
            "fredag") weekday="Fredag" ;;
            "lördag") weekday="Lördag" ;;
            "söndag") weekday="Söndag" ;;
            *) weekday=""; dt_info "No matching weekday found for: '$weekday'" ;;
          esac

          local day_text=$(number_to_text "$day")
          local month_name=""
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

          if [[ "$result" =~ ([0-9]+)-([0-9]+) ]]; then
            home_score="''${BASH_REMATCH[1]}"
            away_score="''${BASH_REMATCH[2]}"
          else
            home_score=0
            away_score=0
          fi

          local home_text=$(number_to_text "$home_score")
          local away_text=$(number_to_text "$away_score")

          local winner=""
          if [ "$home_status" = "WIN" ]; then winner="$home_team"; else winner="$away_team"; fi

          local analysis=""
          local score_diff=$((home_score - away_score))
          local abs_diff=$((score_diff > 0 ? score_diff : -score_diff))

          if [ -n "$weekday" ]; then
            analysis="På $weekday den $day_text $month_name "
          else
            analysis="Den $day_text $month_name "
          fi

          analysis+="spelade $home_team mot $away_team i $venue. "
          analysis+="Matchen slutade $home_text-$away_text "

          if [ "$overtime" = "OT" ]; then
            analysis+="efter övertid. "
          elif [ "$overtime" = "SO" ]; then
            analysis+="efter straffläggning. "
          else
            analysis+="i ordinarie tid. "
          fi
          analysis+="$winner tog hem segern. "

          if [ $abs_diff -ge 4 ]; then
            analysis+="Det var en övertygande seger med $abs_diff målskillnad."
          elif [ $abs_diff -eq 1 ]; then
            analysis+="Det var en jämn match som kunde gått vilket hull som helst."
          elif [ $abs_diff -eq 2 ] || [ $abs_diff -eq 3 ]; then
            analysis+="Det var en bra match med spännande strid."
          fi

          if [ "$overtime" = "OT" ] && [ $abs_diff -eq 1 ]; then
            analysis+=" En riktig dramamatch som avgjordes i övertid!"
          elif [ "$overtime" = "SO" ]; then
            analysis+=" Efter straffar fick $winner äran av den tuffa matchen."
          fi
          echo "$analysis"
        }
      '';

      # 🦆 says ⮞ upcoming game analyzer with TTS
      analyzeUpcomingGame = ''
        analyze_upcoming_game() {
          local game_data="$1"
          local team_filter="$2"
          local home_team=$(echo "$game_data" | jq -r '.home_team')
          local away_team=$(echo "$game_data" | jq -r '.away_team')
          local date=$(echo "$game_data" | jq -r '.date')
          dt_info "DATE: $date"
          local venue=$(echo "$game_data" | jq -r '.venue')

          local year=$(echo "$date" | cut -d'-' -f1)
          local month=$(echo "$date" | cut -d'-' -f2)
          local day=$(echo "$date" | cut -d'-' -f3)
          day=$((10#$day))

          local weekday=""
          if command -v date >/dev/null 2>&1; then
            weekday=$(${pkgs.coreutils}/bin/date -d "$date" "+%A" 2>/dev/null || echo "")
            dt_info "WEEKDAY: $weekday"
          fi

          if [ -z "$weekday" ]; then
            local y=$((10#$year)) m=$((10#$month)) d=$((10#$day))
            if [ $m -lt 3 ]; then m=$((m + 12)); y=$((y - 1)); fi
            local k=$((y % 100))
            local j=$((y / 100))
            local h=$((d + (13*(m+1))/5 + k + (k/4) + (j/4) - 2*j))
            local weekday_num=$(( ((h % 7) + 7) % 7 ))
            case $weekday_num in
              1) weekday="Monday" ;; 2) weekday="Tuesday" ;; 3) weekday="Wednesday" ;;
              4) weekday="Thursday" ;; 5) weekday="Friday" ;; 6) weekday="Saturday" ;;
              0) weekday="Sunday" ;; *) weekday="" ;;
            esac
          fi

          case $weekday in
            "Monday"|"monday") weekday="Måndag" ;;
            "Tuesday"|"tuesday") weekday="Tisdag" ;;
            "Wednesday"|"wednesday") weekday="Onsdag" ;;
            "Thursday"|"thursday") weekday="Torsdag" ;;
            "Friday"|"friday") weekday="Fredag" ;;
            "Saturday"|"saturday") weekday="Lördag" ;;
            "Sunday"|"sunday") weekday="Söndag" ;;
            "måndag") weekday="Måndag" ;;
            "tisdag") weekday="Tisdag" ;;
            "onsdag") weekday="Onsdag" ;;
            "torsdag") weekday="Torsdag" ;;
            "fredag") weekday="Fredag" ;;
            "lördag") weekday="Lördag" ;;
            "söndag") weekday="Söndag" ;;
            *) weekday=""; dt_info "No matching weekday found for: '$weekday'" ;;
          esac

          local day_text=$(number_to_text "$day")

          local month_name=""
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

          local our_team="" opponent="" location=""
          if [ "$home_team" = "$team_filter" ]; then
            our_team="$home_team"; opponent="$away_team"; location="hemma"
          else
            our_team="$away_team"; opponent="$home_team"; location="borta"
          fi

          local analysis=""
          if [ -n "$weekday" ]; then
            analysis="På $weekday den $day_text $month_name "
          else
            analysis="Den $day_text $month_name "
          fi

          analysis+="spelar $our_team $location match mot $opponent"
          if [ -n "$venue" ] && [ "$venue" != "null" ]; then
            analysis+=" i $venue"
          fi
          analysis+="."
          echo "$analysis"
        }
      '';

      # 🦆 says ⮞ Swedish date formatter
      formatSwedishDate = ''
        format_swedish_date() {
          local date_str="$1"
          local year=$(echo "$date_str" | cut -d'-' -f1)
          local month=$(echo "$date_str" | cut -d'-' -f2)
          local day=$(echo "$date_str" | cut -d'-' -f3)
          day=$((10#$day))
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
          dt_debug "Analyzing $games_count games..."
          local games_json=$(cat "$games_file")

          if [ -n "$team_filter" ]; then
            games_json=$(echo "$games_json" | jq --arg team "$team_filter" '
              [.[] | select(
                (.home_team | ascii_downcase | contains($team | ascii_downcase)) or
                (.away_team | ascii_downcase | contains($team | ascii_downcase))
              )]')
            games_count=$(echo "$games_json" | jq length)
            dt_debug "Filtered to $games_count games for team: $team_filter"
          fi

          if [ "$games_count" -eq 0 ]; then
            echo "Inga matcher hittades för den valda perioden."
            return 0
          fi

          local dates=$(echo "$games_json" | jq -r '.[].date' | sort -u)

          while IFS= read -r date; do
            [ -z "$date" ] && continue
            local swedish_date=$(format_swedish_date "$date")
            ( unset BOLD; ${pkgs.gum}/bin/gum format "# 🗓️  **$swedish_date:**" )
            echo "----------------------------"
            echo "$games_json" | jq -r --arg date "$date" '
              [.[] | select(.date == $date)] | sort_by(.start_time) | .[] |
              "\(.start_time)|\(.home_team) - \(.away_team)"
            ' | while IFS='|' read -r start_time matchup; do
              local_time=$(TZ=Europe/Stockholm ${pkgs.coreutils}/bin/date -d "$start_time" "+%H:%M" 2>/dev/null || echo "??:??")
              echo "  • $local_time   $matchup"
            done
            echo ""
          done <<< "$dates"

          if [ "$type" = "recent" ]; then
            echo "$games_json" | jq -c '.[]' | while IFS= read -r game_data; do
              local analysis=$(analyze_game "$game_data")
              echo "💬 $analysis"
              echo ""
            done
          elif [ "$type" = "upcoming" ] && [ -n "$team_filter" ]; then
            echo "$games_json" | jq -c '.[]' | while IFS= read -r game_data; do
              local analysis=$(analyze_upcoming_game "$game_data" "$team_filter")
              echo "🔮 $analysis"
              echo ""
            done
          fi
        }
      '';

      filterLiveGames = ''
        filter_live_games() {
          local games_data="$1"
          local now_epoch
          now_epoch=$(${pkgs.coreutils}/bin/date +%s)
          echo "$games_data" | jq -c '.[]' | while IFS= read -r g; do
            local st se
            st=$(echo "$g" | jq -r '.start_time')
            se=$(${pkgs.coreutils}/bin/date -d "$st" +%s 2>/dev/null) || continue
            if [ "$now_epoch" -ge "$se" ] && [ "$now_epoch" -lt "$((se + 12600))" ]; then
              echo "$g"
            fi
          done | jq -s '.'
        }
      '';
    in {
      description = "Hockey Game Assistant. Fetches game schedule/results from SHL or HockeyAllsvenskan and delivers analyzed natural-language responses (TTS).";
      category    = "🧩 Miscellaneous";
      aliases     = [ "hockeyGames" "hag" ];
      logLevel    = "INFO";

      parameters = [
        { name = "type"; type = "string"; description = "Game type: recent, upcoming or live"; optional = true; default = "upcoming";
          values = [ "recent" "upcoming" "live" ];
        }
        { name   = "days"; type = "int"; description = "Number of past days to show"; optional = true; default = 2; }
        { name   = "league"; type = "string"; description = "League name"; optional = false; default = "shl";
          values = [ "shl" "ha" ];
        }
        { name = "team"; type = "string"; description = "Filter games for specific team"; optional = true; }
        { name = "home"; type = "string"; description = "Filter games where this team is the home team"; optional = true; }
        { name = "away"; type = "string"; description = "Filter games where this team is the away team"; optional = true; }
        { name = "json"; type = "bool"; description = "Machine-readable JSON output; exit 0 if games found, 1 if not."; optional = true; default = false; }
        { name = "dataDir"; type = "path"; description = "Directory path to save data in."; optional = true; default = ""; }
        { name = "debug"; type = "bool"; description = "Enable debug mode for API calls"; optional = true; default = false; }
        { name = "check"; type = "bool"; description = "Silent true/false if any game matches (for scripting/voice)"; optional = true; default = false; }
      ];

      code = ''
        ${cmdHelpers}
        ${numberToText}
        ${formatSwedishDate}
        ${analyzeGame}
        ${analyzeRecentGames}
        ${analyzeUpcomingGame}
        ${filterLiveGames}

        fetch_games() {
          local cfg_host cfg_season cfg_series cfg_game_type
          if [ "$league" = "shl" ]; then
            cfg_host="https://${leagues.shl.siteHost}"
            cfg_season="${leagues.shl.seasonUuid}"
            cfg_series="${leagues.shl.seriesUuid}"
            cfg_game_type="${leagues.shl.gameTypeUuid}"
          else
            cfg_host="https://${leagues.ha.siteHost}"
            cfg_season="${leagues.ha.seasonUuid}"
            cfg_series="${leagues.ha.seriesUuid}"
            cfg_game_type="${leagues.ha.gameTypeUuid}"
          fi

          local url="$cfg_host/api/sports-v2/game-schedule?seasonUuid=$cfg_season&seriesUuid=$cfg_series&gameTypeUuid=$cfg_game_type&gamePlace=all&played=all"
          dt_debug "Fetching $league $type games from $url"

          local state_filter
          case "$type" in
            recent)   state_filter="post-game" ;;
            upcoming) state_filter="pre-game"  ;;
            live)     state_filter="pre-game"  ;;
          esac

          curl -sL -H "User-Agent: Mozilla/5.0" "$url" | \
          jq --arg state "$state_filter" '
            [.gameInfo[] |
              select(.state == $state) |
              {
                date:       (.rawStartDateTime | sub("T.*"; "")),
                start_time: .rawStartDateTime,
                state:      .state,
                home_team:  (.homeTeamInfo.names.short | sub("\\s+$"; "")),
                away_team:  (.awayTeamInfo.names.short | sub("\\s+$"; "")),
                result:     "\(.homeTeamInfo.score)-\(.awayTeamInfo.score)",
                overtime:   (if .shootout then "SO" elif .overtime then "OT" else "" end),
                home_score: .homeTeamInfo.score,
                away_score: .awayTeamInfo.score,
                home_status: .homeTeamInfo.status,
                away_status: .awayTeamInfo.status,
                venue:      .venueInfo.name
              }
            ]
          '
        }

        filter_games_by_matchup() {
          local games_data="$1"
          local home_filter="$2"
          local away_filter="$3"
          local team_filter="$4"
          if [ -z "$home_filter" ] && [ -z "$away_filter" ] && [ -z "$team_filter" ]; then
            echo "$games_data"; return 0
          fi
          echo "$games_data" | jq \
            --arg home "$home_filter" \
            --arg away "$away_filter" \
            --arg team "$team_filter" '
            def fold:
              gsub("å";"a") | gsub("ä";"a") | gsub("ö";"o")
              | ascii_downcase
              | gsub("[^a-z0-9 ]"; " ")
              | gsub("\\s+"; " ")
              | sub("^ +"; "") | sub(" +$"; "");
            def club_word:
              . == "if"  or . == "ik"  or . == "hc"  or . == "sk"
              or . == "is" or . == "bk" or . == "ff"
              or . == "lhc" or . == "fhc" or . == "lhf"
              or . == "saik" or . == "dif";
            def strip_club:
              (split(" ") | map(select(club_word | not)) | join(" ")) as $s
              | if ($s | gsub(" "; "")) == "" then . else $s end;
            def norm: fold | strip_club;
            def matches($api; $filter):
              if $filter == "" then true
              else
                ($api | norm) as $a
                | ($filter | norm) as $f
                | if ($a == "" or $f == "") then false
                  else
                    ($a == $f)
                    or ($a | contains($f))
                    or ($f | contains($a))
                    or (
                      (if ($f | length) <= ($a | length) then $f else $a end) as $shorter
                      | (if ($f | length) <= ($a | length) then $a else $f end) as $longer
                      | ($shorter | split(" ")) as $st
                      | ($longer  | split(" ")) as $lt
                      | all($st[];
                          . as $t
                          | any($lt[];
                              . as $u
                              | $u == $t
                              or ($u | contains($t))
                              or ($t | contains($u))
                              or (($u | length) > 2
                                  and ($t | length) > 2
                                  and (($u[0:3]) == ($t[0:3])))))
                    )
                  end
              end;
            def team_matches_either($g; $t):
              $t == "" or matches($g.home_team; $t) or matches($g.away_team; $t);
            [.[]
              | select(
                  matches(.home_team; $home)
                  and matches(.away_team; $away)
                  and team_matches_either(.; $team)
                )]
          '
        }

        filter_games_by_days() {
          local games_data="$1"
          local days="$2"
          local type="$3"
          local cutoff_date=""
          if [ "$type" = "recent" ]; then
            cutoff_date=$(${pkgs.coreutils}/bin/date -d "$days days ago" +%Y-%m-%d)
          else
            cutoff_date=$(${pkgs.coreutils}/bin/date -d "$days days" +%Y-%m-%d)
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

        if [ -z "''${dataDir:-}" ]; then
          user_home="$(getent passwd "$(id -u)" 2>/dev/null | cut -d: -f6)"
          [ -n "$user_home" ] || user_home="''${HOME:-/tmp}"
          dataDir="''${XDG_STATE_HOME:-$user_home/.local/state}/yo/hockey"
        fi

        mkdir -p "$dataDir" 2>/dev/null || {
          dataDir="/tmp/yo-hockey-$(id -u)"
          mkdir -p "$dataDir"
        }

        games_file="$dataDir/''${league}_games.json"
        dt_debug "🏒🦆says⮞ PUCK!"
        games_data=$(fetch_games)
        if [ -z "$games_data" ] || [ "$games_data" = "null" ] || [ "$games_data" = "[]" ]; then
          dt_error "No games data received from API"
          exit 1
        fi

        if [ -z "$team" ] && [ -n "$home" ]; then
          team="$home"
        fi

        if [ -n "$home" ] || [ -n "$away" ]; then
          dt_debug "Matchup search detected (home='$home' away='$away') – overriding days to 365"
          days=365
        fi

        if [ "$type" = "live" ]; then
          filtered_games="$games_data"
        else
          filtered_games=$(filter_games_by_days "$games_data" "$days" "$type")
        fi

        filtered_games=$(filter_games_by_matchup "$filtered_games" "$home" "$away" "$team")

        if [ "$type" = "live" ]; then
          filtered_games=$(filter_live_games "$filtered_games")
        fi

        games_count=$(echo "$filtered_games" | jq length)

        if [ "$check" = "true" ] || { [ "$type" = "live" ] && [ "$json" != "true" ]; }; then
          if [ "$games_count" -gt 0 ]; then echo "true"; else echo "false"; fi
          exit 0
        fi

        if [ "$json" = "true" ]; then
          now_epoch=$(${pkgs.coreutils}/bin/date +%s)
          echo "$filtered_games" | jq -c \
            --argjson now "$now_epoch" --argjson n "$games_count" '
              def start_epoch: (.start_time | sub("\\.[0-9]+"; "") | fromdateiso8601);
              {
                playing: ($n > 0),
                count:   $n,
                games: [.[] | {
                  home:  .home_team,
                  away:  .away_team,
                  start: .start_time,
                  venue: .venue,
                  state: (
                    if .state == "pre-game"
                       and $now >= start_epoch
                       and $now < (start_epoch + 12600)
                    then "live" else .state end
                  )
                }]
              }
            '
          if [ "$games_count" -gt 0 ]; then exit 0; else exit 1; fi
        fi

        if [ "$games_count" -eq 0 ]; then
          dt_error "No games found for the specified criteria"
          exit 1
        fi

        echo "$filtered_games" > "$games_file"
        dt_debug "Found $games_count $type games"

        analysis_output=$(analyze_recent_games "$games_file" "$team")
        echo "$analysis_output"

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
        elif [ "$type" = "upcoming" ] && [ -n "$team" ]; then
          tts_text=$(echo "$analysis_output" | grep "🔮" | sed 's/.*🔮 //')
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

      voice = {
        priority = 2;
        sentences = [
          "(vad|hur) (hände|gick) [det|matchen] (för|med) {team} (senast|igår)"
          "(berätta|visa) (om|) {team} (senaste|sista) match"
          "(vilka|vad) (hände|resultat) (i|) hockyn (igår|senast)"
          "senaste hockymatcherna"
          "allsvenskan matcher"
          "när (är|spelar) {team} [sin] {type} match"
          "hur har {team} spelat [den] {type} [tiden]"
          "hur (var|spelade) {team} {type} matchen"
          "(visa|hitta|sök) (matchen|matcher) (mellan|) {home} (och|mot) {away}"
          "när [möter|spelar|är] [det] {home} [emot|mot|vs] {away}"
          "vilken dag [möter|spelar|är] [det] {home} [emot|mot|vs] {away}"
          "hur länge [kvar] (till|tills) {home} [möter|spelar] [emot|mot|vs] {away}"
          "spelar {team} {type} (nu|ikväll)"
          "kolla om {team} spelar {type} (nu|ikväll)"
          "kolla om {team} {type} match (nu|ikväll)"
          "{team} spelar {type} nu"
        ];
        lists = {
          type.values = [
            { "in" = "kommande|nästa";   out = "upcoming"; }
            { "in" = "senaste|förra";    out = "recent"; }
            { "in" = "just|live|spelar"; out = "live"; }
          ];
          team.values = [
            { "in" = "björklöven|björklövens|löven|vi"; out = "IF Björklöven"; }
            { "in" = "modo|modos";                      out = "MoDo Hockey"; }
            { "in" = "karlskoga|bik|bofors";            out = "BIK Karlskoga"; }
            { "in" = "nybro|nybros|vikings";            out = "Nybro Vikings IF"; }
            { "in" = "kalmar|kalmars";                  out = "Kalmar HC"; }
            { "in" = "oskarshamn";                      out = "IK Oskarshamn"; }
            { "in" = "almtuna";                         out = "Almtuna IS"; }
            { "in" = "aik|aiks";                        out = "AIK"; }
            { "in" = "mora";                            out = "Mora IK"; }
            { "in" = "södertälje";                      out = "Södertälje SK"; }
            { "in" = "östersund";                       out = "Östersunds IK"; }
            { "in" = "västerås";                        out = "Västerås IK"; }
            { "in" = "vimmerby";                        out = "Vimmerby HC"; }
            { "in" = "färjestad|farjestad|fbk";         out = "Färjestad"; }
            { "in" = "rögle|rogle";                     out = "Rögle"; }
            { "in" = "djurgården|djurgarden|dif";       out = "Djurgården"; }
            { "in" = "växjö|vaxjo|lakers";              out = "Växjö"; }
            { "in" = "skellefteå|skelleftea|saik";      out = "Skellefteå"; }
            { "in" = "örebro|orebro";                   out = "Örebro"; }
            { "in" = "luleå|lulea|lhf";                 out = "Luleå"; }
            { "in" = "frölunda|frolunda|fhc";           out = "Frölunda"; }
            { "in" = "brynäs|brynas";                   out = "Brynäs"; }
            { "in" = "linköping|linkoping|lhc";         out = "Linköping"; }
            { "in" = "hv71|hv";                         out = "HV71"; }
          ];
          home.values = [
            { "in" = "björklöven|björklövens|löven|vi"; out = "Björklöven"; }
            { "in" = "modo|modos";                      out = "MoDo"; }
            { "in" = "karlskoga|bik|bofors";            out = "Karlskoga"; }
            { "in" = "nybro|nybros|vikings";            out = "Nybro"; }
            { "in" = "kalmar|kalmars";                  out = "Kalmar"; }
            { "in" = "oskarshamn";                      out = "Oskarshamn"; }
            { "in" = "almtuna";                         out = "Almtuna IS"; }
            { "in" = "aik|aiks";                        out = "AIK"; }
            { "in" = "mora";                            out = "Mora"; }
            { "in" = "södertälje";                      out = "Södertälje"; }
            { "in" = "östersund";                       out = "Östersunds"; }
            { "in" = "västerås";                        out = "Västerås"; }
            { "in" = "vimmerby";                        out = "Vimmerby"; }
            { "in" = "färjestad|farjestad|fbk";         out = "Färjestad"; }
            { "in" = "rögle|rogle";                     out = "Rögle"; }
            { "in" = "djurgården|djurgarden|dif";       out = "Djurgården"; }
            { "in" = "växjö|vaxjo|lakers";              out = "Växjö"; }
            { "in" = "skellefteå|skelleftea|saik";      out = "Skellefteå"; }
            { "in" = "örebro|orebro";                   out = "Örebro"; }
            { "in" = "luleå|lulea|lhf";                 out = "Luleå"; }
            { "in" = "frölunda|frolunda|fhc";           out = "Frölunda"; }
            { "in" = "brynäs|brynas";                   out = "Brynäs"; }
            { "in" = "linköping|linkoping|lhc";         out = "Linköping"; }
            { "in" = "hv71|hv";                         out = "HV71"; }
          ];
          away.values = [
            { "in" = "björklöven|björklövens|löven|vi"; out = "Björklöven"; }
            { "in" = "modo|modos";                      out = "MoDo Hockey"; }
            { "in" = "karlskoga|bik|bofors";            out = "Karlskoga"; }
            { "in" = "nybro|nybros|vikings";            out = "Nybro"; }
            { "in" = "kalmar|kalmars";                  out = "Kalmar"; }
            { "in" = "oskarshamn";                      out = "IK Oskarshamn"; }
            { "in" = "almtuna";                         out = "Almtuna"; }
            { "in" = "aik|aiks";                        out = "AIK"; }
            { "in" = "mora";                            out = "Mora"; }
            { "in" = "södertälje";                      out = "Södertälje"; }
            { "in" = "östersund";                       out = "Östersunds"; }
            { "in" = "västerås";                        out = "Västerås"; }
            { "in" = "vimmerby";                        out = "Vimmerby"; }
            { "in" = "färjestad|farjestad|fbk";         out = "Färjestad"; }
            { "in" = "rögle|rogle";                     out = "Rögle"; }
            { "in" = "djurgården|djurgarden|dif";       out = "Djurgården"; }
            { "in" = "växjö|vaxjo|lakers";              out = "Växjö"; }
            { "in" = "skellefteå|skelleftea|saik";      out = "Skellefteå"; }
            { "in" = "örebro|orebro";                   out = "Örebro"; }
            { "in" = "luleå|lulea|lhf";                 out = "Luleå"; }
            { "in" = "frölunda|frolunda|fhc";           out = "Frölunda"; }
            { "in" = "brynäs|brynas";                   out = "Brynäs"; }
            { "in" = "linköping|linkoping|lhc";         out = "Linköping"; }
            { "in" = "hv71|hv";                         out = "HV71"; }
          ];
        };
      };
    };


  mkDuckPUCK = leagueKey: league: args:
    let
      inherit self lib config pkgs cmdHelpers swe;

      scraper       = mkScraper league;
      fuzzyMatch    = mkFuzzyMatch league;
      teamApiMap    = mkTeamApiMap league;
      voiceTeamVals = mkVoiceTeamValues league;
    in {
      description = "[🏒🦆] - Your Personal Hockey Assistant! - Expert commentary and analyzer specialized on ${league.displayName}. Analyzing games, scraping scoreboards and keeping track of all dates and numbers.";
      category    = "🧩 Miscellaneous";
      aliases     = league.aliases;
      logLevel    = league.logLevel;

      parameters = [
        { name        = "mode"; description = "What to display/fetch"; optional = false;
          values      = [ # swe.allowFrom "mode"; #[
            "recent" "upcoming"
            "best" "worst" "table"
          ];
          default     = "table";
        }
        { name = "team"; description = "Team specific search with TTS"; optional = true; }
        { name = "stat"; description = "Search for specific stats.";
          type        = "string";
          optional    = true;
          values      = [
            "powerplay" "boxplay"
            "shorthanded_goals" "shorthanded"
            "goalkeeper" "save_percentage"
            "penalty" "tallest" "shortest"
            "heaviest" "lightest"
            "oldest" "youngest" "icetime"
            "goals" "assists" "points"
          ];
        }
        { name = "count";   description = "Optional number to fetch stats for"; optional = true; type = "int"; default = 3; }
        { name = "dataDir"; description = "Directory path to save data."; optional = false;
          default = "/home/" + config.this.user.me.name + "/.config/yo/${league.dataDirName}"; }
      ];

      code = ''
        ${cmdHelpers}
        ${numberToText}
        ${fuzzyMatch}
        ${teamApiMap}

        API_BASE="${league.apiBase}"
        SSGT_UUID="${league.ssgtUuid}"
        LEAGUE_NAME="${league.speakLeague}"
        LEAGUE_TITLE="${league.title}"

        analyze_team() {
          local team_name="$1"
          local table_file="$2"
          dt_debug "Analyzing team: $team_name"
          local team_data
          team_data=$(jq -r ".[] | select(.team == \"$team_name\")" "$table_file")
          if [ -z "$team_data" ]; then
            dt_error "Team '$team_name' not found in table"
            return 1
          fi

          local position points wins losses ties goals_for goals_against goal_diff games_played
          position=$(echo "$team_data" | jq -r '.position')
          points=$(echo "$team_data" | jq -r '.points')
          wins=$(echo "$team_data" | jq -r '.wins')
          losses=$(echo "$team_data" | jq -r '.losses')
          ties=$(echo "$team_data" | jq -r '.ties')
          goals_for=$(echo "$team_data" | jq -r '.goals_for')
          goals_against=$(echo "$team_data" | jq -r '.goals_against')
          goal_diff=$(echo "$team_data" | jq -r '.goal_difference')
          games_played=$(echo "$team_data" | jq -r '.games_played')

          local points_text wins_text losses_text games_played_text goal_diff_text
          local goals_for_text goals_against_text position_text
          points_text=$(number_to_text "$points")
          wins_text=$(number_to_text "$wins")
          losses_text=$(number_to_text "$losses")
          games_played_text=$(number_to_text "$games_played")
          goal_diff_text=$(number_to_text "$goal_diff")
          goals_for_text=$(number_to_text "$goals_for")
          goals_against_text=$(number_to_text "$goals_against")
          position_text=$(position_to_text "$position")

          local analysis=""
          case $position in
            1)
              analysis="Det går jättebra för $team_name just nu! Dom leder $LEAGUE_NAME med $points_text poäng efter $games_played_text matcher. "
              analysis+="Med $wins_text vinster och bara $losses_text förluster är dom klara serieledare. "
              analysis+="Dom har överlägset bäst målskillnad på $goal_diff_text och släpper sällan in mål med bara $goals_against_text insläppta."
              ;;
            2|3)
              analysis="$team_name ligger bra till på $position_text plats med $points_text poäng. "
              analysis+="Med $wins_text vinster och $losses_text förluster är dom med och kämpar i toppen."
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

          local ot_wins ot_losses ot_wins_text ot_losses_text
          ot_wins=$(echo "$team_data" | jq -r '.overtime_wins')
          ot_losses=$(echo "$team_data" | jq -r '.overtime_losses')
          ot_wins_text=$(number_to_text "$ot_wins")
          ot_losses_text=$(number_to_text "$ot_losses")
          if [ "$ot_wins" -gt 2 ]; then
            analysis+=" Laget är tuffa i övertid med $ot_wins_text övertidsvinster."
          elif [ "$ot_losses" -gt 2 ]; then
            analysis+=" Dom har haft otur i övertid med $ot_losses_text övertidsförluster."
          fi
          echo "$analysis"
        }

        hockey_news() {
          response=$(curl -s -L \
              -H "Accept: application/json; charset=utf-8" \
              -H "User-Agent: HockeyNews/1.0" \
              "https://${league.siteHost}/api/articles/site-news/list?page=0&pagesize=10&orderByDate=desc")
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

        get_team_powerplay() {
          local team_name="$1"
          if [ -z "$team_name" ]; then
            dt_error "Please specify a team name"
            return 1
          fi
          local endpoint="$API_BASE/statistics-v2/stats-info/teams_powerplay?count=25&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=result"
          local response
          response=$(curl -s -L -H "Accept: application/json; charset=utf-8" -H "User-Agent: HockeyStats/1.0" "$endpoint")
          if [ $? -ne 0 ]; then
            dt_error "Failed to fetch powerplay data"
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


        get_team_boxplay() {
          local team_name="$1"
          if [ -z "$team_name" ]; then
            dt_error "Please specify a team name"
            return 1
          fi
          local endpoint="$API_BASE/statistics-v2/stats-info/teams_penaltyKilling?count=25&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=result"
          local response
          response=$(curl -s -L -H "Accept: application/json; charset=utf-8" -H "User-Agent: HockeyStats/1.0" "$endpoint")
          if [ $? -ne 0 ]; then
            dt_error "Failed to fetch boxplay data"
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

        analyze_special_teams() {
          local query_type="$1"
          local table_file="$2"
          if [ ! -f "$table_file" ]; then
            dt_error "Table file not found: $table_file"
            return 1
          fi
          case "$query_type" in
            "best-powerplay")
              local row
              row=$(jq -r '[.[] | select(.powerplay != "?" and .powerplay != null) | {team: .team, e: (.powerplay | sub("%"; "") | tonumber)}] | sort_by(.e) | reverse | .[0] | "\(.team)|\(.e)"' "$table_file")
              if [ -n "$row" ] && [ "$row" != "null" ]; then
                IFS='|' read -r team efficiency <<< "$row"
                echo "$team har $LEAGUE_NAME s bästa powerplay med $efficiency% i effektivitet."
              else echo "Kunde inte hitta data om powerplay."; fi
              ;;
            "worst-powerplay")
              local row
              row=$(jq -r '[.[] | select(.powerplay != "?" and .powerplay != null) | {team: .team, e: (.powerplay | sub("%"; "") | tonumber)}] | sort_by(.e) | .[0] | "\(.team)|\(.e)"' "$table_file")
              if [ -n "$row" ] && [ "$row" != "null" ]; then
                IFS='|' read -r team efficiency <<< "$row"
                echo "$team har $LEAGUE_NAME s sämsta powerplay med bara $efficiency% i effektivitet."
              else echo "Kunde inte hitta data om powerplay."; fi
              ;;
            "best-boxplay")
              local row
              row=$(jq -r '[.[] | select(.boxplay != "?" and .boxplay != null) | {team: .team, e: (.boxplay | sub("%"; "") | tonumber)}] | sort_by(.e) | reverse | .[0] | "\(.team)|\(.e)"' "$table_file")
              if [ -n "$row" ] && [ "$row" != "null" ]; then
                IFS='|' read -r team efficiency <<< "$row"
                echo "$team har $LEAGUE_NAME s bästa boxplay med $efficiency% i effektivitet."
              else echo "Kunde inte hitta data om boxplay."; fi
              ;;
            "worst-boxplay")
              local row
              row=$(jq -r '[.[] | select(.boxplay != "?" and .boxplay != null) | {team: .team, e: (.boxplay | sub("%"; "") | tonumber)}] | sort_by(.e) | .[0] | "\(.team)|\(.e)"' "$table_file")
              if [ -n "$row" ] && [ "$row" != "null" ]; then
                IFS='|' read -r team efficiency <<< "$row"
                echo "$team har $LEAGUE_NAME s sämsta boxplay med bara $efficiency% i effektivitet."
              else echo "Kunde inte hitta data om boxplay."; fi
              ;;
          esac
        }

        display_table_with_special_teams() {
          local table_file="$1"
          if [ ! -f "$table_file" ]; then
            dt_error "Table file not found"
            return 1
          fi
          {
            echo "# 🏆 $LEAGUE_TITLE 25/26"
            echo "| Pos | Lag | M | V | X | F | ÖV | ÖF | + | - | +/- | P | PP | BP |"
            echo "|-----|-----|---|---|---|---|----|----|----|----|-----|---|-----|-----|"
            jq -r '.[] | "| \(.position) | \(.team) | \(.games_played) | \(.wins) | \(.ties) | \(.losses) | \(.overtime_wins) | \(.overtime_losses) | \(.goals_for) | \(.goals_against) | \(.goal_difference) | \(.points) | \(.powerplay) | \(.boxplay) |"' "$table_file"
          } | ${pkgs.glow}/bin/glow -
        }

        get_player_stats() {
          local stat_type="$1"
          local count="$2"
          local endpoint="$API_BASE/statistics-v2/stats-info/players_point"
          local params="count=100&sortKey=TP&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=point"
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
                "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Längd: \(.info.height.value) \(.info.height.format)"'
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
                "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Vikt: \(.info.weight.value) \(.info.weight.format)"'
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
                "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Född: \(.info.birthDate)"'
              ;;
            "goals"|"points"|"assists")
              local sort_key
              case "$stat_type" in
                "goals")   sort_key="G"  ;;
                "points")  sort_key="TP" ;;
                "assists") sort_key="A"  ;;
              esac
              local endpoint2="$API_BASE/statistics-v2/stats-info/players_point"
              local params2="count=$count&sortKey=$sort_key&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=point"
              response=$(curl -s "''${endpoint2}?''${params2}")
              # 🦆 says ⮞ FIX: use --arg for $stat and $k (was broken in HA original)
              echo "$response" | jq -r --arg stat "$stat_type" --arg k "$sort_key" '
                .[0].stats[] |
                "\(.Rank). \(.info.fullName) (\(.info.team.name)) - \($stat): \(.[$k])"'
              ;;
            "icetime")
              echo "$response" | jq -r '
                .[0].stats |
                map(select(.TOI_GP != null)) |
                sort_by((.TOI_GP | split(":") | (.[0]|tonumber)*60 + (.[1]|tonumber))) |
                reverse |
                .[0:'$count'] |
                .[] |
                "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Istid: \(.TOI_GP) per match"'
              ;;
            "shorthanded")
              echo "$response" | jq -r '
                .[0].stats |
                sort_by(-.SHTP) |
                .[0:'$count'] |
                .[] |
                "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Boxplay poäng: \(.SHTP)"'
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
          local endpoint="$API_BASE/statistics-v2/stats-info/goalkeepers_summary"
          local sort_key="svPct"
          local json_key="SVSPerc"
          local description="Räddningsprocent"
          case "$stat_type" in
            "save_percentage") sort_key="svPct"; json_key="SVSPerc"; description="Räddningsprocent" ;;
            "gaa")             sort_key="GAA";   json_key="GAA";     description="Insläppta mål i snitt" ;;
          esac
          local params="count=$count&sortKey=$sort_key&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=goal"
          local response
          response=$(curl -s "''${endpoint}?''${params}")
          echo "$response" | jq -r --arg description "$description" --arg k "$json_key" '
            .[0].stats[] |
            "\(.Rank). \(.info.fullName) (\(.info.team.name)) - \($description): \(.[$k])"'
        }

        get_best_goalkeeper() {
          local endpoint="$API_BASE/statistics-v2/stats-info/goalkeepers_summary"
          local params="count=1&sortKey=svPct&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=goal"
          local response
          response=$(curl -s "''${endpoint}?''${params}")
          if [ $? -ne 0 ]; then
            echo "NOT_FOUND"
            return 1
          fi
          echo "$response" | jq -r '
            .[0].stats[0] |
            "\(.info.fullName)|\(.info.team.name)|\(.SVSPerc)|\(.GP)|\(.GAA)|\(.SO)"'
        }


        get_most_shorthanded_goals() {
          local endpoint="$API_BASE/statistics-v2/stats-info/teams_penaltyKilling?count=25&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=result"
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
            "\(.info.siteDisplayName) - \(.SHG) boxplay mål"'
        }

        get_top_shorthanded_teams() {
          local count="''${1:-5}"
          local endpoint="$API_BASE/statistics-v2/stats-info/teams_penaltyKilling?count=25&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=result"
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
            "\(.Rank). \(.info.siteDisplayName) - \(.SHG) boxplay mål"'
        }


        handle_player_stat_query() {
          local stat="$1"
          local count="$2"
          dt_debug "Processing stat query: stat=$stat, count=$count"
          case "$stat" in
            "goals"|"points"|"assists"|"tallest"|"heaviest"|"oldest"|"youngest"|"icetime"|"shorthanded"|"shortest"|"lightest")
              get_player_stats "$stat" "$count"
              ;;
            "save_percentage"|"gaa")
              get_goalie_stats "$stat" "$count"
              ;;
            "penalty")
              local endpoint="$API_BASE/statistics-v2/stats-info/players_penalty"
              local params="count=$count&sortKey=PM&ssgtUuid=$SSGT_UUID&provider=statnet&state=active&moduleType=penalty"
              local response
              response=$(curl -s "''${endpoint}?''${params}")
              echo "$response" | jq -r '
                .[0].stats[] |
                "\(.Rank). \(.info.fullName) (\(.info.team.name)) - Utvisningsminuter: \(.PM)"'
              ;;
            *)
              dt_error "Unknown stat: $stat"
              echo "❌ Okänd statistik: $stat"
              ;;
          esac
        }


        # MAIN

        dt_info "[🏒🦆] duckPUCK🏒🦆 ${league.name}!"
        ${scraper} --dataDir "$dataDir"
        status=$?
        if [ $status -ne 0 ]; then
          dt_error "duck say fuck failed with exit code $status"
          exit $status
        fi
        dt_debug "Scraping done, files updated in $dataDir"
        table_file="$dataDir/table.json"


        if [ -n "$stat" ] && [ -z "$team" ]; then
          if { [ "$stat" = "powerplay" ] || [ "$stat" = "boxplay" ] || [ "$stat" = "shorthanded_goals" ]; } \
             && { [ "$mode" = "best" ] || [ "$mode" = "worst" ]; }; then
            dt_debug "Handling best/worst team stat query - mode: $mode, stat: $stat"
            if [ -f "$table_file" ]; then
              if [ "$stat" = "shorthanded_goals" ]; then
                if [ "$mode" = "best" ]; then
                  result=$(get_most_shorthanded_goals)
                  if [ $? -eq 0 ] && [ -n "$result" ]; then
                    analysis="$result är laget som gjort mest boxplay mål i $LEAGUE_NAME!"
                    echo "$analysis"
                    yo say --text "$analysis" --silence "0.8"
                  fi
                else
                  result=$(get_top_shorthanded_teams 14 | tail -1)
                  if [ $? -eq 0 ] && [ -n "$result" ]; then
                    analysis="$result har gjort minst boxplay mål i $LEAGUE_NAME."
                    echo "$analysis"
                    yo say --text "$analysis" --silence "0.8"
                  fi
                fi
              else
                analysis=$(analyze_special_teams "$mode-$stat" "$table_file")
                echo "$analysis"
                yo say --text "$analysis" --silence "0.8"
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
              yo say --text "$speech_result" --silence "0.8"
            fi
            exit 0
          fi
        fi


        if [ "$stat" = "goalkeeper" ]; then
          if [ -n "$team" ]; then
            api_team=$(map_team_to_api "$team")
            if [ "$mode" = "best" ]; then
              best_gk_data=$(get_best_goalkeeper)
              if [ "$best_gk_data" != "NOT_FOUND" ]; then
                IFS='|' read -r gk_name gk_team gk_save_percent gk_games gk_gaa gk_shutouts <<< "$best_gk_data"
                analysis="$LEAGUE_NAME s bästa målvakt just nu är $gk_name från $gk_team med $gk_save_percent% i räddningsprocent."
                analysis+=" Efter $gk_games matcher har $gk_name bara släppt in $gk_gaa mål i genomsnitt och hållit $gk_shutouts nollor."
                if [ "$gk_team" = "$api_team" ]; then
                  analysis+=" DET ÄR EN $team MÅLVAKT SOM LEDER LIGAN! GRATTIS!"
                fi
                echo "$analysis"
                yo say --text "$analysis" --silence "0.8"
              fi
            else
              echo "Målvaktsstatistik för $team:"
              get_goalie_stats "save_percentage" 25 | grep "$api_team" || echo "Ingen målvaktsdata hittades för $team"
            fi
          else
            if [ "$mode" = "best" ]; then
              best_gk_data=$(get_best_goalkeeper)
              if [ "$best_gk_data" != "NOT_FOUND" ] && [ -n "$best_gk_data" ]; then
                IFS='|' read -r gk_name gk_team gk_save_percent gk_games gk_gaa gk_shutouts <<< "$best_gk_data"
                analysis="$LEAGUE_NAME s bästa målvakt just nu är $gk_name från $gk_team med $gk_save_percent% i räddningsprocent."
                echo "$analysis"
                yo say --text "$analysis" --silence "0.8"
              fi
            else
              get_goalie_stats "save_percentage" $count
            fi
          fi
          exit 0
        fi


        if [ -n "$team" ]; then
          if [ -f "$table_file" ]; then
            matched_team=$(fuzzy_match_team "$team" "$table_file")
            if [ $? -eq 0 ]; then
              team="$matched_team"
            else
              dt_warning "No fuzzy match found for '$team', using exact match"
            fi
            api_team=$(map_team_to_api "$team")

            if [ "$stat" = "powerplay" ]; then
              pp_data=$(get_team_powerplay "$api_team")
              pp_perc=$(echo "$pp_data" | grep "Power Play Efficiency:" | awk '{print $4}' | sed 's/%//')
              rank=$(echo "$pp_data" | grep "Rank:" | awk '{print $2}')
              echo "$pp_data" && echo ""
              if [[ "$pp_perc" =~ ^[0-9.]+$ ]]; then
                case "$rank" in
                  1)    pp_analysis="JÄVLAR ANKA! $team har $LEAGUE_NAME s BÄSTA POWERPLAY på rank ''${rank} med ''${pp_perc}%! " ;;
                  2|3)  pp_analysis="$team har ett ELIT powerplay på rank ''${rank} med ''${pp_perc}%. " ;;
                  4|5|6) pp_analysis="$team har ett SOLITT powerplay på rank ''${rank} med ''${pp_perc}%. " ;;
                  7|8|9) pp_analysis="$team har ett OK powerplay på rank ''${rank} med ''${pp_perc}%. " ;;
                  *)    pp_analysis="$team har ett powerplay på ''${pp_perc}% på rank ''${rank}. " ;;
                esac
                dt_info "🏒🦆duckPUCK🏒🦆 POWERPLAY ANALYS:"
                echo "$pp_analysis"
                yo say "$pp_analysis" --silence "0.8"
              fi

            elif [ "$stat" = "boxplay" ]; then
              bp_data=$(get_team_boxplay "$api_team")
              bp_perc=$(echo "$bp_data" | grep "Boxplay Efficiency:" | awk '{print $3}' | sed 's/%//')
              rank=$(echo "$bp_data" | grep "Rank:" | awk '{print $2}')
              echo "$bp_data" && echo ""
              if [[ "$bp_perc" =~ ^[0-9.]+$ ]]; then
                case "$rank" in
                  1)    bp_analysis="HELT OTROLIGT! $team har $LEAGUE_NAME s BÄSTA BOXPLAY på rank ''${rank} med ''${bp_perc}%! " ;;
                  2|3)  bp_analysis="$team har ett FENOMENALT boxplay på rank ''${rank} med ''${bp_perc}%. " ;;
                  4|5|6) bp_analysis="$team har ett STABILT boxplay på rank ''${rank} med ''${bp_perc}%. " ;;
                  7|8|9) bp_analysis="$team har ett OK boxplay på rank ''${rank} med ''${bp_perc}%. " ;;
                  *)    bp_analysis="$team har ett boxplay på ''${bp_perc}% på rank ''${rank}. " ;;
                esac
                dt_info "🏒🦆duckPUCK🏒🦆 BOXPLAY ANALYS:"
                echo "$bp_analysis"
                yo say "$bp_analysis" --silence "0.8"
              fi

            else
              team_analysis=$(analyze_team "$team" "$table_file")
              if [ $? -eq 0 ]; then
                dt_info "🏒🦆duckPUCK🏒🦆 TEAM ANALYS:"
                echo "$team_analysis"
                yo say "$team_analysis" --silence "0.8"
              fi
            fi
          else
            dt_error "No table data found for analysis"
          fi
        else
          if [ -f "$table_file" ]; then
            team_count=$(jq length "$table_file" 2>/dev/null || echo "0")
            dt_debug "Found $team_count teams in table"
            echo ""
            ( unset BOLD; ${pkgs.gum}/bin/gum format "# 🗞️ **${league.title} NYHETER**" )
            hockey_news | head -5 && echo "----------------------------" && echo ""
            display_table_with_special_teams "$table_file"
            echo ""

            yo duckPUCK-games --league ${leagueKey}
          else
            dt_error "No table data found at $table_file"
          fi
        fi
      '';

      voice = {
        enabled  = true;
        priority = 4;
        sentences = map (s: "${league.voicePrefix} ${s}") sharedSentenceBodies;
        lists = {
          mode.values = [
            { "in" = "förra|senaste|igår";                  out = "recent"; }
            { "in" = "idag|nästa|kommande|imorgon";         out = "upcoming"; }
            { "in" = "tabellen|ställningen|poängställning"; out = "table"; }
            { "in" = "bäst|bästa|best|mest|flest";          out = "best"; }
            { "in" = "sämst|sämsta|kassast";                out = "worst"; }
          ];
          team.values = voiceTeamVals;
          stat.values = [
            { "in" = "power|powerplay|pp|överläge|numerärt överläge";       out = "powerplay"; }
            { "in" = "box|boxplay|bp|box play|undertal|numerärt underläge"; out = "boxplay"; }
            { "in" = "underläge|shorthanded|boxmål|boxplay mål";            out = "shorthanded_goals"; }
            { "in" = "målvakt|målvakten|målvakter|goalie|goalkeeper";       out = "goalkeeper"; }
            { "in" = "räddningsprocent|räddningar|save percentage";         out = "save_percentage"; }
            { "in" = "straff|utvisning|penalty|pim";                        out = "penalty"; }
            { "in" = "längd|längst|lång";                                   out = "tallest"; }
            { "in" = "kort|kortast";                                        out = "shortest"; }
            { "in" = "vikt|tyngst|tung|tjock|tjockast";                     out = "heaviest"; }
            { "in" = "lätt|lättast";                                        out = "lightest"; }
            { "in" = "mål|skytter";                                         out = "goals"; }
            { "in" = "assist|passningar";                                   out = "assists"; }
            { "in" = "äldst|äldsta";                                        out = "oldest";  }
            { "in" = "yngst|yngsta";                                        out = "youngest"; }
            { "in" = "underläge|shorthanded|boxmål";                        out = "shorthanded"; }
            { "in" = "istid|speltid|mest istid";                            out = "icetime"; }
            { "in" = "poäng";                                               out = "points"; }
          ];
          count.values = [
            { "in" = "[1|ett|en|bästa|vem|vilken]"; out = "1"; }
            { "in" = "[2|två|tvåan|näst]";          out = "2"; }
            { "in" = "[3|tre|vilka]";               out = "3"; }
            { "in" = "[5|fem]";                     out = "5"; }
            { "in" = "[10|tio]";                    out = "10"; }
          ];
        };
      };
    };

in {
  yo.scripts = {
    "duckPUCK-ha"    = mkDuckPUCK "ha"  leagues.ha;
    "duckPUCK-shl"   = mkDuckPUCK "shl" leagues.shl;
    "duckPUCK-games" = mkDuckPUCKGames;
  };}
