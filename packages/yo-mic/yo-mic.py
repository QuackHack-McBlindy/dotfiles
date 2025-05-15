import sounddevice as sd
import numpy as np
import requests
import wave
import tempfile

WAKE_SERVER_URL = "http://192.168.1.111:10555/transcribe"
AUDIO_DURATION = 5  
SAMPLE_RATE = 16000  

def record_and_send():
    """Records audio and sends it to the wake server, then exits."""
    print("Recording...")
    audio = sd.rec(int(AUDIO_DURATION * SAMPLE_RATE), samplerate=SAMPLE_RATE, channels=1, dtype=np.int16)
    sd.wait()
    print("Recording complete. Sending to server...")

    with tempfile.NamedTemporaryFile(suffix=".wav", delete=True) as temp_audio:
        with wave.open(temp_audio, "wb") as wf:
            wf.setnchannels(1)
            wf.setsampwidth(2)  
            wf.setframerate(SAMPLE_RATE)
            wf.writeframes(audio.tobytes())

        temp_audio.seek(0)  
        requests.post(WAKE_SERVER_URL, files={"audio": temp_audio})

if __name__ == "__main__":
    record_and_send()
