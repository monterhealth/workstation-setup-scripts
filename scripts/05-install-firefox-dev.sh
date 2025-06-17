#!/bin/bash

# 05-install-firefox-dev.sh
# Installs Firefox Developer Edition from a manually downloaded archive.

set -e

echo "[INFO] Checking for Firefox Developer Edition archive..."
ARCHIVE_PATH=$(ls "$HOME"/Downloads/firefox-*.tar.* 2>/dev/null | head -n 1)

if [[ ! -f "$ARCHIVE_PATH" ]]; then
  echo "[ERROR] No Firefox Developer Edition archive found in ~/Downloads."
  echo "Please download the archive from: https://www.mozilla.org/en-US/firefox/developer/"
  echo "Save it as: firefox-<version>.tar.xz in your ~/Downloads folder."
  exit 1
fi

echo "[INFO] Installing required dependencies..."
sudo apt update
sudo apt install -y libgtk-3-0 libdbus-glib-1-2 xz-utils

INSTALL_DIR="/opt/firefox-devedition"
echo "[INFO] Creating install directory at $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
sudo rm -rf "$INSTALL_DIR"/*
sudo tar -xf "$ARCHIVE_PATH" -C "$INSTALL_DIR" --strip-components=1

echo "[INFO] Creating symlink at /usr/local/bin/firefox-devedition..."
sudo ln -sf "$INSTALL_DIR/firefox" /usr/local/bin/firefox-devedition

DESKTOP_ENTRY="/usr/share/applications/firefox-devedition.desktop"
if [[ ! -f "$DESKTOP_ENTRY" ]]; then
  echo "[INFO] Creating desktop entry..."
  cat <<EOF | sudo tee "$DESKTOP_ENTRY" > /dev/null
[Desktop Entry]
Version=1.0
Name=Firefox Developer Edition
Comment=Browse the Web
GenericName=Web Browser
Exec=/usr/local/bin/firefox-devedition %u
Icon=$INSTALL_DIR/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=firefox-dev
Keywords=web;browser;internet;
EOF
fi

echo "[INFO] Updating desktop database..."
sudo update-desktop-database

echo "[DONE] Firefox Developer Edition is installed and integrated into your system."
echo "You can launch it via your application menu or with the command: firefox-devedition"

