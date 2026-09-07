#!/usr/bin/env bash
# 13-install-redis-insight.sh
# Installs or updates Redis Insight from the latest GitHub release.

set -euo pipefail

PACKAGE_NAME="redisinsight"

echo "[INFO] Installing prerequisites..."
sudo apt update
sudo apt install -y curl ca-certificates jq

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
  amd64) DEB_NAME="Redis-Insight-linux-amd64.deb" ;;
  arm64) DEB_NAME="Redis-Insight-linux-arm64.deb" ;;
  *)
    echo "[ERROR] Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

echo "[INFO] Fetching latest Redis Insight release..."
LATEST_JSON=$(curl -fsSL https://api.github.com/repos/redis/RedisInsight/releases/latest)
LATEST_TAG=$(echo "$LATEST_JSON" | jq -r '.tag_name')
VERSION=${LATEST_TAG#v}

if [[ -z "$LATEST_TAG" || "$LATEST_TAG" == "null" ]]; then
  echo "[ERROR] Could not determine the latest Redis Insight version from GitHub."
  exit 1
fi

DEB_URL=$(echo "$LATEST_JSON" | jq -r --arg name "$DEB_NAME" \
  '.assets[] | select(.name == $name) | .browser_download_url' | head -n 1)
if [[ -z "$DEB_URL" || "$DEB_URL" == "null" ]]; then
  echo "[ERROR] Could not find $DEB_NAME in the latest Redis Insight release."
  exit 1
fi

echo "[INFO] Latest version available: $VERSION"
echo "[INFO] Download URL: $DEB_URL"

INSTALLED_VERSION="$(dpkg-query -W -f='${Version}' "$PACKAGE_NAME" 2>/dev/null || echo none)"
echo "[INFO] Currently installed version: $INSTALLED_VERSION"

if [[ "$INSTALLED_VERSION" == "$VERSION"* ]]; then
  echo "[INFO] You already have Redis Insight $VERSION. No action needed."
else
  TEMP_DEB=$(mktemp --suffix=".deb")
  trap 'rm -f "$TEMP_DEB"' EXIT
  echo "[INFO] Downloading package..."
  curl -fL -o "$TEMP_DEB" "$DEB_URL"
  chmod 644 "$TEMP_DEB"

  echo "[INFO] Installing package..."
  sudo apt install -y "$TEMP_DEB"

  echo "[INFO] Redis Insight has been updated to version $VERSION"
fi

echo "[DONE] Redis Insight is installed. Launch it via your application menu or with: $PACKAGE_NAME"
