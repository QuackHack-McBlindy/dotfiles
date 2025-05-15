from fastapi import FastAPI, File, UploadFile, WebSocket
from fastapi.logger import logger as fastapi_logger
import logging
import uvicorn
import tempfile
import shutil
import soundfile as sf
import subprocess
import re
import time
import threading
import os
import requests
import json
import yaml
import websockets
import ast
from faster_whisper import WhisperModel

class DuckTrace:
    # ANSI escape codes for colors and formatting
    RESET = "\033[0m"
    BOLD = "\033[1m"
    BLINK = "\033[5m"

    RED = "\033[31m"
    YELLOW = "\033[33m"
    GREEN = "\033[32m"
    BLUE = "\033[34m"

    LOG_FILE = "ducktrace.log"

    def _timestamp(self):
       # return time.strftime("%Y-%m-%d %H:%M:%S")
        return time.strftime("%H:%M:%S") 
         
    def _log(self, level, symbol, color, message, blink=False):
        timestamp = self._timestamp()
        blink_text = self.BLINK if blink else ""
        formatted_message = (
            f"{color}{self.BOLD}{blink_text}[🦆📜] {symbol}{level}{symbol} [{timestamp}] - {message}{self.RESET}"
        )
        print(formatted_message)
        with open(self.LOG_FILE, "a") as log_file:
            log_file.write(f"[{timestamp}] {level} - {message}\n")

    def info(self, message):
        self._log("INFO", "✅", self.GREEN, message)

    def warning(self, message):
        self._log("WARNING", "⚠️", self.YELLOW, message)

    def error(self, message):
        self._log("ERROR", "❌", self.RED, message, blink=True)

    def critical(self, message):
        self._log("CRITICAL", "🚨", self.RED, message, blink=True)

    def debug(self, message):
        self._log("DEBUG", "🐛", self.BLUE, message)

# Create a DuckTrace instance inside the script
dt = DuckTrace()

# Intercept FastAPI logs and route them through DuckTrace
class DuckTraceHandler(logging.Handler):
    def emit(self, record):
        log_entry = self.format(record)
        if record.levelname == "INFO":
            dt.info(log_entry)
        elif record.levelname == "WARNING":
            dt.warning(log_entry)
        elif record.levelname == "ERROR":
            dt.error(log_entry)
        elif record.levelname == "CRITICAL":
            dt.critical(log_entry)
        elif record.levelname == "DEBUG":
            dt.debug(log_entry)

# Create a custom handler and formatter
duck_handler = DuckTraceHandler()
formatter = logging.Formatter("%(levelname)s - %(message)s")
duck_handler.setFormatter(formatter)

# Clear existing handlers and set DuckTrace as the only logger
logging.basicConfig(handlers=[duck_handler], level=logging.INFO, force=True)

# Apply it to FastAPI, Uvicorn, and other loggers
fastapi_logger.handlers = [duck_handler]
fastapi_logger.setLevel(logging.INFO)

uvicorn_logger = logging.getLogger("uvicorn")
uvicorn_logger.handlers = [duck_handler]
uvicorn_logger.setLevel(logging.INFO)

# Disable all other loggers except for DuckTrace
logging.getLogger().handlers = [duck_handler]
logging.getLogger("uvicorn.access").handlers = [duck_handler]
logging.getLogger("uvicorn.error").handlers = [duck_handler]

######################################
# SETTINGS
##########
app = FastAPI()
model = WhisperModel("medium", device="cpu", compute_type="int8")  
# Threshold probability to trigger the script
THRESHOLD = 0.85000
# Timeout to prevent multiple triggers for the same wake word
COOLDOWN_PERIOD = 5  # seconds
# Regex to extract probability from log lines
LOG_PATTERN = re.compile(r"probability=([\d\.]+)")
# Track last trigger time
last_trigger_time = 0
# Intents
USER_HOME = os.path.expanduser("~")
CONFIG_PATH = f"{USER_HOME}/dotfiles/home/.config/intents.yaml"
BIN_PATH = f"{USER_HOME}/dotfiles/home/bin/"
#Load intents from YAML
try:
    with open(CONFIG_PATH, "r") as file:
        INTENTS = yaml.safe_load(file)
    if isinstance(INTENTS, dict):
        num_intents = len(INTENTS)
        dt.info(f"Loaded {num_intents} intents from {CONFIG_PATH}.")
    else:
        raise ValueError("Invalid format: INTENTS is not a dictionary.")
except Exception as e:
    import traceback
    dt.error(f"Failed to load intents: {e}\n{traceback.format_exc()}")
####################################
# INTENTS
############
INTENTS = {
    'MediaController': {
        'script': 'mediaController.py 192.168.1.223 "{{ search }}" "{{ typ }}" ',
        'speech': 'Jag fixar det.',
        'packages': 'python3 python312Packages.requests python312Packages.python-dotenv'
    },
    'Time': {
        'script': 'time.py',
        'speech': 'Klockan är {output}',
        'packages': 'python3'
    },
    'musicGenerator': {
        'script': 'musicGen.py {{ genre }} {{ prompt }}',
        'speech': 'Jag genererar några låter åt dig, och återkommer med musiken när dom är klara.',
        'packages': 'python3 python312Packages.requests python312Packages.python-dotenv'
    },
    'noIntent': {
        'script': 'noIntent.py {input}',
        'speech': '{output}',
        'packages': 'python3 python312Packages.requests python312Packages.python-dotenv'
    }
}

USER_HOME = os.path.expanduser("~")
BIN_PATH = os.path.join(USER_HOME, 'dotfiles/home/bin/')

####################################
# FUNCTIONS
############
wyoming_satellite_path = shutil.which("wyoming-satellite")
def start_wyoming_satellite():
    """Start wyoming-satellite in the background."""
    cmd = [
        "/run/current-system/sw/bin/wyoming-satellite",
        "--uri", "tcp://0.0.0.0:10700",
        "--mic-command", "arecord -r 16000 -c 1 -f S16_LE -t raw",
        "--snd-command", "aplay -r 22050 -c 1 -f S16_LE -t raw",
        "--wake-uri", "tcp://127.0.0.1:10400",
        "--wake-word-name", "yo_bitch",
        "--awake-wav", "/home/pungkula/dotfiles/home/sounds/done.wav",
        "--done-wav", "/home/pungkula/dotfiles/home/sounds/awake.wav"
    ]
    subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, stdin=subprocess.DEVNULL)

def play_wav(file_path):
    """Plays a WAV file using aplay."""
    subprocess.Popen(["aplay", file_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def monitor_logs():
    """Monitor wyoming-openwakeword logs and trigger a script when probability is high."""
    global last_trigger_time  

    process = subprocess.Popen(
        ["journalctl", "-u", "wyoming-openwakeword", "-f", "-n", "0"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    for line in process.stdout:  # More efficient log reading
        match = LOG_PATTERN.search(line)
        if match:
            probability = float(match.group(1))
            current_time = time.time()

            if probability > THRESHOLD and (current_time - last_trigger_time) > COOLDOWN_PERIOD:
                dt.info(f"Wake word detected with probability {probability}.")
                dt.warning("MIC ON!")

                play_wav("/home/pungkula/dotfiles/home/sounds/awake.wav")

                voice_client_path = shutil.which("voice-client")
                if voice_client_path:
                    dt.info(f"Starting voice-client at {current_time}")  # Debugging
                    subprocess.Popen([voice_client_path])  # Non-blocking
                    last_trigger_time = current_time
                else:
                    dt.critical("voice-client not found")
                

def get_interpreter(script_path):
    """Determine the interpreter based on file extension."""
    ext = os.path.splitext(script_path)[1]
    return {
        ".sh": "bash",
        ".py": "python",
        ".js": "node",
    }.get(ext, None) 


say_path = shutil.which("say")
if not say_path:
    dt.error("say binary not found. Make sure it is installed and in $PATH.")


def execute_intent(intent_data):
    """Execute script based on Hassil response and intents.yaml configuration"""
    intent_name = intent_data.get("intent")

    if not intent_name:
        dt.debug("No intent found in response.")
        return "Unknown intent.", "Jag förstår inte det där."

    intent_config = INTENTS.get(intent_name)
    if not intent_config:
        dt.debug(f"Intent '{intent_name}' not found in INTENTS config.")
        speech_response = "Jag förstår inte det där."
        subprocess.run([say_path, speech_response])
        return "Unknown intent.", speech_response

    script_template = intent_config.get("script", "").strip()
    speech_template = intent_config.get("speech", "Action output: {output}, runtime: {duration} seconds")
    packages = intent_config.get("packages", "")

    if not script_template:
        dt.debug(f"No script found for intent '{intent_name}'.")
        return "Script not found.", f"Jag kunde inte hitta scriptet för {intent_name}."

    script_command = script_template
    for key, value in intent_data.items():
        script_command = script_command.replace(f"{{{{ {key} }}}}", str(value))

    dt.debug(f"Formatted script command: {script_command}")

    parts = script_command.split()
    if not parts:
        dt.debug("Script command is empty after parsing.")
        return "Invalid script.", "Felaktigt skriptkommando."

    script_file = parts[0]
    script_args = parts[1:]
    script_path = os.path.join(BIN_PATH, script_file)

    if not os.path.exists(script_path):
        dt.debug(f"Script file not found: {script_path}")
        speech_response = f"Jag kunde inte hitta {script_file}."
        subprocess.run([say_path, speech_response])
        return "Script not found.", speech_response

    nix_command = ["nix-shell"]
    if packages:
        nix_command.extend(["-p", *packages.split()])
    #nix_command.extend(["--run", f"python {script_path} " + " ".join(shlex.quote(arg) for arg in script_args)])
    nix_command.extend(["--run", f"python {script_path} {' '.join(script_args)}"])


    try:
        dt.debug(f"Running script in Nix shell: {script_path} with args: {script_args}")
        start_time = time.time()
        result = subprocess.run(nix_command, capture_output=True, text=True, check=True)
        output = result.stdout.strip()
        duration = time.time() - start_time
        dt.info(f"Script output: {output}, execution time: {duration:.2f}s")
    except subprocess.CalledProcessError as e:
        dt.error(f"Error executing {script_path} in Nix shell: {e.stderr}")
        output = f"Error: {e}"
        duration = 0

    # Format speech response
    speech_response = speech_template.replace("{output}", output).replace("{duration}", f"{duration:.2f}")
    dt.debug(f"Final speech response: {speech_response}")

    subprocess.Popen([say_path, speech_response],
                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, stdin=subprocess.DEVNULL)

    return output, speech_response


def send_to_hassil(transcribed_text):
    """Send transcribed text to Hassil, parse its JSON response, and execute the corresponding intent."""
    transcribed_text = re.sub(r"[^a-z0-9\såäö&]", "", transcribed_text.lower())
    dt.info(f"Sending to Hassil: {transcribed_text}")
    
    user_home = os.path.expanduser("~")
    config_path = f"{user_home}/dotfiles/home/.config/custom_sentences/sv"
    
    hassil_path = shutil.which("hassil")
    if not hassil_path:
        dt.error("Hassil binary not found. Make sure it is installed and in $PATH.")
        return

    process = subprocess.Popen(
        [hassil_path, config_path],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    output, error = process.communicate(input=transcribed_text)

    if error.strip():
        dt.error(f"Hassil error: {error.strip()}")

    if not output.strip():
        dt.debug("Empty response from Hassil.")
        return

    dt.debug(f"Raw Hassil response: {output}")

    if output.strip() == "<no match>":
        execute_intent({"intent": "noIntent", "input": transcribed_text})
        return

    # Extract JSON lines
    json_lines = [line for line in output.split("\n") if line.startswith("{")]
    if not json_lines:
        dt.debug("No valid JSON response found from Hassil.")
        return

    json_response = json_lines[0].replace("'", '"')  # Convert invalid JSON format

    try:
        intent_data = json.loads(json_response)
        dt.debug(f"Parsed Hassil response: {intent_data}")
        execute_intent(intent_data)
    except json.JSONDecodeError as e:
        dt.error(f"Error parsing Hassil response: {e}\nRaw response: {json_response}")
        return  # Prevent calling execute_intent with invalid data


@app.post("/transcribe")
async def transcribe_audio(audio: UploadFile = File(...)):
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio:
            temp_audio.write(await audio.read())
            temp_audio_path = temp_audio.name

        segments, _ = model.transcribe(temp_audio_path, language="sv")  

        os.remove(temp_audio_path) 

        if not segments:
            dt.debug(f"No speech detected")
            return {"transcription": "No speech detected"}

        transcription = " ".join(segment.text for segment in segments)
        dt.info(transcription)
        send_to_hassil(transcription)
        return {"transcription", transcription}

    except Exception as e:
        dt.error(f"error!")
        return {"error": str(e)}

def background_tasks():
    """Starts background services"""
    threading.Thread(target=start_wyoming_satellite, daemon=True).start()
    threading.Thread(target=monitor_logs, daemon=True).start()

@app.websocket("/stream")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    print("WebSocket connection established.")

    audio_buffer = bytearray()  # Buffer to accumulate audio data

    while True:
        try:
            data = await websocket.receive_bytes()
            print(f"Received {len(data)} bytes of audio")  # Debugging log
            audio_buffer.extend(data)

            if len(audio_buffer) > 32000:  # Process when enough data (~1 sec)
                audio_data, samplerate = sf.read(io.BytesIO(audio_buffer), dtype="int16")
                audio_buffer.clear()  # Reset buffer

                # Transcribe using Faster-Whisper
                segments, _ = model.transcribe(audio_data)
                transcript = " ".join(segment.text for segment in segments)

                print(f"Transcription: {transcript}")
                await websocket.send_text(transcript)

        except Exception as e:
            print(f"Error: {e}")
            break


if __name__ == "__main__":
    background_tasks()  
    uvicorn.run(app, host="0.0.0.0", port=10555)

