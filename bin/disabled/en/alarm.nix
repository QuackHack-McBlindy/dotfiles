{
  self,
  config,
  lib,
  pkgs,
  ...
} : with lib;
let
  englishNumbers = [
    "zero" "one" "two" "three" "four" "five" "six" "seven" "eight" "nine" "ten"
    "eleven" "twelve" "thirteen" "fourteen" "fifteen" "sixteen" "seventeen" "eighteen" "nineteen" "twenty"
    "twenty-one" "twenty-two" "twenty-three" "twenty-four" "twenty-five" "twenty-six" "twenty-seven" "twenty-eight" "twenty-nine" "thirty"
    "thirty-one" "thirty-two" "thirty-three" "thirty-four" "thirty-five" "thirty-six" "thirty-seven" "thirty-eight" "thirty-nine" "forty"
    "forty-one" "forty-two" "forty-three" "forty-four" "forty-five" "forty-six" "forty-seven" "forty-eight" "forty-nine" "fifty"
    "fifty-one" "fifty-two" "fifty-three" "fifty-four" "fifty-five" "fifty-six" "fifty-seven" "fifty-eight" "fifty-nine" "sixty"
  ];

  englishNumber = n: builtins.elemAt englishNumbers n;
  hoursValues = builtins.map (n: toString n) (lib.range 1 12);
  minutesValues = builtins.map (n: toString n) (lib.range 0 59);
   
in {

  yo.scripts.alarm = {
    description = "Control user alarms.";
    category = "Home Automation";
    logLevel = "INFO";
    parameters = [   
      { name = "hours"; type = "int"; description = "Clock to sewt the alarm for, HH 24 format"; optional = false; values = hoursValues;  }     
      { name = "minutes"; type = "int"; description = "Clock to sewt the alarm for, MM format"; optional = false; values = minutesValues; }
      { name = "ampm"; description = "AM or PM"; optional = false; values = [ "am" "pm" ]; }      
      { name = "list"; type = "bool"; description = "Lists active alarms"; default = false; }      
    ];
    
    code = ''
      if [ "$list" = "true" ] || [ "$list" = "1" ]; then
        zigduck-cli alarm list
        exit 0
      fi

      if [ -z "$hours" ]; then hours=0; fi
      if [ -z "$minutes" ]; then minutes=0; fi
      if [ -z "$ampm" ]; then ampm="am"; fi

      # no time given? list alarms
      if [ "$hours" -eq 0 ] && [ "$minutes" -eq 0 ]; then
        zigduck-cli alarm list
        exit 0
      fi

      # covert 12-hour input to 24hour
      if [ "$ampm" = "pm" ] && [ "$hours" -ne 12 ]; then
        hours=$((hours + 12))
      elif [ "$ampm" = "am" ] && [ "$hours" -eq 12 ]; then
        hours=0
      fi

      name="alarm-$hours-$minutes"
      zigduck-cli alarm add --hours "$hours" --minutes "$minutes" --name "$name"    
    '';
    voice = {
      priority = 1;
      fuzzy = {
        enable = true;
        threshold = 0.4;
      };  
    };
  };  

  yo.scripts.alarm.voice.sentences = [
    # wake-up alarm commands
    "(set|start|create) [a|an] alarm [for] {hours} {minutes} {ampm}"
    "(set|start|create) [a|an] alarm [for] {hours} {ampm}"
    "wake me up at {hours} {minutes} {ampm}"
    "wake me up at {hours} {ampm}"
    "set [a|an] alarm at {hours} {minutes} {ampm}"
    "set [a|an] alarm at {hours} {ampm}"

    # alarm queries
    "how (much|long) {list} until [the|my] alarm"
    "when [is] [the|my] alarm"
    "what time [is] [the|my] alarm"
  ];

  yo.scripts.alarm.voice.lists = {

    hours.values = builtins.concatLists (builtins.genList (
      i: let n = i + 1; in [
        { "in" = toString n; out = toString n; }
        { "in" = englishNumber n; out = toString n; }
      ]
    ) 12);

    minutes.values = builtins.concatLists (builtins.genList (
      i: let n = i + 1; in [
        { "in" = toString n; out = toString n; }
        { "in" = englishNumber n; out = toString n; }
      ]
    ) 59);

    ampm.values = [
      { "in" = "[am|a.m.|in the morning]"; out = "am"; }
      { "in" = "[pm|p.m.|in the afternoon|in the evening|at night]"; out = "pm"; }
    ];

    list.values = [
      { "in" = "[left|remaining]"; out = "true"; }
    ];

  };}
