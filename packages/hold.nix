{ 
  self,
  lib,
  stdenv,
  python3,
  piper-tts
} : let
  pythonEnv = python3.withPackages (ps: [
    ps.numpy
    ps.sounddevice
    ps.requests
    ps.pysoundfile
    ps.pynput
  ]);
in

stdenv.mkDerivation {
  name = "hold";
  src = ./hold;

  buildInputs = [
    pythonEnv
    piper-tts
  ];

  propagatedBuildInputs = [ pythonEnv ];  # Crucial for runtime dependencies

  installPhase = ''
    mkdir -p $out/bin
    echo "#!${pythonEnv}/bin/python3" > $out/bin/hold
    cat $src/hold.py >> $out/bin/hold
    chmod +x $out/bin/hold
  '';

  meta = {
    description = "Hold button to record audio, release to send for transcription";
    license = lib.licenses.mit;
  };
}
