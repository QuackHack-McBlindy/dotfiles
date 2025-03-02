# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.python3
    pkgs.python3Packages.requests
    pkgs.python3Packages.python-dotenv
  ];
  

#  shellHook = ''
#    if [ ! -d ".venv" ]; then
#      virtualenv .venv
#      source .venv/bin/activate
#    else
#      source .venv/bin/activate
#    fi
#  '';
  
}
