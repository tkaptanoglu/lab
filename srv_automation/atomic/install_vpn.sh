#!/bin/bash
# atomic: install_tailscale_vpn.sh
# Purpose: Install Tailscale VPN and start the service

set -euo pipefail

echo "Installing Tailscale VPN..."
# Install Tailscale using the official install script
curl -fsSL https://tailscale.com/install.sh | sh

echo "Starting Tailscale VPN..."
# Bring up the Tailscale service
sudo tailscale up

echo "Tailscale VPN installed and started."

