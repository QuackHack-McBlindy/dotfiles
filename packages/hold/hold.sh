#!/bin/bash

AUDIO_FILE="/tmp/micyo_rec.raw"
RECORDING=0
ctrl_down=0
grave_down=0

echo "🎧 Hold Left Control + \` to record. Release to send."

# Start monitoring keys
sudo keyd -m | while read -r line; do
    [[ -z "$line" || "$line" == $'\x00' ]] && continue

    case "$line" in
        *"leftcontrol down"*) ctrl_down=1 ;;
        *"\` down"*)          grave_down=1 ;;
        *"leftcontrol up"*)   ctrl_down=0 ;;
        *"\` up"*)            grave_down=0 ;;
    esac

    # Start recording
    if [[ $ctrl_down -eq 1 && $grave_down -eq 1 && $RECORDING -eq 0 ]]; then
        echo "🎤 Recording STARTED"
        rm -f "$AUDIO_FILE"

        # Use working arecord settings
        arecord -f S16_LE -r 16000 -c 1 -t raw "$AUDIO_FILE" &
        RECORD_PID=$!
        RECORDING=1
    fi

    # Stop recording when both keys released
    if [[ $ctrl_down -eq 0 && $grave_down -eq 0 && $RECORDING -eq 1 ]]; then
        echo "⏹️ Recording STOPPED"

        # Kill the recording process
        kill -INT $RECORD_PID 2>/dev/null
        wait $RECORD_PID 2>/dev/null

        if [[ -s "$AUDIO_FILE" ]]; then
            echo "📡 Sending audio..."
            curl -X POST http://localhost:10555/transcribe \
                 -F "audio=@$AUDIO_FILE;type=audio/raw"
        else
            echo "❌ No audio recorded!"
        fi

        RECORDING=0
    fi
done
