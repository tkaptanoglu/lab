#!/bin/bash
# atomic/install_samba.sh
# Purpose: Install Samba packages (does not configure shares)

set -euo pipefail

echo "Installing Samba..."

sudo apt update
sudo apt install -y samba

# Enable service (does not restart networking, just ensures on-boot)
sudo systemctl enable smbd 2>/dev/null || true
sudo systemctl enable nmbd 2>/dev/null || true

echo "Samba installed."

