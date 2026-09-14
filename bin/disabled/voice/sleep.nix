# dotfiles/bin/voice/sleep.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ sleep between natural langugage processing commands
  config,
  lib,
  self,
  pkgs,
  cmdHelpers,
  ...
} : let

in { # 🦆 says ⮞
  yo.scripts.sleep = {
      description = "Waits for specified time (seconds). Useful in command chains.";
      category = "🗣️ Voice";
      logLevel = "CRITICAL";
      parameters = [ # 🦆 says ⮞ some paramz to know where to pass audio
        { name = "time"; type = "int"; description = "Time to sleep"; optional = false; }
      ];
      code = ''
        ${cmdHelpers}
        dt_debug "Sleeping for: $time..."
        sleep $time
      '';
      voice = {
        enabled = true;
        priority = 1;
        sentences = [
          "vänta {time}"
        ];
        lists.time.values = [
          { "in" = "1"; out = "1"; }
          { "in" = "2"; out = "2"; }
          { "in" = "3"; out = "3"; }
          { "in" = "5"; out = "5"; }
          { "in" = "10"; out = "10"; }
        ];
      };
  };}
        #  seconds.values = builtins.concatLists (builtins.genList (
        #        i: let n = i + 1; in [
        #          { "in" = toString n; out = toString n; }
        #          { "in" = swedishNumber n; out = toString n; }
        #        ]
        #      ) 60);
             # minutes.values = builtins.concatLists (builtins.genList (
             #   i: let n = i + 1; in [
             #     { "in" = toString n; out = toString n; }
             #     { "in" = swedishNumber n; out = toString n; }
             #   ]
             # ) 60);
             # hours.values = builtins.concatLists (builtins.genList (
             #   i: let n = i + 1; in [
             #     { "in" = toString n; out = toString n; }
             #     { "in" = swedishNumber n; out = toString n; }
             #   ]
             # ) 24);
#      };

 #   };} # 🦆 says ⮞ QuackHack-McBLindy - out yo!
