# devShells/rust.nix
{ pkgs, system, inputs, self }:
{
  buildInputs = with pkgs; [ 
    git
    nixpkgs-fmt
    rustc
    cargo
    clippy
    rustfmt
  ];
  
  shellHook = ''
    echo "Running on ${system}"
  '';
  
  # Add explicit system hint
  NIX_CONFIG = "system = ${system}";
}

