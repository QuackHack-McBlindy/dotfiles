{
  lib,
  config,
  ...
} : {

  blog = {
    enable = true;
    posts.reverse-engineering-the-swedish-hockey-league = {
      filename    = "reverse-engineering-the-swedish-hockey-league.html";
      title       = "Reverse Engineering the Swedish Hockey League inside a Nix string.";
      date        = "2026-11-19";
      tags        = [ "reverse-engineering" "nixos" "nix" "shl" "yo" "voice-assistant" "hockey" "api" ];
      tagline     = "Reverse engineering the Swedish Hockey League inside a Nix string.";
      description = "I assumed there'd be a wall, a token expiry, a rate limit - something. There wasn't. They save an absurd amount of data, so hey - thanks for the free, unlimited API. Of course I made it voice-controlled.";

      header1 = "Meanwhile in";
      header2 = "Sweden";
      eyebrow = "hacking · SHL · HA";

      stats = [
        { value = "331";     label = "Generated Regex patterns";                  accent = "teal"; }
        { value = "88,153";  label = "Understandable voice phrases / variations"; accent = "green"; }
        { value = "266";     label = "Average variations / pattern";              accent = "red"; }
      ];

      text = ''
        Meanwhile our country is being attacked by unknown forces and food worth
        millions is destroyed because the freezers are all on the same network.
        The internet sure is a funny place, but the position we've put ourselves
        in - low, if not zero, security by default - may not end so funny. And I
        can't help but think: will we ever change?

        No. This is something I've been using for some years now.
        It's shorter than you'd expect.

        ## **Step 1: Discover the API.**

        A `curl` against the league's public site, a URL for their internal API
        buried in the `.html`, and another `curl` on that. I braced for
        `403 Forbidden`. I got `200 OK`. I checked again. Still `200`. No
        headers, no token in a cookie, no auth I could see. Just JSON, and decades of it, for the asking.

      '';

      sections = [
        {
          duck  = "**Quackly my hacker story turn into something entirely different...**";
        }
        {
          prose = ''
            **Hats off to the Swedish Hockey League and their web administrators** for keeping the statistics open and see-through allowing open source to keep pushing forward.

            Blind people **do** watch hockey.
            But it's hard to listen for my teams game schuedule, unless someone tells me.
            Now I can just ask, thanks!
          '';
        }

        {
          prose = ''
            ## **Step 2: Find the endpoints.**

            The powerplay endpoint returns the full statistics for every team
            in the league. No headers, no authentication, no rate limit I could
            hit in a minute of hammering. The other stats endpoints -
            `players_point`, `goalkeepers_summary`, `players_penalty`,
            `site-news` - all of them open. I kept waiting for the wall to
            appear. It didn't.
          '';
        }
        {
          code = {
            title   = "curl, 200 OK";
            lang    = "bash";
            content = ''
              $ curl -s "https://www.shl.se/api/statistics-v2/stats-info/teams_powerplay?count=25&ssgtUuid=qa98unlbd6&provider=statnet&state=active&moduleType=result" | head -c 200
              [{"dataColumns":[{"name":"Rank","type":"integer","highlighted":false,"group":""},{"name":"Team","type":"string","highlig
            '';
          };
        }

        {
          prose = ''
            ## **Step 3: Understand the league identifiers.**

            The `ssgtUuid` is not a secret in any meaningful sense. It isn't
            even obfuscated - it sits in a query string in the page source,
            unchanged for years. The `layout-info` endpoint lists one for every
            season, series, and game type the league has ever played. The
            regular-season SHL one for 2026 is `qa98unlbd6`. Both leagues
            publish their own:
          '';
        }
        {
          code = {
            title   = "leagues";
            lang    = "nix";
            content = ''
              ha  = {
                ssgtUuid = "uy2zvu6xaa";
                apiBase  = "https://www.hockeyallsvenskan.se/api";
              };
              shl = {
                ssgtUuid = "qa98unlbd6";
                apiBase  = "https://www.shl.se/api";
              };
            '';
          };
        }

        {
          warning = ''
            These are public endpoints serving public data. Don't hammer them,
            don't redistribute the raw feed
          '';
        }


        {
          prose = ''
            ## **Step 4: Build a reusable Nix configuration.**


            Rather than write multiple `yo`  scripts, I wrote one unified builder.

            **Say hello to mkDuckPUCK!**

            **mkDuckPUCK** is instantiated twice, once per league. I also decided to make one additional script exclusively for searching games.
            Everything that differs between the leagues lives in a plain attrset.
            Teans are defined outside of the league to avoid the need for manual entries each season.
            Teams are also fuzzy matched for user friendly searches.

            The interesting part is that Nix isn't just configuring two scripts here. It's generating the whole interface.

            One attrset describes the league, its teams, API endpoints and identifiers. From that, the builder produces the scraper, team matching, API mappings, voice entities, parameters and sentence templates.

            Same engine. Two leagues. duckPUCK
          '';
        }
        {
          code = {
            title   = "yo.scripts";
            lang    = "nix";
            content = ''
              yo.scripts = {
                "duckPUCK-ha"    = mkDuckPUCK "ha"  leagues.ha;
                "duckPUCK-shl"   = mkDuckPUCK "shl" leagues.shl;
                "duckPUCK-games" = mkDuckPUCKGames;
              };
            '';
          };
        }


        {
          prose = ''
            ## **Step 5: Define the parameters.**

            Every parameter here is what `yo` exposes to the caller and what the
            voice layer fills in from natural language. `mode` is the only required
            one - `table`, `recent`, `upcoming`, `best`, `worst` - and it is pulled
            from a shared enum (`swe.allowFrom`) so the Swedish synonyms stay in
            sync across scripts. `team` is the fuzzy-matched team name, `stat` is
            the stat key (`powerplay`, `tallest`, `goals`, …), `count` is how many
            rows to return, and `dataDir` is where the scraper writes `table.json`.

            All of it is declared once per league, and the builder wires it into
            the scraper, the analyzer and the voice parser. There is no second
            place to keep in sync - which is the whole point of building this
            as an attrset instead of two hand-written shell scripts.

            So, these will be the valid parameters for stats:

            <ul>
                <li>powerplay</li>
                <li>boxplay</li>
                <li>shorthanded_goals</li>
                <li>shorthanded</lu>
                <li>goalkeeper</li>
                <li>save_percentage</li>
                <li>penalty</li>
                <li>tallest</li>
                <li>shortest</li>
                <li>heaviest</li>
                <li>lightest</li>
                <li>oldest</li>
                <li>youngest</li>
                <li>icetime</li>
                <li>goals</li>
                <li>assists</li>
                <li>points</li>
            </ul>

          '';
        }

        {
          code = {
            title   = "yo.scripts.duckPUCK.parameters";
            lang    = "bash";
            content = ''
              parameters = [
                { name        = "mode"; description = "What to display: 'recent', 'table', 'upcoming', or best/worst analysis";
                  optional    = false;
                  values      = [
                    "recent" "upcoming" "table"
                    "best" "worst"
                  ];
                  default     = "table";
                }
                { name = "team"; description = "Team specific search with TTS";                       optional = true; }
                { name = "stat"; description = "Search for specific stats.";
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
                  default = "~/" + ".config/yo/''${league.dataDirName}"; }
              ];

            '';
          };
        }


        {
          prose = ''
            ## **Step 6: Generate the voice vocabulary.**

            The vocabulary is where the project gets silly. Each entry in
            `sharedSentenceBodies` is a Swedish phrase with placeholders for
            `{team}`, `{stat}`, `{mode}` and `{count}`. The `voiceTeamVals` list
            turns every alias - `färjestad`, `farjestad`, `fbk` - into a voice
            entity, so the same team can be reached through any of its names.
            Multiply roughly sixty sentence bodies by the team aliases, the
            stat values, the mode values and the count values, and you land
            around 88,000 recognisable phrases per league.

            The Nix builder does this arithmetic at evaluation time: the
            `sentences` list is `map (s: "''${league.voicePrefix} ''${s}") sharedSentenceBodies`,
            and the `lists` are built from the same attrsets that drive the
            scraper. One source of truth, two leagues, one voice prefix each.
          '';
        }
        {
          code = {
            title   = "yo.scripts.duckPUCK.voice";
            lang    = "bash";
            collapsed = true;
            content = ''
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


              sentences = map (s: "''${league.voicePrefix} ''${s}") sharedSentenceBodies;
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
                count.values = swe.numberFromOneTo 15;
              };

            '';
          };

        }

        {
          prose = ''
            ## **Step 7: Turning raw statistics into spoken interpretation / analysis engine.**

            The assistant actually <strong>understands hockey context</strong>.<br>
            It doesn't simply read a table and announce the numbers.<br>

            It interprets league position and generates contextual commentary:

            <ul>
                <li>League leader.</li>
                <li>Top-three contender.</li>
                <li>Mid-table team.</li>
                <li>Lower-half team.</li>
                <li>Relegation-threatened team.</li>
            </ul>

            Then it adds goal difference, overtime performance and other observations.
            The powerplay and boxplay analysis also evaluates league rankings and generates different commentary depending on performance.

            Numbers into Swedish words, positions into ordinal words, useful for a good duckPUCK commentary.
          '';
        }



        {
          code = {
            title   = "yo shl när möter löven lule?";
            lang    = "bash";
            content = ''
              🦆🏠  HOME via 🐍 v3.14.10 via 🦀 v1.98.0
              05:04:45 ❯ yo do "när möter löven lule"
                 ┌─(yo-duckPUCK-games)
                 │ 🦆 quack! när möter löven lule
                 └─⮞ --home Björklöven
                 └─⮞ --away Luleå
                 └─ ⏰ do took 46.346035ms
              På Lördag den fem December spelar Björklöven hemma match mot Luleå i Visionite Arena.
              På Torsdag den elva Mars spelar Björklöven hemma match mot Luleå i Visionite Arena.
            '';
          };
        }


        {
          code = {
            title   = "yo shl vem är seriens fetaste spelare?";
            lang    = "bash";
            content = ''
              🦆🏠  HOME via 🐍 v3.14.10 via 🦀 v1.98.0
             05:13:31 ❯ yo do "shl vem är ligans fetaste spelare"
                ┌─(yo-duckPUCK-shl)
                │ 🦆 quack! shl vem är ligans fetaste spelare
                └─⮞ --stat heaviest
                └─ ⏰ do took 2.842625ms
                [🦆🏒] INFO - Saved 14 teams to /home/pungkula/.config/yo/hockey-shl/table.json
                [🦆🏒] INFO - SHL scraping completed!
                99. Joona Ikonen (Malmö Redhawks) - Vikt: 178 kg
                79. Radim Zohorna (Färjestad BK) - Vikt: 104 kg
                87. Patrik Karlkvist (Örebro Hockey) - Vikt: 98 kg
            '';
          };
        }

        {
          prose = ''
            ## **And just like that we see a human-error.**

            Someone entered this poor Finish guys length as weight...

            **Sorry `Joona Ikonen`, You're this season's duckPUCK heavy-weight champion!**

          '';
        }

        {
          code = {
            title   = "Click to view duckPUCK source code";
            lang = "nix";
            collapsed = true;
            content = builtins.readFile ../../bin/misc/duckPUCK.nix;
          };
        }

        {
          duck = "dis waz fun huh . stay safe // NcBLindy";
        }
      ];
    };

  };}
