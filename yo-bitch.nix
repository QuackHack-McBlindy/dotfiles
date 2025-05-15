{ 
  self,
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
    ps.wyoming
    ps.python-multipart   
    ps.pysoundfile     
    ps.faster-whisper     
    ps.websockets     
    ps.numpy  
  ]);
in  
stdenv.mkDerivation {
    name = "yo-bitch";
    src = ./yo-bitch;

    buildInputs = [ 
      pythonEnv
      pkgs.psutils
      pkgs.smartmontools
      pkgs.gnused

    ];
    propagatedBuildInputs = [ pythonEnv ];

    installPhase = ''
      mkdir -p $out/bin
      echo "#!${pythonEnv}/bin/python3" > $out/bin/yo-bitch
      cat $src/yo-bitch.py >> $out/bin/yo-bitch
      chmod +x $out/bin/yo-bitch
    '';

    meta = {
      description = "Execute Yo scripts with Yo bitch voice commands.";
      license = lib.licenses.mit;
      maintainers = [ "QuackHack-McBlindy" ];
    };
}
