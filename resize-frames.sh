#!/bin/bash

# Set the root project directory
RACINE_PROJET="$(cd "$(dirname "$0")/.." && pwd)"

# Directory containing the frames
FRAME_DIR="$RACINE_PROJET/frames"

# Iterate over each subfolder in the frames directory
for subdir in "$FRAME_DIR"/*; do
    # Check if it is a directory
    if [ -d "$subdir" ]; then
        echo "Processing directory: $subdir"
        # Count total number of PNG frames in the subdirectory
        total_frames=$(find "$subdir" -name '*.png' | wc -l)
        current_frame=0
        # Iterate over each PNG frame in the subdirectory
        for frame in "$subdir"/*.png; do
            ((current_frame++))
            echo "Resizing frame $current_frame/$total_frames..."
            # Lanczos
            convert "$frame" -filter Lanczos -resize 1280x720\! -quality 92 "$frame"
        done
    fi
done

echo "All frames have been resized."
