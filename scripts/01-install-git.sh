#!/bin/bash

# 01-install-git.sh
# Installs Git and sets global username and email if desired

set -e

echo "Installing Git..."
sudo apt update
sudo apt install -y git

# Optional: configure Git globally (uncomment to use)
# echo "Setting global Git username and email..."
# git config --global user.name "Your Name"
# git config --global user.email "you@example.com"

echo "Git installation completed."

