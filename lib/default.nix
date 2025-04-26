# lib/default.nix
{ self, lib, inputs }:
let
  attrs = import ./attrs.nix { inherit lib; };
  nixosLib = import ./nixos.nix { inherit self lib attrs inputs; };
in {
  inherit (attrs) mapHosts mapModules;
  inherit (nixosLib) mkApp mkFlake;
}
