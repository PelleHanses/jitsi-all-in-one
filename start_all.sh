#!/bin/bash
# Starts all containers

cd /opt/jitsi-all-in-one


## All other but JItsi
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

mkdir jitsi_custom
mv * ../jitsi_custom/
mv .* ../jitsi_custom/
cd ..
rm -fr ./jitsi_git

# Optional: Confirm where you are
pwd
