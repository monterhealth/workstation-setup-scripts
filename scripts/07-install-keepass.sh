#!/bin/bash

# 07-install-keepass.sh
# Installs KeePassXC on Ubuntu

set -e

echo "[INFO] Update apt..."
sudo apt update

echo "[INFO] Installing KeepassXC..."
sudo apt install -y keepassxc

echo "[DONE] KeePassXC installation complete. It will be kept up to date via APT."

