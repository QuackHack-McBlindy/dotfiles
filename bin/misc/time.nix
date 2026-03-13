# dotfiles/bin/misc/time.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Handles time related scripts.  
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
  yo.scripts.timee = {
    description = "Tells time, day, date & week";
    category = "🧩 Miscellaneous";
    code = ''
      ${cmdHelpers}
      export LC_TIME=sv_SE.UTF-8
      TIME=$(date "+%H . %M")
      DAY=$(date "+%A")
      DATE=$(date "+%d %B")
      WEEK=$(date +%V)
      say_duck "Klockan är $TIME . Det är $DAY dem $DATE ."
      echo "$TIME"
      yo say "Klockan är $TIME . Det är $DAY den $DATE . Vecka $WEEK"
    '';
    voice = {
      enabled = true;
      priority = 2;
      sentences = [
        "(va|vad|vart) är klockan"
        "hur mycket är klockan"
        "(va|vad|vart) är det för dag"
        "vilket datum är det"
        "vad är det för datum"
      ];
    };
    
  };}
