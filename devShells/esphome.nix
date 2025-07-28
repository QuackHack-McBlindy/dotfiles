# dotfiles/devShells/python.nix
{ 
  pkgs,
  system,
  inputs,
  self
} : let # 🦆 duck say ⮞ put them python pkgs here yo!
  pythonPackages = ps: [ 
    ps.numpy
    ps.pip
    ps.requests   
    ps.lz4
    ps.python-dotenv
    ps.noisereduce
    ps.websockets
    ps.aioesphomeapi
    ps.pytickersymbols
#    ps.yfinance
    ps.pyannote-audio
#    ps.onnxruntime
#    ps.tflite-runtime
#    ps.openwakeword
  ];
  
  myPython = pkgs.python3.withPackages pythonPackages;
  actualPythonPkgs = pythonPackages pkgs.python3.pkgs;

  myBuildInputs = with pkgs; [
    nixpkgs-fmt
    git
    wget
    gnumake
    flex
    bison
    gperf
    pkg-config
    cmake
    ncurses5
    ninja
    myPython    
    virtualenv
  ];

  pythonPkgNames = builtins.map (pkg: pkg.pname or pkg.name) actualPythonPkgs;
  formatRed = name: "echo - \$'\\e[0;31m'${name}\$'\\e[0m'";
  formatHeader = text: "echo \$'\\e[1m'${text}\$'\\e[0m'";
in {
  buildInputs = myBuildInputs;

  shellHook = ''
    echo "Running on ${system}"
    echo ""
    ${formatHeader "Build inputs:"}
    ${pkgs.lib.concatMapStringsSep "\n" (pkg: "echo - \$'\\e[0;31m'${pkg.name}\$'\\e[0m'") myBuildInputs}
    echo ""
    ${formatHeader "Python packages:"}
    ${pkgs.lib.concatMapStringsSep "\n" formatRed pythonPkgNames}

    if [ ! -d ".venv" ]; then
      export IDF_PATH=$(pwd)/esp-idf
      export PATH=$IDF_PATH/tools:$PATH
      export IDF_PYTHON_ENV_PATH=$(pwd)/.python_env

      if [ ! -e $IDF_PYTHON_ENV_PATH ]; then
        python -m venv $IDF_PYTHON_ENV_PATH
        . $IDF_PYTHON_ENV_PATH/bin/activate
        pip install -r $IDF_PATH/requirements.txt
      else
        . $IDF_PYTHON_ENV_PATH/bin/activate
      fi
    fi  
  '';

  NIX_CONFIG = "system = ${system}";
}

