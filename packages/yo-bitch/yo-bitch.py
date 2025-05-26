from fastapi import FastAPI, File, UploadFile, WebSocket
from fastapi.logger import logger as fastapi_logger
from contextlib import asynccontextmanager
#from pathlib import Path
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
#import requests
#import json
import yaml
import string
#import websockets
#import ast
import asyncio
from faster_whisper import WhisperModel
import numpy as np
import datetime
#from wyoming.asr import Transcript
#from wyoming.client import AsyncClient
#from wyoming.wake import Detect

class DuckTrace:
    LOG_FILE = os.path.expanduser("~/.config/yo-bitch.log")
    MAX_LOG_SIZE = 5 * 1024 * 1024  # 5MB
    BACKUP_COUNT = 8
    RESET = "\033[0m"
    BOLD = "\033[1m"
    BLINK = "\033[5m"
    RED = "\033[31m"
    YELLOW = "\033[33m"
    GREEN = "\033[32m"
    BLUE = "\033[34m"

    def __init__(self):
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

dt = DuckTrace()

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

duck_handler = DuckTraceHandler()
formatter = logging.Formatter("%(levelname)s - %(message)s")
duck_handler.setFormatter(formatter)
logging.basicConfig(handlers=[duck_handler], level=logging.INFO, force=True)

fastapi_logger.handlers = [duck_handler]
fastapi_logger.setLevel(logging.INFO)

uvicorn_logger = logging.getLogger("uvicorn")
uvicorn_logger.handlers = [duck_handler]
uvicorn_logger.setLevel(logging.INFO)

logging.getLogger().handlers = [duck_handler]
logging.getLogger("uvicorn.access").handlers = [duck_handler]
logging.getLogger("uvicorn.error").handlers = [duck_handler]

def expand_path(path: str) -> str:
    return os.path.expanduser(os.path.expandvars(path))

def load_config():
    default_config_path = os.path.expanduser("~/.config/yo-bitch/config.yaml")
    config_path = os.getenv("YO_BITCH_CONFIG", default_config_path)
    config_path = expand_path(config_path)
    
    if not os.path.exists(config_path):
        config_dir = os.path.dirname(config_path)
        os.makedirs(config_dir, exist_ok=True)
        
        default_config = {
            "logging": {
                "log_file": "~/.config/yo-bitch.log",
                "max_log_size": 5242880,
                "backup_count": 8
            },
            "whisper": {
                "model_size": "medium",
                "device": "cpu",
                "compute_type": "int8",
                "sample_rate": 16000
            },
            "wake_word": {
                "threshold": 0.85,
                "cooldown_period": 15,
                "log_unit": "wyoming-openwakeword",
                "log_regex": "probability=([\\d\\.]+)",
                "awake_sound": "~/dotfiles/modules/themes/sounds/awake.wav",
                "done_sound": "~/dotfiles/modules/themes/sounds/done.wav",
                "wake_uri": "tcp://127.0.0.1:10400",
                "wake_word_name": "yo_bitch"
            },
            "wyoming_satellite": {
                "binary": "wyoming-satellite",
                "name": "YoBitch-Satellite",
                "uri": "tcp://0.0.0.0:10700",
                "mic_command": "arecord -r 16000 -c 1 -f S16_LE -t raw",
                "snd_command": "aplay -r 22050 -c 1 -f S16_LE -t raw"
            },
            "audio": {
                "say_binary": "say",
                "default_playback_cmd": "aplay",
                "temporary_audio_suffix": ".wav"
            },
            "api": {
                "host": "0.0.0.0",
                "port": 10555,
                "language": "sv",
                "vad_filter": True
            },
            "mic_command": "yo-mic",
            "commands": {
                "voice_commands": [
                    {
                        "match": "klockan",
                        "response": "Klockan är {time:%H:%M}"
                    },
                    {
                        "match": "datum",
                        "response": "Idag är det {date:%Y-%m-%d}"
                    },
                    {
                        "match": "veckodag",
                        "response": "Det är {weekday:%A}"
                    }
                ]
            }
        }

        try:
            with open(config_path, "w") as f:
                yaml.safe_dump(default_config, f, default_flow_style=False, sort_keys=False)
            print(f"Created default config at {config_path}")
        except Exception as e:
            raise RuntimeError(f"Failed to create config file: {e}")

    try:
        with open(config_path, "r") as f:
            config = yaml.safe_load(f)
    except Exception as e:
        raise RuntimeError(f"Failed to load config: {e}")

    # Expand paths in config
    config["logging"]["log_file"] = expand_path(config["logging"]["log_file"])
    config["wake_word"]["awake_sound"] = expand_path(config["wake_word"]["awake_sound"])
    config["wake_word"]["done_sound"] = expand_path(config["wake_word"]["done_sound"])
    
    return config

# Load config before initializing other components
try:
    config = load_config()
except Exception as e:
    print(f"Failed to load config: {e}")
    raise

# Logging
LOG_FILE = config["logging"]["log_file"]
MAX_LOG_SIZE = config["logging"]["max_log_size"]
BACKUP_COUNT = config["logging"]["backup_count"]

# Whisper model
WHISPER_MODEL_SIZE = config["whisper"]["model_size"]
WHISPER_DEVICE = config["whisper"]["device"]
WHISPER_COMPUTE_TYPE = config["whisper"]["compute_type"]
WHISPER_SAMPLE_RATE = config["whisper"]["sample_rate"]

# Wake word
WAKE_THRESHOLD = config["wake_word"]["threshold"]
WAKE_COOLDOWN = config["wake_word"]["cooldown_period"]
WAKE_LOG_UNIT = config["wake_word"]["log_unit"]
WAKE_LOG_REGEX = config["wake_word"]["log_regex"]
AWAKE_SOUND = config["wake_word"]["awake_sound"]
DONE_SOUND = config["wake_word"]["done_sound"]
WAKE_URI = config["wake_word"]["wake_uri"]
WAKE_WORD_NAME = config["wake_word"]["wake_word_name"]

# Wyoming Satellite
SATELLITE_BINARY = config["wyoming_satellite"]["binary"]
SATELLITE_NAME = config["wyoming_satellite"]["name"]
SATELLITE_URI = config["wyoming_satellite"]["uri"]
SATELLITE_MIC_CMD = config["wyoming_satellite"]["mic_command"]
SATELLITE_SND_CMD = config["wyoming_satellite"]["snd_command"]

MIC_COMMAND = config["mic_command"]

# Audio playback
SAY_BINARY = config["audio"]["say_binary"]
DEFAULT_PLAYBACK_CMD = config["audio"]["default_playback_cmd"]
TEMP_AUDIO_SUFFIX = config["audio"]["temporary_audio_suffix"]

# API
API_HOST = config["api"]["host"]
API_PORT = config["api"]["port"]
API_LANGUAGE = config["api"]["language"]
API_VAD_FILTER = config["api"]["vad_filter"]

# Voice command patterns
VOICE_COMMANDS = config["commands"]["voice_commands"]

LOG_PATTERN = re.compile(WAKE_LOG_REGEX)
LAST_TRIGGER_TIME = 0

model = WhisperModel(
    WHISPER_MODEL_SIZE,
    device=WHISPER_DEVICE,
    compute_type=WHISPER_COMPUTE_TYPE
)

@asynccontextmanager
async def lifespan(app: FastAPI):
    dt.info("Starting background services...")
    threading.Thread(target=start_wyoming_satellite, daemon=True).start()
    threading.Thread(target=monitor_logs, daemon=True).start()
    dt.info("All background services started")
    yield
    
app = FastAPI(lifespan=lifespan)

def start_wyoming_satellite():
    """Start wyoming-satellite in the background using config values."""
    if not shutil.which(SATELLITE_BINARY):
        raise RuntimeError(f"{SATELLITE_BINARY} binary not found in PATH.")
    cmd = [
        SATELLITE_BINARY,
        "--name", SATELLITE_NAME,
        "--uri", SATELLITE_URI,
        "--mic-command", SATELLITE_MIC_CMD,
        "--snd-command", SATELLITE_SND_CMD,
        "--wake-uri", WAKE_URI,
        "--wake-word-name", WAKE_WORD_NAME,
        "--awake-wav", AWAKE_SOUND,
        "--done-wav", DONE_SOUND
    ]
    dt.debug(f"Launching satellite with: {' '.join(cmd)}")
    subprocess.Popen(cmd)


def play_wav(file_path):
    """Play a WAV file using configured player."""
    subprocess.Popen([DEFAULT_PLAYBACK_CMD, file_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def monitor_logs():
    """Monitor wake word logs and trigger mic on threshold."""
    global LAST_TRIGGER_TIME
    LAST_TRIGGER_TIME = time.time()

    process = subprocess.Popen(
        ["journalctl", "-u", "wyoming-openwakeword", "-f", "-n", "0"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    for line in process.stdout:
        match = LOG_PATTERN.search(line)
        if match:
            probability = float(match.group(1))
            current_time = time.time()
            if probability > WAKE_THRESHOLD and (current_time - LAST_TRIGGER_TIME) > WAKE_COOLDOWN:
                play_wav(AWAKE_SOUND)
                dt.debug(f"Wake word detected with probability {probability}.")
                dt.info("MIC ON!")
                LAST_TRIGGER_TIME = current_time

                result = subprocess.run(MIC_COMMAND, shell=True, capture_output=True, text=True)
                if result.returncode != 0:
                    dt.error(f"Mic command failed: {result.stderr}")
                else:
                    dt.debug(f"Mic command output: {result.stdout}")

def format_dynamic_response(template: str) -> str:
    now = datetime.datetime.now()
    return template.format(
        time=now,
        date=now,
        weekday=now
    )

async def parse_voice_command(text: str) -> str:
    text = text.lower()
    for cmd in VOICE_COMMANDS:
        if cmd["match"] in text:
            return format_dynamic_response(cmd["response"])
    return ""

@app.post("/transcribe")
async def transcribe_audio(audio: UploadFile = File(...)):
    try:
        contents = await audio.read()
        audio_array = np.frombuffer(contents, dtype=np.int16)
        samplerate = WHISPER_SAMPLE_RATE
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp_wav:
            sf.write(tmp_wav.name, audio_array, samplerate, subtype="PCM_16")
            tmp_wav_path = tmp_wav.name
        segments, _ = model.transcribe(tmp_wav_path, language=API_LANGUAGE, vad_filter=API_VAD_FILTER)
        os.remove(tmp_wav_path)
        if not segments:
            return {"transcription": "No speech detected"}
        transcription = "".join(segment.text for segment in segments)
        cleaned_transcription = transcription.lower().translate(str.maketrans('', '', '.,!?'))
        transcription = cleaned_transcription.strip()
        dt.info(f"Transcribed: {transcription}")
        if transcription.strip():
            cmd = await parse_voice_command(transcription)
            if cmd:
                dt.info(f"Executed command: {cmd}")
                subprocess.Popen(["say", cmd], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                dt.debug("No Python command matched")
                dt.debug("Sending to Nix NLP")
                dt.info(f"Running: yo bitch {transcription}")
                subprocess.Popen(["yo", "bitch", transcription], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            dt.debug("Empty transcription")
        return {"transcription": transcription}
    except Exception as e:
        dt.error(f"Transcription error: {e}")
        return {"error": str(e)}
        
if __name__ == "__main__":
    uvicorn.run(app, host=API_HOST, port=API_PORT)

