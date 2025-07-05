# dotfiles/bin/misc/time.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ one file for all time related scripts and intents
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
  yo.bitch = { 
    intents = {
      time = {
        priority = 2;
        data = [{
          sentences = [
            "(va|vad|vart) är klockan"
            "hur mycket är klockan"
            "(va|vad|vart) är det för dag"
            "vilket datum är det"
            "vad är det för datum"
          ];
        }];  
      };
      
      timer = {
        priority = 5;
        data = [{
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
        }];
      }; 
      
      alarm = {
        priority = 5;
        data = [{
          sentences = [
            "(ställ|sätt|starta) [en] (väckarklocka|väckarklockan|larm|alarm) [på] [klocka|klockan] {hours} {minutes}"   
            "väck mig [klocka|klockan] {hours} {minutes}"
          ];        
          lists = {
            hours.values = lib.genList (n: {
              "in" = toString (n + 1);
              out = toString (n + 1);
            }) 24;  
            minutes.values = lib.genList (n: {
              "in" = toString n;
              out = toString n;
            }) 60;
          };
        }];
      };      
    };
  };

  yo.scripts.timer = {
    description = "Set a timer";
    category = "🧩 Miscellaneous";
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
  };  

  yo.scripts.time = {
    description = "Tells time, day and date";
    category = "🧩 Miscellaneous";
    code = ''
      ${cmdHelpers}
      export LC_TIME=sv_SE.UTF-8
      TIME=$(date "+%H . %M")
      DAY=$(date "+%A")
      DATE=$(date "+%d %B")
      say_duck "Klockan är $TIME . Det är $DAY dem $DATE ."
      if_voice_say "Klockan är $TIME . Det är $DAY den $DATE ."  
    '';
  };  

    
   yo.scripts.alarm = {
    description = "Set an alarm for a specified time";
    category = "🧩 Miscellaneous";
    aliases = [ "wakeup" ];
    parameters = [     
      { name = "hours"; description = "Clock to sewt the alarm for, HH 24 format"; }     
      { name = "minutes"; description = "Clock to sewt the alarm for, MM format"; }    
      { name = "sound"; description = "Soundfile to be played on finished timer"; default = "/home/pungkula/dotfiles/modules/themes/sounds/finished.wav"; }
    ];
    code = ''
      (
        ${cmdHelpers}
        SOUNDFILE="$sound"  
        HOUR24=$((10#$hours))
        MINUTE=$((10#$minutes))
        if_voice_say "Okej kompis, jag ställde din väckarklocka på $HOUR24 $MINUTE"
        now=$(date +%s)
        target=$(date -d "today $HOUR24:$MINUTE" +%s)

        if [ $target -le $now ]; then
          target=$(date -d "tomorrow $HOUR24:$MINUTE" +%s)
        fi

       while [ $(date +%s) -lt $target ]; do
          remaining=$((target - $(date +%s)))
          echo -ne "Time until alarm: ''${remaining}s\r"
          sleep 1
        done
      
        echo -e "\n\e[1;5;31m[TIMER FINISHED]\e[0m"

        if [ -f "$SOUNDFILE" ]; then
          for i in {1..10}; do
            aplay "$SOUNDFILE" >/dev/null 2>&1
          done
        
          sleep 30
        
         for i in {1..8}; do
            aplay "$SOUNDFILE" >/dev/null 2>&1
          done
        fi
      ) > /tmp/yo-timer.log 2>&1 & disown
    '';
    
  };}
