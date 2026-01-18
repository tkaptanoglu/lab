#!/bin/bash
# atomic/mount_external_drive.sh
# Purpose: Mount /dev/sda1 at /mnt/external and persist via /etc/fstab (UUID-based)

set -euo pipefail

echo "Mounting external drive (/dev/sda1 -> /mnt/external)..."

DEVICE="/dev/sda1"
MOUNT_POINT="/mnt/external"

# Ensure device exists
if [ ! -b "$DEVICE" ]; then
  echo "ERROR: $DEVICE not found. Check lsblk output."
  exit 1
fi

# Ensure mount point exists
sudo mkdir -p "$MOUNT_POINT"

# If already mounted, do nothing
if mountpoint -q "$MOUNT_POINT"; then
  echo "$MOUNT_POINT is already mounted."
  exit 0
fi

# Get UUID and filesystem type
UUID="$(sudo blkid -s UUID -o value "$DEVICE")"
FSTYPE="$(sudo blkid -s TYPE -o value "$DEVICE")"

if [ -z "$UUID" ] || [ -z "$FSTYPE" ]; then
  echo "ERROR: Could not determine UUID or filesystem type for $DEVICE."
  exit 1
fi

# Add fstab entry if missing (UUID-based)
FSTAB_LINE="UUID=${UUID} ${MOUNT_POINT} ${FSTYPE} defaults,nofail 0 2"
if ! grep -q "UUID=${UUID}" /etc/fstab; then
  echo "Persisting mount in /etc/fstab..."
  echo "$FSTAB_LINE" | sudo tee -a /etc/fstab > /dev/null
else
  echo "fstab entry already exists for UUID=${UUID}."
fi

# Mount it
sudo mount "$MOUNT_POINT"

echo "Mounted $DEVICE at $MOUNT_POINT."
df -h "$MOUNT_POINT" || true

