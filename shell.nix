# shell.nix (must be a function)
{ pkgs, system, inputs, self }:
{
  buildInputs = with pkgs; [ 
    git
    nixpkgs-fmt
    # Ensure these are for the right architecture
    (python3.withPackages (ps: [ ps.numpy ]))
  ];
  
  shellHook = ''
    echo "Running on ${system}"
  '';
  
  # Add explicit system hint
  NIX_CONFIG = "system = ${system}";
}


#{ self, system, inputs, pkgs ? import <nixpkgs> {} }:
#pkgs.mkShell {
#  buildInputs = with pkgs; [
#    python3
#    (python3.withPackages (ps: with ps; [
#      requests
#      python-dotenv
#      sh 
#      pysilero-vad
#      wyoming
#      webrtc-noise-gain
#      aiozeroconf
#      pyring-buffer
#      websockets
#      flask
#      flask-swagger-ui
#      virtualenv
#      invoke
#      pyaudio
#    ]))
#  ];
#}

