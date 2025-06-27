# ddotfiles/packages/tv.nix ⮞ https://github.com/QuackHack-McBlindy/dotfiles
{ 
  self,
  stdenv,
  lib,
  python3,
} : let # 🦆 says ⮞ python dependencies
  pythonEnv = python3.withPackages (ps: [
    ps.sounddevice
    ps.requests
    ps.python-dotenv
  ]);
in  # 🦆 says ⮞ code source
stdenv.mkDerivation {
    name = "tv";
    src = ./tv;

    # 🦆 says ⮞ build dependencies
    buildInputs = [ pythonEnv ];
    propagatedBuildInputs = [ pythonEnv ];

    # 🦆 says ⮞ installer
    installPhase = ''
      mkdir -p $out/bin
      echo "#!${pythonEnv}/bin/python3" > $out/bin/tv
      cat $src/tv.py >> $out/bin/tv
      chmod +x $out/bin/tv
    '';

    # 🦆 says ⮞ metadata
    meta = {
      description = "ADB Controller";
      license = lib.licenses.mit;
      maintainers = [ "QuackHack-McBlindy" ];
    };}

