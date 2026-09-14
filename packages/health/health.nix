# dotfiles/packages/health.nix ⮞ https://github.com/QuackHack-McBlindy/dotfiles
{
  self,
  stdenv,
  lib,
  pkgs,
  python3,
} : let # 🦆 says ⮞ python dependencies
  pythonEnv = python3.withPackages (ps: [
    ps.requests
    ps.fastapi
    ps.uvicorn
    ps.psutil
  ]);
in # 🦆 says ⮞ source code
stdenv.mkDerivation {
    name = "health";
    src = ./health;

    # 🦆 says ⮞ python dependencies
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

    # 🦆 says ⮞ installer
    installPhase = ''
      mkdir -p $out/bin
      echo "#!${pythonEnv}/bin/python3" > $out/bin/health
      cat $src/health.py >> $out/bin/health
      chmod +x $out/bin/health
    '';

    # 🦆 says ⮞ metadata
    meta = {
      description = ''
        Nix package for running health checks on your machines from the terminal.
        Displays only the most crucial information, like - CPU usage & temperatures,
        disk information, uptime  & remaining space, disk information and memory usage.
      '';
      license = lib.licenses.mit;
      maintainers = [ "QuackHack-McBlindy" ];
    };}
