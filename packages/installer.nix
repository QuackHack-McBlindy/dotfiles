{ self, system, lib, ... }:

let
  installer-flake = self.inputs.installer;
in installer-flake.packages.${system}.installer-iso 
