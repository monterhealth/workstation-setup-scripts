#!/bin/bash

# 02-install-docker.sh
# Installs Docker Engine and related tools using Docker's official APT repository.

set -e

echo ">>> Removing old Docker versions (if any)..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true

echo ">>> Installing required packages..."
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

echo ">>> Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo ">>> Setting up Docker APT repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo ">>> Updating package index..."
sudo apt update

echo ">>> Installing Docker Engine and components..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ">>> Adding user '$USER' to docker group..."
sudo usermod -aG docker "$USER"

echo ">>> Testing Docker installation..."
sudo docker run --rm hello-world

echo ">>> Docker installation complete!"
echo ">>> You may need to log out and log back in for Docker group changes to take effect."

