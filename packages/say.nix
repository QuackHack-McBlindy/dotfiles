{ lib, stdenv, python3, piper-tts }:

let
  pythonEnv = python3.withPackages (ps: [
    ps.numpy
    ps.sounddevice
    ps.requests
    ps.pysoundfile
    ps.torch
    ps.langid
  ]);
in

stdenv.mkDerivation {
  name = "say";
  src = ./say;

  buildInputs = [
    pythonEnv
    piper-tts
  ];

  propagatedBuildInputs = [ pythonEnv ];  # Crucial for runtime dependencies

  installPhase = ''
    mkdir -p $out/bin
    echo "#!${pythonEnv}/bin/python3" > $out/bin/say  # Use wrapped python
    cat $src/say.py >> $out/bin/say
    chmod +x $out/bin/say
  '';

  meta = {
    description = "Python script for text-to-speech using Piper";
    license = lib.licenses.mit;
  };
}
