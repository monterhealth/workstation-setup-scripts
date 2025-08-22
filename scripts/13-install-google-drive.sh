#!/usr/bin/env bash
# 06-install-google-drive.sh
# Hardened rclone setup for Google Drive:
# - Reliable two-way sync via rclone bisync + systemd user timer
# - Optional: stable rclone mount unit + healthcheck
# NOTE: Keep code/comments in English per team convention.

set -euo pipefail

### ====== USER SETTINGS ======
REMOTE_NAME="google_drive_ngrts"        # rclone remote name (must exist via `rclone config`)
REMOTE_SUBPATH="MonterSync"              # remote subfolder to sync to
LOCAL_DIR="$HOME/GoogleDriveLocal"       # local folder to keep in sync
ENABLE_MOUNT=false                       # set to true to also create a mount (optional)
MOUNT_DIR="$HOME/GoogleDrive"            # where to mount the remote (if ENABLE_MOUNT=true)
BISYNC_INTERVAL_MIN=10                   # how often bisync runs
LOG_DIR="$HOME/.local/share/rclone"
CACHE_DIR="$HOME/.cache/rclone"
SERVICE_BISYNC="rclone-bisync"
SERVICE_MOUNT="rclone-gdrive"
SERVICE_HEALTH="rclone-gdrive-health"
### ===========================

echo "[INFO] Installing rclone (and fuse3 for modern systems)..."
sudo apt update -y
sudo apt install -y rclone fuse3 || sudo apt install -y rclone fuse

mkdir -p "$LOCAL_DIR" "$LOG_DIR" "$CACHE_DIR"

echo "[INFO] Verifying rclone remote '$REMOTE_NAME'..."
if ! rclone lsd "${REMOTE_NAME}:" >/dev/null 2>&1; then
  echo "[ERROR] rclone remote '$REMOTE_NAME' not usable yet."
  echo "        Run: rclone config   (create a 'drive' remote named: $REMOTE_NAME)"
  exit 1
fi

echo "[INFO] Ensuring remote subpath exists: ${REMOTE_NAME}:${REMOTE_SUBPATH}"
rclone mkdir "${REMOTE_NAME}:${REMOTE_SUBPATH}" || true

### ----- BISYNC: systemd user service + timer -----
echo "[INFO] Creating systemd user service for rclone bisync..."
mkdir -p "$HOME/.config/systemd/user"

cat > "$HOME/.config/systemd/user/${SERVICE_BISYNC}.service" <<EOF
[Unit]
Description=Rclone bisync Google Drive <-> Local

[Service]
Type=oneshot
ExecStart=/usr/bin/rclone bisync "%h/GoogleDriveLocal" "${REMOTE_NAME}:${REMOTE_SUBPATH}" \
  --create-empty-src-dirs \
  --track-renames \
  --check-access \
  --tpslimit 10 --tpslimit-burst 10 \
  --drive-stop-on-upload-limit \
  --log-file "%h/.local/share/rclone/bisync.log" \
  --log-level INFO
EOF

cat > "$HOME/.config/systemd/user/${SERVICE_BISYNC}.timer" <<EOF
[Unit]
Description=Run rclone bisync every ${BISYNC_INTERVAL_MIN} minutes

[Timer]
OnBootSec=2m
OnUnitActiveSec=${BISYNC_INTERVAL_MIN}m
Unit=${SERVICE_BISYNC}.service
Persistent=true

[Install]
WantedBy=timers.target
EOF

### ----- Optional MOUNT: stable unit + healthcheck -----
if [ "$ENABLE_MOUNT" = true ]; then
  echo "[INFO] Creating robust rclone mount service..."
  mkdir -p "$MOUNT_DIR"

  # Ensure allow_other is permitted; harmless if already present
  if ! grep -q '^user_allow_other' /etc/fuse.conf 2>/dev/null; then
    echo "[INFO] Adding 'user_allow_other' to /etc/fuse.conf (sudo)..."
    echo "user_allow_other" | sudo tee -a /etc/fuse.conf >/dev/null
  fi

  cat > "$HOME/.config/systemd/user/${SERVICE_MOUNT}.service" <<'EOF'
[Unit]
Description=Mount Google Drive via rclone (stable)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
# Ensure mount dir exists
ExecStartPre=/usr/bin/bash -lc 'mkdir -p "$HOME/GoogleDrive"'
ExecStart=/usr/bin/rclone mount google_drive_ngrts: "$HOME/GoogleDrive" \
  --vfs-cache-mode full \
  --vfs-cache-max-size 10G \
  --vfs-cache-max-age 168h \
  --dir-cache-time 72h \
  --attr-timeout 1s \
  --poll-interval 15s \
  --tpslimit 10 \
  --tpslimit-burst 10 \
  --drive-stop-on-upload-limit \
  --uid %U --gid %G \
  --umask 002 \
  --allow-other \
  --cache-dir "$HOME/.cache/rclone"
ExecStop=/bin/fusermount -uz "$HOME/GoogleDrive"
Restart=always
RestartSec=5
TimeoutStopSec=20

[Install]
WantedBy=default.target
EOF

  echo "[INFO] Creating mount healthcheck (restart on failure via OnFailure)..."

  # Healthcheck service: fails if listing the mount times out -> triggers restart
  cat > "$HOME/.config/systemd/user/${SERVICE_HEALTH}.service" <<EOF
[Unit]
Description=Healthcheck for rclone mount
OnFailure=${SERVICE_MOUNT}.service

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -lc 'timeout 10 bash -lc "ls -1 \\"$MOUNT_DIR\\" >/dev/null"'
EOF

  cat > "$HOME/.config/systemd/user/${SERVICE_HEALTH}.timer" <<EOF
[Unit]
Description=Run rclone mount healthcheck every 5 minutes

[Timer]
OnBootSec=3m
OnUnitActiveSec=5m
Unit=${SERVICE_HEALTH}.service
Persistent=true

[Install]
WantedBy=timers.target
EOF
fi

### ----- Enable units -----
echo "[INFO] Reloading user systemd and enabling units..."
systemctl --user daemon-reload
systemctl --user enable --now "${SERVICE_BISYNC}.timer"

if [ "$ENABLE_MOUNT" = true ]; then
  systemctl --user enable --now "${SERVICE_MOUNT}.service"
  systemctl --user enable --now "${SERVICE_HEALTH}.timer"
fi

echo "[INFO] Enabling lingering so user services start at boot..."
loginctl enable-linger "$USER" || true

### ----- First sync safety: offer resync once if state absent -----
STATE_DIR="$LOCAL_DIR/.rclone-bisync"
if [ ! -d "$STATE_DIR" ]; then
  echo "[INFO] Running initial safe resync (one-time)..."
  rclone bisync "$LOCAL_DIR" "${REMOTE_NAME}:${REMOTE_SUBPATH}" \
    --resync \
    --create-empty-src-dirs \
    --track-renames \
    --check-access \
    --tpslimit 10 --tpslimit-burst 10 \
    --drive-stop-on-upload-limit \
    --log-file "$LOG_DIR/bisync-initial.log" \
    --log-level INFO || true
fi

echo
echo "[SUCCESS] Setup complete."
echo "- Bisync runs every ${BISYNC_INTERVAL_MIN} min:  systemctl --user status ${SERVICE_BISYNC}.timer"
if [ "$ENABLE_MOUNT" = true ]; then
  echo "- Mount at: $MOUNT_DIR   (logs: journalctl --user -u ${SERVICE_MOUNT} -f)"
fi
echo "- Bisync log: $LOG_DIR/bisync.log"
echo "- Tip: Use your own Google API client_id/secret in 'rclone config' (reduces throttling)."

