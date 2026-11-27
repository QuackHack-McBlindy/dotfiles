# dotfiles/bin/misc/joke.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Tell's bad jokes lol?
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {
  yo.scripts.testy = {
    description = "test";
    category = "🧩 Miscellaneous";
    # autoStart = false;
    logLevel = "INFO";
    responses = [
      { name = "nisse"; description = "."; text = "SNUS"; }
    ];
    code = ''
      echo "$nisse"
    '';

  };}
