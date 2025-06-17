#!/bin/bash

# 09-install-dbeaver.sh
# Installs DBeaver Community Edition via official APT repository for auto-updates

set -e

echo "[INFO] Installing prerequisites: curl, ca-certificates, default-jdk..."
sudo apt update
sudo apt install -y curl ca-certificates default-jdk gnupg

echo "[INFO] Adding DBeaver GPG repository key..."
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key |
  gpg --dearmor |
  sudo tee /usr/share/keyrings/dbeaver-keyring.gpg > /dev/null

echo "[INFO] Adding DBeaver APT repository..."
echo "deb [signed-by=/usr/share/keyrings/dbeaver-keyring.gpg] https://dbeaver.io/debs/dbeaver-ce /" |
  sudo tee /etc/apt/sources.list.d/dbeaver.list > /dev/null

echo "[INFO] Updating package list and installing DBeaver..."
sudo apt update
sudo apt install -y dbeaver-ce

echo "[DONE] DBeaver CE is installed. Launch it via your app menu or by running 'dbeaver-ce'."

