{ 
  stdenv,
  lib,
  pkgs,
  python3,
} : let
  pythonEnv = python3.withPackages (ps: [
    ps.requests
    ps.fastapi
    ps.uvicorn
    ps.psutil
  ]);
in  
stdenv.mkDerivation {
    name = "health";
    src = ./health;

    buildInputs = [ 
      pythonEnv
      pkgs.psutils
      pkgs.smartmontools
      pkgs.gnused
      pkgs.python312Packages.uvicorn
      pkgs.python312Packages.fastapi
      pkgs.python312Packages.psutil 
    ];
    propagatedBuildInputs = [ pythonEnv ];

    installPhase = ''
      mkdir -p $out/bin
      echo "#!${pythonEnv}/bin/python3" > $out/bin/health
      cat $src/health.py >> $out/bin/health
      chmod +x $out/bin/health
    '';

    meta = {
      description = "Nix healthchecks";
      license = lib.licenses.mit;
      maintainers = [ "QuackHack-McBlindy" ];
    };
}
