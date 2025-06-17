#!/bin/bash

# 03-install-cursor.sh
# Installs Cursor AI editor via AppImage on Ubuntu with full desktop integration.

set -e

echo ">>> Installing prerequisites (libfuse2)..."
sudo apt update
sudo apt install -y libfuse2 curl

APPDIR="$HOME/Applications/cursor"
mkdir -p "$APPDIR"

echo ">>> Please download the latest Cursor AppImage manually:"
echo "    → https://www.cursor.sh/downloads"
echo ">>> Save the file in your Downloads folder (e.g., Cursor-1.0.0-x86_64.AppImage)"
read -p "Press Enter to continue when ready..."

# Zoek naar een bestand dat voldoet aan het patroon Cursor-*.AppImage
APPIMAGE_SOURCE=$(find "$HOME/Downloads" -maxdepth 1 -type f -iname "Cursor-*.AppImage" | head -n 1)

if [ -z "$APPIMAGE_SOURCE" ]; then
  echo "[ERROR] No Cursor AppImage file found in ~/Downloads."
  echo "Please make sure the file is named something like 'Cursor-1.0.0-x86_64.AppImage'."
  exit 1
fi

APPIMAGE_TARGET="$APPDIR/cursor.AppImage"

echo ">>> Copying AppImage to $APPIMAGE_TARGET..."
cp "$APPIMAGE_SOURCE" "$APPIMAGE_TARGET"

echo ">>> Setting executable permissions..."
chmod +x "$APPIMAGE_TARGET"

echo ">>> Installing icon..."
CURSOR_ICON_IMAGE="cursor.png"
# curl -fsSL "https://raw.githubusercontent.com/cursor-so/icons/main/icon.png" -o "$APPDIR/cursor.png"
cp "./03-cursor/$CURSOR_ICON_IMAGE" "$APPDIR/$CURSOR_ICON_IMAGE"

echo ">>> Creating symlink in /usr/local/bin..."
sudo ln -sf "$APPIMAGE_TARGET" /usr/local/bin/cursor

echo ">>> Creating desktop entry..."
cat << EOF | sudo tee /usr/share/applications/cursor.desktop > /dev/null
[Desktop Entry]
Version=1.0
Name=Cursor
Comment=AI-powered code editor
Exec=/usr/local/bin/cursor --no-sandbox
Icon=$APPDIR/$CURSOR_ICON_IMAGE
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=Cursor
MimeType=text/plain;
EOF

echo ">>> Updating desktop database..."
sudo update-desktop-database

echo ">>> [SUCCESS] Cursor installed. Launch via app launcher or by running: cursor"

