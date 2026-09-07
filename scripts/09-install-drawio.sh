#!/bin/bash
set -euo pipefail

# 09-install-drawio.sh
# Installs or updates draw.io (diagrams.net Desktop) from the latest GitHub release.

echo "[INFO] Installing prerequisites..."
sudo apt update
sudo apt install -y curl ca-certificates jq wget

echo "[INFO] Fetching latest draw.io release..."
LATEST_JSON=$(curl -fsSL https://api.github.com/repos/jgraph/drawio-desktop/releases/latest)
LATEST_TAG=$(echo "$LATEST_JSON" | jq -r '.tag_name')
VERSION=${LATEST_TAG#v}

if [[ -z "$LATEST_TAG" || "$LATEST_TAG" == "null" ]]; then
  echo "[ERROR] Could not determine the latest draw.io version from GitHub."
  exit 1
fi

DEB_URL=$(echo "$LATEST_JSON" | jq -r '.assets[] | select(.name | test("^drawio-amd64-.*\\.deb$")) | .browser_download_url' | head -n 1)
if [[ -z "$DEB_URL" || "$DEB_URL" == "null" ]]; then
  echo "[ERROR] Could not find an amd64 .deb asset in the latest draw.io release."
  exit 1
fi

echo "[INFO] Latest version available: $VERSION"
echo "[INFO] Download URL: $DEB_URL"

INSTALLED_VERSION="$(drawio --version 2>/dev/null || echo "none")"
echo "[INFO] Currently installed version: $INSTALLED_VERSION"

if [[ "$INSTALLED_VERSION" == "$VERSION" ]]; then
  echo "[INFO] You already have the latest version ($VERSION). No action needed."
else
  TEMP_DEB=$(mktemp --suffix=".deb")
  echo "[INFO] Downloading package..."
  curl -fL -o "$TEMP_DEB" "$DEB_URL"

  echo "[INFO] Installing package..."
  sudo apt install -y "$TEMP_DEB"
  rm -f "$TEMP_DEB"

  echo "[INFO] draw.io has been updated to version $VERSION"
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  sudo gtk-update-icon-cache -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi

echo "[DONE] draw.io installation completed."
