# ddotfiles/packages/yo-rs.nix ⮞ https://github.com/QuackHack-McBlindy/dotfiles
{ # 🦆 says ⮞ voice package
  self,
  lib,
  pkgs,
  rustPlatform,
  fetchFromGitHub,
  ...
} : let
  tinyWhisper = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin";
    sha256 = "sha256-vgfgSOHlma1GNByNKhNWRQl6U4IhZ4t6zdGxkZxuGyE=";
  };
  # 🦆 says ⮞ small whisper model
  whisperModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin";
    sha256 = "sha256-G+OpsgY4Z7k35k4ux0gzZKeZF+FX+pjF2UtcH//qmHs=";
  };
in  
rustPlatform.buildRustPackage {
  pname = "yo-rs";
  version = "0.1.3";

  src = ./yo-rs;

  cargoLock = {
    lockFile = ./yo-rs/Cargo.lock;
  };

  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.cmake
    pkgs.libclang
    rustPlatform.bindgenHook
  ];


  buildInputs = [ pkgs.openssl.dev pkgs.alsa-lib-with-plugins ];

  # 🦆 says ⮞ required for some crates that use cmake
  env.CMAKE_POLICY_VERSION_MINIMUM = "3.5";

  # 🦆 says ⮞ install default wale-word + tiny mwhisper to $out/share/yo-rs
  postInstall = ''
    # 🦆 says ⮞ install ding.wav
    mkdir -p $out/share/yo-rs
    cp ding.wav $out/share/yo-rs/ding.wav

    # 🦆 says ⮞ install small Whisper model
    mkdir -p $out/share/yo-rs/models/stt
    cp ${whisperModel} $out/share/yo-rs/models/stt/ggml-small.bin
  '';

  meta = with lib; {
    description = "Minimal multi-client microphone audio streaming with wake-word detection and transcription";
    license = licenses.mit;
    maintainers = [ "QuackHack-McBlindy" ];
    
  };}
