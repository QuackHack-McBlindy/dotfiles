# ddotfiles/packages/health-rs.nix ⮞ https://github.com/QuackHack-McBlindy/dotfiles
{ # 🦆 says ⮞ health-rs does JSON system health
  self,
  lib,
  pkgs,
  rustPlatform,
  fetchFromGitHub,
  ...
} : let

in
rustPlatform.buildRustPackage {
  pname = "health-rs";
  version = "0.1.0";

  src = ./health-rs;

  cargoLock = {
    lockFile = ./health-rs/Cargo.lock;
  };

  nativeBuildInputs = [

    rustPlatform.bindgenHook
  ];

  buildInputs = [ ];

  meta = with lib; {
    description = "System health reports";
    license = licenses.mit;
    maintainers = [ "QuackHack-McBlindy" ];
    mainProgram = "health-rs";

  };}
