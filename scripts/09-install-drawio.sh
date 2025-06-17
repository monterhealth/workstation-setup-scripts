#!/bin/bash

# 09-install-drawio.sh
# Installs draw.io (diagrams.net) using Snap

set -e

echo "[INFO] Ensuring snapd is installed..."
sudo apt update
sudo apt install -y snapd

echo "[INFO] Installing draw.io via Snap..."
sudo snap install drawio

echo "[DONE] draw.io installed. You can launch it from your app launcher or with 'drawio'."

