#!/bin/bash

# 07-install-keepass.sh
# Installs KeePassXC on Ubuntu

set -e

echo "[INFO] Update apt..."
sudo apt update

if apt-cache show keepassxc-full >/dev/null 2>&1; then
  echo "[INFO] Installing KeePassXC (keepassxc-full)..."
  sudo apt install -y keepassxc-full
else
  echo "[INFO] Installing KeePassXC..."
  sudo apt install -y keepassxc
fi

echo "[DONE] KeePassXC installation complete. It will be kept up to date via APT."
