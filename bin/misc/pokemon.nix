# dotfiles/bin/misc/pokemon.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 duck say ⮞ pokenix usage via voice....
  self, # 🦆 ⮞ "do i have bulbasaur shiny"
  lib, # 🦆 ⮞ "how much does ducklett weigh"
  config, # 🦆 ⮞ "do i have bulbasaur in beast ball"
  pkgs, # 🦆 ⮞ "do i have bulbasaur in beast ball with egg moves"
  cmdHelpers, # 🦆 ⮞ "how many shinies do i have left"
  sweSpeech, # 🦆 ⮞ "do i have bulbasaur with zero attack"
  ... # 🦆 ⮞ and so on....
} : let # 🦆 says ⮞ SLICK RIGHT?!

  pokemonCollection = species:
    let
      specials = map
        (key: { kind = "special"; inherit key; data = config.pokenix.specials.${key}; })
        (builtins.filter
          (key: config.pokenix.specials.${key}.species == species)
          (builtins.attrNames config.pokenix.specials));
      events = map
        (key: { kind = "event"; inherit key; data = config.pokenix.events.${key}; })
        (builtins.filter
          (key: config.pokenix.events.${key}.species == species)
          (builtins.attrNames config.pokenix.events));
      shinies =
        if builtins.hasAttr species config.pokenix.shiny then [
          { kind = "shiny"; key = species; data = config.pokenix.shiny.${species}; }
        ] else [];
    in specials ++ shinies ++ events;

  helpers = ''
    _pokedex_json() {
      fetch pokedex
      cat "$CACHE/pokedex.json" 2>/dev/null
    }

    pokedex_by_number() {
        jq --argjson number "$1" \
            '.pokemon | to_entries[]
             | select(.value.dexNumber == $number)
             | .value' \
            "$CACHE/pokedex.json"
    }

    pokedex_hidden_ability() {
        _pokedex_json | jq -r --arg pokemon "$1" \
            '.pokemon[$pokemon].abilities[] | select(.hidden == true).name'
    }

    pokedex_cry() {
        local pokemon="$1"
        local version="''${2:-latest}"
        if [[ "$version" != "latest" && "$version" != "legacy" ]]; then
            echo "Usage: pokedex_cry <pokemon> [latest|legacy]" >&2
            return 1
        fi
        _pokedex_json | jq -r --arg pokemon "$pokemon" --arg version "$version" \
            '.pokemon[$pokemon].cries[$version]'
    }

    pokedex_evolution() {
        _pokedex_json | jq --arg pokemon "$1" --arg evolveTo "$2" \
            '.pokemon[$pokemon].evolutionSteps[] | select(.species == $evolveTo)'
    }

    pokedex_types() {
        _pokedex_json | jq -r --arg pokemon "$1" '.pokemon[$pokemon].types[]'
    }

    pokedex_learn_level() {
        _pokedex_json | jq --arg pokemon "$1" --arg move "$2" \
            '[.pokemon[$pokemon].learnset.level[]
              | select(.moves | index($move))
              | .level]'
    }

    pokedex_egg_groups() {
        _pokedex_json | jq -r --arg pokemon "$1" '.pokemon[$pokemon].eggGroups[]'
    }

    pokedex_catch_rate() {
        _pokedex_json | jq -r --arg pokemon "$1" '.pokemon[$pokemon].captureRate'
    }

    pokedex_weight_kg() {
        _pokedex_json | jq -r --arg pokemon "$1" '
          .pokemon[$pokemon].weight
          | if . == null then "unknown"
            else "\(.) kg"
            end'
    }

    pokedex_height_cm() {
        _pokedex_json | jq -r --arg pokemon "$1" '
          .pokemon[$pokemon].height
          | if . == null then "unknown"
            else "\(. * 100) cm"
            end'
    }

    pokedex_color() {
        _pokedex_json | jq -r --arg pokemon "$1" '.pokemon[$pokemon].color // "unknown"'
    }

    pokedex_evo_chain() {
        local pokemon="$1"
        if [[ -z "$pokemon" ]]; then
            echo "Usage: pokedex_evo_chain <pokemon>" >&2
            return 1
        fi
        _pokedex_json | jq -r --arg pokemon "$pokemon" \
            '.pokemon[$pokemon].evolutionSteps[].species'
    }

    pokedex_evo_chain_json() {
        local pokemon="$1"
        if [[ -z "$pokemon" ]]; then
            echo "Usage: pokedex_evo_chain_json <pokemon>" >&2
            return 1
        fi
        _pokedex_json | jq --arg pokemon "$pokemon" \
            '.pokemon[$pokemon].evolutionSteps'
    }

    pokedex_move() {
        _pokedex_json | jq --arg move "$1" '.moves[$move]'
    }

    pokedex_move_power() {
        _pokedex_json | jq -r --arg move "$1" '.moves[$move].power'
    }

    pokedex_move_type() {
        _pokedex_json | jq -r --arg move "$1" '.moves[$move].type'
    }

    evo_relatives() {
      _pokedex_json | jq -r --arg t "$1" '
        ( [.pokemon | to_entries[]
            | select(.value.evolutionSteps[]?.species == $t)
            | .key]
          + [.pokemon[$t].evolutionSteps[]?.species // empty]
        ) | unique | .[]
      ' 2>/dev/null
    }

    play_cry() {
      local url="$1"
      [ -z "$url" ] || [ "$url" = "null" ] && return 1
      if command -v mpv    >/dev/null 2>&1; then
        mpv --no-video --really-quiet --no-terminal "$url" >/dev/null 2>&1 &
      elif command -v ffplay >/dev/null 2>&1; then
        ffplay -nodisp -autoexit -loglevel quiet "$url" >/dev/null 2>&1 &
      elif command -v vlc    >/dev/null 2>&1; then
        cvlc --play-and-exit --quiet "$url" >/dev/null 2>&1 &
      else
        echo "⚠  No audio player (mpv/ffplay/vlc) — URL: $url" >&2
        return 1
      fi
    }

    join_words() {
      jq -R -s -r 'split("\n") | map(select(. != ""))
        | if length == 0 then ""
          elif length == 1 then .[0]
          elif length == 2 then join(" and ")
          else (.[0:-1] | join(", ")) + " and " + .[-1]
          end'
    }
  '';
in {
  yo.scripts.pokemon = {
    description = "Search user defined Pokémon using PokéNix.";
    category = "🧩 Miscellaneous";
    autoStart = false;
    logLevel = "WARNING";
    parameters = [
      { name = "pokemon";    type = "string"; description = "Subject Pokémon"; }
      { name = "ball";       type = "string"; description = "Specific ball"; }
      { name = "dex";        type = "string"; description = "Pokédex number"; }
      { name = "iv";         type = "string"; description = "IV value 0–31"; }
      { name = "ev";         type = "string"; description = "EV value 0–252"; }
      { name = "stats";      type = "string"; description = "Stat name";
        values = [ "atk" "spa" "hp" "def" "spd" "spe" ]; }
      { name = "many";       type = "string"; description = "Count target";
        values = [ "shiny" "events" "aprimons" "ribbons" "legendary" "mythical" ]; }
      { name = "question";   type = "string"; description = "Info query";
        values = [ "cry" "evolve" "ability" "type" "move" "egggroup" "learnset"
                   "ribbons" "legendary" "mythical" "hidden" "info" "event"
                   "special" "bollar" "weight" "height" "color" "happiness" "catchrate" ]; }
      { name = "ribbon";     type = "string"; description = "Specific ribbon"; }
      { name = "eggMoves";   type = "string"; description = "Egg moves flag"; }
      { name = "moves";      type = "string"; description = "Move name"; }
      { name = "ability";    type = "string"; description = "Ability name"; }
      { name = "shiny";      type = "bool";   description = "Shiny search"; }
      { name = "ha";         type = "bool";   description = "Hidden ability search"; }
      { name = "em";         type = "bool";   description = "Egg-move-complete search"; }
      { name = "ribbons";    type = "bool";   description = "List mons with ribbons"; }
      { name = "listMissing"; type = "bool";  description = "List missing shinies"; }
      { name = "shinyLeft";  type = "bool";   description = "Remaining shiny count"; }
    ];
    code = ''
      POKEDEX_FLAKE="/home/pungkula/dotfiles"
      POKEDEX_HOST="''${hostname:-desktop}"

      POKEMON=$pokemon
      CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/pokenix"
      FLAKE="''${POKEDEX_FLAKE}#nixosConfigurations.''${POKEDEX_HOST}.config.pokenix"
      mkdir -p "$CACHE"
      ${helpers}

      fetch() {
        local a="$1" path="''${2:-$1}"
        local f="$CACHE/$a.json"
        if [ ! -f "$f" ] || [ -n "$(find "$f" -mmin +5 2>/dev/null)" ]; then
          if ! nix eval "$FLAKE.$path" --json 2>"$CACHE/$a.err" > "$f.tmp"; then
            echo "⚠ fetch failed: $FLAKE.$path" >&2
            head -3 "$CACHE/$a.err" >&2
            rm -f "$f.tmp"
            return 1
          fi
          mv "$f.tmp" "$f"
        fi
      }

      stat_name() {
        case "$1" in
          hp)  echo "HP" ;;
          atk) echo "Attack" ;;
          def) echo "Defense" ;;
          spa) echo "Sp. Attack" ;;
          spd) echo "Sp. Defense" ;;
          spe) echo "Speed" ;;
          *)   echo "$1" ;;
        esac
      }

      if [ -n "$many" ]; then
        case "$many" in
          shiny)
            fetch shiny
            T=$(jq 'length' "$CACHE/shiny.json")
            O=$(jq '[.[] | select(.ball != null)] | length' "$CACHE/shiny.json")
            echo "You have $O of $T shinies — $((T-O)) left."
            ;;
          events)
            fetch events
            echo "You have $(jq 'length' "$CACHE/events.json") events."
            ;;
          aprimons)
            fetch breedables
            T=$(jq 'length' "$CACHE/breedables.json")
            O=$(jq '[.[] | [.[] | select(type == "object") | select(.ball == true)] | length > 0] | length' "$CACHE/breedables.json")
            B=$(jq '[.[] | .[] | select(type == "object") | select(.ball == true)] | length' "$CACHE/breedables.json")
            echo "You have $O of $T species, with $B balls captured."
            ;;
          ribbons)
            fetch shiny; fetch specials
            N=$(jq '[.[] | select((.ribbons // []) | length > 0)] | length' "$CACHE/specials.json")
            M=$(jq '[.[] | select((.ribbons // []) | length > 0)] | length' "$CACHE/shiny.json")
            echo "$((N+M)) Pokémon have ribbons — $N in specials and $M in shinies."
            ;;
          legendary|mythical)
            F=$([ "$many" = "legendary" ] && echo isLegendary || echo isMythical)
            N=$(_pokedex_json | jq --arg f "$F" '[.pokemon | .[] | select(.[$f] == true)] | length')
            echo "There are $N $many species."
            ;;
          *) echo "Unknown many=$many" ;;
        esac
        exit 0
      fi

      if [ "$shinyLeft" = "true" ]; then
        fetch shiny
        T=$(jq 'length' "$CACHE/shiny.json")
        O=$(jq '[.[] | select(.ball != null)] | length' "$CACHE/shiny.json")
        echo "You have $O of $T shinies — $((T-O)) left."
        exit 0
      fi

      if [ "$listMissing" = "true" ]; then
        fetch shiny
        T=$(jq 'length' "$CACHE/shiny.json")
        O=$(jq '[.[] | select(.ball != null)] | length' "$CACHE/shiny.json")
        MISSING=$(jq -r 'to_entries[] | select(.value.ball == null) | .key' "$CACHE/shiny.json" | join_words)
        echo "You're missing $((T-O)) shinies: $MISSING."
        exit 0
      fi

      if [ -n "$dex" ]; then
        fetch breedables
        fetch debug-shiny debug.shiny
        fetch debug-events debug.events
        fetch specials

        NAME=$(_pokedex_json | jq -r --argjson d "$dex" '
          [.pokemon | to_entries[] | select(.value.dexNumber == $d) | .key] | .[0] // empty')
        [ -z "$NAME" ] && NAME=$(jq -r --argjson d "$dex" '[to_entries[] | select(.value.dex == $d) | .key] | .[0] // empty' "$CACHE/breedables.json")

        SHINY=$(jq -r --argjson d "$dex" '[to_entries[] | select(.value.dex == $d) | .key] | join("\n")' "$CACHE/debug-shiny.json" | join_words)
        EVENTS=$(jq -r --argjson d "$dex" '[to_entries[] | select(.value.dex == $d)] | length' "$CACHE/debug-events.json")
        SPECIALS=$(jq -r --argjson d "$dex" '[to_entries[] | select(.value.dex == $d)] | length' "$CACHE/specials.json")

        OUT="Number $dex is $NAME."
        [ -n "$SHINY" ] && OUT+=" You have shiny $SHINY." || OUT+=" No shiny."
        [ "$EVENTS" != "0" ] && OUT+=" $EVENTS event(s)." || OUT+=" No events."
        [ "$SPECIALS" != "0" ] && OUT+=" $SPECIALS special(s)." || OUT+=" No specials."
        echo "$OUT"
        exit 0
      fi

      if [ -n "$iv" ] && [ -n "$stats" ]; then
        case "$stats" in att|attack) STAT="atk" ;; *) STAT="$stats" ;; esac
        STAT_NAME=$(stat_name "$STAT")
        fetch shiny; fetch specials; fetch events; fetch breedables

        matches_for() {
          local target="$1"
          jq -r --arg p "$target" --arg s "$STAT" --argjson v "$iv" '
            to_entries[]
            | select(.key == $p or (.key | startswith($p + "-")))
            | select(.value.ball != null)
            | select(.value.ivs[$s] == $v)
            | .key' "$CACHE/shiny.json"
          jq -r --arg p "$target" --arg s "$STAT" --argjson v "$iv" '
            to_entries[]
            | select((.value.species? // "") == $p or ((.value.species? // "") | startswith($p + "-")))
            | select(.value.ivs[$s] == $v)
            | .key' "$CACHE/specials.json"
        }

        exists_for() {
          local target="$1"
          local out=""
          local s1=$(jq -r --arg p "$target" '
            [to_entries[] | select(.key == $p or (.key | startswith($p + "-"))) | select(.value.ball != null) | .key]
            | if length > 0 then "shiny (\(join(", ")))" else "" end' "$CACHE/shiny.json")
          [ -n "$s1" ] && out+="$s1, "
          local s2=$(jq -r --arg p "$target" '
            [to_entries[] | select((.value.species? // "") == $p or ((.value.species? // "") | startswith($p + "-"))) | .key]
            | if length > 0 then "special (\(join(", ")))" else "" end' "$CACHE/specials.json")
          [ -n "$s2" ] && out+="$s2, "
          local s3=$(jq -r --arg p "$target" '
            [to_entries[] | select((.value.species? // "") == $p or ((.value.species? // "") | startswith($p + "-"))) | .key]
            | if length > 0 then "event (\(join(", ")))" else "" end' "$CACHE/events.json")
          [ -n "$s3" ] && out+="$s3, "
          local s4=$(jq -r --arg p "$target" '
            [.[$p] // {} | to_entries[] | select(.value | type == "object") | select(.value.ball == true) | .key]
            | if length > 0 then "breedable (\(join(", ")))" else "" end' "$CACHE/breedables.json")
          [ -n "$s4" ] && out+="$s4, "
          echo "$out" | sed 's/, $//'
        }

        if [ -z "$POKEMON" ]; then
          ALL=$( { jq -r --arg s "$STAT" --argjson v "$iv" 'to_entries[] | select(.value.ivs[$s] == $v) | .key' "$CACHE/shiny.json"
                   jq -r --arg s "$STAT" --argjson v "$iv" 'to_entries[] | select(.value.ivs[$s] == $v) | .key' "$CACHE/specials.json"; } )
          COUNT=$(echo "$ALL" | grep -c .)
          if [ "$COUNT" = "0" ]; then
            echo "No Pokémon have $iv $STAT_NAME IV."
          else
            NAMES=$(echo "$ALL" | join_words)
            echo "Yes, $COUNT Pokémon have $iv $STAT_NAME IV: $NAMES."
          fi
          exit 0
        fi

        DIRECT=$(matches_for "$POKEMON")
        if [ -n "$DIRECT" ]; then
          COUNT=$(echo "$DIRECT" | grep -c .)
          [ "$COUNT" = "1" ] && echo "Yes, your $DIRECT has $iv $STAT_NAME IV." \
                            || { NAMES=$(echo "$DIRECT" | join_words); echo "Yes, $NAMES have $iv $STAT_NAME IV."; }
          exit 0
        fi

        EVO_MATCH=""
        for REL in $(evo_relatives "$POKEMON"); do
          M=$(matches_for "$REL")
          if [ -n "$M" ]; then
            EVO_MATCH="$M"
            break
          fi
        done
        if [ -n "$EVO_MATCH" ]; then
          COUNT=$(echo "$EVO_MATCH" | grep -c .)
          [ "$COUNT" = "1" ] && echo "Yes, your $EVO_MATCH has $iv $STAT_NAME IV — it's an evolution of $POKEMON." \
                            || { NAMES=$(echo "$EVO_MATCH" | join_words); echo "Yes, $NAMES have $iv $STAT_NAME IV — evolutions of $POKEMON."; }
          exit 0
        fi

        EXISTS=$(exists_for "$POKEMON")
        if [ -n "$EXISTS" ]; then
          echo "No $POKEMON with $iv $STAT_NAME IV. You have: $EXISTS."
        else
          echo "No $POKEMON with $iv $STAT_NAME IV, and $POKEMON isn't in your collection."
        fi
        exit 0
      fi

      if [ -n "$ribbon" ]; then
        fetch shiny; fetch specials
        S=$(jq -r --arg r "$ribbon" 'to_entries[] | select((.value.ribbons // []) | map(ascii_downcase) | index($r | ascii_downcase)) | .key' "$CACHE/shiny.json")
        SP=$(jq -r --arg r "$ribbon" 'to_entries[] | select((.value.ribbons // []) | map(ascii_downcase) | index($r | ascii_downcase)) | .key' "$CACHE/specials.json")
        ALL=$( { echo "$S"; echo "$SP"; } | grep -v '^$' )
        if [ -z "$ALL" ]; then echo "No Pokémon have $ribbon."
        else NAMES=$(echo "$ALL" | join_words); echo "Yes, $NAMES have $ribbon."; fi
        exit 0
      fi

      if [ -n "$question" ]; then
        case "$question" in
          cry)
            [ -z "$POKEMON" ] && { echo "Which Pokémon?"; exit 0; }
            URL=$(pokedex_cry "$POKEMON" latest)
            if [ -z "$URL" ] || [ "$URL" = "null" ]; then
              echo "No cry for $POKEMON."
            else
              play_cry "$URL" && echo "♪ $POKEMON"
            fi
            ;;
          evolve)
            [ -z "$POKEMON" ] && { echo "Which Pokémon?"; exit 0; }
            EVO=$(pokedex_evo_chain "$POKEMON")
            [ -z "$EVO" ] && echo "$POKEMON doesn't evolve." \
                          || { NAMES=$(echo "$EVO" | join_words); echo "$POKEMON evolves into $NAMES."; }
            ;;
          ability|hidden)
            [ -z "$POKEMON" ] && { echo "Which Pokémon?"; exit 0; }
            HA=$(pokedex_hidden_ability "$POKEMON")
            [ -z "$HA" ] && echo "$POKEMON has no hidden ability." \
                         || echo "$POKEMON's hidden ability is $HA."
            ;;
          type)
            [ -z "$POKEMON" ] && { echo "Which Pokémon?"; exit 0; }
            T=$(pokedex_types "$POKEMON")
            if [ -z "$T" ]; then echo "No type data for $POKEMON."
            else NAMES=$(echo "$T" | join_words); echo "$POKEMON is $NAMES."; fi
            ;;
          egggroup)
            [ -z "$POKEMON" ] && { echo "Which Pokémon?"; exit 0; }
            G=$(pokedex_egg_groups "$POKEMON")
            if [ -z "$G" ]; then echo "No egg group data for $POKEMON."
            else NAMES=$(echo "$G" | join_words); echo "$POKEMON is in the $NAMES egg groups."; fi
            ;;
          weight)
            [ -z "$POKEMON" ] && { echo "Which Pokémon?"; exit 0; }
            W=$(pokedex_weight_kg "$POKEMON")
            if [ -z "$W" ] || [ "$W" = "unknown" ] || [ "$W" = "null" ]; then
              echo "No weight data for $POKEMON."
            else
              echo "$POKEMON weighs $W."
            fi
            ;;
          height)
            [ -z "$POKEMON" ] && { echo "Which Pokémon?"; exit 0; }
            H=$(pokedex_height_cm "$POKEMON")
            if [ -z "$H" ] || [ "$H" = "unknown" ] || [ "$H" = "null" ]; then
              echo "No height data for $POKEMON."
            else
              echo "$POKEMON is $H tall."
            fi
            ;;
          color)
            [ -z "$POKEMON" ] && { echo "Which Pokémon?"; exit 0; }
            C=$(pokedex_color "$POKEMON")
            if [ -z "$C" ] || [ "$C" = "unknown" ] || [ "$C" = "null" ]; then
              echo "No color data for $POKEMON."
            else
              echo "$POKEMON is $C."
            fi
            ;;
          learnset)
            [ -z "$POKEMON" ] && { echo "Which Pokémon?"; exit 0; }
            if [ -n "$moves" ]; then
              L=$(pokedex_learn_level "$POKEMON" "$moves" | jq -r 'map(tostring) | join(" and ")')
              [ -z "$L" ] && echo "$POKEMON doesn't learn $moves by level." \
                          || echo "$POKEMON learns $moves at level $L."
            else
              _pokedex_json | jq --arg p "$POKEMON" '.pokemon[$p].learnset'
            fi
            ;;
          move)
            [ -z "$moves" ] && { echo "Which move?"; exit 0; }
            M=$(pokedex_move "$moves")
            if [ -z "$M" ] || [ "$M" = "null" ]; then echo "No data for $moves."
            else
              echo "$M" | jq -r '
                "\(.name // "?") is \(.type // "?") \(.damageClass // "?")"
                + (if .power then ", \(.power) power" else "" end)
                + (if .accuracy then ", \(.accuracy)% accuracy" else "" end)
                + (if .pp then ", \(.pp) PP" else "" end) + "."
              '
            fi
            ;;
          ribbons)
            fetch shiny; fetch specials
            ALL=$( { jq -r 'to_entries[] | select((.value.ribbons // []) | length > 0) | "\(.key) (\(.value.ribbons | join(", ")))"' "$CACHE/specials.json"
                     jq -r 'to_entries[] | select((.value.ribbons // []) | length > 0) | "\(.key) (\(.value.ribbons | join(", ")))"' "$CACHE/shiny.json"; } | grep -v '^$' )
            if [ -z "$ALL" ]; then echo "No Pokémon have ribbons."
            else NAMES=$(echo "$ALL" | join_words); echo "Yes, $NAMES."; fi
            ;;
          legendary|mythical)
            F=$([ "$question" = "legendary" ] && echo isLegendary || echo isMythical)
            N=$(_pokedex_json | jq --arg f "$F" '[.pokemon | .[] | select(.[$f] == true)] | length')
            echo "There are $N $question species."
            ;;
          info)
            fetch shiny
            BALL=$(jq -r --arg p "$POKEMON" '.[$p].ball // "not owned"' "$CACHE/shiny.json")
            if [ "$BALL" = "not owned" ] || [ "$BALL" = "null" ]; then
              echo "No shiny entry for $POKEMON."
            else
              STYLE=$(jq -r --arg p "$POKEMON" '.[$p].style // "star"' "$CACHE/shiny.json")
              NATURE=$(jq -r --arg p "$POKEMON" '.[$p].nature // "—"' "$CACHE/shiny.json")
              echo "$POKEMON: shiny in $BALL ball, $STYLE style, nature $NATURE."
            fi
            ;;
          event)
            fetch events
            M=$(jq -r --arg s "$POKEMON" '
              [to_entries[] | select((.value.species? // "") == $s or ((.value.species? // "") | startswith($s + "-")))
               | "\(.key)\(if .value.year then " (\(.value.year))" else "" end)"]
              | join(" and ")' "$CACHE/events.json")
            if [ -z "$M" ] || [ "$M" = "" ]; then echo "No events for $POKEMON."
            else echo "Yes, $POKEMON has events: $M."; fi
            ;;
          special)
            fetch specials
            M=$(jq -r --arg s "$POKEMON" '
              [to_entries[] | select((.value.species? // "") == $s or ((.value.species? // "") | startswith($s + "-")))
               | "\(.key)\(if .value.level then " (Lv \(.value.level))" else "" end)"]
              | join(" and ")' "$CACHE/specials.json")
            if [ -z "$M" ] || [ "$M" = "" ]; then echo "No specials for $POKEMON."
            else echo "Yes, $POKEMON has specials: $M."; fi
            ;;
          bollar)
            fetch breedables
            O=$(jq -r --arg p "$POKEMON" '.[$p] // {} | [to_entries[] | select(.value | type == "object") | select(.value.ball == true) | .key] | join("\n")' "$CACHE/breedables.json" | join_words)
            M=$(jq -r --arg p "$POKEMON" '.[$p] // {} | [to_entries[] | select(.value | type == "object") | select(.value.possible == true and .value.ball != true) | .key] | join("\n")' "$CACHE/breedables.json" | join_words)
            if [ -z "$O" ]; then echo "$POKEMON isn't in your breedables collection."
            else
              OUT="You have $POKEMON in $O"
              [ -n "$M" ] && OUT+=", missing $M"
              echo "$OUT."
            fi
            ;;
          *) echo "Unknown question=$question" ;;
        esac
        exit 0
      fi

      [ -z "$POKEMON" ] && { echo "No Pokémon specified."; exit 0; }

      if [ -n "$ribbons" ] && [ "$ribbons" != "false" ]; then
        fetch shiny; fetch specials
        ALL=$( { jq -r 'to_entries[] | select((.value.ribbons // []) | length > 0) | "\(.key) (\(.value.ribbons | join(", ")))"' "$CACHE/specials.json"
                 jq -r 'to_entries[] | select((.value.ribbons // []) | length > 0) | "\(.key) (\(.value.ribbons | join(", ")))"' "$CACHE/shiny.json"; } | grep -v '^$' )
        if [ -z "$ALL" ]; then echo "No Pokémon have ribbons."
        else NAMES=$(echo "$ALL" | join_words); echo "Yes, $NAMES."; fi
        exit 0
      fi

      if [ -n "$shiny" ] && [ "$shiny" != "false" ]; then
        fetch shiny
        B=$(jq -r --arg p "$POKEMON" '
          [to_entries[] | select(.key == $p or (.key | startswith($p + "-"))) | select(.value.ball != null)
           | "\(.key) (\(.value.ball) ball)"]
          | join(" and ")' "$CACHE/shiny.json")
        [ -n "$B" ] && echo "Yes, you have shiny $B." \
                    || echo "No, you don't have shiny $POKEMON."
        exit 0
      fi

      if [ -n "$ha" ] && [ "$ha" != "false" ]; then
        fetch breedables
        if [ -n "$ball" ]; then
          V=$(jq -r --arg p "$POKEMON" --arg b "$ball" '.[$p][$b].ha // false' "$CACHE/breedables.json")
          [ "$V" = "true" ] && echo "Yes, HA $POKEMON in $ball." || echo "No HA $POKEMON in $ball."
        else
          H=$(jq -r --arg p "$POKEMON" '.[$p] // {} | [to_entries[] | select(.value | type == "object") | select(.value.ha == true) | .key] | join("\n")' "$CACHE/breedables.json" | join_words)
          [ -n "$H" ] && echo "You have HA $POKEMON in $H." || echo "No $POKEMON with HA."
        fi
        exit 0
      fi

      if [ -n "$em" ] && [ "$em" != "false" ] && [ -z "$ball" ]; then
        fetch breedables
        EGGS=$(_pokedex_json | jq -r --arg p "$POKEMON" '.pokemon[$p].eggMoves // [] | join("\n")' | join_words)
        H=$(jq -r --arg p "$POKEMON" '.[$p] // {} | [to_entries[] | select(.value | type == "object") | select(.value.eggMoves == true) | .key] | join("\n")' "$CACHE/breedables.json" | join_words)
        [ -z "$EGGS" ] && echo "$POKEMON has no egg moves." || echo "$POKEMON's egg moves are $EGGS."
        [ -n "$H" ] && echo "You have egg-move-complete specimens in $H."
        exit 0
      fi

      if [ -n "$ball" ]; then
        fetch breedables
        P=$(jq -r --arg p "$POKEMON" --arg b "$ball" '.[$p][$b].possible // false' "$CACHE/breedables.json")
        if [ "$P" != "true" ]; then echo "No, $POKEMON can't be in a $ball ball."; exit 0; fi
        O=$(jq -r --arg p "$POKEMON" --arg b "$ball" '.[$p][$b].ball // false' "$CACHE/breedables.json")
        if [ "$O" != "true" ]; then echo "No, you don't have $POKEMON in a $ball ball."; exit 0; fi
        if [ -n "$eggMoves" ] && [ "$eggMoves" != "false" ]; then
          E=$(jq -r --arg p "$POKEMON" --arg b "$ball" '.[$p][$b].eggMoves // false' "$CACHE/breedables.json")
          [ "$E" = "true" ] && echo "Yes, your $POKEMON in $ball ball has all egg moves." \
                            || echo "You have $POKEMON in $ball, but not with egg moves."
        else
          echo "Yes, you have $POKEMON in a $ball ball."
        fi
        exit 0
      fi

      fetch shiny; fetch breedables; fetch specials; fetch events
      SHINY=$(jq -r --arg p "$POKEMON" '
        [to_entries[] | select(.key == $p or (.key | startswith($p + "-"))) | select(.value.ball != null)
         | "\(.key) (\(.value.ball) ball)"]
        | join(" and ")' "$CACHE/shiny.json")
      O=$(jq -r --arg p "$POKEMON" '.[$p] // {} | [to_entries[] | select(.value | type == "object") | select(.value.ball == true) | .key] | join("\n")' "$CACHE/breedables.json" | join_words)
      M=$(jq -r --arg p "$POKEMON" '.[$p] // {} | [to_entries[] | select(.value | type == "object") | select(.value.possible == true and .value.ball != true) | .key] | join("\n")' "$CACHE/breedables.json" | join_words)
      SPECIALS=$(jq -r --arg p "$POKEMON" '
        [to_entries[] | select((.value.species? // "") == $p or ((.value.species? // "") | startswith($p + "-"))) | .key]
        | join("\n")' "$CACHE/specials.json" | join_words)
      EVENTS=$(jq -r --arg p "$POKEMON" '
        [to_entries[] | select((.value.species? // "") == $p or ((.value.species? // "") | startswith($p + "-"))) | .key]
        | join("\n")' "$CACHE/events.json" | join_words)

      OUT="$POKEMON: "
      [ -n "$SHINY" ] && OUT+="shiny $SHINY. " || OUT+="no shiny. "
      [ -n "$O" ] && OUT+="In your collection: $O. " || OUT+="Not in your collection. "
      [ -n "$SPECIALS" ] && OUT+="Specials: $SPECIALS. "
      [ -n "$EVENTS" ] && OUT+="Events: $EVENTS. "
      [ -n "$M" ] && OUT+="Missing: $M."
      echo "$OUT"
    '';
    voice = {
      priority = 5;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;

      sentences = [
        "har (ja|jag) [någon|nån] {pokemon} [i] [en] {ball} [ball] (me|med) egg {eggMoves} och {ha}"
        "har (ja|jag) [någon|nån] {pokemon} [i] [en] {ball} [ball] (me|med) {ha} och {eggMoves}"

        "har (ja|jag) [någon|nån] {pokemon} [i] [en] {ball} [ball] (me|med) egg {eggMoves}"
        "har (ja|jag) [någon|nån] {pokemon} [i] [en] {ball} [ball] (me|med) {ha}"
        "har (ja|jag) [någon|nån] {pokemon} [i] [en] {ball} [ball]"
        "har (ja|jag) [någon|nån] {pokemon} [i] [en] {ball}"

        "har (ja|jag) [någon|nån] {pokemon} [med] {iv} [i] {stats}"
        "har (ja|jag) [någon|nån] [med] {iv} [i] {stats}"

        "har (ja|jag) [någon|nån] {pokemon} [med] {ha}"

        "har (ja|jag) [någon|nån] {pokemon} {shiny}"
        "har (ja|jag) [någon|nån] {shiny} {pokemon}"

        "vilken pokemon [har|är] [nummer] {dex}"

        "vilka [egg] {em} har {pokemon}"

        "har (ja|jag) [någon|nån] [pokemon] [med] {ribbon} [ribbon]"

        "hur många {many} [har|äger] (ja|jag)"
        "hur många {many} finns det"

        "vilken {question} är {pokemon}"
        "vilken {question} är {move}"

        "hur [lätt|mycket] {question} [är] [en] {pokemon} [egentligen]"
        "vad {question} [en] {pokemon}"
        "när {question} [en] {pokemon}"
        "i vilken level {question} [sig] [en] {pokemon} [moves]"
        "vilken {question} [är|har] {pokemon}"
        "vilka [egg] {question} [är|har] {pokemon} [i]"
        "vad har {pokemon} för {question} [ability]"

        "har (ja|jag) [någon|nån|några] [pokemon] [med] {question}"

        "har (ja|jag) [någon|nån] {pokemon}"
      ];

      lists = {
        pokemon.values = map (name: { "in" = name; out = name; })
          (lib.unique (
            builtins.attrNames config.pokenix.pokedex.pokemon
            ++ map (n: lib.head (lib.splitString "-" n))
                   (builtins.attrNames config.pokenix.pokedex.pokemon)
          ));

        ability.values = map (name: { "in" = name; out = name; })
          (lib.unique (builtins.concatLists (
            map (pokemon: map (ability: ability.name) pokemon.abilities)
                (builtins.attrValues config.pokenix.pokedex.pokemon))));

        move.values = map (name: { "in" = name; out = name; })
          (builtins.attrNames config.pokenix.pokedex.moves);

        eggMoves.wildcard = true;
        ribbon.wildcard   = true;
        iv.values         = sweSpeech.numberFromZeroTo 31;
        ev.values         = sweSpeech.numberFromZeroTo 252;
        dex.values        = sweSpeech.numberFromZeroTo 1025;
        level.values      = sweSpeech.numberFromOneTo 100;
        shiny.values   = [{ "in" = "shiny|shinie"; out = "true"; }];
        em.values      = [{ "in" = "move|moves";   out = "true"; }];
        events.values  = [{ "in" = "events";       out = "true"; }];
        ha.values      = [{ "in" = "ha|hidden|gömd"; out = "true"; }];
        ribbons.values = [{ "in" = "ribbons";      out = "true"; }];
        many.values = [
          { "in" = "shiny";     out = "shiny"; }
          { "in" = "events";    out = "events"; }
          { "in" = "aprimons";  out = "aprimons"; }
          { "in" = "ribbons";   out = "ribbons"; }
          { "in" = "legendary"; out = "legendary"; }
          { "in" = "mythical";  out = "mythical"; }
        ];
        question.values = [
          { "in" = "låter|gråter|cry|sound";         out = "cry"; }
          { "in" = "evolvar|evolve|evolution";       out = "evolve"; }
          { "in" = "typ|types|type";                 out = "type"; }
          { "in" = "grupp|grouper|egggroup";         out = "egggroup"; }
          { "in" = "learnset|learnable|inlärning";   out = "learnset"; }
          { "in" = "ribbons";                        out = "ribbons"; }
          { "in" = "legendary";                      out = "legendary"; }
          { "in" = "mythical";                       out = "mythical"; }
          { "in" = "hidden|gömd";                    out = "hidden"; }
          { "in" = "info|detaljer";                  out = "info"; }
          { "in" = "events";                         out = "event"; }
          { "in" = "specials";                       out = "special"; }
          { "in" = "samlingar";                      out = "bollar"; }
          { "in" = "bollar|ballar";                  out = "bollar"; }
          { "in" = "väger|mycket väger|vikt|weight"; out = "weight"; }
          { "in" = "lång|är lång|längd|höjd|height"; out = "height"; }
          { "in" = "färg|color";                     out = "color"; }
          { "in" = "lycklig|happy";                  out = "happiness"; }
          { "in" = "fånga|fångad|catch";             out = "catchrate"; }
        ];
        stats.values = [
          { "in" = "attack";                          out = "atk"; }
          { "in" = "special attack|magi|magic";       out = "spa"; }
          { "in" = "hp|health|liv";                   out = "hp"; }
          { "in" = "defence|defense";                 out = "def"; }
          { "in" = "special defence|special defense"; out = "spd"; }
          { "in" = "speed|fart";                      out = "spe"; }
        ];
        ball.values = [
          { "in" = "safari"; out = "safari"; }
          { "in" = "sport";  out = "sport"; }
          { "in" = "fast";   out = "fast"; }
          { "in" = "friend"; out = "friend"; }
          { "in" = "heavy";  out = "heavy"; }
          { "in" = "level";  out = "level"; }
          { "in" = "lure";   out = "lure"; }
          { "in" = "dream";  out = "dream"; }
          { "in" = "moon";   out = "moon"; }
          { "in" = "beast";  out = "beast"; }
          { "in" = "love";   out = "love"; }
        ];
      };
    };

  };}
