#!/bin/bash

set -e

echo "[INFO] Installing Spotify..."

# Download de key op de juiste manier
echo "[INFO] Downloading and saving the Spotify GPG key..."
curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

# Voeg de repo toe met correcte signed-by verwijzing
echo "[INFO] Adding Spotify APT repository..."

# Update en installeer
echo "[INFO] Updating apt and installing Spotify..."
# sudo apt update
# sudo apt install -y spotify-client
sudo apt-get update && sudo apt-get install spotify-client

echo "[SUCCESS] Spotify is now installed."

