# devShells/go.nix
{ pkgs, system, inputs, self }:
{
  buildInputs = with pkgs; [ 
    git
    nixpkgs-fmt
    go
    gopls
  ];
  
  shellHook = ''
    echo "Running on ${system}"
  '';
  
  # Add explicit system hint
  NIX_CONFIG = "system = ${system}";
}

