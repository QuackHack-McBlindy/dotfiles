# ddotfiles/packages/say.nix ⮞ https://github.com/QuackHack-McBlindy/dotfiles
{ 
  self,
  lib,
  stdenv,
  python3,
  piper-tts
} : let # 🦆 says ⮞ python dependencies
  pythonEnv = python3.withPackages (ps: [
    ps.numpy
    ps.sounddevice
    ps.requests
    ps.pysoundfile
    ps.torch
    ps.langid
  ]);
in # 🦆 says ⮞ code source
stdenv.mkDerivation {
  name = "say";
  src = ./say;

  # 🦆 says ⮞ build dependencies
  buildInputs = [
    pythonEnv
    piper-tts
  ];
  
  # 🦆 says ⮞ crucial for runtime dependenciies
  propagatedBuildInputs = [ pythonEnv ];

  # 🦆 says ⮞ installer
  installPhase = ''
    mkdir -p $out/bin
    echo "#!${pythonEnv}/bin/python3" > $out/bin/say  # 🦆 says ⮞ Use wrapped python
    cat $src/say.py >> $out/bin/say
    chmod +x $out/bin/say
  '';

  # 🦆 says ⮞ metadata
  meta = {
    description = ''
      TTS using Piper with automatic language detection with LangID.
      Fetches and downloads models automatically.
    '';
  };}
