# dotfiles/bin/home/timer.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ timer management - used when cooking or whatever  
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  # 🦆 says ⮞ english number words 1-60
  englishNumbers = [
    "one" "two" "three" "four" "five" "six" "seven" "eight" "nine" "ten"
    "eleven" "twelve" "thirteen" "fourteen" "fifteen" "sixteen" "seventeen" "eighteen" "nineteen" "twenty"
    "twenty-one" "twenty-two" "twenty-three" "twenty-four" "twenty-five" "twenty-six" "twenty-seven" "twenty-eight" "twenty-nine" "thirty"
    "thirty-one" "thirty-two" "thirty-three" "thirty-four" "thirty-five" "thirty-six" "thirty-seven" "thirty-eight" "thirty-nine" "forty"
    "forty-one" "forty-two" "forty-three" "forty-four" "forty-five" "forty-six" "forty-seven" "forty-eight" "forty-nine" "fifty"
    "fifty-one" "fifty-two" "fifty-three" "fifty-four" "fifty-five" "fifty-six" "fifty-seven" "fifty-eight" "fifty-nine" "sixty"
  ];
  # 🦆 says ⮞ get that number yo
  englishNumber = n: builtins.elemAt englishNumbers (n - 1);
  
  # 🦆 says ⮞ this fetches which host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = "homie";
  mqttHostip = if mqttHost != null
    then self.nixosConfigurations.${mqttHost}.config.this.host.ip or (
      let
        resolved = builtins.readFile (pkgs.runCommand "resolve-host" {} ''
          ${pkgs.dnsutils}/bin/host -t A ${mqttHost} > $out
        '');
      in
        lib.lists.head (lib.strings.splitString " " (lib.lists.elemAt (lib.strings.splitString "\n" resolved) 0))
    )
    else (throw "No Mosquitto host found in configuration");
  mqttAuth = "-u mqtt -P $(cat ${config.sops.secrets.mosquitto.path})";
    
in {  
  yo.scripts.timer = {
    description = "Set a timer";
    category = "🛖 Home Automation";
    parameters = [  
      { name = "minutes"; type = "int"; description = "Minutes to set the timer on"; default = "0";  }     
      { name = "seconds"; type = "int"; description = "Seconds to set the timer on"; default = "0"; }     
      { name = "hours"; type = "int"; description = "Hours to set the timer on"; default = "0"; }
      { name = "list"; type = "bool"; description = "Lists active timers"; default = false;  }      
      { name = "sound"; type = "path"; description = "Soundfile to be played on finished timer"; default = /home/pungkula/dotfiles/modules/themes/sounds/finished.wav; }
    ];
    code = ''
      ${cmdHelpers}
      SOUNDFILE="$sound"
      HOURS="$hours"
      MINUTES="$minutes"
      SECONDS="$seconds"
      mqttHost="${mqttHost}"

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
                if_voice_say "Timer $counter. Rings at $finish_time. In $hours_left hours, $minutes_left minutes and $seconds_left seconds" --blocking true --silence "0.6"
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
      dt_info "Setting timer on $TIMER_MINUTES minutes ..."
      say "Okay buddy! I set a timer for $TIMER_MINUTES minutes"
      
      if [ "$(hostname)" != "$mqttHost" ]; then
        dt_info "Setting timer on $TIMER_MINUTES minutes on $mqttHost ..."
        ssh $mqttHost "yo timer --minutes $TIMER_MINUTES"
      fi

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

        yo notify "TIMER RINGING!!"

        if [ -f "$SOUNDFILE" ]; then
          for i in {1..10}; do
            aplay "$SOUNDFILE" >/dev/null 2>&1
          done
          sleep 15
          for i in {1..8}; do
            aplay "$SOUNDFILE" >/dev/null 2>&1
            yo notify "TIMER RINGING!!"
          done
        else
          dt_warning "Sound file not found: $SOUNDFILE"
        fi
      ) > /tmp/yo-timer.log 2>&1 &
      pid=$!
      echo "$pid $end_time" > "$LOGFILE_DIR/$pid.pid"
      disown "$pid"
    '';
    voice = {
      priority = 1;
      sentences = [
        "(set|start|create) [a] timer [for] {hours} (hour|hours) {minutes} (minute|minutes) {seconds} (second|seconds)"
        "(set|start|create) [a] timer [for] {minutes} (minute|minutes) [and] {seconds} (second|seconds)"
        "(set|start|create) [a] timer [for] {minutes} (minute|minutes)"                     
        "(set|start|create) [a] timer [for] {seconds} (second|seconds)"      
        
        "how (much|long) {list} left on [the] timer"
        "time {list} on [the] timer"
        "when {list} [the] timer"
      ];        
      lists = {
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
        };
      }; 
    };
    
  }
