#!/bin/bash

# 12-install-spotify.sh
# Installs Spotify from the official APT repository.

set -e

SPOTIFY_KEY_URL="https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc"
SPOTIFY_KEYRING="/etc/apt/keyrings/spotify.gpg"
SPOTIFY_SOURCE_LIST="/etc/apt/sources.list.d/spotify.list"

echo "[INFO] Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y curl ca-certificates gnupg

echo "[INFO] Adding Spotify GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL "$SPOTIFY_KEY_URL" | sudo gpg --dearmor --yes -o "$SPOTIFY_KEYRING"
sudo chmod 644 "$SPOTIFY_KEYRING"
sudo rm -f /etc/apt/trusted.gpg.d/spotify.gpg

echo "[INFO] Adding Spotify APT repository..."
echo "deb [signed-by=$SPOTIFY_KEYRING] https://repository.spotify.com stable non-free" \
  | sudo tee "$SPOTIFY_SOURCE_LIST" > /dev/null

echo "[INFO] Installing Spotify..."
sudo apt-get update
sudo apt-get install -y spotify-client

echo "[SUCCESS] Spotify is now installed."
