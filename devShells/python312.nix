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
    ps.fastapi
    ps.uvicorn
    ps.requests   
    ps.lz4
    ps.flask
    ps.python-dotenv
    ps.noisereduce
    ps.pytickersymbols
    ps.yfinance
    ps.websockets
    ps.pyannote-audio
#    ps.onnxruntime
#    ps.tflite-runtime
#    ps.openwakeword
  ];
  
  myPython = pkgs.python3.withPackages pythonPackages;
  actualPythonPkgs = pythonPackages pkgs.python3.pkgs;

  myBuildInputs = with pkgs; [
    git
    nixpkgs-fmt
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
      virtualenv .venv
      source .venv/bin/activate
      pip install openwakeword https://github.com/google-coral/pycoral/releases/download/v2.0.0/tflite_runtime-2.5.0-cp39-cp39-linux_armv7l.whl https://github.com/google-coral/pycoral/releases/download/v2.0.0/tflite_runtime-2.5.0-cp310-cp310-linux_x86_64.whl
    else
      source .venv/bin/activate
    fi
  '';

  NIX_CONFIG = "system = ${system}";
}

