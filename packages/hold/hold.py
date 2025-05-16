

#!/usr/bin/env python3
import subprocess
import time
from pynput import keyboard

# Config
HOLD_KEY = keyboard.Key.space  # Change to any key (e.g., 'k', keyboard.Key.ctrl_l)
AUDIO_FILE = "audio.raw"

# State tracking
is_recording = False
recording_process = None

def on_press(key):
    global is_recording, recording_process
    if key == HOLD_KEY and not is_recording:
        is_recording = True
        # Start recording in background
        recording_process = subprocess.Popen([
            "arecord", "-f", "S16_LE", "-r", "16000", "-c", "1", "-t", "raw", AUDIO_FILE
        ])
        print("🎤 Recording started...")

def on_release(key):
    global is_recording, recording_process
    if key == HOLD_KEY and is_recording:
        is_recording = False
        # Stop recording
        recording_process.send_signal(subprocess.signal.SIGINT)
        recording_process.wait()
        print("⏹️ Recording stopped")
        
        # Send for transcription
        print("📡 Sending audio...")
        subprocess.run([
            "curl", "-X", "POST", "http://localhost:10555/transcribe",
            "-F", f"audio=@{AUDIO_FILE};type=audio/raw"
        ])

# Start listener
with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
    print(f"Press and hold [{HOLD_KEY}] to record...")
    listener.join()
