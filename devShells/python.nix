# dotfiles/devShells/python.nix
{ 
  pkgs,
  system,
  inputs,
  self
} : let
  pythonPackages = ps: [ ps.numpy ps.requests ps.lz4 ];
  myPython = pkgs.python3.withPackages pythonPackages;

  myBuildInputs = with pkgs; [
    git
    nixpkgs-fmt
    myPython
  ];

  pythonPkgNames = builtins.map (pkg: pkg.pname or pkg.name) (pythonPackages pkgs.python3.pkgs);
  formatRed = name: "echo - \$'\\e[0;31m'${name}\$'\\e[0m'";
  formatHeader = text: "echo \$'\\e[1m'${text}\$'\\e[0m'";
in {
  buildInputs = myBuildInputs;

  shellHook = ''
    echo "Running on ${system}"
    echo ""
    ${formatHeader "Build inputs:"}
    ${pkgs.lib.concatMapStringsSep "\n" (pkg: "echo - \$'\\e[0;31m'${pkg.name}\$'\\e[0m'") myBuildInputs}
    echo ""
    ${formatHeader "Python packages:"}
    ${pkgs.lib.concatMapStringsSep "\n" formatRed pythonPkgNames}
  '';

  NIX_CONFIG = "system = ${system}";
}

