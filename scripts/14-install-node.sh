#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y curl build-essential

echo "[INFO] Installing NVM..."
if [ ! -d "$HOME/.nvm" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
  echo "[INFO] NVM already installed, skipping."
fi

export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "[INFO] Installing latest Node.js LTS..."
if ! nvm ls --no-colors | grep -q 'lts/*'; then
  nvm install --lts
fi

nvm use --lts
nvm alias default lts/*

echo "[INFO] Installation complete."
echo " Node: $(node -v)"
echo " npm:  $(npm -v)"

