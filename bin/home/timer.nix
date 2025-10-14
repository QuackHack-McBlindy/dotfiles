# dotfiles/bin/home/timer.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Handles timers.  
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  # 🦆 says ⮞ sweeedish number words 1-60
  swedishNumbers = [
    "ett" "två" "tre" "fyra" "fem" "sex" "sju" "åtta" "nio" "tio"
    "elva" "tolv" "tretton" "fjorton" "femton" "sexton" "sjutton" "arton" "nitton" "tjugo"
    "tjugoett" "tjugotvå" "tjugotre" "tjugofyra" "tjugofem" "tjugosex" "tjugosju" "tjugoåtta" "tjugonio" "trettio"
    "trettioett" "trettiotvå" "trettiotre" "trettiofyra" "trettiofem" "trettiosex" "trettiosju" "trettioåtta" "trettionio" "fyrtio"
    "fyrtioett" "fyrtiotvå" "fyrtiotre" "fyrtiofyra" "fyrtiofem" "fyrtiosex" "fyrtiosju" "fyrtioåtta" "fyrtionio" "femtio"
    "femtioett" "femtiotvå" "femtiotre" "femtiofyra" "femtiofem" "femtiosex" "femtiosju" "femtioåtta" "femtionio" "sextio"
  ];
  # 🦆 says ⮞ get dat number yo
  swedishNumber = n: builtins.elemAt swedishNumbers (n - 1);
in {  
  yo.scripts.timer = {
    description = "Set a timer";
    category = "🛖 Home Automation";
    parameters = [  
      { name = "minutes"; description = "Minutes to set the timer on"; default = "0";  }     
      { name = "seconds"; description = "Seconds to set the timer on"; default = "0"; }     
      { name = "hours"; description = "Hours to set the timer on"; default = "0"; }
      { name = "list"; type = "bool"; description = "Lists active timers"; default = false;  }      
      { name = "sound"; type = "path"; description = "Soundfile to be played on finished timer"; default = /home/pungkula/dotfiles/modules/themes/sounds/finished.wav; }
    ];
    code = ''
      ${cmdHelpers}
      SOUNDFILE="$sound"
      HOURS="$hours"
      MINUTES="$minutes"
      SECONDS="$seconds"

      LOGFILE_DIR="/tmp/yo-timers"
      mkdir -p "$LOGFILE_DIR"

      if [ "$list" = "true" ]; then
        timers=()
        counter=1

        if ls "$LOGFILE_DIR"/*.pid >/dev/null 2>&1; then
          for pidfile in "$LOGFILE_DIR"/*.pid; do
            pid=$(basename "$pidfile" .pid)
            if ps -p "$pid" >/dev/null 2>&1; then
              end_time=$(awk '{print $2}' "$pidfile")
              remaining=$((end_time - $(date +%s)))
              if [ $remaining -gt 0 ]; then
                hours_left=$((remaining / 3600))
                minutes_left=$(((remaining % 3600) / 60))
                seconds_left=$((remaining % 60))
                finish_time=$(date -d @$end_time +'%H:%M:%S')
                timers+=("{\"id\":$pid,\"counter\":$counter,\"target\":\"$finish_time\",\"hours_left\":$hours_left,\"minutes_left\":$minutes_left,\"seconds_left\":$seconds_left}")
                if_voice_say "Timer $counter . Ringer klockan $finish_time . om $hours_left timmar, $minutes_left minuter och $seconds_left sekunder" --blocking true --silence "0.6"
                counter=$((counter + 1))
              fi
            else
              rm -f "$pidfile"
            fi
          done
        fi

        if [ ''${#timers[@]} -eq 0 ]; then
          echo '{"timers":[]}'
        else
          printf '{"timers":[%s]}\n' "$(IFS=,; echo "''${timers[*]}")"
        fi
        exit 0
      fi

      TIMER_TOTAL=$((HOURS * 3600 + MINUTES * 60 + SECONDS))
      DURATION=$TIMER_TOTAL
      TIMER_MINUTES=$((DURATION / 60))
      if_voice_say "OKej kompis! Jag Ställde en timer på $TIMER_MINUTES minuter"

      start_time=$(date +%s)
      end_time=$((start_time + DURATION))

      (
        while [ $(date +%s) -lt $end_time ]; do
          now=$(date +%s)
          remaining=$((end_time - now))
          echo -ne "Time remaining: ''${remaining}s\r"
          sleep 1
        done

        echo -e "\n\e[1;5;31m[TIMER FINISHED]\e[0m"
        rm -f "$LOGFILE_DIR/$$.pid"

        if [ -f "$SOUNDFILE" ]; then
          for i in {1..10}; do
            aplay "$SOUNDFILE" >/dev/null 2>&1
          done
          sleep 15
          for i in {1..8}; do
            aplay "$SOUNDFILE" >/dev/null 2>&1
          done
        else
          echo "Sound file not found: $SOUNDFILE"
        fi
      ) > /tmp/yo-timer.log 2>&1 &
      pid=$!
      echo "$pid $end_time" > "$LOGFILE_DIR/$pid.pid"
      disown "$pid"
    '';
    voice = {
      priority = 5;
      sentences = [
        "(skapa|ställ|sätt|starta) [en] timer [på] {hours} (timme|timmar) {minutes} (minut|minuter) {seconds} (sekund|sekunder)"
        "(skapa|ställ|sätt|starta) [en] timer [på] {minutes} (minut|minuter) [och] {seconds} (sekund|sekunder)"
        "(skapa|ställ|sätt|starta) [en] timer [på] {minutes} (minut|minuter)"                     
        "(skapa|ställ|sätt|starta) [en] timer [på] {seconds} sekunder"      
        
        "hur {list} är det kvar på timern"
        "tid {list} på timern"
      ];        
      lists = {
        list.values = [
          { "in" = "[länge|kvar]"; out = "true"; }
        ];
        seconds.values = builtins.concatLists (builtins.genList (
                i: let n = i + 1; in [
                  { "in" = toString n; out = toString n; }     
                  { "in" = swedishNumber n; out = toString n; }
                ]
              ) 60);
              minutes.values = builtins.concatLists (builtins.genList (
                i: let n = i + 1; in [
                  { "in" = toString n; out = toString n; }
                  { "in" = swedishNumber n; out = toString n; }
                ]
              ) 60);
              hours.values = builtins.concatLists (builtins.genList (
                i: let n = i + 1; in [
                  { "in" = toString n; out = toString n; }
                  { "in" = swedishNumber n; out = toString n; }
                ]
              ) 24);
        };
      }; 
    };
    
  }
