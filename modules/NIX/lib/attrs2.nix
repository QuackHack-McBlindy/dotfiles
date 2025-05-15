# dotfiles/lib/attrs.nix
{ 
  lib
} :
mapHosts = dir:
  let
    entries = builtins.readDir dir;
    isHost = name: type: type == "directory";
    hosts = lib.filterAttrs isHost entries;
  in lib.mapAttrs' (name: _:
    nameValuePair name (import (dir + "/${name}"))
  ) hosts;
