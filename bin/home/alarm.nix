# dotfiles/bin/home/alarm.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ alarms - takin' care of wakeup - forcefully getting me out of bed 
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
  
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  mqttHost = lib.findSingle (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.services.mosquitto.enable or false
    ) null null sysHosts;    
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
   yo.scripts.alarm = {
    description = "Set an alarm for a specified time";
    category = "🛖 Home Automation";  
    aliases = [ "wakeup" ];
    parameters = [     
      { name = "hours"; type = "int"; description = "Clock to sewt the alarm for, HH 24 format"; optional = false; }     
      { name = "minutes"; type = "int"; description = "Clock to sewt the alarm for, MM format"; optional = false; }
      { name = "list"; type = "bool"; description = "Lists active alarms"; default = false; }          
      { name = "sound"; type = "path"; description = "Soundfile to be played on finished timer"; default = /home/pungkula/dotfiles/modules/themes/sounds/finished.wav; }
    ];
    code = ''
      ${cmdHelpers}
      SOUNDFILE="$sound"
      mqttHost="${mqttHost}"
      LOGFILE_DIR="/tmp/yo-alarms"
      mkdir -p "$LOGFILE_DIR"
  
      if [ "$list" = "true" ]; then
        alarms=()
        counter=1
        if ls "$LOGFILE_DIR"/*.pid >/dev/null 2>&1; then
          for pidfile in "$LOGFILE_DIR"/*.pid; do
            pid=$(basename "$pidfile" .pid)
            if ps -p "$pid" >/dev/null 2>&1; then
              read _ target_time < "$pidfile"
              remaining=$((target_time - $(date +%s)))
              if [ $remaining -gt 0 ]; then
                hours_left=$((remaining / 3600))
                minutes_left=$(((remaining % 3600) / 60))
                seconds_left=$((remaining % 60))
                rounded_time=$(date -d @$target_time +'%H:%M')
                alarms+=("{\"id\":$pid,\"counter\":$counter,\"target\":\"$rounded_time\",\"hours_left\":$hours_left,\"minutes_left\":$minutes_left,\"seconds_left\":$seconds_left}")
                if_voice_say "Väckarklocka $counter . Klockan $rounded_time . Ringer om $hours_left timmar och $minutes_left minuter" --blocking true --silence "0.6"
                counter=$((counter + 1))
              fi
            else
              rm -f "$pidfile"
            fi
          done
        fi

        if [ ''${#alarms[@]} -eq 0 ]; then
          echo '{"alarms":[]}'
        else
          printf '{"alarms":[%s]}\n' "$(IFS=,; echo "''${alarms[*]}")"
        fi
        exit 0
      fi


      HOUR24=$((10#$hours))
      MINUTE=$((10#$minutes))

      now=$(date +%s)
      target=$(date -d "today $HOUR24:$MINUTE" +%s)
      if [ $target -le $now ]; then
        target=$(date -d "tomorrow $HOUR24:$MINUTE" +%s)
      fi

      if [ "$(hostname)" != "$mqttHost" ]; then
        dt_info "Set alarm for $HOUR24:$MINUTE on $mqttHost ..."
        ssh $mqttHost "yo alarm --hours $hours --minutes $minutes"
      fi  

      if_voice_say "Okej kompis, jag ställde din väckarklocka på $HOUR24:$MINUTE"
      dt_info "Set alarm for $HOUR24:$MINUTE"

      (
        while [ $(date +%s) -lt $target ]; do
          remaining=$((target - $(date +%s)))
          echo -ne "Time until alarm: ''${remaining}s\r"
          sleep 1
        done

        echo -e "\n\e[1;5;31m[ALARM RINGS]\e[0m"
        rm -f "$LOGFILE_DIR/$$.pid"

        yo notify "Dags att vakna!!"
        # 🦆 says ⮞ TODO waiting for required tech parts
        # yo bed --state up && sleep 10
        # yo bed --state down && sleep 10        
        # yo bed --state up && sleep 10
        # yo bed --state down && sleep 10
        # yo bed --state up && sleep 10

        if [ -f "$SOUNDFILE" ]; then
          for i in {1..10}; do
            aplay "$SOUNDFILE" >/dev/null 2>&1
          done
          sleep 30
          for i in {1..8}; do
            aplay "$SOUNDFILE" >/dev/null 2>&1
            yo notify "UPP UR SÄNGEN!!!!"
          done
        else
          echo "Sound file not found: $SOUNDFILE"
        fi
      ) > /tmp/yo-alarm.log 2>&1 &
      pid=$!
      echo "$pid $target" > "$LOGFILE_DIR/$pid.pid"
      disown "$pid"
    '';
    voice = {
      priority = 5;
      sentences = [
        "(ställ|sätt|starta) [en] (väckarklocka|väckarklockan|larm|alarm) [på] [klocka|klockan] {hours} [och] {minutes}"   
        "väck mig [klocka|klockan] {hours} [och] {minutes}"
        
        "när ska jag {list} [upp]"
        "när {list} min väckarklocka"
      ];        
      lists = {
        list.values = [
          { "in" = "[stiga|vakna|ringer]"; out = "true"; }
        ];
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
