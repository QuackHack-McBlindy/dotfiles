# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.python3
    pkgs.python3Packages.requests
    pkgs.python3Packages.python-dotenv
    pkgs.python312Packages.sh
    pkgs.python312Packages.pysilero-vad
    pkgs.python312Packages.webrtc-noise-gain
    pkgs.python312Packages.aiozeroconf
  ];
}
