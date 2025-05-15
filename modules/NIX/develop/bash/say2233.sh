#!/bin/bash

# Default language (Swedish)
DEFAULT_LANGUAGE="sv"

# Enable or disable language detection ("on" or "off")
LANG_DETECT="on"

# Global variable for model storage directory
PIPER_DIR="/home/pungkula/dotfiles/home/.local/share/piper"

# URL to Piper voices list
VOICES_URL="https://raw.githubusercontent.com/rhasspy/piper/refs/heads/master/VOICES.md"

# Function to fetch download URLs from VOICES.md
fetch_model_urls() {
    local lang="$1"

    # Fetch VOICES.md content
    local voices_data=$(curl -s "$VOICES_URL")

    # Extract model and config URLs
    local model_url=$(echo "$voices_data" | grep -oE "https://[^\ ]+/$lang[^ ]+\.onnx" | head -n 1)
    local config_url=$(echo "$voices_data" | grep -oE "https://[^\ ]+/$lang[^ ]+\.onnx\.json" | head -n 1)

    # Validate extracted URLs
    if [[ -z "$model_url" || -z "$config_url" ]]; then
        echo "Error: Could not find valid model URLs for language '$lang'" >&2
        exit 1
    fi

    echo "$model_url $config_url"
}

# Function to detect language using langid
detect_language() {
    if [[ "$LANG_DETECT" == "off" ]]; then
        echo "$DEFAULT_LANGUAGE"
        return
    fi

    # Remove non-letter characters before detection
    local clean_text=$(echo "$1" | tr -cd '[:alpha:] [:space:]')

    local detected_lang=$(langid <<< "$clean_text" | awk -F", " '{print $1}' | tr -d "('")

    # Default to Swedish for unsupported languages
    if [[ "$detected_lang" == "en" ]]; then
        echo "en_US"  # Force American English
    elif [[ "$detected_lang" != "sv" ]]; then
        echo "$DEFAULT_LANGUAGE"
    else
        echo "$detected_lang"
    fi
}

# Function to download the Piper model if missing
download_model() {
    local model_path="$1"
    local config_path="$2"
    local model_url="$3"
    local config_url="$4"

    # Create directory if not exists
    mkdir -p "$PIPER_DIR"

    # Download model if missing
    if [[ ! -f "$model_path" ]]; then
        echo "Downloading model: $model_url"
        wget -q --show-progress -O "$model_path" "$model_url"
    fi

    # Download config if missing
    if [[ ! -f "$config_path" ]]; then
        echo "Downloading config: $config_url"
        wget -q --show-progress -O "$config_path" "$config_url"
    fi
}

# Function to set Piper language
set_piper_language() {
    local lang="$1"
    local text="$2"

    # Default to Swedish if detected language is neither "sv" nor "en_US"
    [[ "$lang" != "en_US" ]] && lang="sv"

    # Fetch model URLs dynamically
    read -r MODEL_URL CONFIG_URL <<< "$(fetch_model_urls "$lang")"

    # Define model and config file paths
    local model_filename=$(basename "$MODEL_URL")
    local config_filename=$(basename "$CONFIG_URL")

    MODEL="$PIPER_DIR/$model_filename"
    CONFIG="$PIPER_DIR/$config_filename"

    # Download the model if missing
    download_model "$MODEL" "$CONFIG" "$MODEL_URL" "$CONFIG_URL"

    # Verify file existence before running Piper
    if [[ ! -f "$MODEL" || ! -f "$CONFIG" ]]; then
        echo "Error: Model or config file not found!"
        exit 1
    fi

    # Debugging output
    echo "Using model: $MODEL"
    echo "Using config: $CONFIG"

    echo "$text" | sed -z 's/\n/ /g' | piper -q -m "$MODEL" -c "$CONFIG" -s 21 -f - | aplay
}

# Ensure text input is provided
if [[ -z "$1" ]]; then
    echo "Please provide some text as an argument."
    exit 1
fi

TEXT="$1"
LANG=$(detect_language "$TEXT")

echo "Detected language: $LANG"
set_piper_language "$LANG" "$TEXT"

