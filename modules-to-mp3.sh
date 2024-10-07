#!/bin/bash

# Dossier contenant les fichiers modules
input_folder="../modules"  # Remplace par le chemin de ton dossier
output_folder="../mp3"     # Dossier de sortie pour les fichiers MP3

# Créer le dossier de sortie s'il n'existe pas
mkdir -p "$output_folder"

# Compter le nombre de fichiers modules à convertir
total_files=$(find "$input_folder" -type f \( -iname "*.mod" -o -iname "*.s3m" -o -iname "*.xm" -o -iname "*.it" -o -iname "*.S3M" -o -iname "*.IT" -o -iname "*.MOD" -o -iname "*.XM" \) | wc -l)
current_file=0

# Boucle sur chaque fichier module dans le dossier
for file in "$input_folder"/*.{mod,s3m,xm,it,S3M,XM,IT,MOD}; do
  # Vérifier si le fichier existe pour éviter les erreurs si le pattern ne correspond à aucun fichier
  if [ -f "$file" ]; then
    ((current_file++))
    
    # Récupérer le nom du fichier sans l'extension
    filename=$(basename "$file")
    base_name="${filename%.*}"
    
    # Afficher la progression et les détails du fichier en cours
    echo "[$current_file/$total_files] Conversion de : $filename"

    # Convertir le fichier module en WAV d'abord
    xmp -o "$output_folder/$base_name.wav" "$file"
    
    # Vérifier si la conversion WAV a réussi
    if [ $? -eq 0 ]; then
      # Convertir le fichier WAV en MP3 en supprimant le silence à la fin
      ffmpeg -loglevel error -i "$output_folder/$base_name.wav" -af "silenceremove=stop_periods=-1:stop_duration=1:stop_threshold=-50dB" "$output_folder/$base_name.mp3"
      
      # Supprimer le fichier WAV intermédiaire
      rm "$output_folder/$base_name.wav"

      echo "[$current_file/$total_files] Conversion terminée : $base_name.mp3"
    else
      echo "Erreur lors de la conversion de $filename. Passage au suivant."
    fi
    
    echo "------------------------------------"
  fi
done

echo "Toutes les conversions sont terminées !"
