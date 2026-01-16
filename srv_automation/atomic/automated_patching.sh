#!/bin/bash
# atomic: automated_patching.sh
# Purpose: Configure unattended upgrades to install daily security patches automatically

set -euo pipefail

echo "=== Setting up unattended upgrades ==="

echo "Installing unattended-upgrades package"
sudo apt install -y unattended-upgrades

sudo tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

echo "=== Unattended upgrades configured to run daily ==="

