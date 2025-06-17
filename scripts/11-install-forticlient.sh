#!/bin/bash
# 11-install-forticlient.sh
# Installs FortiClient VPN on Ubuntu 24.04 with DNS resolution fix
# https://community.fortinet.com/t5/Support-Forum/Ubuntu-24-04-Forticlient-VPN-installation-w-DNS-resolution-fix/td-p/312896
set -e

# Prompt for VPN DNS
read -rp "Enter your VPN DNS IP address (e.g. 10.0.0.1): " VPN_DNS

# Validate input
if [[ -z "$VPN_DNS" ]]; then
    echo "[ERROR] No VPN DNS provided. Exiting."
    exit 1
fi

echo "[INFO] Adding universe repository and FortiClient source..."
sudo add-apt-repository -y universe
wget -qO- https://repo.fortinet.com/repo/forticlient/7.4/ubuntu22/DEB-GPG-KEY | sudo apt-key add -
sudo add-apt-repository -y "deb https://repo.fortinet.com/repo/forticlient/7.4/ubuntu22/ stable non-free"
sudo apt update

echo "[INFO] Installing FortiClient VPN..."
if ! sudo apt install -y forticlient; then
    echo "[WARN] Installation failed — attempting manual vendoring of dependencies."
    wget http://mirrors.kernel.org/ubuntu/pool/universe/liba/libappindicator/libappindicator1_12*.deb
    wget http://mirrors.kernel.org/ubuntu/pool/universe/libd/libdbusmenu/libdbusmenu-gtk4_16*.deb
    sudo apt install -y ./libappindicator1_*.deb ./libdbusmenu-gtk4_*.deb
    sudo apt install -f -y
fi

echo "[INFO] Configuring DNS via systemd-resolved..."
sudo sed -i "/^#*DNS=/c\DNS=${VPN_DNS} 8.8.8.8" /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved

echo "[INFO] Re-link resolv.conf"
sudo mv /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null || true
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

echo "[DONE] FortiClient VPN installed. Start it via menu or with the 'forticlient' command."

