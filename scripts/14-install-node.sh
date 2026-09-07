#!/usr/bin/env bash
# 14-install-node.sh
# Installs nvm and the latest Node.js LTS.

set -euo pipefail

NVM_FALLBACK_VERSION="v0.40.7"

echo "[INFO] Installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y curl ca-certificates build-essential

echo "[INFO] Determining latest nvm release..."
NVM_VERSION="$(
  curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest \
    | sed -n 's/.*"tag_name": "\([^"]*\)".*/\1/p' \
    | head -n 1
)"
NVM_VERSION="${NVM_VERSION:-$NVM_FALLBACK_VERSION}"

echo "[INFO] Installing nvm ${NVM_VERSION}..."
curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash

export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

echo "[INFO] Installing latest Node.js LTS..."
nvm install --lts
nvm alias default 'lts/*'
nvm use default

echo "[INFO] Installation complete."
echo " nvm:  $(nvm --version)"
echo " Node: $(node -v)"
echo " npm:  $(npm -v)"
