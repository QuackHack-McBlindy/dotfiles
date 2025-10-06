{ # 🦆 says ⮞ collects data from played games and gives detailed reports and season table 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
}: let
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
    games_path = os.path.join(args.dataDir, "games.json")
    table_path = os.path.join(args.dataDir, "table.json")
    state_path = os.path.join(args.dataDir, "scraped_games.json")
    logging.basicConfig(level=logging.INFO, format="[🦆🏒] %(levelname)s - %(message)s")
    logger = logging.getLogger()
    # 🦆 says ⮞ load state
    if os.path.exists(state_path):
        with open(state_path) as f:
            scraped = set(json.load(f))
    else:
        scraped = set()

    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5",
    }

    def fetch(url):
        logger.info(f"Fetching {url}")
        try:
            r = requests.get(url, headers=headers, timeout=15)
            r.raise_for_status()
            return r.text
        except Exception as e:
            logger.error(f"Failed to fetch {url}: {e}")
            return None

    def scrape_schedule():
        """Find finished games from schedule page"""
        url = "https://www.hockeyallsvenskan.se/game-schedule"
        html = fetch(url)
        if not html:
            return []
        
        logger.info("Looking for game links in schedule...")
        
        game_links = re.findall(r'href="(/game-center/[^"]+)"', html)
        logger.info(f"Found {len(game_links)} total game links")
        
        # 🦆 says ⮞ filter for finished games - look for "Efter matchen" or post-game indicators
        finished_games = []
        for link in game_links:
            full_url = "https://www.hockeyallsvenskan.se" + link
            
            # Check if this is a finished game by looking for post-game state
            if 'state=post-game' in link:
                finished_games.append(full_url)
            else:
                try:
                    game_html = fetch(full_url)
                    if game_html and ('Efter matchen' in game_html or 'efter matchen' in game_html):
                        finished_games.append(full_url + "?state=post-game")
                except:
                    continue
        
        logger.info(f"Found {len(finished_games)} finished games")
        return finished_games

    def scrape_game_basic_info(url):
        """Scrape basic game info without detailed report"""
        logger.info(f"Getting basic info from: {url}")
        html = fetch(url)
        if not html:
            return None
        
        game_id_match = re.search(r'/game-center/[^/]+/([^/?]+)', url)
        game_id = game_id_match.group(1) if game_id_match else url
        
        teams = []
        score = ""
        
        team_patterns = [
            r'<span[^>]*class="[^"]*team-name[^"]*"[^>]*>([^<]+)</span>',
            r'<div[^>]*class="[^"]*team[^"]*"[^>]*>.*?<span[^>]*>([^<]+)</span>',
            r'data-team-name="([^"]*)"',
            r'<h2[^>]*>([^<]+)</h2>'
        ]
        
        for pattern in team_patterns:
            found_teams = re.findall(pattern, html, re.IGNORECASE)
            if len(found_teams) >= 2:
                teams = found_teams[:2]
                break
        
        score_patterns = [
            r'<span[^>]*class="[^"]*score[^"]*"[^>]*>([^<]+)</span>',
            r'<div[^>]*class="[^"]*result[^"]*"[^>]*>([^<]+)</div>',
            r'(\d+\s*-\s*\d+)'
        ]
        
        for pattern in score_patterns:
            found_scores = re.findall(pattern, html, re.IGNORECASE)
            if found_scores:
                score = found_scores[0]
                break
        
        return {
            "id": game_id,
            "url": url,
            "date": datetime.now().strftime("%Y-%m-%d"),
            "teams": teams if teams else ["Unknown", "Unknown"],
            "score": score.strip() if score else "Unknown",
            "scraped_at": datetime.now().isoformat()
        }

    def scrape_table():
        """Scrape complete league table with all stats"""
        url = "https://sportstatistik.nu/hockey/hockeyallsvenskan/tabell"
        html = fetch(url)
        if not html:
            logger.error("Failed to fetch table")
            return []
        
        logger.info("Parsing table data...")
        table_data = []
        rows = re.findall(r'<tr[^>]*>(.*?)</tr>', html, re.DOTALL)
        logger.info(f"Found {len(rows)} table rows")
        
        for row in rows:
            cells = re.findall(r'<t[dh][^>]*>(.*?)</t[dh]>', row, re.DOTALL)
            if len(cells) >= 11:  # We need all columns including OTW, OTL, etc.
                clean_cells = []
                for cell in cells:
                    clean = re.sub(r'<[^>]*>', "", cell)
                    clean = re.sub(r'&nbsp;', ' ', clean)
                    clean = re.sub(r'\s+', ' ', clean).strip()
                    clean_cells.append(clean)
                
                if clean_cells[1] == 'Lag' or not clean_cells[0].isdigit():
                    continue
                
                table_data.append({
                    "position": clean_cells[0],
                    "team": clean_cells[1],
                    "games_played": clean_cells[2],
                    "wins": clean_cells[3],
                    "ties": clean_cells[4],  # T
                    "losses": clean_cells[5],  # L
                    "overtime_wins": clean_cells[6],  # OTW
                    "overtime_losses": clean_cells[7],  # OTL
                    "goals_for": clean_cells[8],  # G
                    "goals_against": clean_cells[9],  # GA
                    "goal_difference": clean_cells[10],  # +/-
                    "points": clean_cells[11] if len(clean_cells) > 11 else "0"
                })
        
        logger.info(f"Extracted {len(table_data)} teams with complete stats")
        return table_data

    def main():
        """Main execution function"""
        logger.info("🏒 Starting hockey scraper...")
        
        # 🦆 says ⮞ First, let's just get basic game results
        logger.info("📅 Looking for recent game results...")
        game_urls = scrape_schedule()
        new_games = []
        
        for url in game_urls:
            game_id_match = re.search(r'/game-center/[^/]+/([^/?]+)', url)
            if not game_id_match:
                continue
                
            game_id = game_id_match.group(1)
            
            if game_id not in scraped:
                game_data = scrape_game_basic_info(url)
                if game_data:
                    new_games.append(game_data)
                    scraped.add(game_id)
                    logger.info(f"✅ Added game: {game_data['teams'][0]} vs {game_data['teams'][1]} - {game_data['score']}")
                else:
                    logger.warning(f"❌ Failed to scrape game: {url}")
            else:
                logger.debug(f"📝 Game already scraped: {game_id}")
        
        if not new_games:
            logger.info("🤔 No games found via schedule, trying direct approach...")
            today = datetime.now()
            recent_days = 7
            
            for days_ago in range(recent_days):
                date = today - timedelta(days=days_ago)
                date_str = date.strftime("%Y-%m-%d")

        
        # 🦆 says ⮞ update games.json
        all_games = []
        if os.path.exists(games_path):
            try:
                with open(games_path, 'r') as f:
                    all_games = json.load(f)
            except Exception as e:
                logger.error(f"Failed to load existing games: {e}")
        
        all_games.extend(new_games)
        
        try:
            with open(games_path, 'w') as f:
                json.dump(all_games, f, ensure_ascii=False, indent=2)
            logger.info(f"💾 Saved {len(all_games)} games to {games_path}")
        except Exception as e:
            logger.error(f"Failed to save games: {e}")
        
        # 🦆 says ⮞ scrape and save table
        logger.info("🏆 Scraping league table...")
        table_data = scrape_table()
        if table_data:
            try:
                with open(table_path, 'w') as f:
                    json.dump(table_data, f, ensure_ascii=False, indent=2)
                logger.info(f"💾 Saved {len(table_data)} teams to {table_path}")
                
                print("\n🏆 CURRENT STANDINGS:")
                print("=" * 80)
                print(f"{'Pos':<4} {'Team':<20} {'GP':<3} {'W':<3} {'T':<3} {'L':<3} {'OTW':<3} {'OTL':<3} {'GF':<3} {'GA':<3} {'+/-':<4} {'P':<3}")
                print("-" * 80)
                for team in table_data[:10]:  # Show top 10
                    print(f"{team['position']:<4} {team['team']:<20} {team['games_played']:<3} {team['wins']:<3} {team['ties']:<3} {team['losses']:<3} {team['overtime_wins']:<3} {team['overtime_losses']:<3} {team['goals_for']:<3} {team['goals_against']:<3} {team['goal_difference']:<4} {team['points']:<3}")
                print()
                
            except Exception as e:
                logger.error(f"Failed to save table: {e}")
        else:
            logger.warning("No table data to save")
        
        # 🦆 says ⮞ save state
        try:
            with open(state_path, 'w') as f:
                json.dump(list(scraped), f, ensure_ascii=False, indent=2)
            logger.info(f"💾 Saved state with {len(scraped)} scraped games")
        except Exception as e:
            logger.error(f"Failed to save state: {e}")
        
        if new_games:
            print("\n🎯 NEW GAMES FOUND:")
            print("=" * 50)
            for game in new_games:
                print(f"🏒 {game['teams'][0]} {game['score']} {game['teams'][1]}")
                print(f"   📅 {game['date']}")
                print()
        
        logger.info("🎉 Hockey scraping completed!")

    if __name__ == "__main__":
        main()
  '';
in {
  yo.scripts.hockey = {
    description = "Scrapes hockey game data and standings from HockeyAllsvenskan";
    category = "🧩 Miscellaneous";
    autoStart = false;    
    logLevel = "DEBUG";
    parameters = [
      { name = "dataDir"; description = "Directory path to save data in."; optional = false; default = "/home/" + config.this.user.me.name + "/.config/yo/hockey"; }
    ];
    code = ''
      ${cmdHelpers}
      dt_info "🏒 Starting hockey scraper..."
      dt_debug "Using data dir: $dataDir"
      
      ${scraper} --dataDir "$dataDir"
      status=$?
      
      if [ $status -ne 0 ]; then
        dt_error "Scraper failed with exit code $status"
        exit $status
      fi
      
      dt_info "Scraping done, files updated in $dataDir"
      
      games_file="$dataDir/games.json"
      table_file="$dataDir/table.json"
      
      if [ -f "$games_file" ]; then
        game_count=$(jq length "$games_file" 2>/dev/null || echo "0")
        dt_info "Found $game_count games in storage"
        
        echo ""
        echo "🎯 RECENT GAMES:"
        echo "================"
        jq -r '.[-10:] | reverse[] | "🏒 \(.home_team) \(.score) \(.away_team)\n   📅 \(.date)"' "$games_file" 2>/dev/null || echo "No games to display"
        echo ""
      fi
      
      if [ -f "$table_file" ]; then
        team_count=$(jq length "$table_file" 2>/dev/null || echo "0")
        dt_info "Found $team_count teams in table"
        
        echo ""
        echo "🏆 CURRENT STANDINGS:"
        echo "===================="
        jq -r '.[] | "\(.position). \(.team) - \(.points)p (\(.wins)-\(.losses)-\(.ties))"' "$table_file" 2>/dev/null || echo "No table to display"
        echo ""
      fi
    '';
    voice = {
      sentences = [
        "hockey tabellen"
        "hur har senaste matcherna gått"
      ];
    };
  };}
