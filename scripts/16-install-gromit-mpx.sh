#!/bin/bash

# 16-install-gromit-mpx.sh
# Installs Gromit-MPX, an on-screen annotation tool, from Ubuntu APT.

set -e

echo "[INFO] Update apt..."
sudo apt update

echo "[INFO] Installing Gromit-MPX..."
sudo apt install -y gromit-mpx

echo "[DONE] Gromit-MPX installation complete. It will be kept up to date via APT."
echo "Launch it via your application menu or with: gromit-mpx"
echo "Default toggle key is F9."
