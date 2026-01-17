#!/bin/bash
# atomic/install_falco.sh
# Purpose: Install and enable Falco as a persistent systemd service

set -euo pipefail

echo "=== Installing Falco ==="

# Prerequisites
sudo apt update
sudo apt install -y curl gnupg apt-transport-https lsb-release

# Add Falco GPG key
curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg

# Add Falco repository
echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/falcosecurity.list

# Install Falco
sudo apt update
sudo apt install -y falco

# Enable and start service
sudo systemctl enable falco
sudo systemctl start falco

echo "=== Falco installed and running ==="

