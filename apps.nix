# apps.nix
{ self, pkgs, ... }@inputs:
let
  # Choose a reference host that has the yo scripts
  referenceHost = builtins.head (builtins.attrNames self.nixosConfigurations);
in {
  update-readme = {
    type = "app";
    program = "${self.legacyPackages.${pkgs.system}.update-readme}/bin/update-readme";
  };
  edit = {
    type = "app";
    program = "${self.nixosConfigurations.${referenceHost}.config.yo.scripts.edit}/bin/yo-edit"
  };
} 
