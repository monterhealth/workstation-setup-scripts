#!/usr/bin/env bash

set -e

echo "=== Installing GIMP ==="

# Update package lists
sudo apt update -y

# Install GIMP via apt (stable, compatible, lowest friction)
sudo apt install -y gimp

echo "=== GIMP installation complete ==="
echo "You can launch GIMP via the application menu or by running: gimp"

