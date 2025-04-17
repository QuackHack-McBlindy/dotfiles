# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.python3
    pkgs.python3Packages.requests
    pkgs.python3Packages.python-dotenv
    pkgs.python312Packages.sh
    
    pkgs.python312Packages.pysilero-vad
    pkgs.python312Packages.wyoming
    pkgs.python312Packages.webrtc-noise-gain
    pkgs.python312Packages.aiozeroconf
    pkgs.python312Packages.pyring-buffer
    pkgs.python312Packages.websockets
    pkgs.python312Packages.flask
    pkgs.python312Packages.flask-swagger-ui
    pkgs.python3Packages.virtualenv
    pkgs.python313Packages.invoke
    pkgs.python312Packages.pyaudio
  ];
  

#  shellHook = ''
#    if [ ! -d ".venv" ]; then
#      virtualenv .venv
#      source .venv/bin/activate
#      pip install "Flask[async]" requests dotenv
#      pip install tflite2onnx
#      pip instlal pyaudio
#    else
#      source .venv/bin/activate
#    fi
#  '';
  
}
