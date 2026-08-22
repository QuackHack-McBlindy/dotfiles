{ 
  config,
  lib,
  pkgs,
  ...
} : let
  englishNumbers = [
    "zero" "one" "two" "three" "four" "five" "six" "seven" "eight" "nine" "ten"
    "eleven" "twelve" "thirteen" "fourteen" "fifteen" "sixteen" "seventeen" "eighteen" "nineteen" "twenty"
    "twenty-one" "twenty-two" "twenty-three" "twenty-four" "twenty-five" "twenty-six" "twenty-seven" "twenty-eight" "twenty-nine" "thirty"
    "thirty-one" "thirty-two" "thirty-three" "thirty-four" "thirty-five" "thirty-six" "thirty-seven" "thirty-eight" "thirty-nine" "forty"
    "forty-one" "forty-two" "forty-three" "forty-four" "forty-five" "forty-six" "forty-seven" "forty-eight" "forty-nine" "fifty"
    "fifty-one" "fifty-two" "fifty-three" "fifty-four" "fifty-five" "fifty-six" "fifty-seven" "fifty-eight" "fifty-nine" "sixty"
  ];

  englishNumber = n: builtins.elemAt englishNumbers n;
  timerValues = builtins.map (n: toString n) (lib.range 0 60);
  

in {

  yo.scripts.timer-en = {
    description = "Control user timers.";
    category = "Home Automation";
    logLevel = "INFO"; 
    parameters = [
      { name = "minutes"; type = "string"; description = "Minutes to set the timer on"; default = "0"; values = timerValues; }     
      { name = "seconds"; type = "string"; description = "Seconds to set the timer on"; default = "0"; values = timerValues; }     
      { name = "hours"; type = "string"; description = "Hours to set the timer on"; default = "0"; values = timerValues; }
      { name = "list"; type = "bool"; description = "Lists active timers"; default = false;  }
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
  };  

  yo.scripts.timer-en.voice.sentences = [
    "(set|start|create) [a] timer [for] {hours} (hour|hours) {minutes} (minute|minutes) {seconds} (second|seconds)"
    "(set|start|create) [a] timer [for] {minutes} (minute|minutes) [and] {seconds} (second|seconds)"
    "(set|start|create) [a] timer [for] {minutes} (minute|minutes)"                     
    "(set|start|create) [a] timer [for] {seconds} (second|seconds)"      
        
    "how (much|long) {list} left on [the] timer"
    "time {list} on [the] timer"
    "when {list} [the] timer"
  ];   
  
  yo.scripts.timer-en.voice.lists = {
    list.values = [
      { "in" = "[left|remaining]"; out = "true"; }
    ];
    seconds.values = builtins.concatLists (builtins.genList (
      i: let n = i + 1; in [
        { "in" = toString n; out = toString n; }     
        { "in" = englishNumber n; out = toString n; }
      ]
    ) 60);
    minutes.values = builtins.concatLists (builtins.genList (
      i: let n = i + 1; in [
        { "in" = toString n; out = toString n; }
        { "in" = englishNumber n; out = toString n; }
      ]
    ) 60);
    hours.values = builtins.concatLists (builtins.genList (
      i: let n = i + 1; in [
        { "in" = toString n; out = toString n; }
        { "in" = englishNumber n; out = toString n; }
      ]
    ) 24);

    
  };}
