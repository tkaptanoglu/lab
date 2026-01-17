#!/bin/bash
# atomic/enable_persistent_journald.sh
# Purpose: Ensure systemd-journald logs persist across reboots

set -euo pipefail

echo "Enabling persistent journald logging..."

# Create persistent log directory
sudo mkdir -p /var/log/journal

# Set correct permissions
sudo systemd-tmpfiles --create --prefix /var/log/journal

# Ensure journald uses persistent storage
JOURNALD_CONF="/etc/systemd/journald.conf"

sudo sed -i \
  -e 's/^#\?Storage=.*/Storage=persistent/' \
  "$JOURNALD_CONF"

# Restart journald to apply changes
sudo systemctl restart systemd-journald

echo "Persistent journald logging enabled."

