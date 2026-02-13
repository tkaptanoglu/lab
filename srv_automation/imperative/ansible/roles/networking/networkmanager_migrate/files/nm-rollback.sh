#!/usr/bin/env bash
set -euo pipefail

log() { echo "[rollback] $*"; logger -t nm-rollback -- "$*"; }

log "rolling back to systemd-networkd"

# Re-enable networkd
systemctl enable systemd-networkd.service systemd-networkd.socket || true
systemctl start systemd-networkd.service systemd-networkd.socket || true

# Stop NM (best-effort)
systemctl stop NetworkManager || true
systemctl disable NetworkManager || true

# Remove netplan NM renderer override if it exists (best-effort)
if [ -f /etc/netplan/10-networkmanager-override.yaml ]; then
  rm -f /etc/netplan/10-networkmanager-override.yaml || true
fi

log "netplan generate/apply"
netplan generate || true
netplan apply || true

log "rollback complete"

