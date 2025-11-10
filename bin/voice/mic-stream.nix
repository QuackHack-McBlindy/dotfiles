# dotfiles/bin/config/mic-strean.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ stream chunks mic audio ⮞ transcribe chunks ⮞ translate to shell command
  config, 
  lib,
  self,
  pkgs,
  cmdHelpers,
  PyDuckTrace, 
  ...         
} : let 
  # 🦆 says ⮞ auto correct list yo 
  autocorrect = import ./../autoCorrect.nix;
  
  # 🦆 says ⮞ dis fetch what host has Mosquitto
  sysHosts = lib.attrNames self.nixosConfigurations; 
  transcriptionHost = lib.findFirst
    (host:
      let cfg = self.nixosConfigurations.${host}.config;
      in cfg.yo.scripts.transcribe.autoStart or false
    ) null sysHosts;
  transcriptionHostIP = if transcriptionHost != null then
    self.nixosConfigurations.${transcriptionHost}.config.this.host.ip
  else
    "0.0.0.0";

  environment.systemPackages = [ pkgs.alsa-utils pkgs.whisper-cpp ];  
  pyEnv = pkgs.python3.withPackages (ps: [
    ps.pyaudio
    ps.websockets
    ps.faster-whisper
    ps.numpy
    ps.soundfile
    ps.python-multipart
    ps.noisereduce
  ]);
  
  # 🦆 says ⮞ the streaming microphone
  audioCaptureClient = pkgs.writeScript "audio-capture-client.py" ''
    #!${pyEnv}/bin/python
    import argparse
    import pyaudio
    import websockets
    import asyncio
    import json
    import subprocess
    from collections import deque
    import numpy as np
    
    # 🦆 import duckTrace loggin'
    import sys
    ${PyDuckTrace}
    # 🦆 setup loggin'     
    setup_ducktrace_logging("mic-stream.log", "INFO")

    parser = argparse.ArgumentParser()
    parser.add_argument('--chunk', type=int, default=1024)
    parser.add_argument('--silence', type=int, default=2.0)
    parser.add_argument('--silenceLevel', type=int, default=500)
    args = parser.parse_args()

    
    # 🦆 says ⮞ audio configuration
    CHUNK = args.chunk
    FORMAT = pyaudio.paInt16
    CHANNELS = 1
    RATE = 16000
    SILENCE_THRESHOLD = args.silenceLevel
    SILENCE_DURATION = args.silence 

    class AudioStreamer:
        def __init__(self):
            with TranscriptionTimer("PyAudio initialization"):
                self.audio = pyaudio.PyAudio()
            self.silence_buffer = deque(maxlen=int(RATE * SILENCE_DURATION / CHUNK))
            self.is_speaking = False
            self.audio_buffer = b""
            
        async def connect_with_retry(self):
            max_retries = 10
            retry_delay = 2     
            for attempt in range(max_retries):
                try:
                    dt_info(f"Connecting to WebSocket (attempt {attempt + 1}/{max_retries})...")
                    websocket = await websockets.connect("ws://localhost:8765", ping_interval=None)
                    dt_debug("Connected to WebSocket server!")
                    return websocket
                except Exception as e:
                    dt_warning(f"Failed to connect: {e}")
                    if attempt < max_retries - 1:
                        dt_info(f"Retrying in {retry_delay} seconds...")
                        await asyncio.sleep(retry_delay)
                    else:
                        dt_error("Max connection retries exceeded")
                        raise
        
        async def handle_transcription(self, transcription):
            if transcription and transcription.strip():
                with TranscriptionTimer("NLP processing"):
                    dt_info(f"TRANSCRIPTION: {transcription}")        
                    # 🦆 says ⮞ u take it from hhere brain (nlp) yo
                    try: # 🦆 says ⮞ if u wanna have fun change `do` 
                        result = subprocess.run( # 🦆 says ⮞ to `chat` below
                            ["yo", "do", transcription.strip()],
                            capture_output=True,
                            text=True,
                            timeout=10
                        )
                        if result.returncode == 0:
                            dt_info(f"NLP processed successfully")
                            # 🦆 says ⮞ steal da time from da brain
                            for line in result.stdout.split('\n'):
                                if 'do took' in line:
                                    dt_debug(f"NLP {line.strip()}")
                        else:
                            dt_error(f"NLP failed: {result.stderr}")
                    except Exception as e:
                        dt_error(f"Error calling NLP: {e}")
            
        async def stream_audio(self):
            try:
                with TranscriptionTimer("Audio stream setup"):
                    stream = self.audio.open(
                        format=FORMAT,
                        channels=CHANNELS,
                        rate=RATE,
                        input=True,
                        frames_per_buffer=CHUNK
                    )
                
                dt_debug("Audio input initialized, connecting to WebSocket...")
                websocket = await self.connect_with_retry()
                
                dt_info("🎙️ 🔴 !")
                
                # 🦆 says ⮞ shut up and listen yo
                transcription_task = asyncio.create_task(self.listen_for_transcriptions(websocket))
                
                while True:
                    try:
                        with TranscriptionTimer("audio chunk capture"):
                            data = stream.read(CHUNK, exception_on_overflow=False)
                        if not data:
                            continue
                            
                        audio_chunk = np.frombuffer(data, dtype=np.int16)
                        
                        # 🦆 says ⮞ calculate RMS for silence detect
                        if len(audio_chunk) > 0:
                            squared = audio_chunk.astype(np.float64) ** 2
                            mean_squared = np.mean(squared)
                            rms = np.sqrt(mean_squared) if mean_squared > 0 else 0
                        else:
                            rms = 0
                        
                        self.silence_buffer.append(rms > SILENCE_THRESHOLD)    
                        # 🦆 says ⮞ speech boundaries?
                        was_speaking = self.is_speaking
                        self.is_speaking = sum(self.silence_buffer) > len(self.silence_buffer) * 0.3      
                        try: # 🦆 says ⮞ audio chunk go go go
                            await websocket.send(json.dumps({
                                'type': 'audio_chunk',
                                'chunk': data.hex(),
                                'is_final': False,
                                'timestamp': asyncio.get_event_loop().time()
                            }))
                            
                            # 🦆 says ⮞ finally shutting up? silent now? go final chunk yo
                            if was_speaking and not self.is_speaking:
                                dt_debug("Silence detected, sending final chunk")
                                dt_info("🔇")
                                await websocket.send(json.dumps({
                                    'type': 'audio_chunk',
                                    'chunk': data.hex(),
                                    'is_final': True,
                                    'timestamp': asyncio.get_event_loop().time()
                                }))
                                
                        except websockets.exceptions.ConnectionClosed:
                            dt_warning("WebSocket connection closed, reconnecting...")
                            websocket = await self.connect_with_retry()
                            # 🦆 says ⮞ restart transcription ears
                            transcription_task.cancel()
                            transcription_task = asyncio.create_task(self.listen_for_transcriptions(websocket))
                            continue
                            
                        await asyncio.sleep(0.01)
                        
                    except Exception as e:
                        dt_error(f"Error processing audio: {e}")
                        await asyncio.sleep(0.1)
                        
            except Exception as e:
                dt_error(f"Fatal error: {e}")
            finally:
                if 'stream' in locals():
                    stream.stop_stream()
                    stream.close()
                self.audio.terminate()
    
        async def listen_for_transcriptions(self, websocket):
            try:
                async for message in websocket:
                    data = json.loads(message)
                    if data.get('type') == 'transcription':
                        transcription = data.get('text', "")
                        await self.handle_transcription(transcription)
            except Exception as e:
                dt_error(f"Error in transcription listener: {e}")
    
    async def main():
        streamer = AudioStreamer()
        await streamer.stream_audio()
    
    if __name__ == "__main__":
        asyncio.run(main())
  '';
  
in {
  yo.scripts.mic-stream = {
    description = "Stream microphone audio to WS chunk transcription";
    category = "🗣️ Voice";
    logLevel = "INFO";
    parameters = [
        { name = "chunk"; type = "int"; description = "Chunk size for the audio"; default = 1024; }
        { name = "silence"; type = "int"; description = "How many seconds of silence before final chunk is sent"; default = 2; }
        { name = "silenceLevel"; type = "int"; description = "Threashhold level for it to be conciidered silence (default 500)"; default = 500; }  
    ];
    code = ''
      ${cmdHelpers}
      CHUNK_SIZE=$chunk
      SILENCE_DURATION=$silence
      SILENCE_LEVEL=$silenceLevel
      
      # 🦆 says ⮞ pass args to python script yo
      ${audioCaptureClient} --chunk "$CHUNK_SIZE" --silence "$SILENCE_DURATION" --silenceLevel "$SILENCE_LEVEL"
    '';

  };}# 🦆 says ⮞ QuackHack-McBLindy - out yo!  
