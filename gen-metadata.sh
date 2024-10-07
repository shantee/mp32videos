#!/bin/bash

# Dossier contenant les fichiers modules
input_folder="../modules"  # Remplace par le chemin de ton dossier
output_folder="../metadata"  # Dossier où enregistrer les fichiers texte


# Créer le dossier de sortie s'il n'existe pas
mkdir -p "$output_folder"

# Parcourir chaque fichier module dans le dossier
for file in "$input_folder"/*.{mod,s3m,xm,it,S3M,XM,IT,MOD}; do
  # Vérifier si le fichier existe pour éviter les erreurs
  if [ -f "$file" ]; then
    # Extraire le nom du fichier sans extension
    filename=$(basename "$file")
    base_name="${filename%.*}"
    
    # Fichier de sortie pour les informations extraites
    output_file="$output_folder/$base_name.txt"
    
    # Créer deux fichiers temporaires
    temp_file_1=$(mktemp)
    temp_file_2=$(mktemp)
    
    # Ajouter la première ligne avec le nom du fichier dans temp_file_1
    echo "filename : $filename" > "$temp_file_1"
    
    # Obtenir la taille du fichier en octets et l'ajouter à temp_file_1
    filesize=$(du -h "$file" | cut -f1)  # Taille dans un format lisible
    echo "filesize : $filesize bytes" >> "$temp_file_1"
    
    # Exécuter la commande xmp et enregistrer la sortie dans temp_file_2
    xmp --load-only -v "$file" > "$temp_file_2" 2>&1
    
    # Supprimer toutes les lignes avant le mot "Loading" dans temp_file_2
    sed -i '0,/Loading/d' "$temp_file_2"
    
    # Troncature à 33 caractères des lignes de la section "Instruments:" avec cut
   
    cat "$temp_file_2" > "$temp_file_2.truncated"
    
    # Concaténer temp_file_1 et temp_file_2.truncated dans le fichier de sortie final
    cat "$temp_file_1" "$temp_file_2.truncated" > "$output_file"
    
    # Supprimer les fichiers temporaires
    rm "$temp_file_1" "$temp_file_2" "$temp_file_2.truncated"
    
    # Supprimer les lignes contenant 'Instrument name' et les lignes vides
    grep -v 'Instrument name' "$output_file" > temp3 && mv temp3 "$output_file"
    grep -v '^\s*$' "$output_file" > temp4 && mv temp4 "$output_file"
    
tac "$output_file" | while read -r line; do
  visible_chars=$(echo "$line" | tr -d '[:space:]')  # Supprime tous les espaces et caractères invisibles
  if [[ ${#visible_chars} -ge 3 ]]; then  # Si le nombre de caractères visibles est supérieur ou égal à 3
    echo "$line"
  fi
done | tac > temp && mv temp "$output_file"

tac "$output_file" | awk '
  BEGIN { remove_chars = 1 }  # Activer la suppression des caractères
  /Instruments:/ { remove_chars = 0 }  # Désactiver la suppression quand on trouve "Instruments:"
  {
    if (remove_chars == 1) {
      print substr($0, 3)  # Supprimer les deux premiers caractères
    } else {
      print  # Garder la ligne intacte si "Instruments:" est trouvé
    }
  }
' | tac > temp && mv temp "$output_file"

tac "$output_file" | awk '
  BEGIN { remove_chars = 1 }  # Commencer à supprimer les caractères
  /Instruments:/ { remove_chars = 0 }  # Arrêter quand on trouve "Instruments:"
  {
    if (remove_chars == 1) {
      print substr($0, 1, length($0)-41)  # Supprimer les 41 derniers caractères
    } else {
      print  # Garder la ligne intacte si "Instruments:" est trouvé
    }
  }
' | tac > temp_file_final
mv temp_file_final "$output_file"

    # Afficher un message pour confirmer l'extraction
    echo "Informations extraites pour : $filename"
  fi
done

echo "Extraction terminée pour tous les fichiers modules."