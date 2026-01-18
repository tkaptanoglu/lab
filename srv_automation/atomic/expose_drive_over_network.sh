#!/bin/bash
# atomic/expose_drive_over_network.sh
# Purpose: Export /mnt/external over NFS (Tailscale-preferred, wlan0 acceptable)

set -euo pipefail

echo "Exposing /mnt/external over NFS..."

EXPORT_DIR="/mnt/external"
EXPORTS_FILE="/etc/exports.d/srv_automation_external.exports"

if ! mountpoint -q "$EXPORT_DIR"; then
  echo "ERROR: $EXPORT_DIR is not mounted. Run mount_external_drive.sh first."
  exit 1
fi

echo "Installing NFS server..."
sudo apt update
sudo apt install -y nfs-kernel-server

# Determine allowed CIDRs
ALLOW_CIDRS=()

# Prefer Tailscale network if tailscale0 exists and has an IPv4
if ip -o -4 addr show dev tailscale0 >/dev/null 2>&1; then
  # Tailscale generally uses 100.64.0.0/10
  ALLOW_CIDRS+=("100.64.0.0/10")
fi

# Also allow wlan0 subnet if present (best-effort)
WLAN_SUBNET="$(ip -o -4 route show dev wlan0 2>/dev/null | awk '{print $1}' | head -n 1 || true)"
if [ -n "${WLAN_SUBNET}" ]; then
  ALLOW_CIDRS+=("${WLAN_SUBNET}")
fi

if [ "${#ALLOW_CIDRS[@]}" -eq 0 ]; then
  echo "ERROR: Could not detect tailscale0 or wlan0 subnet. Refusing to export to 0.0.0.0/0."
  exit 1
fi

# Build exports content (conservative options)
# - rw,sync,no_subtree_check
# - root_squash for safety (avoid giving root on clients root on server)
EXPORTS_CONTENT=""
for cidr in "${ALLOW_CIDRS[@]}"; do
  EXPORTS_CONTENT+="${EXPORT_DIR} ${cidr}(rw,sync,no_subtree_check,root_squash)\n"
done

echo "Writing NFS exports to $EXPORTS_FILE..."
printf "%b" "$EXPORTS_CONTENT" | sudo tee "$EXPORTS_FILE" > /dev/null

# Apply exports
sudo exportfs -ra

# Enable and start NFS server
sudo systemctl enable --now nfs-server

echo "NFS export configured. Current exports:"
sudo exportfs -v

