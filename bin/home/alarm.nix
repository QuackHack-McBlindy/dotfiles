# dotfiles/bin/home/alarm.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ taking care of wakeup.  
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
   yo.scripts.alarm = {
    description = "Set an alarm for a specified time";
    category = "🛖 Home Automation";  
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
    voice = {
      priority = 5;
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
    };
    
  };}
