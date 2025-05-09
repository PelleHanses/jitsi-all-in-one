#!/bin/bash

INPUT_FILE="jitsi-variables.lst"
ENV_FILE="jitsi_custom/.env"

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
