# ddotfiles/packages/say/say.py ⮞ https://github.com/QuackHack-McBlindy/dotfiles
import os
import sys
import re
import requests
import tempfile
import shutil
import subprocess

USER = os.getenv("USER", "default")
MODEL_DIR = os.path.expanduser("~/.local/share/piper")
VOICES_MD_URL = "https://raw.githubusercontent.com/rhasspy/piper/refs/heads/master/VOICES.md"
DEFAULT_LANGUAGE = "sv"  # Swedish
MIN_WORDS_FOR_DETECTION = 4  # Use default language if text is too short
SUPPORTED_LANGUAGES = {"en", "sv"}

def detect_language(text):
    if len(text.split()) < MIN_WORDS_FOR_DETECTION:
        return DEFAULT_LANGUAGE

    try:
        import langid
        lang, _ = langid.classify(text)
        if lang not in SUPPORTED_LANGUAGES:
            return DEFAULT_LANGUAGE
        return "en_US" if lang == "en" else lang
    except ImportError:
        return DEFAULT_LANGUAGE


def fetch_model_urls(language):
    """Fetches model & config URLs for the given language using regex."""
    response = requests.get(VOICES_MD_URL)
    if response.status_code != 200:
        print("Error fetching VOICES.md")
        sys.exit(1)

    model_match = re.search(rf"https://\S+/{language}[^ ]+\.onnx", response.text)
    config_match = re.search(rf"https://\S+/{language}[^ ]+\.onnx\.json", response.text)

    if not model_match or not config_match:
        print(f"Error: Could not find valid model URLs for language '{language}'")
        sys.exit(1)

    return model_match.group(0), config_match.group(0)

def download_file(url, dest_path):
    """Downloads a file if missing."""
    if not os.path.exists(dest_path):
        print(f"Downloading {url} → {dest_path}")
        response = requests.get(url, stream=True)
        with open(dest_path, "wb") as f:
            for chunk in response.iter_content(1024):
                f.write(chunk)

def ensure_model_exists(language):
    """Ensures model & config exist, downloading if necessary."""
    os.makedirs(MODEL_DIR, exist_ok=True)
    model_url, config_url = fetch_model_urls(language)

    model_path = os.path.join(MODEL_DIR, os.path.basename(model_url))
    config_path = os.path.join(MODEL_DIR, os.path.basename(config_url))
    download_file(model_url, model_path)
    download_file(config_url, config_path)

    return model_path, config_path

def speak(text):
    """Detects language, ensures model exists, generates speech, and plays it."""
    lang = detect_language(text)
    model, config = ensure_model_exists(lang)

    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp_wav:
        wav_path = tmp_wav.name

    try:
        subprocess.run([
            "piper",
            "-m", model,
            "-c", config,
            "-f", wav_path
        ], input=text.encode(), check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        subprocess.run(["aplay", wav_path], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError as e:
        print(f"Error running Piper: {e}")
        sys.exit(1)
    finally:
        os.remove(wav_path)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: say 'text to speak'")
        sys.exit(1)

    speak(sys.argv[1])
