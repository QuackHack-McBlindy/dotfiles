# dotfiles/bin/home/timer.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ timer management - ised when cooking or whatever
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  swe,
  ...
} : let
  zigduck-cli = self.inputs.zigduck.packages.${pkgs.stdenv.hostPlatform.system}.zigduck-cli;
in {
  yo.scripts.timer = {
    description = "Set a timer";
    category = "🛖 Home Automation";
    parameters = [
      { name = "minutes"; type = "string"; description = "Minutes to set the timer on"; default = "0";
        values = swe.allowFrom "minutes"; }
      { name = "seconds"; type = "string"; description = "Seconds to set the timer on"; default = "0";
        values = swe.allowFrom "seconds"; }
      { name = "hours"; type = "string"; description = "Hours to set the timer on"; default = "0";
        values = swe.allowFrom "hours"; }
      { name = "list"; type = "bool"; description = "Lists active timers"; default = false;  }
      { name = "sound"; type = "path"; description = "Soundfile to be played on finished timer"; default = /home/pungkula/dotfiles/modules/themes/sounds/finished.wav; }
    ];
    code = ''
      if [ "$list" = "true" ] || [ "$list" = "1" ]; then
        ${zigduck-cli}/bin/zigduck-cli timer list
        exit 0
      fi

      if [ -z "$hours" ]; then hours=0; fi
      if [ -z "$minutes" ]; then minutes=0; fi
      if [ -z "$seconds" ]; then seconds=0; fi

      if [ "$hours" -eq 0 ] && [ "$minutes" -eq 0 ] && [ "$seconds" -eq 0 ]; then
        ${zigduck-cli}/bin/zigduck-cli timer list
        exit 0
      fi

      ${zigduck-cli}/bin/zigduck-cli timer set --hours "$hours" --minutes "$minutes" --seconds "$seconds"
    '';
    voice = {
      priority = 5;
      fuzzy = {
        enable = true;
        threshold = 0.9;
      };
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
        list.values    = [
          { "in" = "länge|kvar"; out = "true"; }
        ];
        seconds.values = swe.clock.seconds;
        minutes.values = swe.clock.minutes;
        hours.values   = swe.clock.hours;
      };
    };

  };}
