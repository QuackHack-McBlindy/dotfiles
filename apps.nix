# apps.nix
{ self, pkgs, ... }@inputs:
{
  update-readme = {
    type = "app";
    program = "${self.legacyPackages.${pkgs.system}.update-readme}/bin/update-readme";
  };
}
