#!/bin/bash

# 06-install-chrome.sh
# Installs Google Chrome Stable via Google's official APT repository (auto-update enabled)

set -e

echo "[INFO] Installing prerequisites: wget, ca-certificates..."
sudo apt update
sudo apt install -y wget ca-certificates gnupg

echo "[INFO] Adding Google's GPG key to keyrings..."
sudo install -m 0755 -d /usr/share/keyrings
wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/google-chrome-keyring.gpg > /dev/null

echo "[INFO] Adding Google Chrome repository..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] \
https://dl.google.com/linux/chrome/deb/ stable main" \
  | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

echo "[INFO] Updating package list and installing Chrome..."
sudo apt update
sudo apt install -y google-chrome-stable

echo "[DONE] Google Chrome Stable has been installed and will receive automatic updates via APT."

