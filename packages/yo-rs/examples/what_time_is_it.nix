# dotfiles/packages/yo-rs/examples/what_time_is_it.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ simple example of a yo script with TTS
  self,# 🦆 ⮞ & defined sentences (for shell translation) 
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
  # 🦆 says ⮞ get dat number yo
  englishNumber = n: builtins.elemAt englishNumbers (n - 1);
in {
  yo.scripts.time = {
    description = "Tells time, day, date & week";
    category = "🧩 Miscellaneous";
    code = ''
      ${cmdHelpers}
      export LC_TIME=en_US.UTF-8
      TIME=$(date "+%H . %M")
      DAY=$(date "+%A")
      DATE=$(date "+%d %B")
      WEEK=$(date +%V)
      yo say "The time is $TIME. It is $DAY, $DATE. Week $WEEK"
    '';
    voice = {
      enabled = true;
      priority = 2;
      sentences = [
        "(what|whats) the time"
        "what (time|day|week|date) is it [now|today]"
      ];
    };
    
  };}
