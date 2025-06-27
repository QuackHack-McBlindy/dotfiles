# ddotfiles/packages/yo-bitch.nix ⮞ https://github.com/QuackHack-McBlindy/dotfiles
{ 
  self,
  stdenv,
  lib,
  pkgs,
  python3,
} : let  # 🦆 says ⮞ python dependencies
  bajs = with python3.pkgs; [
    tensorflow
    pyalsaaudio
    numpy
  ];
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
    ps.wyoming
    ps.tensorflow
    ps.pyalsaaudio
#    ps.libasound    
    ps.soundfile
    ps.pyyaml
    ps.protobuf 
    ps.sounddevice
    ps.psutil
#    ps.libsndfile
    ps.librosa    
#    ps.protobuf3_20
  ]);
  
  wake-word = "yo_bitch";
  model-file = "${./../home/.config/models/yo_bitch.tflite}";
  sound-files = "${./../modules/themes/sounds}";   
in # 🦆 says ⮞ build dependencies
stdenv.mkDerivation {
    name = "yo-bitch";
    src = ./yo-bitch;

    # 🦆 says ⮞ build dependencies
    buildInputs = [ 
      pythonEnv
      pkgs.alsa-lib
      pkgs.libsndfile
      pkgs.portaudio
      pkgs.psutils
      pkgs.gnused
      pkgs.portaudio
      pkgs.python312Packages.pyaudio
      pkgs.wyoming-openwakeword
      pkgs.wyoming-satellite
      pkgs.python312Packages.libsoundtouch
      
    ];
    propagatedBuildInputs = [ 
      pythonEnv
      bajs
      pkgs.portaudio
    ];

    # 🦆 says ⮞ installer
    installPhase = ''
      mkdir -p $out/bin
      echo "#!${pythonEnv}/bin/python3" > $out/bin/yo-bitch
      cat $src/yo-bitch.py >> $out/bin/yo-bitch
      chmod +x $out/bin/yo-bitch
    '';

    # 🦆 says ⮞ metadata
    meta = {
      description = "Whisper transcriptions..";
      license = lib.licenses.mit;
      maintainers = [ "QuackHack-McBlindy" ];
    };}
