# apps.nix
{ self, pkgs, ... }:
{
  # Simple script-based app
  hello = {
    type = "app";
    program = "${pkgs.hello}/bin/hello";
  };

  # Python script using your devShell dependencies
  run-python-script = {
    type = "app";
    program = pkgs.writeShellScriptBin "run-script" ''
      ${pkgs.python3}/bin/python ${./your_script.py}
    '';
  };

  # Custom package from your flake
  my-package = {
    type = "app";
    program = "${self.packages.${pkgs.system}.example}/bin/example";
  };

  # NixOS module app (e.g., rebuild)
  rebuild = {
    type = "app";
    program = "${pkgs.writeShellScriptBin "rebuild" ''
      sudo nixos-rebuild switch --flake .#$1
    ''}/bin/rebuild";
  };
}
