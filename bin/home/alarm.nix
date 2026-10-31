# dotfiles/bin/home/alarm.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  sweSpeech,
  ...
} : let
  zigduck-cli = self.inputs.zigduck.packages.${pkgs.stdenv.hostPlatform.system}.zigduck-cli;

  hoursValues = builtins.map (n: toString n) (lib.range 0 23);
in {
  yo.scripts.alarm = {
    description = "Set an alarm for a specified time";
    category = "🛖 Home Automation";
    aliases = [ "wakeup" ];
    parameters = [
      { name = "hours";      type = "string"; description = "Clock hour, 24h format"; default = "0"; values = hoursValues; optional = false; }
      { name = "minutes";    type = "string"; description = "Clock minute"; default = "0"; values = sweSpeech.timerParamValues; }
      { name = "minuteWord"; type = "string"; description = "Minute phrase part (fem, kvart, …)"; default = ""; }
      { name = "prep";       type = "string"; description = "Direction: över / i / halv"; default = ""; }
      { name = "list";       type = "bool";   description = "Lists active alarms"; default = false; }
    ];
    code = ''
      if [ "$list" = "true" ] || [ "$list" = "1" ]; then
        ${zigduck-cli}/bin/zigduck-cli alarm list
        exit 0
      fi

      : "''${hours:=0}"
      : "''${minutes:=0}"

      if [ "$hours" -eq 0 ] && [ "$minutes" -eq 0 ] && [ -z "$prep" ]; then
        ${zigduck-cli}/bin/zigduck-cli alarm list
        exit 0
      fi

      raw_hours="$hours"
      raw_minutes="$minutes"
      raw_prep="$prep"
      raw_mw="''${minuteWord:-0}"

      if [ "$raw_hours" -ge 1 ] && [ "$raw_hours" -le 12 ]; then
        base1="$raw_hours"
        base2=$(( raw_hours + 12 ))
      else
        base1="$raw_hours"
        base2="$raw_hours"
      fi

      apply_prep() {
        local h=$1
        if [ -z "$raw_prep" ]; then
          echo "$h $raw_minutes"
          return
        fi
        local offset
        case "$raw_prep" in
          halv)  offset=-30 ;;
          över)  offset="$raw_mw" ;;
          i)     offset="-$raw_mw" ;;
          *)     offset=0 ;;
        esac
        local t=$(( h * 60 + offset ))
        t=$(( (t + 1440) % 1440 ))
        echo "$(( t / 60 )) $(( t % 60 ))"
      }

      read h1 m1 <<< "$(apply_prep "$base1")"
      read h2 m2 <<< "$(apply_prep "$base2")"

      now_h=$(date +%-H)
      now_m=$(date +%-M)
      now_today=$(( now_h * 60 + now_m ))

      cand1=$(( h1 * 60 + m1 ))
      cand2=$(( h2 * 60 + m2 ))

      BEST=999999
      BEST_H=$h1
      BEST_M=$m1

      for t in "$cand1" "$cand2" "$(( cand1 + 1440 ))" "$(( cand2 + 1440 ))"; do
        d=$(( t - now_today ))
        if [ "$d" -gt 0 ] && [ "$d" -lt "$BEST" ]; then
          BEST=$d
          BEST_H=$(( t / 60 % 24 ))
          BEST_M=$(( t % 60 ))
        fi
      done

      hours=$BEST_H
      minutes=$BEST_M

      name="alarm-$hours-$minutes"
      ${zigduck-cli}/bin/zigduck-cli alarm add \
        --hours   "$hours" \
        --minutes "$minutes" \
        --name    "$name"
    '';
    voice = {
      priority = 5;
      fuzzy = { enable = true; threshold = 0.9; };
      sentences = [
        "(ställ|sätt|start|starta|skap|skapa|gör|fixa) [en|ett] (väckarklocka|väckarklockan|larm|alarm) [på] [klocka|klockan] {hours} [och] {minutes}"
        "(ställ|sätt|start|starta|skap|skapa|gör|fixa) [en|ett] (väckarklocka|väckarklockan|larm|alarm) [på] [klocka|klockan] {minuteWord} {prep} {hours}"
        "(ställ|sätt|start|starta|skap|skapa|gör) [en|ett] (väckarklocka|väckarklockan|larm|alarm) [på] [klocka|klockan] {prep} {hours}"
        "jag vill stiga upp [klock|klocka|klockan] {hours} [och] {minutes}"
        "väck mig [klocka|klockan] {hours} [och] {minutes}"

        "väck mig {minuteWord} {prep} {hours}"
        "jag vill stiga upp {minuteWord} {prep} {hours}"

        "väck mig {prep} {hours}"
        "jag vill stiga upp {prep} {hours}"

        "när ska jag {list} [upp]"
        "när {list} min väckarklocka"
      ];
      lists = {
        list.values        = [ { "in" = "[stiga|vakna|ringer]"; out = "true"; } ];
        prep.values        = sweSpeech.clockPrepValues;
        minuteWord.values  = sweSpeech.clockMinuteWordValues;
        hours.values       = sweSpeech.clockHourValues;
        minutes.values     = sweSpeech.numberValuesOneBased 59;
      };

    };

  };}
