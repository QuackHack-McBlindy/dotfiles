{ self, system, inputs, pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    (python3.withPackages (ps: with ps; [
      requests
      python-dotenv
      sh 
      pysilero-vad
      wyoming
      webrtc-noise-gain
      aiozeroconf
      pyring-buffer
      websockets
      flask
      flask-swagger-ui
      virtualenv
      invoke
      pyaudio
    ]))
  ];
}

