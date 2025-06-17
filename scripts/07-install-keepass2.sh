#!/bin/bash

# 07-install-keepass2.sh
# Installs KeePass2 on Ubuntu via official PPA

set -e

echo "[INFO] Installing prerequisites..."
sudo apt update
sudo apt install -y software-properties-common gnupg2

echo "[INFO] Adding KeePass2 PPA..."
sudo add-apt-repository -y ppa:ubuntuhandbook1/keepass2

echo "[INFO] Updating package list..."
sudo apt update

echo "[INFO] Installing KeePass2..."
sudo apt install -y keepass2

echo "[DONE] KeePass2 installation complete. It will be kept up to date via APT."

