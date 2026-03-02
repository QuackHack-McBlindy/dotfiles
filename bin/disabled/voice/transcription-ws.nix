# dotfiles/bin/config/transcription-ws.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ websock in da butt.  
  self, # 🦆 says ⮞ diz iz becomin' worldz fastest voice azzsiztant? 🏆
  lib,
  config,
  pkgs,
  cmdHelpers,
  PythonDuckTrace,
  ... 
} : let
  transcriptionAutoStart = config.yo.scripts.transcribe.autoStart or false;
  # 🦆 says ⮞ dependencies  
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
  
  wsServer = pkgs.writeScript "transcription-ws-server.py" ''
    #!${pyEnv}/bin/python
    import asyncio
    import websockets
    import json
    import logging
    import numpy as np
    from faster_whisper import WhisperModel
    import tempfile
    import soundfile as sf
   
    # 🦆 import duckTrace loggin'
    import sys
    ${PythonDuckTrace}
    
    setup_ducktrace_logging("transcription-ws.log", "INFO")

    model = WhisperModel("base", device="cpu")
    
    # 🦆 says ⮞ free audio buffer 4 all!!!1
    client_buffers = {}
    
    async def transcribe_audio(audio_data, sample_rate=16000):
        try:
            # 🦆 says ⮞ convert bytes to numpy array (16bit PCM)
            audio_np = np.frombuffer(audio_data, dtype=np.int16).astype(np.float32) / 32768.0       
            # 🦆 says ⮞ transcribe yo
            segments, info = model.transcribe(
                audio_np,
                language="sv",
                beam_size=5,
                vad_filter=True
            )
            
            transcription = " ".join(segment.text for segment in segments)
            dt_info(f"Transcription: {transcription}")
            return transcription
            
        except Exception as e:
            dt_error(f"Transcription error: {e}")
            return ""
    
    async def handler(websocket):
        client_id = id(websocket)
        client_buffers[client_id] = b""
        dt_info(f"New client connected: {client_id}")        
        try:
            async for message in websocket:
                try:
                    data = json.loads(message)       
                    if data.get('type') == 'audio_chunk':
                        # 🦆 says ⮞ convert hex back to bytes
                        audio_bytes = bytes.fromhex(data['chunk'])
                        client_buffers[client_id] += audio_bytes       
                        # 🦆 says ⮞ iz diz final chunk?
                        if data.get('is_final', False):
                            dt_debug(f"Final chunk received for {client_id}, transcribing...") 
                            # 🦆 says ⮞ transcribe da accumulated audio
                            transcription = await transcribe_audio(client_buffers[client_id])  
                            # 🦆 says ⮞ send transcription back2client
                            await websocket.send(json.dumps({
                                'type': 'transcription',
                                'text': transcription,
                                'timestamp': data.get('timestamp')
                            }))   
                            # 🦆 says ⮞ buffer plx go away
                            client_buffers[client_id] = b""
                        
                        # 🦆 says ⮞ acknowledgment here u go yo!
                        await websocket.send(json.dumps({
                            'type': 'acknowledge',
                            'message': 'Audio received',
                            'timestamp': data.get('timestamp')
                        }))
                        
                    elif data.get('type') == 'ping':
                        await websocket.send(json.dumps({'type': 'pong'}))
                        
                    elif data.get('type') == 'test':
                        await websocket.send(json.dumps({
                            'type': 'response', 
                            'message': 'Server is working!'
                        }))
                        
                except json.JSONDecodeError as e:
                    dt_error(f"JSON decode error: {e}")
                except Exception as e:
                    dt_error(f"Error processing message: {e}")
                    
        except websockets.exceptions.ConnectionClosed:
            dt_info(f"Client disconnected: {client_id}")
            if client_id in client_buffers:
                del client_buffers[client_id]
    
    async def main():
        dt_info("Starting WebSocket transcription server on ws://0.0.0.0:8765")
        async with websockets.serve(handler, "0.0.0.0", 8765, ping_interval=None):
            await asyncio.Future() # 🦆 says ⮞ run forever yo
    
    if __name__ == "__main__":
        asyncio.run(main())
  '';

in {
  yo.scripts.transcription-ws = {
    description = "WebSocket server for real-time transcription streaming to NLP";
    category = "🗣️ Voice";
    autoStart = false;
    logLevel = "DEBUG";
    code = ''
      ${cmdHelpers} # 🦆 says ⮞ load default helper functions 
      #USE_GPU="$gpu"      

      # 🦆 says ⮞ GPU configuration
      #if [ "$USE_GPU" = "true" ]; then
      #  DEVICE="cuda"
      #else
      #  DEVICE="cpu"
      #fi


      ${wsServer}
    '';
    
  };}
  

