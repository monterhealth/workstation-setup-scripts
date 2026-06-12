#!/bin/bash

# 03-install-cursor.sh
# Installs Cursor AI editor via the official APT repository on Ubuntu/Debian.

set -euo pipefail

CURSOR_KEYRING="/usr/share/keyrings/anysphere.gpg"
CURSOR_KEYRING_LEGACY="/etc/apt/trusted.gpg.d/anysphere.gpg"
CURSOR_SOURCE_LIST="/etc/apt/sources.list.d/cursor.list"
CURSOR_SOURCE_DEB822="/etc/apt/sources.list.d/cursor.sources"
CURSOR_APT_REPO="https://downloads.cursor.com/aptrepo"
LEGACY_APPDIR="$HOME/Applications/cursor"
LEGACY_APPIMAGE="$LEGACY_APPDIR/cursor.AppImage"
LEGACY_SYMLINK="/usr/local/bin/cursor"
LEGACY_DESKTOP="/usr/share/applications/cursor.desktop"

remove_legacy_appimage_install() {
  echo "[INFO] Removing legacy AppImage installation artifacts (if present)..."

  if [ -L "$LEGACY_SYMLINK" ]; then
    echo "[INFO] Removing $LEGACY_SYMLINK"
    sudo rm -f "$LEGACY_SYMLINK"
  fi

  if [ -f "$LEGACY_DESKTOP" ] && grep -qE 'Applications/cursor|--no-sandbox' "$LEGACY_DESKTOP"; then
    echo "[INFO] Removing custom AppImage desktop entry at $LEGACY_DESKTOP"
    sudo rm -f "$LEGACY_DESKTOP"
  fi

  if [ -f "$LEGACY_APPIMAGE" ]; then
    echo "[INFO] Removing $LEGACY_APPIMAGE"
    rm -f "$LEGACY_APPIMAGE"
  fi
}

configure_cursor_apt_repository() {
  echo "[INFO] Adding Cursor GPG key..."
  sudo install -m 0755 -d /usr/share/keyrings
  curl -fsSL https://downloads.cursor.com/keys/anysphere.asc \
    | gpg --dearmor \
    | sudo tee "$CURSOR_KEYRING" > /dev/null
  sudo chmod 644 "$CURSOR_KEYRING"

  if [ -f "$CURSOR_KEYRING_LEGACY" ]; then
    echo "[INFO] Removing deprecated keyring at $CURSOR_KEYRING_LEGACY"
    sudo rm -f "$CURSOR_KEYRING_LEGACY"
  fi

  echo "[INFO] Configuring Cursor APT repository..."
  if apt modernize-sources --help >/dev/null 2>&1; then
    sudo tee "$CURSOR_SOURCE_DEB822" > /dev/null <<EOF
### THIS FILE IS AUTOMATICALLY CONFIGURED ###
# You may comment out this entry, but any other modifications may be lost.
Types: deb
URIs: $CURSOR_APT_REPO
Suites: stable
Components: main
Architectures: amd64,arm64
Signed-By: $CURSOR_KEYRING
EOF
    if [ -f "$CURSOR_SOURCE_LIST" ]; then
      sudo rm -f "$CURSOR_SOURCE_LIST"
    fi
  else
    sudo tee "$CURSOR_SOURCE_LIST" > /dev/null <<EOF
### THIS FILE IS AUTOMATICALLY CONFIGURED ###
# You may comment out this entry, but any other modifications may be lost.
deb [arch=amd64,arm64 signed-by=$CURSOR_KEYRING] $CURSOR_APT_REPO stable main
EOF
    if [ -f "$CURSOR_SOURCE_DEB822" ]; then
      sudo rm -f "$CURSOR_SOURCE_DEB822"
    fi
  fi
}

verify_apt_repository() {
  local cursor_source

  if [ -f "$CURSOR_SOURCE_DEB822" ]; then
    cursor_source="$CURSOR_SOURCE_DEB822"
  else
    cursor_source="$CURSOR_SOURCE_LIST"
  fi

  echo "[INFO] Verifying Cursor APT repository..."
  set +e
  APT_UPDATE_OUTPUT="$(
    sudo apt-get update \
      -o "Dir::Etc::sourcelist=$cursor_source" \
      -o "Dir::Etc::sourceparts=-" \
      -o "APT::Get::List-Cleanup=0" 2>&1
  )"
  APT_UPDATE_STATUS=$?
  set -e

  if [ "$APT_UPDATE_STATUS" -ne 0 ]; then
    echo "[ERROR] Updating the Cursor APT repository failed."
    echo "$APT_UPDATE_OUTPUT"
    exit 1
  fi

  if echo "$APT_UPDATE_OUTPUT" | grep -qiE 'NO_PUBKEY|not signed|Hash Sum mismatch'; then
    echo "[ERROR] Cursor APT repository verification failed."
    echo "$APT_UPDATE_OUTPUT"
    exit 1
  fi

  if ! apt-cache policy cursor | grep -q "downloads.cursor.com/aptrepo"; then
    echo "[ERROR] Cursor package was not found in the configured APT repository."
    apt-cache policy cursor || true
    exit 1
  fi
}

echo "[INFO] Installing prerequisites..."
sudo apt update
sudo apt install -y curl ca-certificates gnupg

remove_legacy_appimage_install
configure_cursor_apt_repository
verify_apt_repository

echo "[INFO] Installing Cursor..."
sudo apt install -y cursor

if command -v update-desktop-database >/dev/null 2>&1; then
  sudo update-desktop-database
fi

INSTALLED_VERSION="$(dpkg-query -W -f='${Version}' cursor 2>/dev/null || true)"
echo "[DONE] Cursor ${INSTALLED_VERSION:-installed} is available via the app launcher or by running: cursor"
echo "[INFO] Future updates: sudo apt update && sudo apt install --only-upgrade cursor"
