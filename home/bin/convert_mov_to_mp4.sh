#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <input.mov>"
    exit 1
fi

INPUT="$1"

if [[ ! -f "$INPUT" ]]; then
    echo "error: File not found: $INPUT"
    exit 1
fi

BASENAME="${INPUT%.*}"
OUTPUT="${BASENAME}.mp4"

ffmpeg -i "$INPUT" \
    -c:v libx264 \
    -preset medium \
    -crf 23 \
    -pix_fmt yuv420p \
    -movflags +faststart \
    -c:a aac \
    -b:a 192k \
    "$OUTPUT"

echo "Done: $OUTPUT"
