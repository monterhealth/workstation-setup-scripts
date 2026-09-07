#!/bin/bash

# 05-install-firefox-dev.sh
# Installs Firefox Developer Edition from Mozilla's official APT repository.

set -e

MOZILLA_KEYRING="/etc/apt/keyrings/packages.mozilla.org.asc"
MOZILLA_SOURCE_LIST="/etc/apt/sources.list.d/mozilla.list"
MOZILLA_PIN_FILE="/etc/apt/preferences.d/mozilla"
EXPECTED_FINGERPRINT="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"
LEGACY_INSTALL_DIR="/opt/firefox-devedition"
LEGACY_SYMLINK="/usr/local/bin/firefox-devedition"

echo "[INFO] Installing prerequisites..."
sudo apt update
sudo apt install -y wget ca-certificates gnupg

echo "[INFO] Adding Mozilla APT repository signing key..."
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- \
  | sudo tee "$MOZILLA_KEYRING" > /dev/null
sudo chmod 644 "$MOZILLA_KEYRING"

FINGERPRINT="$(
  gpg --show-keys --with-colons "$MOZILLA_KEYRING" 2>/dev/null \
    | awk -F: '/^fpr:/ { print $10; exit }'
)"
if [[ "$FINGERPRINT" != "$EXPECTED_FINGERPRINT" ]]; then
  echo "[ERROR] Mozilla signing key fingerprint does not match."
  echo "        Expected: $EXPECTED_FINGERPRINT"
  echo "        Received: ${FINGERPRINT:-unknown}"
  exit 1
fi

echo "[INFO] Adding Mozilla APT repository..."
echo "deb [signed-by=$MOZILLA_KEYRING] https://packages.mozilla.org/apt mozilla main" \
  | sudo tee "$MOZILLA_SOURCE_LIST" > /dev/null

echo "[INFO] Pinning Mozilla packages so they take priority over Ubuntu's Firefox packages..."
sudo tee "$MOZILLA_PIN_FILE" > /dev/null <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

echo "[INFO] Installing Firefox Developer Edition..."
sudo apt update
sudo apt install -y firefox-devedition

if [[ -L "$LEGACY_SYMLINK" ]]; then
  echo "[INFO] Removing legacy tarball symlink at $LEGACY_SYMLINK"
  sudo rm -f "$LEGACY_SYMLINK"
fi
if [[ -d "$LEGACY_INSTALL_DIR" ]]; then
  echo "[INFO] Removing legacy tarball install at $LEGACY_INSTALL_DIR"
  sudo rm -rf "$LEGACY_INSTALL_DIR"
fi

echo "[DONE] Firefox Developer Edition is installed and will receive updates via APT."
echo "You can launch it via your application menu or with the command: firefox-devedition"
