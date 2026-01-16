#!/bin/bash
# atomic: configure_dns.sh
# Purpose: Ensure DNS is configured correctly using systemd-resolved

set -euo pipefail

echo "=== Configuring DNS (systemd-resolved) ==="

# Ensure systemd-resolved is enabled and running
sudo systemctl enable systemd-resolved
sudo systemctl start systemd-resolved

# Ensure /etc/resolv.conf is the correct symlink
RESOLV_CONF_TARGET="/run/systemd/resolve/stub-resolv.conf"

if [ -L /etc/resolv.conf ]; then
	CURRENT_TARGET=$(readlink -f /etc/resolv.conf)
else
	CURRENT_TARGET=""
fi

if [ "$CURRENT_TARGET" != "$RESOLV_CONF_TARGET" ]; then
	echo "Fixing /etc/resolv.conf symlink..."
	sudo ln -sf "$RESOLV_CONF_TARGET" /etc/resolv.conf
else
	echo "/etc/resolv.conf is already correctly configured."
fi

echo "=== DNS configuration complete ==="

