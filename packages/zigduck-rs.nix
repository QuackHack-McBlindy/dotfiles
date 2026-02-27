# ddotfiles/packages/zigduck-rs.nix ⮞ https://github.com/QuackHack-McBlindy/dotfiles
{ # 🦆 says ⮞ home automation system service
  self,# 🦆 ⮞ + CLI device controller
  lib,
  pkgs,
  rustPlatform,
  fetchFromGitHub,
  ...
} : let

in  
rustPlatform.buildRustPackage {
  pname = "zigduck-rs";
  version = "0.1.0";

  src = ./zigduck-rs;

  cargoLock = {
    lockFile = ./zigduck-rs/Cargo.lock;
  };

  env.CMAKE_POLICY_VERSION_MINIMUM = "3.5";


  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.cmake
    pkgs.libclang
    rustPlatform.bindgenHook
  ];

  buildInputs = [ 
    pkgs.openssl.dev
    pkgs.mosquitto
    pkgs.zigbee2mqtt
  ];

  # 🦆 says ⮞ required for some crates that use cmake
#  env.CMAKE_POLICY_VERSION_MINIMUM = "3.5";

  meta = with lib; {
    description = "Home automation system written in Rust";
    license = licenses.mit;
    maintainers = [ "QuackHack-McBlindy" ];
    mainProgram = "zigduck-rs";
    
  };}
