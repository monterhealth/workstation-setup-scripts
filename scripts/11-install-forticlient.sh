#!/bin/bash
# 11-install-openfortivpn.sh
# Installs openfortivpn on Ubuntu 24.04 and sets up global config
# DNS configuration is optional

set -e

echo "[INFO] Installing openfortivpn..."
sudo apt update
sudo apt install -y openfortivpn

# Prompt for VPN details
read -rp "Enter your VPN host (e.g. vpn.bedrijf.nl): " VPN_HOST
read -rp "Enter your VPN port (default: 443): " VPN_PORT
VPN_PORT=${VPN_PORT:-443}
read -rp "Enter your VPN username: " VPN_USER
read -rp "Optional: Enter your VPN DNS IP address (or press Enter to skip): " VPN_DNS

# Validate required inputs
if [[ -z "$VPN_HOST" || -z "$VPN_USER" ]]; then
    echo "[ERROR] VPN host and username are required. Exiting."
    exit 1
fi

echo "[INFO] Creating global openfortivpn config at /etc/openfortivpn/config..."
sudo tee /etc/openfortivpn/config > /dev/null <<EOF
host = ${VPN_HOST}
port = ${VPN_PORT}
username = ${VPN_USER}
# password = your_password_here  # (leave this out for security)
# trusted-cert = <optional-cert-fingerprint>
EOF

sudo chmod 600 /etc/openfortivpn/config
sudo chown root:root /etc/openfortivpn/config

# Optional DNS setup
if [[ -n "$VPN_DNS" ]]; then
    echo "[INFO] Configuring systemd-resolved with custom VPN DNS..."
    sudo sed -i "/^#*DNS=/c\DNS=${VPN_DNS} 8.8.8.8" /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved

    echo "[INFO] Re-link resolv.conf"
    sudo mv /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null || true
    sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
else
    echo "[INFO] No DNS override provided. Skipping DNS configuration."
fi

echo "[DONE] openfortivpn installed and configured."
echo "Run it with: sudo openfortivpn"
echo ""
echo "🔐 Tip: Don't store your password in the config file!"
echo "🔐 Enter it manually when prompted, or use a secure password manager."

