{ 
#  self,
  stdenv,
  lib,
  python3,
} : let
  pythonEnv = python3.withPackages (ps: [
    ps.sounddevice
    ps.requests
    ps.python-dotenv
  ]);
in  
stdenv.mkDerivation {
    name = "tv";
    src = ./tv;

    buildInputs = [ pythonEnv ];
    propagatedBuildInputs = [ pythonEnv ];

    installPhase = ''
      mkdir -p $out/bin
      echo "#!${pythonEnv}/bin/python3" > $out/bin/tv
      cat $src/tv.py >> $out/bin/tv
      chmod +x $out/bin/tv
    '';

    meta = {
      description = "ADB Controller";
      license = lib.licenses.mit;
      maintainers = [ "QuackHack-McBlindy" ];
    };
}
