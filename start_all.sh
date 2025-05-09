#!/bin/bash
# Starts all containers

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
cd data
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

mkdir ../../jitsi_custom
rsync -a ./ ../../jitsi_custom/
cp ../../jitsi_custom/env.example ../../jitsi_custom/.env
cd ../../../
rm -fr ./jitsi_git

## -------- Fix Jitsi .env -----------
INPUT_FILE="data/jitsi-variables.lst"
ENV_FILE="data/jitsi_custom/.env"

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

echo "Uppdatering klar."

## --------- Fix Jitsi passwords -------
cd data/jitsi_custom
./gen-passwords.sh


echo
echo "-----------------------------------"
echo "              Klart                "
echo "-----------------------------------"
echo
