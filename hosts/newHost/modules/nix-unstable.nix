{ pkgs, ... }:

{
  nix.package = pkgs.nixVersions.unstable;
}
