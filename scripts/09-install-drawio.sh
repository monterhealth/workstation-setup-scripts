#!/bin/bash
set -euo pipefail

# drawio-latest-install.sh
# Automatically installs or updates draw.io (diagrams.net Desktop) from the latest GitHub release

# 1. Fetch the latest release version from GitHub API
LATEST_JSON=$(curl -s https://api.github.com/repos/jgraph/drawio-desktop/releases/latest)
LATEST_TAG=$(echo "$LATEST_JSON" | jq -r '.tag_name')
VERSION=${LATEST_TAG#v}

# 2. Construct the .deb package URL for amd64
DEB_URL="https://github.com/jgraph/drawio-desktop/releases/download/${LATEST_TAG}/drawio-amd64-${VERSION}.deb"

echo "[INFO] Latest version available: $VERSION"
echo "[INFO] Download URL: $DEB_URL"

# 3. Check currently installed version (if any)
INSTALLED_VERSION="$(drawio --version 2>/dev/null || echo "none")"
echo "[INFO] Currently installed version: $INSTALLED_VERSION"

if [[ "$INSTALLED_VERSION" == "$VERSION" ]]; then
  echo "[INFO] You already have the latest version ($VERSION). No action needed."
else
  # 4. Download and install the .deb package
  TEMP_DEB=$(mktemp --suffix=".deb")
  echo "[INFO] Downloading package..."
  curl -L -o "$TEMP_DEB" "$DEB_URL"

  echo "[INFO] Installing package..."
  sudo apt install -y "$TEMP_DEB"
  rm -f "$TEMP_DEB"

  echo "[INFO] draw.io has been updated to version $VERSION"
fi

# 5. Ensure the application icon is properly installed
ICON_PATH="/usr/share/icons/hicolor/512x512/apps/drawio.png"
if [[ ! -f "$ICON_PATH" ]]; then
  echo "[INFO] Downloading draw.io icon..."
  sudo wget -q https://raw.githubusercontent.com/jgraph/drawio-desktop/dev/icons/icon512.png -O "$ICON_PATH"

  echo "[INFO] Updating icon cache..."
  sudo gtk-update-icon-cache /usr/share/icons/hicolor
else
  echo "[INFO] draw.io icon already present."
fi

echo "[DONE] draw.io installation and icon setup completed."

