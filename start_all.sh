#!/bin/bash
# Starts all containers

current_path=$(pwd)

## All other but JItsi
mkdir data/grafana data/prometheus -p
chmod 777 data/grafana
chmod 777 data/prometheus
echo "Starts all other but JItsi"
docker compose up -d

echo
echo "-------------------------------------------------"
echo
#docker ps
echo
echo "-------------------------------------------------"
echo

## Jitsi
echo "  - Path: $current_path"
cd $current_path
mkdir tt
cd tt
pwd
# Get the latest zipball URL
url=$(curl -s https://api.github.com/repos/jitsi/docker-jitsi-meet/releases/latest | grep 'zipball_url' | cut -d\" -f4)

# Download with wget (you can also use curl -L -o jitsi_latest.zip "$url" instead)
wget -O jitsi_latest.zip "$url"

# Extract the zip into a known directory
unzip jitsi_latest.zip -d jitsi_git

# Find the actual subfolder (GitHub names it like jitsi-docker-jitsi-meet-abcdef)
target_dir=$(find jitsi_git -maxdepth 1 -mindepth 1 -type d)
echo " - Subfolder = $target_dir"

# Enter the extracted directory
cd "$target_dir" || { echo "Failed to cd into extracted directory"; exit 1; }
echo "  - Inside $target_dir"

mkdir $current_path/jitsi_custom
rsync -a ./ $current_path/jitsi_custom/
cp $current_path/jitsi_custom/env.example $current_path/jitsi_custom/.env
cd $current_path
rm -fr ./tt
cd $current_path/jitsi_custom

## -------- Fix Jitsi .env -----------
INPUT_FILE="$current_path/data/jitsi-variables.lst"
ENV_FILE="$current_path/jitsi_custom/.env"

# Skapa .env-filen om den inte finns
touch "$ENV_FILE"

# Gå igenom varje rad i input-filen
while IFS='=' read -r key value; do
  # Hoppa över tomma rader eller kommentarer
  [[ -z "$key" || "$key" =~ ^# ]] && continue

  # Om nyckeln redan finns, ersätt raden
  if grep -q "^$key=" "$ENV_FILE"; then
    sed -i "s|^$key=.*|$key=$value|" "$ENV_FILE"
  else
    echo "$key=$value" >> "$ENV_FILE"
  fi
done < "$INPUT_FILE"

echo "  - Kopierar in custom-config.js"
cat $current_path/data/jitsi_custom/custom-config.js >> $current_path/jitsi_custom/custom-config.js
#cp $current_path/data/jitsi_custom/custom-config.js $current_path/jitsi_custom/

echo "Uppdatering klar."

## --------- Fix docker-compose.yml ---------
#- ./custom-config.js:/config/custom-config.js:Z
#
input_file="docker-compose.yml"
output_file="docker-compose.new.yml"
insert_line="            - ./custom-config.js:/config/custom-config.js:Z"
found_volumes=0

awk -v insert="$insert_line" '
  $0 ~ /^[[:space:]]*web:/ { in_web=1 }
  in_web && /^[[:space:]]*volumes:/ {
    print
    print insert
    found_volumes=1
    next
  }
  { print }
' "$input_file" > "$output_file"
mv $output_file $input_file


## --------- Fix Jitsi passwords -------
cd $current_path/jitsi_custom
./gen-passwords.sh

echo " - Startar Jitsi"
#docker compose up -d
echo 
docker ps
echo
echo "-----------------------------------"
echo "              Klart                "
echo "-----------------------------------"
echo
