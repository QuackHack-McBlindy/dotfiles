# dotfiles/bin/config/transcribe.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Configures and runs a TLS/SSL transcription server API endpoint featuring faster-whisper.  
  self, # 🦆 says ⮞ Define "whisperd" at ccnfig.this.host.modules.services to enable, install dependencies & start it at boot.
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
  
  # 🦆 says ⮞ creates TLS/SSL API endpoint fpr receivin' dat audio dat needz transcription - yo
  server = pkgs.writeScript "whisperd-server.py" ''
    #!${pyEnv}/bin/python
    import argparse
    import asyncio
    import wave
    import threading
    import subprocess
    import time
    import logging
    import tempfile
    from fastapi import FastAPI, Request, HTTPException, UploadFile, File, Form, Query
    from faster_whisper import WhisperModel
    import soundfile as sf
    import numpy as np
    import noisereduce as nr
    import uvicorn
    from collections import defaultdict
    from contextlib import asynccontextmanager
    import os
    import concurrent.futures
    from fastapi.middleware.cors import CORSMiddleware

    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=8000)
    parser.add_argument('--model', type=str, default='medium')
    parser.add_argument('--language', type=str, default='sv')
    parser.add_argument('--beamSize', type=int, default=10)    
    parser.add_argument('--device', type=str, default='cpu')
    parser.add_argument('--cert', type=str, default=None)
    parser.add_argument('--key', type=str, default=None)
    args = parser.parse_args()
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    logger = logging.getLogger("whisperd")
    
    # 🦆 says ⮞ audio configuration
    SAMPLE_RATE = 16000
    SAMPLE_WIDTH = 2
    CHANNELS = 1
    SESSION_TIMEOUT = 2.0  # seconds
    
    # 🦆 says ⮞ session management
    sessions_lock = threading.Lock()
    sessions = defaultdict(lambda: {
        'chunks': [],
        'last_received': 0,
        'recording': False
    })
    
    # 🦆 says ⮞ thread pool for transcription
    transcription_executor = concurrent.futures.ThreadPoolExecutor(max_workers=4)
    
    # 🦆 says ⮞ Initialize model
    logger.info(f"Loading Whisper model: {args.model} on {args.device}")
    model = WhisperModel(
        args.model,
        device=args.device,
        compute_type="float32" if args.device == "cpu" else "float16"
    )
    model_lock = threading.Lock()
    
    @asynccontextmanager
    async def lifespan(app: FastAPI):
        cleaner_thread = threading.Thread(
            target=cleanup_expired_sessions,
            daemon=True
        )
        cleaner_thread.start()
        logger.info("Started session cleanup thread")    
        yield
        transcription_executor.shutdown(wait=False)
        logger.info("Server shutdown complete")


    app = FastAPI(lifespan=lifespan)

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Allows all origins
        allow_credentials=True,
        allow_methods=["*"],  # Allows all methods
        allow_headers=["*"],  # Allows all headers
    )
    
    def transcribe_audio(audio_data: np.ndarray, reduce_noise: bool = True) -> str:
        try:
            if reduce_noise:
                logger.debug("Applying noise reduction")
                audio_data = nr.reduce_noise(
                    y=audio_data, 
                    sr=SAMPLE_RATE,
                    stationary=True,
                    prop_decrease=0.75
                )   
            with tempfile.NamedTemporaryFile(suffix=".wav") as tmp:
                sf.write(tmp.name, audio_data, SAMPLE_RATE)  
                with model_lock:
                    logger.debug("Starting transcription")
                    segments, _ = model.transcribe(
                        tmp.name,
                        language=args.language,
                        vad_filter=True,
                        temperature=0.0,
                        beam_size=args.beamSize,
                        without_timestamps=True
                    )
                    transcription = " ".join(segment.text for segment in segments)
                    logger.info(f"Transcription complete: {transcription[:50]}...")
                    return transcription
        except Exception as e:
            logger.error(f"Transcription failed: {str(e)}")
            return ""


    def process_completed_session(client_ip: str, chunks: list):
        logger.info(f"Processing completed session for {client_ip}")
        try:
            raw_audio = b"".join(chunks)
            audio_data = np.frombuffer(raw_audio, dtype=np.int16)
            future = transcription_executor.submit(
                transcribe_audio, 
                audio_data,
                True
            )
            transcription = future.result()  
            logger.info(f"Transcription for {client_ip}: {transcription}")          
        except Exception as e:
            logger.error(f"Session processing failed for {client_ip}: {str(e)}")

    def cleanup_expired_sessions():
        while True:
            time.sleep(1)
            current_time = time.time()
            expired_ips = [] 
            with sessions_lock:
                for ip, session in list(sessions.items()):
                    if not session['chunks'] or current_time - session['last_received'] < SESSION_TIMEOUT:
                        continue
                    
                    if session['recording']:
                        logger.info(f"Session completed for {ip}")
                        threading.Thread(
                            target=process_completed_session,
                            args=(ip, session['chunks']),
                            daemon=True
                        ).start()
                        session['recording'] = False
                        session['chunks'] = []
                    else:
                        logger.warning(f"Clearing expired chunks for {ip}")
                        session['chunks'] = []   
                    if not session['recording'] and not session['chunks']:
                        expired_ips.append(ip)   
                for ip in expired_ips:
                    del sessions[ip]

    @app.post("/audio_upload")
    async def receive_audio(request: Request):
        client_ip = request.client.host
        if not client_ip:
            raise HTTPException(status_code=400, detail="Client IP unavailable")
        audio_data = await request.body()
        if not audio_data:
            raise HTTPException(status_code=400, detail="Empty audio data")  
        with sessions_lock:
            session = sessions[client_ip]
            if not session['recording']:
                logger.info(f"New recording session started for {client_ip}")
                session['recording'] = True
            session['chunks'].append(audio_data)
            session['last_received'] = time.time() 
        logger.debug(f"Received {len(audio_data)} bytes from {client_ip}")
        return {"status": "received", "bytes": len(audio_data)}

    @app.get("/play")
    def play(sound: str = Query(...)):
        subprocess.Popen(["aplay", sound])
        return {"status": "playing", "file": sound}

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
            transcription = " ".join(segment.text for segment in segments)
            logging.info(f"[transcription] {transcription}")
            return {"transcription": transcription}

    @app.post("/trans")
    async def trans(request: Request):
        audio_bytes = await request.body()
        if not audio_bytes:
            raise HTTPException(status_code=400, detail="No audio data received")
        audio_np = np.frombuffer(audio_bytes, dtype=np.int16)
        transcription = transcribe_audio_np(audio_np, reduce_noise=True)
        return {"transcription": transcription}
 
    # 🦆 says ⮞ handle certs
    ssl_params = {}
    if args.cert and args.key:
        ssl_params = {"ssl_certfile": args.cert, "ssl_keyfile": args.key}
    uvicorn.run(app, host="0.0.0.0", port=args.port, log_level="debug", **ssl_params)
  '';
in { # 🦆 says ⮞ yo yo yo yo  

  yo.scripts.transcribe = {
    description = "Transcription server-side service. Sit and waits for audio that get transcribed and returned.";
    category = "🗣️ Voice"; 
    autoStart = true;
    #autoStart = config.this.host.hostname == "desktop"; # 🦆 says ⮞ dat'z sum conditional quack-fu yo!
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
        --key "$KEY" \
        2>&1 | while IFS= read -r line; do
          dt_info "$line"
        done
    '';
  };

  # 🦆 says ⮞ firewall rulez
  networking.firewall = lib.mkIf transcriptionAutoStart { allowedTCPPorts = [ 8765 25451 6379 8111 ]; };

  # 🦆 says ⮞ used for wake word locking yo
  services.redis = lib.mkIf transcriptionAutoStart {
    enable = true;
    bind = "0.0.0.0";
    port = 6379;
    requirePassFile = config.sops.secrets.redis.path;
  };
  
  sops.secrets = {
    redis = {
      sopsFile = ./../../secrets/redis.yaml;
      owner = config.this.user.me.name;
      group = config.this.user.me.name;
      mode = "0440";
    };    

  };}# 🦆 says ⮞ duckie duck duck
# 🦆 says ⮞ QuackHack-McBLindy out - peace!  
