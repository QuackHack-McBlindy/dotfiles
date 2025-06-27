# dotfiles/lib/default.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self,
  lib,
  inputs
} : let # 🦆 duck say ⮞ we're importing dirMap and giving it the lib
  dirMap = import ./dirMap.nix { inherit lib; };  
  # 🦆 duck say ⮞ now we bring in makeFlake — giving it all the good stuff
  makeFlake = import ./makeFlake.nix { inherit self lib dirMap inputs; };
  
  # 🦆 duck say ⮞ for all ya Nix debbuin' needz
  duckTrace = import ./duckTrace.nix { inherit lib; }; 
  
in { # 🦆 duck say ⮞ mappings
  inherit (dirMap) mapHosts mapModules;
  # 🦆 duck say ⮞ givf buildin' tools yo
  inherit (makeFlake) makeApp makeFlake;  
  # 🦆 duck say ⮞ i say - let da tracin' begin!
  inherit duckTrace;
  }
