{ 
  pkgs,
  system,
  inputs,
  self
} : let
  myBuildInputs = with pkgs; [
    git
    nixpkgs-fmt
    go
    gopls
  ];

  formatRed = name: "echo - \$'\\e[0;31m'${name}\$'\\e[0m'";
  formatHeader = text: "echo \$'\\e[1m'${text}\$'\\e[0m'";
in {
  buildInputs = myBuildInputs;

  shellHook = ''
    echo "Running on ${system}"
    echo ""
    ${formatHeader "Build inputs:"}
    ${pkgs.lib.concatMapStringsSep "\n" (pkg: "echo - \$'\\e[0;31m'${pkg.name}\$'\\e[0m'") myBuildInputs}
  '';
  
  NIX_CONFIG = "system = ${system}";
}
