#!/bin/bash

# Run as: sudo ./record_on_combo.sh

AUDIO_FILE="/tmp/micyo_rec.raw"
AUDIO_DEVICE="hw:0,0"  # Update as needed using `arecord -l`
RECORDING=0
COOLDOWN=0
DEBOUNCE_TIME=2  # seconds

ctrl_down=0
grave_down=0

echo "🎧 Listening for Left Control + \` combo..."

# Monitor keys via keyd
sudo keyd -m | while read -r line; do
    # Optional: log keyd output for debugging
    echo "KEYD: [$line]" >> /tmp/keyd_debug.log

    # Skip empty or null character lines (keyd noise)
    [[ -z "$line" || "$line" == $'\x00' ]] && continue

    case "$line" in
        *"leftcontrol down"*) ctrl_down=1 ;;
        *"\` down"*)          grave_down=1 ;;
        *"leftcontrol up"*)   ctrl_down=0 ;;
        *"\` up"*)            grave_down=0 ;;
    esac

    current_time=$(date +%s)

    # START recording
    if [[ $ctrl_down -eq 1 && $grave_down -eq 1 && $RECORDING -eq 0 && $current_time -ge $COOLDOWN ]]; then

        # Check if the audio device is in use
        if fuser /dev/snd/* >/dev/null 2>&1; then
            echo "⚠️ Audio device is busy. Skipping..."
            COOLDOWN=$((current_time + DEBOUNCE_TIME))
            continue
        fi

        echo "🎤 Recording STARTED"
        rm -f "$AUDIO_FILE"

        # Start arecord in the background
        arecord -q -f S16_LE -r 16000 -c 1 -t raw -D "$AUDIO_DEVICE" "$AUDIO_FILE" &
        RECORD_PID=$!

        sleep 0.2  # Give time for arecord to initialize

        if ! ps -p $RECORD_PID >/dev/null; then
            echo "❌ Failed to start recording!"
            RECORDING=0
            COOLDOWN=$((current_time + DEBOUNCE_TIME))
            continue
        fi

        RECORDING=1
        COOLDOWN=$((current_time + DEBOUNCE_TIME))
    fi

    # STOP recording
    if [[ $ctrl_down -eq 0 && $grave_down -eq 0 && $RECORDING -eq 1 ]]; then
        echo "⏹️ Recording STOPPED"
        kill -INT $RECORD_PID 2>/dev/null
        wait $RECORD_PID 2>/dev/null

        if [[ -s "$AUDIO_FILE" ]]; then
            echo "📡 Sending audio..."
            curl -X POST http://localhost:10555/transcribe \
                -F "audio=@$AUDIO_FILE;type=audio/raw"
        else
            echo "❌ Empty recording - check microphone permissions or input!"
            sudo -u $SUDO_USER aplay "$AUDIO_FILE"
        fi

        RECORDING=0
        COOLDOWN=$((current_time + DEBOUNCE_TIME))
    fi
done
