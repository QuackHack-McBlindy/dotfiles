# dotfiles/bin/home/alarm.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ alarms - takin' care of wakeup - forcefully getting me out of bed
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
  zigduck-cli = self.inputs.zigduck.packages.${pkgs.stdenv.hostPlatform.system}.zigduck-cli;

  # 🦆 says ⮞ sweeedish number words 1-60
  swedishNumbers = [
    "noll" "ett" "två" "tre" "fyra" "fem" "sex" "sju" "åtta" "nio" "tio"
    "elva" "tolv" "tretton" "fjorton" "femton" "sexton" "sjutton" "arton" "nitton" "tjugo"
    "tjugoett" "tjugotvå" "tjugotre" "tjugofyra" "tjugofem" "tjugosex" "tjugosju" "tjugoåtta" "tjugonio" "trettio"
    "trettioett" "trettiotvå" "trettiotre" "trettiofyra" "trettiofem" "trettiosex" "trettiosju" "trettioåtta" "trettionio" "fyrtio"
    "fyrtioett" "fyrtiotvå" "fyrtiotre" "fyrtiofyra" "fyrtiofem" "fyrtiosex" "fyrtiosju" "fyrtioåtta" "fyrtionio" "femtio"
    "femtioett" "femtiotvå" "femtiotre" "femtiofyra" "femtiofem" "femtiosex" "femtiosju" "femtioåtta" "femtionio" "sextio"
  ];
  # 🦆 says ⮞ get dat number yo
  swedishNumber = n: builtins.elemAt swedishNumbers (n - 1);


  hoursValues = builtins.map (n: toString n) (lib.range 1 12);
  minutesValues = builtins.map (n: toString n) (lib.range 0 59);


in {

   yo.scripts.alarm = {
    description = "Set an alarm for a specified time";
    category = "🛖 Home Automation";
    aliases = [ "wakeup" ];
    parameters = [
      { name = "hours"; type = "string"; description = "Clock to sewt the alarm for, HH 24 format"; optional = false; values = hoursValues;  }
      { name = "minutes"; type = "string"; description = "Clock to sewt the alarm for, MM format"; optional = false; values = minutesValues; }
      { name = "list"; type = "bool"; description = "Lists active alarms"; default = false; }
      { name = "sound"; type = "path"; description = "Soundfile to be played on finished timer"; default = /home/pungkula/dotfiles/modules/themes/sounds/finished.wav; }
    ];
    code = ''
      if [ "$list" = "true" ] || [ "$list" = "1" ]; then
        ${zigduck-cli}/bin/zigduck-cli alarm list
        exit 0
      fi

      if [ -z "$hours" ]; then hours=0; fi
      if [ -z "$minutes" ]; then minutes=0; fi
      if [ -z "$ampm" ]; then ampm="am"; fi

      # no time given? list alarms
      if [ "$hours" -eq 0 ] && [ "$minutes" -eq 0 ]; then
        ${zigduck-cli}/bin/zigduck-cli alarm list
        exit 0
      fi

      name="alarm-$hours-$minutes"
      ${zigduck-cli}/bin/zigduck-cli alarm add --hours "$hours" --minutes "$minutes" --name "$name"
    '';
    voice = {
      priority = 5;
      fuzzy = {
        enable = true;
        threshold = 0.9;
      };
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
        hours.values = builtins.concatLists (builtins.genList (
          i: let n = i + 1; in [
            { "in" = toString n; out = toString n; }
            { "in" = swedishNumber n; out = toString n; }
          ]
        ) 24);
        minutes.values = builtins.concatLists (builtins.genList (
          i: let n = i + 1; in [
            { "in" = toString n; out = toString n; }
            { "in" = swedishNumber n; out = toString n; }
          ]
        ) 60);
      };
    };

  };}
