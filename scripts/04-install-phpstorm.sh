#!/bin/bash

# 04-install-toolbox.sh
# Installs JetBrains Toolbox App (for installing PhpStorm and other JetBrains IDEs)

set -e

echo "[INFO] Installing required dependencies..."
sudo apt update
sudo apt install -y wget tar libfuse2 libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin jq

echo "[INFO] Fetching latest JetBrains Toolbox download URL..."
TOOLBOX_JSON=$(wget -qO- "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release")
TOOLBOX_URL=$(echo "$TOOLBOX_JSON" | jq -r '.TBA[0].downloads.linux.link')

if [[ -z "$TOOLBOX_URL" || "$TOOLBOX_URL" == "null" ]]; then
  echo "[ERROR] Failed to extract Toolbox download URL."
  exit 1
fi

echo "[INFO] Downloading Toolbox from: $TOOLBOX_URL"
TMPDIR=$(mktemp -d)
wget -qO "$TMPDIR/toolbox.tar.gz" "$TOOLBOX_URL"

echo "[INFO] Extracting Toolbox..."
tar -xzf "$TMPDIR/toolbox.tar.gz" -C "$TMPDIR"

# Zoek naar de juiste uitvoerbare binary in de submap
TOOLBOX_BIN=$(find "$TMPDIR" -type f -name jetbrains-toolbox -perm /u+x | head -n 1)

if [[ -z "$TOOLBOX_BIN" ]]; then
  echo "[ERROR] Toolbox executable not found after extraction."
  exit 1
fi

echo "[INFO] Moving Toolbox to /opt/jetbrains-toolbox..."
sudo mkdir -p /opt/jetbrains-toolbox
sudo cp -r "$(dirname "$TOOLBOX_BIN")"/* /opt/jetbrains-toolbox/

echo "[INFO] Creating symlink to /usr/local/bin..."
sudo ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox

echo "[INFO] Cleaning up..."
rm -rf "$TMPDIR"

echo "[INFO] Launching JetBrains Toolbox..."
/usr/local/bin/jetbrains-toolbox &

echo "[DONE] Toolbox installed and launched. Use it to install PhpStorm and configure auto-start."

