# dotfiles/bin/home/timer.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ timer management - ised when cooking or whatever  
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
    "femtioett" "femtiotvå" "femtiotre" "femtiofyra" "femtiofem" "femtiosex" "femtiosju" "femtioåtta" "femtionio"
  ];



  swedishNumber = n: builtins.elemAt swedishNumbers (n - 1);
  timerValues = builtins.map (n: toString n) (lib.range 0 59);
 
in {  
  yo.scripts.timer = {
    description = "Set a timer";
    category = "🛖 Home Automation";
    parameters = [  
      { name = "minutes"; type = "string"; description = "Minutes to set the timer on"; default = "0"; values = timerValues; }     
      { name = "seconds"; type = "string"; description = "Seconds to set the timer on"; default = "0"; values = timerValues; }     
      { name = "hours"; type = "string"; description = "Hours to set the timer on"; default = "0"; values = timerValues; } 
      { name = "list"; type = "bool"; description = "Lists active timers"; default = false;  }
      { name = "sound"; type = "path"; description = "Soundfile to be played on finished timer"; default = /home/pungkula/dotfiles/modules/themes/sounds/finished.wav; }
    ];
    code = ''
      if [ "$list" = "true" ] || [ "$list" = "1" ]; then
        zigduck-cli timer list
        exit 0
      fi

      if [ -z "$hours" ]; then hours=0; fi
      if [ -z "$minutes" ]; then minutes=0; fi
      if [ -z "$seconds" ]; then seconds=0; fi
      
      if [ "$hours" -eq 0 ] && [ "$minutes" -eq 0 ] && [ "$seconds" -eq 0 ]; then
        zigduck-cli timer list
        exit 0
      fi

      zigduck-cli timer set --hours "$hours" --minutes "$minutes" --seconds "$seconds"    
    '';
    voice = {
      priority = 1;
      sentences = [
        "(skapa|ställ|sätt|starta) [en] (time|timer|timern) [på] {hours} (timme|timmar) {minutes} (minut|minuter) {seconds} (sekund|sekunder)"
        "(skapa|ställ|sätt|starta) [en] (time|timer|timern) [på] {minutes} (minut|minuter) [och] {seconds} (sekund|sekunder)"
        "(skapa|ställ|sätt|starta) [en] (time|timer|timern) [på] {minutes} (minut|minuter)"                     
        "(skapa|ställ|sätt|starta) [en] (time|timer|timern) [på] {seconds} sekunder"      
        
        "hur {list} är det kvar på (time|timer|timern)"
        "tid {list} på (time|timer|timern)"
        "när {list} (time|timer|timern)"
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
              ) 59);
              minutes.values = builtins.concatLists (builtins.genList (
                i: let n = i + 1; in [
                  { "in" = toString n; out = toString n; }
                  { "in" = swedishNumber n; out = toString n; }
                ]
              ) 59);
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
