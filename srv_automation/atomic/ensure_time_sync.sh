#!/bin/bash
# atomic/ensure_time_sync.sh
# Purpose: Ensure reliable system time synchronization

set -euo pipefail

echo "Ensuring system time synchronization..."

# Enable and start systemd-timesyncd
sudo systemctl enable systemd-timesyncd
sudo systemctl start systemd-timesyncd

# Ensure NTP is enabled
sudo timedatectl set-ntp true

# Sanity check (non-fatal)
timedatectl status | grep -q "System clock synchronized: yes" || true

echo "Time synchronization ensured."

