import os
import json
import requests
import torch
import langid
from pathlib import Path
from piper import PiperTTS

# Global settings
DEFAULT_LANGUAGE = "sv"
LANG_DETECT = True  # Set to False to disable language detection
PIPER_DIR = Path.home() / ".local/share/piper"
VOICES_URL = "https://raw.githubusercontent.com/rhasspy/piper/refs/heads/master/VOICES.md"

# Ensure model directory exists
PIPER_DIR.mkdir(parents=True, exist_ok=True)

# Function to fetch model URLs
def fetch_model_urls(lang):
    response = requests.get(VOICES_URL)
    response.raise_for_status()

    lines = response.text.splitlines()
    model_url = next((line for line in lines if f"/{lang}" in line and line.endswith(".onnx")), None)
    config_url = next((line for line in lines if f"/{lang}" in line and line.endswith(".onnx.json")), None)

    if not model_url or not config_url:
        raise RuntimeError(f"Error: Could not find valid model URLs for language '{lang}'")

    return model_url.strip(), config_url.strip()

# Function to detect language
def detect_language(text):
    if not LANG_DETECT:
        return DEFAULT_LANGUAGE

    detected_lang, _ = langid.classify(text)

    # Default to Swedish if language is not supported
    if detected_lang == "en":
        return "en_US"
    elif detected_lang != "sv":
        return DEFAULT_LANGUAGE
    return detected_lang

# Function to download models
def download_model(model_path, config_path, model_url, config_url):
    for url, path in [(model_url, model_path), (config_url, config_path)]:
        if not path.exists():
            print(f"Downloading {url}")
            response = requests.get(url, stream=True)
            response.raise_for_status()
            with open(path, "wb") as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)

# Function to synthesize speech
def synthesize_speech(text, lang):
    model_url, config_url = fetch_model_urls(lang)

    model_path = PIPER_DIR / Path(model_url).name
    config_path = PIPER_DIR / Path(config_url).name

    download_model(model_path, config_path, model_url, config_url)

    # Load Piper model
    with open(config_path, "r", encoding="utf-8") as f:
        model_config = json.load(f)

    device = "cuda" if torch.cuda.is_available() else "cpu"
    piper = PiperTTS.load(model_path, model_config, device=device)

    # Generate and play speech
    audio_data = piper.synthesize(text)
    piper.play(audio_data)

# Main execution
if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python voice_client.py '<text>'")
        sys.exit(1)

    text = sys.argv[1]
    language = detect_language(text)

    print(f"Detected language: {language}")
    synthesize_speech(text, language)
