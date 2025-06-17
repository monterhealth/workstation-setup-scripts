#!/bin/bash

# 08-install-discord.sh
# Installs Discord using Snap for automatic updates

set -e

echo "[INFO] Ensuring snapd is installed..."
sudo apt update
sudo apt install -y snapd

echo "[INFO] Installing Discord via Snap..."
sudo snap install discord

echo "[DONE] Discord installed via Snap. It will auto-update in the background."

