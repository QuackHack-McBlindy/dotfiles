# dotfiles/bin/config/transcribe.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Configures and runs a TLS/SSL transcription server API endpoint featuring faster-whisper.  
  self, # 🦆 says ⮞ Define `"whisperd"` at `ccnfig.this.host.modules.services` to enable, install dependencies & start it at boot.
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ dependencies  
  environment.systemPackages = [ pkgs.alsa-utils pkgs.whisper-cpp ];  
  pyEnv = pkgs.python3.withPackages (ps: [
    ps.fastapi
    ps.uvicorn
    ps.faster-whisper
    ps.numpy
    ps.soundfile
    ps.python-multipart
    ps.noisereduce
  ]);
  # 🦆 says ⮞ creates TLS/SSL API endpoint fpr receivin' dat audio dat needz transcription - yo
  server = pkgs.writeScript "whisperd-server.py" ''
    #!${pyEnv}/bin/python
    import argparse
    from fastapi import FastAPI, UploadFile, File, Form
    import uvicorn
    import soundfile as sf
    import numpy as np
    import tempfile
    from faster_whisper import WhisperModel
    import subprocess
    import shutil
    import noisereduce as nr 
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=8000)
    parser.add_argument('--model', type=str, default='medium')
    parser.add_argument('--language', type=str, default='sv')
    parser.add_argument('--beamSize', type=int, default=10)    
    parser.add_argument('--device', type=str, default='cpu')
    parser.add_argument('--cert', type=str, default=None)
    parser.add_argument('--key', type=str, default=None)
    args = parser.parse_args()
    app = FastAPI()
    model = WhisperModel(args.model, device=args.device)

    # 🦆 says ⮞ api endpoint
    @app.post("/transcribe")
    async def transcribe(
        audio: UploadFile = File(...),
        reduce_noise: bool = Form(True),
    ):
        audio_data = np.frombuffer(await audio.read(), dtype=np.int16)
        if reduce_noise:
            audio_data = nr.reduce_noise(y=audio_data, sr=16000)
        with tempfile.NamedTemporaryFile(suffix=".wav") as tmp:
            sf.write(tmp.name, audio_data, 16000)
            segments, _ = model.transcribe(
                tmp.name,
                language=args.language,
                vad_filter=False,
                temperature=0.0,
                beam_size=args.beamSize,
            )
            return {"transcription": " ".join(segment.text for segment in segments)}
 
    # 🦆 says ⮞ handle certs
    ssl_params = {}
    if args.cert and args.key:
        ssl_params = {"ssl_certfile": args.cert, "ssl_keyfile": args.key}
    uvicorn.run(app, host="0.0.0.0", port=args.port, log_level="debug", **ssl_params)
  '';
in { # 🦆 says ⮞ yo yo yo yo  
  yo.scripts.transcribe = {
    description = "Transcription server-side service. Sit and waits for audio that get transcribed and returned.";
    category = "⚙️ Configuration"; 
    autoStart = config.this.host.hostname == "desktop"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
#    helpFooter = '' # 🦆 says ⮞ TODO some useful & fun helpFooter yo
#    '';
    logLevel = "INFO";
    parameters = [ # 🦆 says ⮞ server api configuration goez here yo
      { name = "port"; description = "Port to listen on"; default = "25451"; } # 🦆 says ⮞ "duck" ASCII encoded truncated 32 bit 
      { name = "model"; description = "Model"; default = "large"; }
      { name = "language"; description = "Language to transcribe"; default = "sv"; } 
      { name = "beamSize"; description = "Beam size for the model"; default = "10"; }       
      { name = "gpu"; description = "Use GPU for faster transcription"; default = "false"; }
      # 🦆 says ⮞ SSL file path'z yo
      { name = "cert"; description = "Path to SSL certificate to run the sever on"; default = "/home/pungkula/.config/whisper/whisper/cert.pem"; } 
      { name = "key"; description = "Path to key file to run the sever on"; default = "/home/pungkula/.config/whisper/whisper/key.pem"; } 
    ];
    code = ''
      ${cmdHelpers} # 🦆 says ⮞ load default helper functions 
      export PATH="$PATH:/run/current-system/sw/bin" # 🦆 says ⮞ annoying but easy
      PORT="$port"
      MODEL="$model"
      BEAMSIZE="$beamSize"
      LANGUAGE="$language"
      CERT="$cert"
      KEY="$key"
      USE_GPU="$gpu"      

      # 🦆 says ⮞ GPU configuration
      if [ "$USE_GPU" = "true" ]; then
        DEVICE="cuda"
      else
        DEVICE="cpu"
      fi

       # 🦆 says ⮞ verify SSL files
      if [ ! -f "$CERT" ]; then
        fail "SSL certificate not found: $CERT"
      fi
      if [ ! -f "$KEY" ]; then
        fail "SSL key not found: $KEY"
      fi

      # 🦆 says ⮞ show server information
      dt_info "[whisperd] Starting SSL transcription service:"
      dt_info "  Port:      $PORT"
      dt_info "  Model:     $MODEL"
      dt_info "  Language:  $LANGUAGE"
      dt_info "  Beam Size:  $BEAMSIZE"      
      dt_info "  GPU:       $USE_GPU ($DEVICE)"
      dt_info "  Cert:      $CERT"
      dt_info "  Key:       $KEY"

      # 🦆 says ⮞ yo dj spin dat stuffz up
      ${server} \
        --port "$PORT" \
        --model "$MODEL" \
        --language "$LANGUAGE" \
        --device "$DEVICE" \
        --beamSize "$BEAMSIZE" \
        --cert "$CERT" \
        --key "$KEY"                
    '';
  };

  # 🦆 says ⮞ firewall rulez
  networking.firewall = lib.mkIf (lib.elem "whisperd" config.this.host.modules.services) { allowedTCPPorts = [ 25451 ]; };
  } # 🦆 says ⮞ duckie duck duck
# 🦆 says ⮞ QuackHack-McBLindy out - peace!  

