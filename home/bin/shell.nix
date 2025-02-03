# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.python3
    pkgs.python3Packages.requests
    pkgs.python3Packages.python-dotenv
    pkgs.python312Packages.npyscreen
    pkgs.python312Packages.paramiko
    pkgs.python312Packages.curtsies
    pkgs.python312Packages.psutils
  ];
}
