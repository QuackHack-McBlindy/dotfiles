# dotfiles/bin/misc/timer.nix
{ 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {  
  yo.bitch = { 
    intents = {
      timer = {
        data = [{
          sentences = [
            "skapa en timer på {hours} timmar {minutes} minuter"
            "ställ en timer på {hours} timmar {minutes} minuter"
            "skapa en timer på {minutes} minuter"
            "ställ en timer på {minutes} minuter"
            "skapa en timer på {seconds} minuter {minutes} sekunder"
            "ställ en timer på {seconds} minuter {minutes} sekunder"
            "skapa timer på {hours} timmar {minutes} minuter"
            "ställ timer på {hours} timmar {minutes} minuter"
            "skapa timer på {minutes} minuter"
            "ställ timer på {minutes} minuter"
            "skapa timer på {seconds} minuter {minutes} sekunder"
            "ställ timer på {seconds} minuter {minutes} sekunder"
            "skapa en timer {hours} timmar {minutes} minuter"
            "ställ en timer {hours} timmar {minutes} minuter"
            "skapa en timer {minutes} minuter"
            "ställ en timer {minutes} minuter"
            "skapa en timer {seconds} minuter {minutes} sekunder"
            "ställ en timer {seconds} minuter {minutes} sekunder"
            "skapa timer {hours} timmar {minutes} minuter"
            "ställ timer {hours} timmar {minutes} minuter"
            "skapa timer {minutes} minuter"
            "ställ timer {minutes} minuter"
            "skapa timer {minutes} minuter {minutes} sekunder"
            "ställ timer {seconds} minuter {minutes} sekunder"            
          ];        
          lists = {
            seconds.values = builtins.genList (
              i: {
                "in" = toString (i + 1);
                out = toString (i + 1);
              }
            ) 60;
            minutes.values = builtins.genList (
              i: {
                "in" = toString (i + 1);
                out = toString (i + 1);
              }
            ) 60;
            hours.values = builtins.genList (
              i: {
                "in" = toString (i + 1);
                out = toString (i + 1);
              }
            ) 24;            
          };
        }];
      };
      
      alarm = {
        data = [{
          sentences = [
            "skapa en väckarklocka på klockan {minutes} och {hours}"
            "ställ en väckarklocka på klockan {minutes} och {hours}"
            "skapa väckarklocka på {minutes} och {hours}"
            "ställ väckarklocka på {minutes} och {hours}"        
            "skapa en väckarklocka på klockan {minutes}:{hours}"
            "ställ en väckarklocka på klockan {minutes}:{hours}"
            "skapa väckarklocka på {minutes}.{hours}"
            "ställ väckarklocka på {minutes}.{hours}"                 
          ];        
          lists = {
            hours.values = builtins.genList (
              i: {
                "in" = toString (i + 1);
                out = toString (i + 1);
              }
            ) 24; 
          minutes.values = builtins.genList (
              i: {
                "in" = toString (i + 1);
                out = toString (i + 1);
              }
            ) 60; 
          };
        }];
      };      
    };
  };

  yo.scripts.timer = {
    description = "Set a timer";
    category = "🧩 Miscellaneous";
#    aliases = [ "" ];
#    helpFooter = ''
#    '';
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
    
   yo.scripts.alarm = {
    description = "Set an alarm for a specified time";
    category = "🧩 Miscellaneous";
#    aliases = [ "" ];
#    helpFooter = ''
#    '';
    parameters = [     
      { name = "hours"; description = "Clock to sewt the alarm for, HH 24 format"; }     
      { name = "minutes"; description = "Clock to sewt the alarm for, MM format"; }    
      { name = "sound"; description = "Soundfile to be played on finished timer"; default = "/home/pungkula/dotfiles/modules/themes/sounds/finished.wav"; }
    ];
    code = ''
      ${cmdHelpers}
      SOUNDFILE="$sound"  
      HOUR24=$((10#$hours))
      MINUTE=$((10#$minutes))
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
    '';
    
  };}
