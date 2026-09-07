#!/bin/bash

# 02-install-docker.sh
# Installs Docker Engine from Docker's official APT repository.

set -e

echo ">>> Removing conflicting Docker packages (if any)..."
sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc || true

echo ">>> Installing required packages..."
sudo apt update
sudo apt install -y ca-certificates curl

echo ">>> Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo rm -f /etc/apt/keyrings/docker.gpg

echo ">>> Setting up Docker APT repository..."
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo rm -f /etc/apt/sources.list.d/docker.list

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
