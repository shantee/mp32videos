#!/bin/bash

# Determine the root directory (parent of 'scripts' directory)
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Create 'videos' directory at the root if it doesn't exist
[ ! -d "$ROOT_DIR/videos" ] && mkdir "$ROOT_DIR/videos"

# Iterate over each subfolder in 'frames' (from the root directory)
for dir in "$ROOT_DIR/frames/"*/; do
    # Get the name of the subfolder (e.g., 'music1')
    name=$(basename "$dir")
    
    # Corresponding MP3 file path
    mp3_file="$ROOT_DIR/mp3/$name.mp3"
    
    # Check if the MP3 file exists
    if [ -f "$mp3_file" ]; then
        # Paths for temporary and final video files
        temp_video="$ROOT_DIR/videos/${name}_temp.mp4"
        final_video="$ROOT_DIR/videos/${name}.mp4"
        
        # Frame naming pattern (assuming names like 'frame-000257.png')
        frame_pattern="$dir/frame-%06d.png"
        
        # Check if frames exist in the subfolder
        if ls "$dir"/frame-*.png 1> /dev/null 2>&1; then
            echo "Processing $name..."
            
            # Find the starting frame number
            first_frame=$(ls "$dir"/frame-*.png | sort | head -n 1)
            start_number=$(basename "$first_frame" | sed -E 's/frame-0*([0-9]+)\.png/\1/')
            
            echo "Starting frame number is $start_number"
            
            # Get the duration of the MP3 file
            mp3_duration=$(ffprobe -i "$mp3_file" -show_entries format=duration -v quiet -of csv="p=0")
            
            # Get the total number of frames
            total_frames=$(ls "$dir"/frame-*.png | wc -l)
            
            # Calculate the required frame rate
            export LC_NUMERIC="C"
            framerate=$(awk "BEGIN {print $total_frames / $mp3_duration}")
            
            echo "Calculated frame rate is $framerate fps"
            
            # Create the video from frames specifying the starting number and calculated frame rate
            ffmpeg -framerate $framerate -start_number $start_number -i "$frame_pattern" -c:v libx264 -pix_fmt yuv420p "$temp_video"
            
            # Add the audio track to the video
            ffmpeg -i "$temp_video" -i "$mp3_file" -c:v copy -c:a aac -shortest "$final_video"
            
            # Remove the temporary video file
            rm "$temp_video"
            
            echo "Video for $name created successfully."
        else
            echo "No frames found in $dir"
        fi
    else
        echo "MP3 file for $name not found: $mp3_file"
    fi
done

# Demande à l'utilisateur s'il souhaite supprimer le contenu du dossier frames/
echo
read -p "Voulez-vous supprimer tout le contenu du dossier frames/? (o/n): " confirm_delete
if [[ "$confirm_delete" == "o" || "$confirm_delete" == "y" ]]; then
    rm -rf "$ROOT_DIR/frames/"*
    echo "Le contenu du dossier frames/ a été supprimé."
else
    echo "Le contenu du dossier frames/ n'a pas été supprimé."
fi