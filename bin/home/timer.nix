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
      { name = "sound"; description = "Soundfile to be played on finished timer"; default = "/home/pungkula/dotfiles/modules/themes/sounds/finished.wav"; }
    ];
    code = ''
      (
        ${cmdHelpers}
        SOUNDFILE="$sound"
        HOURS="$hours"
        MINUTES="$minutes"
        SECONDS="$seconds"
      
        TIMER_TOTAL=$((HOURS * 3600 + MINUTES * 60 + SECONDS))
        DURATION=$TIMER_TOTAL
        TIMER_MINUTES=$((DURATION / 60)) 
        if_voice_say "OKej kompis! Jag Ställde en timer på $TIMER_MINUTES minuter"
        start_time=$(date +%s)
        end_time=$((start_time + DURATION))
      
        while [ $(date +%s) -lt $end_time ]; do
          now=$(date +%s)
          remaining=$((end_time - now))
          echo -ne "Time remaining: ''${remaining}s\r"
          sleep 1
        done
      
        echo -e "\n\e[1;5;31m[TIMER FINISHED]\e[0m"
      
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
      ) > /tmp/yo-timer.log 2>&1 & disown
    '';
    voice = {
      priority = 5;
      sentences = [
        "(skapa|ställ|sätt|starta) [en] timer [på] {hours} (timme|timmar) {minutes} (minut|minuter) {seconds} (sekund|sekunder)"
        "(skapa|ställ|sätt|starta) [en] timer [på] {minutes} (minut|minuter) [och] {seconds} (sekund|sekunder)"
        "(skapa|ställ|sätt|starta) [en] timer [på] {minutes} (minut|minuter)"                     
        "(skapa|ställ|sätt|starta) [en] timer [på] {seconds} sekunder"                     
      ];        
      lists = {
        seconds.values = builtins.concatLists (builtins.genList (
                i: let n = i + 1; in [
                  { "in" = toString n; out = toString n; }       # Digit string (e.g., "5")
                  { "in" = swedishNumber n; out = toString n; }  # Swedish word (e.g., "fem")
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
