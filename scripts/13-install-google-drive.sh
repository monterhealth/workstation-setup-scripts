#!/bin/bash

# 06-install-google-drive.sh
# Installs and configures rclone for Google Drive sync on Ubuntu

set -e

RCLONE_MOUNT_DIR="$HOME/GoogleDrive"
SERVICE_NAME="rclone-gdrive"
CONFIG_PATH="$HOME/.config/rclone"
REMOTE_NAME="google_drive_ngrts"

echo "[INFO] Installing rclone..."
sudo apt update
sudo apt install -y rclone fuse

echo "[INFO] Creating mount directory at $RCLONE_MOUNT_DIR..."
mkdir -p "$RCLONE_MOUNT_DIR"

echo "[INFO] rclone is now installed."

echo
echo "=== NEXT STEP ==="
echo "You must now manually configure Google Drive access:"
echo "Run: rclone config"
echo " - Choose 'n' for new remote"
echo " - Name it: $REMOTE_NAME"
echo " - Choose 'drive' as storage type"
echo " - Follow the authentication prompts"
echo
read -p "Press [ENTER] when configuration is completed..."

echo "[INFO] Testing mount command..."
rclone ls "${REMOTE_NAME}:" || { echo "[ERROR] rclone config might be incomplete."; exit 1; }

echo "[INFO] Creating systemd user service for auto-mount..."
mkdir -p "$HOME/.config/systemd/user"

cat <<EOF > "$HOME/.config/systemd/user/${SERVICE_NAME}.service"
[Unit]
Description=Mount Google Drive using rclone
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/rclone mount ${REMOTE_NAME}: $RCLONE_MOUNT_DIR \\
  --vfs-cache-mode writes \\
  --allow-other \\
  --dir-cache-time 72h \\
  --poll-interval 15s \\
  --umask 002 \\
  --uid $(id -u) --gid $(id -g)
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

echo "[INFO] Reloading and enabling rclone mount service..."
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now "${SERVICE_NAME}.service"

echo "[INFO] Enabling lingering so service starts at boot..."
loginctl enable-linger "$USER"

echo "[SUCCESS] Google Drive is now mounted at: $RCLONE_MOUNT_DIR"

