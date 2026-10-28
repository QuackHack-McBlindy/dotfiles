# dotfiles/bin/misc/hockeyGames.nix
{
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
}: let

  # 🦆 says ⮞ league-specific API identifiers
  leagues = {
    shl = {
      host        = "https://www.shl.se";
      seasonUuid  = "ndcf81nlb3";
      seriesUuid  = "qQ9-bb0bzEWUk";
      gameTypeUuid = "qQ9-af37Ti40B";
    };
    ha = {
      host        = "https://www.hockeyallsvenskan.se";
      seasonUuid  = "xs4m9qupsi";
      seriesUuid  = "qQ9-594cW8OWD";
      gameTypeUuid = "qQ9-af37Ti40B";
    };
  };

  leagueConfig = league: leagues.${league} or leagues.ha;

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
      # 🦆 says ⮞ parse date into Swedish format with weekday
      local year=$(echo "$date" | cut -d'-' -f1)
      local month=$(echo "$date" | cut -d'-' -f2)
      local day=$(echo "$date" | cut -d'-' -f3)
      day=$((10#$day)) # 🦆 says ⮞ remove leading zero

      # 🦆 says ⮞ get weekday in Swedish
      local weekday=""
      if command -v date >/dev/null 2>&1; then
        weekday=$(LANG=C ${pkgs.coreutils}/bin/date -d "$date" "+%A" 2>/dev/null || echo "")
      fi

      # 🦆 says ⮞ convert to Swedish
      case $weekday in
        "Monday"|"monday") weekday="Måndag" ;;
        "Tuesday"|"tuesday") weekday="Tisdag" ;;
        "Wednesday"|"wednesday") weekday="Onsdag" ;;
        "Thursday"|"thursday") weekday="Torsdag" ;;
        "Friday"|"friday") weekday="Fredag" ;;
        "Saturday"|"saturday") weekday="Lördag" ;;
        "Sunday"|"sunday") weekday="Söndag" ;;
        # 🦆 says ⮞ also handle Swedish lowercase
        "måndag") weekday="Måndag" ;;
        "tisdag") weekday="Tisdag" ;;
        "onsdag") weekday="Onsdag" ;;
        "torsdag") weekday="Torsdag" ;;
        "fredag") weekday="Fredag" ;;
        "lördag") weekday="Lördag" ;;
        "söndag") weekday="Söndag" ;;
        *)
          weekday=""
          dt_info "No matching weekday found for: '$weekday'"
          ;;
      esac
      # 🦆 says ⮞ convert day to text
      local day_text=$(number_to_text "$day")
      # 🦆 says ⮞ get month name
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

      # 🦆 says ⮞ generate analysis with weekday
      local analysis=""
      local score_diff=$((home_score - away_score))
      local abs_diff=$((score_diff > 0 ? score_diff : -score_diff))

      # 🦆 says ⮞ start with weekday and date
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

      # 🦆 says ⮞ parse date into Swedish format with weekday
      local year=$(echo "$date" | cut -d'-' -f1)
      local month=$(echo "$date" | cut -d'-' -f2)
      local day=$(echo "$date" | cut -d'-' -f3)
      day=$((10#$day)) # 🦆 says ⮞ remove leading zero

      # 🦆 says ⮞ get weekday
      local weekday=""
      # 🦆 says ⮞ date
      if command -v date >/dev/null 2>&1; then
        weekday=$(${pkgs.coreutils}/bin/date -d "$date" "+%A" 2>/dev/null || echo "")
        dt_info "WEEKDAY: $weekday"
      fi

      # 🦆 says ⮞ if date command failed, try using a fallback calculation
      if [ -z "$weekday" ]; then
        # 🦆 says ⮞ fallback: Zeller's congruence approximation
        local y=$((10#$year)) m=$((10#$month)) d=$((10#$day))
        # 🦆 says ⮞ Adjust for Zeller's congruence
        if [ $m -lt 3 ]; then
          m=$((m + 12))
          y=$((y - 1))
        fi
        local k=$((y % 100))
        local j=$((y / 100))
        local h=$((d + (13*(m+1))/5 + k + (k/4) + (j/4) - 2*j))
        local weekday_num=$(( ((h % 7) + 7) % 7 ))   # 🦆 says ⮞ ensure positive modulo

        case $weekday_num in
          1) weekday="Monday" ;;
          2) weekday="Tuesday" ;;
          3) weekday="Wednesday" ;;
          4) weekday="Thursday" ;;
          5) weekday="Friday" ;;
          6) weekday="Saturday" ;;
          0) weekday="Sunday" ;;
          *) weekday="" ;;
        esac
      fi

      # 🦆 says ⮞ convert to Swedish
      case $weekday in
        "Monday"|"monday") weekday="Måndag" ;;
        "Tuesday"|"tuesday") weekday="Tisdag" ;;
        "Wednesday"|"wednesday") weekday="Onsdag" ;;
        "Thursday"|"thursday") weekday="Torsdag" ;;
        "Friday"|"friday") weekday="Fredag" ;;
        "Saturday"|"saturday") weekday="Lördag" ;;
        "Sunday"|"sunday") weekday="Söndag" ;;
        # 🦆 says ⮞ also handle Swedish lowercase
        "måndag") weekday="Måndag" ;;
        "tisdag") weekday="Tisdag" ;;
        "onsdag") weekday="Onsdag" ;;
        "torsdag") weekday="Torsdag" ;;
        "fredag") weekday="Fredag" ;;
        "lördag") weekday="Lördag" ;;
        "söndag") weekday="Söndag" ;;
        *)
          weekday=""
          dt_info "No matching weekday found for: '$weekday'"
          ;;
      esac

      # 🦆 says ⮞ convert day to text
      local day_text=$(number_to_text "$day")

      # 🦆 says ⮞ get month name
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

      # 🦆 says ⮞ determine if our team is home or away
      local our_team=""
      local opponent=""
      local location=""

      if [ "$home_team" = "$team_filter" ]; then
        our_team="$home_team"
        opponent="$away_team"
        location="hemma"
      else
        our_team="$away_team"
        opponent="$home_team"
        location="borta"
      fi

      # 🦆 says ⮞ generate natural Swedish speech
      local analysis=""
      if [ -n "$weekday" ]; then
        analysis="På $weekday den $day_text $month_name "
      else
        analysis="Den $day_text $month_name "
      fi

      analysis+="spelar $our_team $location match mot $opponent"

      # 🦆 says ⮞ add venue info if available
      if [ -n "$venue" ] && [ "$venue" != "null" ]; then
        analysis+=" i $venue"
      fi

      analysis+="."
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
      dt_debug "Analyzing $games_count games..."
      local games_json=$(cat "$games_file")

      # 🦆 says ⮞ filter by team if specified
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

      # 🦆 says ⮞ sort 'em up or down or anyway u like it🦆don't judge
      local dates=$(echo "$games_json" | jq -r '.[].date' | sort -u)

      while IFS= read -r date; do
        [ -z "$date" ] && continue
        local swedish_date=$(format_swedish_date "$date")

        # 🦆 says ⮞ head
        BOLD=1
        ${pkgs.gum}/bin/gum format "# 🗓️  **$swedish_date:**"
        echo "----------------------------"
        # 🦆 says ⮞ filter games for this date AND team
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
      elif [ "$type" = "upcoming" ] && [ -n "$team_filter" ]; then
        # 🦆 says ⮞ analyze upcoming games with TTS
        echo "$games_json" | jq -c '.[]' | while IFS= read -r game_data; do
          local analysis=$(analyze_upcoming_game "$game_data" "$team_filter")
          echo "🔮 $analysis"
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

  # 🦆 says ⮞ filter for live games (wall-clock, since API has no "live" state)
  filterLiveGames = ''
    filter_live_games() {
      local games_data="$1"
      local now_epoch
      now_epoch=$(${pkgs.coreutils}/bin/date +%s)

      # 🦆 says ⮞ 3h30m = 12600s covers regulation + OT/SO + ceremonies
      # 🦆 says ⮞ lower bound: game start (puck drop). upper bound: safety net
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
  yo.scripts.hockeyGames = {
    description = "Hockey Assistant. Provides Hockey Allsvenskan data and deliver analyzed natural language responses (TTS).";
    category = "🧩 Miscellaneous";
    aliases = [ "hag" ];
    autoStart = false;
    logLevel = "INFO";
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
      { name = "dataDir"; type = "path"; description = "Directory path to save data in."; optional = false; default = "/home/" + config.this.user.me.name + "/.config/yo/hockey"; }
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
          cfg_host="${leagues.shl.host}"
          cfg_season="${leagues.shl.seasonUuid}"
          cfg_series="${leagues.shl.seriesUuid}"
          cfg_game_type="${leagues.shl.gameTypeUuid}"
        else
          cfg_host="${leagues.ha.host}"
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
          live)     state_filter="pre-game"  ;;   # only pre-game exists; time-window does the rest
        esac

        curl -sL -H "User-Agent: Mozilla/5.0" "$url" | \
        jq --arg state "$state_filter" '
          [.gameInfo[] |
            select(.state == $state) |
            {
              date:       (.rawStartDateTime | sub("T.*"; "")),
              start_time: .rawStartDateTime,          # NEW — keep full UTC ISO
              state:      .state,                      # NEW — "pre-game" | "post-game"
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

      # 🦆 says ⮞ fetch PP/PK stats for each finished game

      fetch_team_stats() {
        local game_uuid="$1"
        local cfg_host
        if [ "$league" = "shl" ]; then
          cfg_host="${leagues.shl.host}"
        else
          cfg_host="${leagues.ha.host}"
        fi
        local url="$cfg_host/api/gameday/team-stats?gameUuid=$game_uuid"
        curl -sL -H "User-Agent: Mozilla/5.0" "$url" | jq '{
          home_team: .homeTeam.names.short,
          away_team: .awayTeam.names.short,
          home_power_play: (.homeTeamStats.powerPlayGoals|tostring + "/" + (.homeTeamStats.powerPlayOpportunities|tostring) + " (" + (.homeTeamStats.powerPlayPercentage|tostring) + "%)"),
          away_power_play: (.awayTeamStats.powerPlayGoals|tostring + "/" + (.awayTeamStats.powerPlayOpportunities|tostring) + " (" + (.awayTeamStats.powerPlayPercentage|tostring) + "%)"),
          home_penalty_kill: (.homeTeamStats.penaltyKillPercentage|tostring + "%"),
          away_penalty_kill: (.awayTeamStats.penaltyKillPercentage|tostring + "%")
        }'
      }


      filter_games_by_matchup() {
        local games_data="$1"
        local home_filter="$2"
        local away_filter="$3"

        if [ -z "$home_filter" ] && [ -z "$away_filter" ]; then
          echo "$games_data"
          return 0
        fi

        echo "$games_data" | jq \
          --arg home "$home_filter" \
          --arg away "$away_filter" '

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

          [.[]
            | select(matches(.home_team; $home) and matches(.away_team; $away))]
        '
      }


      filter_games_by_days() {
        local games_data="$1"
        local days="$2"
        local type="$3"
        # 🦆 says ⮞ get date YYYY-MM-DD format
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
      mkdir -p "$dataDir"
      games_file="$dataDir/''${league}_games.json"
      dt_debug "🏒🦆says⮞ PUCK!"
      games_data=$(fetch_games)
      if [ -z "$games_data" ] || [ "$games_data" = "null" ] || [ "$games_data" = "[]" ]; then
        dt_error "No games data received from API"
        exit 1
      fi

      # 🦆 says ⮞ if only --home given, default team to it
      if [ -z "$team" ] && [ -n "$home" ]; then
        team="$home"
      fi

      # 🦆 says ⮞ when searching a specific matchup, widen the window to a full year
      if [ -n "$home" ] || [ -n "$away" ]; then
        dt_debug "Matchup search detected (home='$home' away='$away') – overriding days to 365"
        days=365
      fi

      # 🦆 says ⮞ days filter is meaningless for `live` — game is in the past few hours
      if [ "$type" = "live" ]; then
        filtered_games="$games_data"
      else
        filtered_games=$(filter_games_by_days "$games_data" "$days" "$type")
      fi

      filtered_games=$(filter_games_by_matchup "$filtered_games" "$home" "$away")

      if [ "$type" = "live" ]; then
        filtered_games=$(filter_live_games "$filtered_games")
      fi

      # 🦆 says ⮞ filter to specific team (either side)
      if [ -n "$team" ]; then
        filtered_games=$(echo "$filtered_games" | jq --arg t "$team" '
          [.[] | select(
            (.home_team | ascii_downcase | contains($t | ascii_downcase)) or
            (.away_team | ascii_downcase | contains($t | ascii_downcase))
          )]')
      fi

      games_count=$(echo "$filtered_games" | jq length)

      # 🦆 says ⮞ silent boolean — forced for live games unless --json
      if [ "$check" = "true" ] || { [ "$type" = "live" ] && [ "$json" != "true" ]; }; then
        if [ "$games_count" -gt 0 ]; then
          echo "true"
        else
          echo "false"
        fi
        exit 0
      fi

      # 🦆 says ⮞ machine-consumable exit path — no TTS, no analysis, no spam
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

      # 🦆 says ⮞ save da quackin' data yo
      echo "$filtered_games" > "$games_file"
      dt_debug "Found $games_count $type games"

      # 🦆 says ⮞ analyze and display
      analysis_output=$(analyze_recent_games "$games_file" "$team")
      echo "$analysis_output"

      # 🦆 says ⮞ TTS for both recent AND upcoming games
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
    # 🦆 says ⮞ vwe'll wanna quack diz with voice yo
    voice = {
      priority = 2;
      sentences = [
        # 🦆 says ⮞ game results patterns
        "(vad|hur) (hände|gick) [det|matchen] (för|med) {team} (senast|igår)"
        "(berätta|visa) (om|) {team} (senaste|sista) match"
        "(vilka|vad) (hände|resultat) (i|) hockyn (igår|senast)"
        "senaste hockymatcherna"
        "allsvenskan matcher"
        # 🦆 says ⮞ type based
        "när (är|spelar) {team} [sin] {type} match"
        "hur har {team} spelat [den] {type} [tiden]"
        "hur (var|spelade) {team} {type} matchen"
        # 🦆 says ⮞ team vs team search
        "(visa|hitta|sök) (matchen|matcher) (mellan|) {home} (och|mot) {away}"
        "när [möter|spelar|är] [det] {home} [emot|mot|vs] {away}"
        "vilken dag [möter|spelar|är] [det] {home} [emot|mot|vs] {away}"
        "hur länge [kvar] (till|tills) {home} [möter|spelar] [emot|mot|vs] {away}"
        # 🦆 says ⮞ team live RIGHT NOW? (true/false)
        "spelar {team} {type} (nu|ikväll)"
        "kolla om {team} spelar {type} (nu|ikväll)"
        "kolla om {team} {type} match (nu|ikväll)"
      ];
      lists = {
        type.values = [
          { "in" = "kommande|nästa"; out = "upcoming"; }
          { "in" = "senaste|förra";  out = "recent"; }
          { "in" = "just|live|spelar";      out = "live"; }
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

  };}
