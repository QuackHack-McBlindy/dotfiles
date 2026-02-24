# dotfiles/devShells/python38.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ 4 da python 3.8 development
  pkgs,
  system,
  inputs,
  self
} : let
  # 🦆 duck say ⮞ put them python pkgs here yo!
  pythonPackages = ps: [ 
    #ps.numpy
    ps.pip
    ps.requests   
   # ps.lz4
 #   ps.flask
    
#    ps.python-dotenv
#    ps.noisereduce
#    ps.pytickersymbols
#    ps.yfinance
#    ps.pyannote-audio
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

  # 🦆 says ⮞ display dependencies when entering shell
  shellHook = ''
    echo "Running on ${system}"
    echo ""
    ${formatHeader "Build inputs:"}
    ${pkgs.lib.concatMapStringsSep "\n" (pkg: "echo - \$'\\e[0;31m'${pkg.name}\$'\\e[0m'") myBuildInputs}
    echo ""
    ${formatHeader "Python packages:"}
    ${pkgs.lib.concatMapStringsSep "\n" formatRed pythonPkgNames}

    if [ ! -d ".venv" ]; then
      virtualenv .venv -p python3.8
      source .venv/bin/activate
      pip install torch transformers librosa numpy
    else
      source .venv/bin/activate
    fi
  '';

  NIX_CONFIG = "system = ${system}";
}

