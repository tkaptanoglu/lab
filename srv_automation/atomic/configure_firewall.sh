#!/bin/bash
# atomic: configure_firewall.sh
# Purpose: Configure a baseline firewall using ufw (Uncomplicated Firewall)

set -euo pipefail

echo "=== Configuring baseline firewall ==="

# Install ufw
sudo apt install -y ufw

# Enable UFW logging
sudo ufw logging on

# Allow essential traffic: SSH by default
sudo ufw allow OpenSSH

# Disable default policies
sudo ufw default deny incoming
sudo ufw default deny outgoing

# Enable UFW if not already enabled
if ! sudo ufw status | grep -q "Status: active"; then
	echo "Enabling UFW..."
	echo "y" | sudo ufw enable
else
	echo "UFW already enabled."
fi

echo "=== Firewall configured successfully ==="

