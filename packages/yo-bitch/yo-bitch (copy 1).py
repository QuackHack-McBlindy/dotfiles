from fastapi import FastAPI, File, UploadFile, WebSocket
from fastapi.logger import logger as fastapi_logger
import logging
from logging.handlers import RotatingFileHandler
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
import asyncio
from faster_whisper import WhisperModel

# Remove YAML intents config
USER_HOME = os.path.expanduser("~")
BIN_PATH = os.path.join(USER_HOME, 'dotfiles/home/bin/')



class DuckTrace:
    LOG_FILE = "/home/$USER/.config/yo-bitch.log"
    MAX_LOG_SIZE = 5 * 1024 * 1024  # 5MB
    BACKUP_COUNT = 3

    # ANSI escape codes for colors and formatting
    RESET = "\033[0m"
    BOLD = "\033[1m"
    BLINK = "\033[5m"

    RED = "\033[31m"
    YELLOW = "\033[33m"
    GREEN = "\033[32m"
    BLUE = "\033[34m"

    LOG_FILE = "ducktrace.log"
###
    def __init__(self):
        # Set up rotating file handler
        self.file_handler = RotatingFileHandler(
            self.LOG_FILE, maxBytes=self.MAX_LOG_SIZE, backupCount=self.BACKUP_COUNT
        )
        self.file_handler.setFormatter(logging.Formatter("[%(asctime)s] %(levelname)s - %(message)s"))
        self.file_logger = logging.getLogger("DuckFileLogger")
        self.file_logger.setLevel(logging.DEBUG)
        self.file_logger.addHandler(self.file_handler)
        self.file_logger.propagate = False

    def _timestamp(self):
        return time.strftime("%H:%M:%S") 


    def _timestamp(self):
       # return time.strftime("%Y-%m-%d %H:%M:%S")
        return time.strftime("%H:%M:%S") 
         
    def _log(self, level, symbol, color, message, blink=False):
        timestamp = self._timestamp()
        blink_text = self.BLINK if blink else ""
        formatted_message = (
            f"{color}{self.BOLD}{blink_text}[🦆📜] {symbol}{level}{symbol} [{timestamp}] - {message}{self.RESET}"
        )
        self.file_logger.log(getattr(logging, level), message)
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


#def handle_detection(event: Detect):
    # Get sound paths from package installation
#    sound_dir = os.path.join(os.path.dirname(__file__), "share", "voice-assistant", "sounds")
#    play_wav(os.path.join(sound_dir, "awake.wav"))
    
    

######################################
# SETTINGS
##########
app = FastAPI()
model = WhisperModel("medium", device="cpu", compute_type="int8")  
#model = WhisperModel("medium", device="cpu", compute_type="float32")
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

yo_path = "/run/current-system/sw/bin/yo-bitch"


USER_HOME = os.path.expanduser("~")
BIN_PATH = os.path.join(USER_HOME, 'dotfiles/home/bin/')
import numpy as np
####################################
# FUNCTIONS
############
from wyoming.asr import Transcript
from wyoming.client import AsyncClient
from wyoming.wake import Detect

async def monitor_wake_word():
    """Connect directly to Wyoming wake word service"""
    client = AsyncClient(uri="tcp://127.0.0.1:10400")
    
    try:
        await client.connect()
        while True:
            event = await client.read_event()
            if isinstance(event, Detect):
                handle_detection(event)
            elif event is None:
                break
    finally:
        await client.disconnect()

#def handle_detection(event: Detect):
#    global last_trigger_time
#    current_time = time.time()
    
#    if (current_time - last_trigger_time) > COOLDOWN_PERIOD:
#        dt.info(f"Wake word detected: {event.name} (confidence={event.confidence})")
#        last_trigger_time = current_time
        
#        command = (
#            "arecord -f S16_LE -r 16000 -c 1 -d 5 -t raw audio.raw && "
#            "curl -X POST http://127.0.0.1:10555/transcribe "
#            "-F \"audio=@audio.raw;type=audio/raw\""
#        )

#        subprocess.Popen(command, shell=True)

wyoming_satellite_path = shutil.which("wyoming-satellite")
def start_wyoming_satellite():
    """Start wyoming-satellite in the background with full configuration."""
    if not wyoming_satellite_path:
        raise RuntimeError("wyoming-satellite binary not found.")

    cmd = [
        wyoming_satellite_path,
        "--name", "YoBitch-Satellite",
        "--uri", "tcp://0.0.0.0:10700",
        "--mic-command", "arecord -r 16000 -c 1 -f S16_LE -t raw",
        "--snd-command", "aplay -r 22050 -c 1 -f S16_LE -t raw",
        "--wake-uri", "tcp://127.0.0.1:10400",
        "--wake-word-name", "yo_bitch",
        "--awake-wav", "/home/pungkula/dotfiles/modules/themes/sounds/done.wav",
        "--done-wav", "/home/pungkula/dotfiles/modules/themes/sounds/awake.wav"
    ]

    subprocess.Popen(cmd)

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
                play_wav("/home/pungkula/dotfiles/modules/themes/sounds/awake.wav")
                dt.debug(f"Wake word detected with probability {probability}.")
                dt.info("MIC ON!")
                command = 'yo-mic'
                subprocess.run(command, shell=True)
                #dt.info(f"Starting voice-client at {current_time}")  
                last_trigger_time = current_time 
                
                #voice_client_path = shutil.which("yo-mic")
#                voice_client_path = subprocess.Popen(command, shell=True)
#                if voice_client_path:
#                    dt.info(f"Starting voice-client at {current_time}")  
#                    subprocess.Popen([voice_client_path]) 
#                    last_trigger_time = current_time
#                else:
#                    dt.critical("voice-client not found")

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


@app.post("/hassil")
def send_to_hassil(transcribed_text: str):
    """Send transcribed text to Hassil, parse its JSON response, and execute the corresponding intent."""
    transcribed_text = re.sub(r"[^a-z0-9\såäö&]", "", transcribed_text.lower())
    dt.info(f"Sending to Hassil: {transcribed_text}")
    
    user_home = os.path.expanduser("~")
  
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



#async def parse_voice_command(text: str) -> list:
#    """Parse natural language command"""
#    try:
#        dt.debug(f"Attempting to parse command: {text}")

        # Check if 'yo' is available
#        yo_path = shutil.which("yo-bitch")
#        if not yo_path:
#            dt.error("'yo' command not found in PATH.")
 #           await speak("Yo-kommando inte installerad", urgent=True)
#            return []

#        proc = await asyncio.create_subprocess_exec(
#            yo_path, text,
#            stdout=asyncio.subprocess.PIPE,
#            stderr=asyncio.subprocess.PIPE
#        )

#        try:
#            stdout, stderr = await asyncio.wait_for(proc.communicate(), timeout=10)
#        except asyncio.TimeoutError:
#            dt.error("'yo parse' timed out")
#            await speak("Tolkning timeout", urgent=True)
#            proc.kill()
#            await proc.communicate()
#            return []

        # Log stderr if present
#        if stderr:
 #           error_msg = stderr.decode().strip()
 #           dt.warning(f"'yo parse' stderr: {error_msg}")

#        result = stdout.decode().strip()
#        dt.info(f"'yo parse' raw output: {result}")

 #       if not result:
#            dt.error("Empty response from 'yo parse'")
 #           await speak("Tomt svar från tolkning", urgent=True)
#            return []

#        try:
 #           parsed = json.loads(result)
#            cmd = parsed.get("command", [])
#            dt.info(f"Parsed command: {cmd}")
#            return cmd
#        except json.JSONDecodeError as e:
#            dt.error(f"Failed to parse JSON: {e}\nRaw output: {result}")
#            await speak("Fel i kommandotolkning", urgent=True)
#            return []
#        except KeyError:
#            dt.error(f"Missing 'command' key in JSON: {parsed}")
#            await speak("Fel format på svar", urgent=True)
#            return []

#    except Exception as e:
#        dt.error(f"Unexpected error in parse_voice_command: {str(e)}", exc_info=True)
#        await speak("Allvarligt fel i tolkning", urgent=True)
#        return []

@app.post("/transcribe")
async def transcribe_audio(audio: UploadFile = File(...)):
    try:
        # Read raw bytes
        contents = await audio.read()

        # Convert raw 16-bit PCM data into a NumPy array
        audio_array = np.frombuffer(contents, dtype=np.int16)
        samplerate = 16000

        # Save to temporary WAV file using soundfile
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp_wav:
            sf.write(tmp_wav.name, audio_array, samplerate, subtype="PCM_16")
            tmp_wav_path = tmp_wav.name

        # Transcribe with whisper
        segments, _ = model.transcribe(tmp_wav_path, language="sv")

        # Remove temp file
        os.remove(tmp_wav_path)

        if not segments:
            return {"transcription": "No speech detected"}

        transcription = " ".join(segment.text for segment in segments)
        dt.info(f"Transcribed: {transcription}")
        cmd = await parse_voice_command(transcription)
        dt.info(cmd)

        if cmd:
            dt.info("executed")
        else:
            dt.warning("No command parsed from input")
        return {"transcription": transcription}

    except Exception as e:
        dt.error(f"Transcription error: {e}")

        return {"error": str(e)}


def construct_yo_command(text: str) -> list:
    """Convert natural language to yo command"""
    # Use yo's built-in NLP
    result = subprocess.run(
        ["yo", "parse", text],
        capture_output=True, text=True
    )
    return json.loads(result.stdout)["command"]
    
        
async def execute_yo_intent(command: list):
    """Execute yo command with voice-specific enhancements"""
    if not command:
        await speak("Jag förstår inte det där")
        return

    cmd_name = command[0]
    
    try:
        # Get metadata async
        meta_proc = await asyncio.create_subprocess_exec(
            "yo", cmd_name, "--json",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, _ = await meta_proc.communicate()
        meta = json.loads(stdout.decode())

        # Handle privilege escalation
        if meta.get("needs_sudo"):
            command = ["sudo", "-n"] + command

        # Execute command async
        proc = await asyncio.create_subprocess_exec(
            *command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await proc.communicate()

        if stdout:
            await speak(stdout.decode())
        if proc.returncode != 0:
            await speak(f"Error: {stderr.decode()}", urgent=True)

    except Exception as e:
        await speak(f"Fel uppstod: {str(e)}", urgent=True)
        dt.error(f"Command failed: {e}")
        
async def speak(text: str, urgent=False):
    """Use yo's TTS system"""
    args = ["speak", text]
    if urgent:
        args.insert(1, "--urgent")
    
    proc = await asyncio.create_subprocess_exec(
        "yo", *args,
        stdout=asyncio.subprocess.DEVNULL,
        stderr=asyncio.subprocess.DEVNULL
    )
    await proc.wait() 
 

#def background_tasks():
#    """Start services with error handling"""
#    try:
#        model_path = "/home/pungkula/.config/models/yo_bitch.tflite"
#        if not os.path.exists(model_path):
#            raise FileNotFoundError(f"Model file not found at {model_path}")
#        detector = WakeWordDetector(model_path)
#        detector.start()  
        
#        while True:
#            time.sleep(1)
#    except Exception as e:
#        dt.critical(f"Fatal initialization error: {str(e)}")
#        os._exit(1)


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


@app.get("/health")
async def health_check():
    """Verify yo integration"""
    try:
        proc = await asyncio.create_subprocess_exec(
            "yo", "--version",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, _ = await proc.communicate()
        return {
            "yo_version": stdout.decode().strip(),
            "status": "OK"
        }
    except Exception as e:
        dt.critical(f"Health check failed: {e}")
        raise HTTPException(status_code=500, detail="yo integration broken")


#from tensorflow.lite.python.interpreter import Interpreter
#import sounddevice as sd
#class WakeWordDetector:
#    def __init__(self, model_path, threshold=0.85, cooldown=5):
#        self.threshold = threshold
#        self.cooldown = cooldown
#        self.last_trigger = 0

        # Load model
#        self.interpreter = Interpreter(model_path=model_path)
#        self.interpreter.allocate_tensors()
        
        # Get model details
#        self.input_details = self.interpreter.get_input_details()
#        self.output_details = self.interpreter.get_output_details()
#        self.input_shape = self.input_details[0]['shape']
        
        # Audio config
#        self.sample_rate = 16000
#        self.chunk_size = self.input_shape[1] * self.input_shape[2]
        
        # Initialize audio stream with correct callback signature
#        self.stream = sd.InputStream(
#            samplerate=self.sample_rate,
#            channels=1,
#            dtype=np.int16,
#            blocksize=self.chunk_size,
#            callback=self._audio_callback
#        )

#    def _audio_callback(self, indata, frames, time_info, status):
#        """Single unified audio callback"""
#        try:
#            audio = indata[:, 0]
#            if len(audio) < self.chunk_size:
#                audio = np.pad(audio, (0, self.chunk_size - len(audio)))
#            else:
#                audio = audio[:self.chunk_size]
            
                # Normalize and reshape
#            input_data = (audio.astype(np.float32) / 32767.0).reshape(self.input_shape)
            
            # Run inference
#            self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
#            self.interpreter.invoke()
#            probability = self.interpreter.get_tensor(self.output_details[0]['index'])[0]
            
                # Detection logic
#            current_time = time.time()
#            if (probability > self.threshold and 
#                (current_time - self.last_trigger) > self.cooldown):
#                self.last_trigger = current_time
#                self.on_detected()
                
#        except Exception as e:
#            dt.error(f"Audio processing error: {str(e)}")

#    def start(self):
#        """Start listening"""
#        self.stream.start()

#    def stop(self):
#        """Stop listening"""
#        self.stream.stop()


#    def on_detected(self):
#        """Handle wake word detection"""
#        dt.info("Wake word detected!")
        play_wav("/path/to/awake.wav")
#        subprocess.Popen([shutil.which("yo-mic")])   

@app.on_event("startup")
def initialize_background_services():
    """Start all required background services when the API starts"""
    dt.info("Starting background services...")    
    # Wyoming Satellite
    threading.Thread(target=start_wyoming_satellite, daemon=True).start()    
    # Log monitoring for wake word
    threading.Thread(target=monitor_logs, daemon=True).start()    
    # Wake Word Detector
#    model_path = "/home/pungkula/.config/models/yo_bitch.tflite"
#    if os.path.exists(model_path):
#        detector = WakeWordDetector(model_path)
#        threading.Thread(target=detector.start, daemon=True).start()
#    else:
#        dt.critical(f"Wake word model missing: {model_path}")
    dt.info("All background services started")   

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=10555)

