import sounddevice as sd
import numpy as np
import requests
import wave
import tempfile

SERVER_URL = "http://localhost:8765/transcribe"  # Ensure it matches the server port
AUDIO_DURATION = 5  # Seconds to record
SAMPLE_RATE = 16000  # Hz

def record_audio():
    print("Recording...")
    audio = sd.rec(int(AUDIO_DURATION * SAMPLE_RATE), samplerate=SAMPLE_RATE, channels=1, dtype=np.int16)
    sd.wait()
    print("Recording complete.")

    # Save as a proper WAV file
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio:
        with wave.open(temp_audio.name, "wb") as wf:
            wf.setnchannels(1)
            wf.setsampwidth(2)  # 16-bit audio
            wf.setframerate(SAMPLE_RATE)
            wf.writeframes(audio.tobytes())
        return temp_audio.name

def send_audio_to_server(audio_path):
    print("Sending audio to server...")
    with open(audio_path, "rb") as f:
        response = requests.post(SERVER_URL, files={"audio": f})
    print("Transcription:", response.text)

if __name__ == "__main__":
    audio_path = record_audio()
    send_audio_to_server(audio_path)
