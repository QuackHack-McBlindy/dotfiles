# dotfiles/packages/installer.nix
{ 
  self,
  system,
  lib,
  ...
} : let
  installer-flake = self.inputs.installer;
in
  if builtins.hasAttr system installer-flake.packages
  then installer-flake.packages.${system}.installer-iso
  else null
