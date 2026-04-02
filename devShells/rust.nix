# dotfiles/devShells/rust.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ 4 da rust development
  pkgs,
  system,
  inputs,
  self
} : let # 🦆says⮞ list dependencies
  myBuildInputs = with pkgs; [
    git
    nixpkgs-fmt
    rustc
    cargo
    clippy
    esp-generate
    rustup
    rustfmt
  ];

  formatRed = name: "echo - \$'\\e[0;31m'${name}\$'\\e[0m'";
  formatHeader = text: "echo \$'\\e[1m'${text}\$'\\e[0m'";
in {
  buildInputs = myBuildInputs;

  # 🦆 says ⮞ display dependencies when entering shell
  shellHook = ''
    echo "Running on ${system}"
    echo ""
    ${formatHeader "Build inputs:"}
    ${pkgs.lib.concatMapStringsSep "\n" (pkg: "echo - \$'\\e[0;31m'${pkg.name}\$'\\e[0m'") myBuildInputs}
  '';
  
  NIX_CONFIG = "system = ${system}";
}
