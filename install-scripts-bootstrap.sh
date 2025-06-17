#!/bin/bash

# Exit if any command fails
set -e

# Define variables
PROJECTS_DIR="/mnt/data/projects"
REPO_NAME="workstation-setup-scripts"
REPO_URL="https://github.com/yourusername/workstation-setup-scripts.git"  # Replace with your actual repo URL
TARGET_DIR="$PROJECTS_DIR/$REPO_NAME"

# Ensure the base projects directory exists
mkdir -p "$PROJECTS_DIR"

# Install Git if not present
if ! command -v git &> /dev/null; then
    echo "[INFO] Git is not installed. Installing now..."
    sudo apt update
    sudo apt install -y git
else
    echo "[INFO] Git is already installed."
fi

# Clone the setup repository
if [ -d "$TARGET_DIR" ]; then
    echo "[INFO] Directory $TARGET_DIR already exists. Skipping clone."
else
    echo "[INFO] Cloning repository into $TARGET_DIR..."
    git clone "$REPO_URL" "$TARGET_DIR"
fi

# Make all .sh files in the repo executable
echo "[INFO] Making all .sh files in $TARGET_DIR executable..."
find "$TARGET_DIR" -type f -name "*.sh" -exec chmod +x {} \;

echo "[SUCCESS] Bootstrap completed. You can now run the individual install scripts from $TARGET_DIR."

