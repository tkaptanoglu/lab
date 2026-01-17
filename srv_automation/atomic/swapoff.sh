#!/bin/bash
# atomic/swapoff.sh
# Purpose: Disable swap (required for Kubernetes)

set -euo pipefail

echo "Disabling swap..."

# Disable swap immediately (safe if already disabled)
sudo swapoff -a || true

# Comment out any swap entries in /etc/fstab to make it persistent
if grep -qE '^\s*[^#].*\s+swap\s+' /etc/fstab; then
    sudo sed -i.bak '/\sswap\s/s/^/#/' /etc/fstab
fi

# Show current memory and swap status (informational)
free -h || true

echo "Swap disabled."

