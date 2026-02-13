#!/usr/bin/env bash
set -euo pipefail

log() { echo "[cutover] $*"; logger -t nm-cutover -- "$*"; }

log "starting cutover to NetworkManager"

# Pre-warm NM (safe even if already enabled/started)
systemctl enable NetworkManager || true
systemctl start NetworkManager || true

# Force NM renderer via netplan override already written by Ansible
log "netplan generate/apply"
netplan generate || true
netplan apply || true

# Now stop/disable networkd bits (this may drop SSH, so do it last)
log "stop/disable networkd related units"
systemctl stop systemd-networkd.service systemd-networkd.socket systemd-networkd-wait-online.service 2>/dev/null || true
systemctl disable systemd-networkd.service systemd-networkd.socket systemd-networkd-wait-online.service 2>/dev/null || true

# netplan may create netplan-wpa-wlan0; disable if present
systemctl stop netplan-wpa-wlan0.service 2>/dev/null || true
systemctl disable netplan-wpa-wlan0.service 2>/dev/null || true

log "cutover complete"

