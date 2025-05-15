

def record_audio(filename, duration=5, rate=16000, chunk=1024, channels=1):
    p = pyaudio.PyAudio()
    stream = p.open(format=pyaudio.paInt16, channels=channels, rate=rate, input=True, frames_per_buffer=chunk)
    
    frames = []
    print("Recording...")
    for _ in range(0, int(rate / chunk * duration)):
        data = stream.read(chunk)
        frames.append(data)
    print("Recording finished.")
    
    stream.stop_stream()
    stream.close()
    p.terminate()
    
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(channels)
        wf.setsampwidth(p.get_sample_size(pyaudio.paInt16))
        wf.setframerate(rate)
        wf.writeframes(b''.join(frames))

def transcribe_audio(filename, servers):
    with open(filename, 'rb') as f:
        audio_data = f.read()
    
    for server in servers:
        url = f"http://{server}/transcribe"
        files = {"audio_file": (filename, io.BytesIO(audio_data), "audio/wav")}
        
        try:
            response = requests.post(url, files=files, timeout=10)
            if response.status_code == 200:
                return response.json().get("text", "")
            else:
                print(f"Server {server} returned status {response.status_code}, trying next...")
        except requests.exceptions.RequestException as e:
            print(f"Error connecting to {server}: {e}, trying next...")
    
    return "Transcription failed on all servers."

if __name__ == "__main__":
    FILENAME = "recorded_audio.wav"
    SERVERS = ["192.168.1.211:10300", "192.168.1.111:10300"]
    
    record_audio(FILENAME, duration=5)
    transcription = transcribe_audio(FILENAME, SERVERS)
    print("Transcribed text:", transcription)

