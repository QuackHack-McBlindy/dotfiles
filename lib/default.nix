# dotfiles/lib/default.nix
{ self, lib, inputs }:
let
  dirMap = import ./dirMap.nix { inherit lib; };
  makeFlake = import ./makeFlake.nix { inherit self lib dirMap inputs; };
in {
  inherit (dirMap) mapHosts mapModules;
  inherit (makeFlake) makeApp makeFlake;
}
