import sounddevice as sd
import numpy as np
import requests
import wave
import tempfile
import json

# Server & Home Assistant Configuration
SERVER_URL = "http://localhost:8765/transcribe"  # Matches the server port
HA_URL = "http://192.168.1.211:8123/api/conversation/process"
HA_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIzZjUyZDE4Y2JjNzE0YzFjOTJkN2RjMDFhNjM2N2I4MyIsImlhdCI6MTc0MDQxOTE5MiwiZXhwIjoyMDU1Nzc5MTkyfQ.-xwBYz3989mM2SSv2xJwF841h2cb0IRwBYCKPMyAOno"  # Replace with your actual token
AUDIO_DURATION = 5  # Seconds
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
    result = response.json()
    
    if "transcription" in result:
        transcription = result["transcription"]
        print("Transcription:", transcription)
        send_to_home_assistant(transcription)
    else:
        print("Error:", result.get("error", "Unknown error"))

def send_to_home_assistant(transcribed_text):
    headers = {
        "Authorization": f"Bearer {HA_TOKEN}",
        "Content-Type": "application/json"
    }
    payload = {
        "text": transcribed_text,
        "language": "sv_SE",
        "agent_id": "conversation.home_assistant"
    }
    
    print("Sending transcription to Home Assistant...")
    response = requests.post(HA_URL, headers=headers, data=json.dumps(payload))
    
    if response.status_code == 200:
        ha_response = response.json()
        speech = ha_response.get("response", {}).get("speech", {}).get("plain", {}).get("speech")
        
        if speech:
            print("Home Assistant response:", speech)
            say_text(speech)
        else:
            print("No response from Home Assistant.")
    else:
        print("Failed to send to Home Assistant:", response.text)

def say_text(text):
    """Call a system command to speak the text (assuming a Linux system with 'bash say')"""
    import subprocess
    subprocess.run(["bash", "say", text])

if __name__ == "__main__":
    audio_path = record_audio()
    send_audio_to_server(audio_path)

