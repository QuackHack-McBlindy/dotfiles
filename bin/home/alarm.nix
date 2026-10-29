# dotfiles/bin/home/alarm.nix
{
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  zigduck-cli = self.inputs.zigduck.packages.${pkgs.stdenv.hostPlatform.system}.zigduck-cli;

  swedishNumbers = [
    "noll" "ett" "två" "tre" "fyra" "fem" "sex" "sju" "åtta" "nio" "tio"
    "elva" "tolv" "tretton" "fjorton" "femton" "sexton" "sjutton" "arton" "nitton" "tjugo"
    "tjugoett" "tjugotvå" "tjugotre" "tjugofyra" "tjugofem" "tjugosex" "tjugosju" "tjugoåtta" "tjugonio" "trettio"
    "trettioett" "trettiotvå" "trettiotre" "trettiofyra" "trettiofem" "trettiosex" "trettiosju" "trettioåtta" "trettionio" "fyrtio"
    "fyrtioett" "fyrtiotvå" "fyrtiotre" "fyrtiofyra" "fyrtiofem" "fyrtiosex" "fyrtiosju" "fyrtioåtta" "fyrtionio" "femtio"
    "femtioett" "femtiotvå" "femtiotre" "femtiofyra" "femtiofem" "femtiosex" "femtiosju" "femtioåtta" "femtionio" "sextio"
  ];
  swedishNumber = n: builtins.elemAt swedishNumbers (n - 1);

  hoursValues   = builtins.map (n: toString n) (lib.range 0 23);
  minutesValues = builtins.map (n: toString n) (lib.range 0 59);

  mkNumValueList = max:
    builtins.concatLists (builtins.genList
      (i: let n = i + 1; in [
        { "in" = toString n;      out = toString n; }
        { "in" = swedishNumber n; out = toString n; }
      ])
      max);

in {
  yo.scripts.alarm = {
    description = "Set an alarm for a specified time";
    category = "🛖 Home Automation";
    aliases = [ "wakeup" ];
    parameters = [
      { name = "hours";      type = "string"; description = "Clock hour, 24h format"; default = "0"; values = hoursValues; optional = false; }
      { name = "minutes";    type = "string"; description = "Clock minute"; default = "0"; values = minutesValues; }
      { name = "minuteWord"; type = "string"; description = "Minute phrase part (fem, kvart, …)"; default = ""; }
      { name = "prep";       type = "string"; description = "Direction: över / i / halv"; default = ""; }
      { name = "list";       type = "bool";   description = "Lists active alarms"; default = false; }
      { name = "sound";      type = "path";   description = "Soundfile to be played on finished alarm"; default = "${self}/modules/themes/sounds/finished.wav"; }
    ];
    code = ''
      if [ "$list" = "true" ] || [ "$list" = "1" ]; then
        ${zigduck-cli}/bin/zigduck-cli alarm list
        exit 0
      fi

      : "${hours:=0}"
      : "${minutes:=0}"


      if [ -n "$prep" ]; then
        case "$prep" in
          halv) offset=-30 ;;
          över) offset="''${minuteWord:-0}" ;;
          i)    offset="-''${minuteWord:-0}" ;;
          *)    offset=0 ;;
        esac
        total=$(( hours * 60 + offset ))
        total=$(( (total + 1440) % 1440 ))
        hours=$(( total / 60 ))
        minutes=$(( total % 60 ))
      fi

      if [ "$hours" -eq 0 ] && [ "$minutes" -eq 0 ]; then
        ${zigduck-cli}/bin/zigduck-cli alarm list
        exit 0
      fi

      name="alarm-$hours-$minutes"
      ${zigduck-cli}/bin/zigduck-cli alarm add \
        --hours   "$hours" \
        --minutes "$minutes" \
        --name    "$name" \
        --sound   "$sound"
    '';
    voice = {
      priority = 5;
      fuzzy = { enable = true; threshold = 0.9; };
      sentences = [
        "(ställ|sätt|start|starta|skap|skapa|gör) [en] (väckarklocka|väckarklockan|larm|alarm) [på] [klocka|klockan] {hours} [och] {minutes}"
        "jag vill stiga upp [klock|klocka|klockan] {hours} [och] {minutes}"
        "väck mig [klocka|klockan] {hours} [och] {minutes}"

        "(ställ|sätt|start|starta|skap|skapa|gör) [en] (väckarklocka|väckarklockan|larm|alarm) [på] [klocka|klockan] {minuteWord} {prep} {hours}"
        "väck mig {minuteWord} {prep} {hours}"
        "jag vill stiga upp {minuteWord} {prep} {hours}"

        "(ställ|sätt|start|starta|skap|skapa|gör) [en] (väckarklocka|väckarklockan|larm|alarm) [på] [klocka|klockan] {prep} {hours}"
        "väck mig {prep} {hours}"
        "jag vill stiga upp {prep} {hours}"

        "när ska jag {list} [upp]"
        "när {list} min väckarklocka"
      ];
      lists = {
        list.values = [
          { "in" = "[stiga|vakna|ringer]"; out = "true"; }
        ];

        prep.values = [
          { "in" = "över"; out = "över"; }
          { "in" = "i";    out = "i"; }
          { "in" = "halv"; out = "halv"; }
        ];

        minuteWord.values =
          [ { "in" = "kvart"; out = "15"; } ]
          ++ mkNumValueList 29;

        hours.values   = mkNumValueList 12;
        minutes.values = mkNumValueList 59;
      };
    };

  };}
