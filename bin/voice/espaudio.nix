# dotfiles/bin/config/espaudio.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ WIP dev  
  self, # 🦆 says ⮞ 
  lib,
  config,
  pkgs,
  cmdHelpers,
  PyDuckTrace,
  ... 
} : let
  transcriptionAutoStart = config.yo.scripts.transcribe.autoStart or false;
  # 🦆 says ⮞ dependencies  
  environment.systemPackages = [ pkgs.alsa-utils pkgs.whisper-cpp ];  
  pyEnv = pkgs.python3.withPackages (ps: [
    ps.fastapi
    ps.pyaudio
    ps.uvicorn
    ps.faster-whisper
    ps.numpy
    ps.flask
    ps.soundfile
    ps.python-multipart
    ps.noisereduce
  ]); # 🦆 TODO ⮞ merge 
  # test with: arecord -f S16_LE -r 16000 -d 10 -c 1 -t raw | curl -X POST -H "Content-Type: application/octet-stream" --data-binary @- http://192.168.1.111:8111/upload_audio
    
  espserver = pkgs.writeScript "whisperd-server.py" ''
    #!${pyEnv}/bin/python      
    from flask import Flask, request
    import subprocess
    import numpy as np
    import tempfile
    import soundfile as sf
    import logging
    from faster_whisper import WhisperModel
    import noisereduce as nr
    app = Flask(__name__)
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger("espserver")
    model = WhisperModel("base", device="cpu")
    @app.route('/upload_audio', methods=['POST'])
    def upload_audio():
        audio_data = request.data
        if not audio_data:
            return 'No audio data received', 400
        try:
            audio_np = np.frombuffer(audio_data, dtype=np.int16)
            audio_np = nr.reduce_noise(y=audio_np, sr=16000)
            with tempfile.NamedTemporaryFile(suffix=".wav") as tmp:
                sf.write(tmp.name, audio_np, 16000)
                segments, _ = model.transcribe(tmp.name, vad_filter=False, language="sv")
                transcription = " ".join(segment.text for segment in segments)
            logger.info(f"[transcription] {transcription}")
            subprocess.Popen(["yo-bitch", 'transcription'])
            print(transcription, flush=True)
            return {'transcription': transcription}, 200
        except Exception as e:
            logger.error(f"Failed to transcribe audio: {str(e)}")
            return 'Transcription failed', 500
    if __name__ == '__main__':
        app.run(host='0.0.0.0', port=8111)
  '';

in { # 🦆 says ⮞ yo yo yo yo  

  yo.scripts.espaudio = {
    description = "WIP! ESP32 audio development";
    category = "🗣️ Voice"; 
    logLevel = "DEBUG";
    autoStart = false;
    code = ''
      ${cmdHelpers}    
      ${espserver}
      dt_info "Started ESPAudio sucessfully"
    '';
    
  };}  
