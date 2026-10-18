# dotfiles/bin/misc/wait.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ sleep/wait.
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
in {
  yo.scripts.wait = {
    description = "Sleep before continue.";
    category = "🧩 Miscellaneous";
    parameters = [
      { name = "duration"; description = "Duration in seconds to sleep for"; type = "int"; optional = true;  }
    ];
    code = ''
      ${cmdHelpers}
      export LC_TIME=sv_SE.UTF-8
      TIME=$(date "+%H . %M")
      DAY=$(date "+%A")
      DATE=$(date "+%d %B")
      WEEK=$(date +%V)
      DURATION=$duration
      sleep $DURATION
    '';
    voice = {
      enabled = true;
      fuzzy.enable = false;
      fuzzy.threshold = 0.3;
      priority = 3;
      sentences = [
        "vänta [i] {duration} [sec|sekunder]"
      ];
      lists = {
        seconds.values = builtins.concatLists (builtins.genList (
                i: let n = i + 1; in [
                  { "in" = toString n; out = toString n; }
                  { "in" = swedishNumber n; out = toString n; }
                ]
        ) 59);
      };
    };

  };}
