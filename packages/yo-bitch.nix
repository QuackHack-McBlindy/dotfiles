
{ 
  self,
  stdenv,
  lib,
  pkgs,
  python3,
} : let
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
   
in  

stdenv.mkDerivation {
    name = "yo-bitch";
    src = ./yo-bitch;

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
