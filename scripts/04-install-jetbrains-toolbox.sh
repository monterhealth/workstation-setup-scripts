#!/bin/bash

# 04-install-jetbrains-toolbox.sh
# Installs JetBrains Toolbox App (for installing PhpStorm and other JetBrains IDEs)

set -e

echo "[INFO] Installing required dependencies..."
sudo apt update
sudo apt install -y wget tar jq libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin dbus-user-session libxcb-keysyms1

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
  arm64) DOWNLOAD_KEY="linuxARM64" ;;
  amd64) DOWNLOAD_KEY="linux" ;;
  *)
    echo "[ERROR] Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

echo "[INFO] Fetching latest JetBrains Toolbox download URL ($DOWNLOAD_KEY)..."
TOOLBOX_JSON=$(wget -qO- "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release")
TOOLBOX_URL=$(echo "$TOOLBOX_JSON" | jq -r ".TBA[0].downloads.${DOWNLOAD_KEY}.link")

if [[ -z "$TOOLBOX_URL" || "$TOOLBOX_URL" == "null" ]]; then
  echo "[ERROR] Failed to extract Toolbox download URL."
  exit 1
fi

echo "[INFO] Downloading Toolbox from: $TOOLBOX_URL"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
wget -qO "$TMPDIR/toolbox.tar.gz" "$TOOLBOX_URL"

echo "[INFO] Extracting Toolbox..."
tar -xzf "$TMPDIR/toolbox.tar.gz" -C "$TMPDIR"

TOOLBOX_BIN=$(find "$TMPDIR" -type f -path '*/bin/jetbrains-toolbox' -perm /u+x | head -n 1)
if [[ -z "$TOOLBOX_BIN" ]]; then
  TOOLBOX_BIN=$(find "$TMPDIR" -type f -name jetbrains-toolbox -perm /u+x | head -n 1)
fi

if [[ -z "$TOOLBOX_BIN" ]]; then
  echo "[ERROR] Toolbox executable not found after extraction."
  exit 1
fi

TOOLBOX_ROOT="$(dirname "$(dirname "$TOOLBOX_BIN")")"
if [[ "$(basename "$(dirname "$TOOLBOX_BIN")")" != "bin" ]]; then
  TOOLBOX_ROOT="$(dirname "$TOOLBOX_BIN")"
fi

echo "[INFO] Installing Toolbox to /opt/jetbrains-toolbox..."
sudo rm -rf /opt/jetbrains-toolbox
sudo mkdir -p /opt/jetbrains-toolbox
sudo cp -a "$TOOLBOX_ROOT"/. /opt/jetbrains-toolbox/

if [[ -x /opt/jetbrains-toolbox/bin/jetbrains-toolbox ]]; then
  sudo ln -sf /opt/jetbrains-toolbox/bin/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox
else
  sudo ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox
fi

echo "[INFO] Launching JetBrains Toolbox..."
/usr/local/bin/jetbrains-toolbox &

echo "[DONE] Toolbox installed and launched. Use it to install PhpStorm and configure auto-start."
