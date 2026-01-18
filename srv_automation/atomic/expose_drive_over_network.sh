#!/bin/bash
# atomic/expose_drive_over_network.sh
# Purpose: Expose /mnt/external over the network via Samba (SMB) for Windows access,
#          with Tailscale access preferred (bind to tailscale0 if present).

set -euo pipefail

echo "Exposing /mnt/external over Samba..."

SHARE_PATH="/mnt/external"
SHARE_NAME="external"
SMB_CONF="/etc/samba/smb.conf"
MARK_BEGIN="### srv_automation: external share BEGIN"
MARK_END="### srv_automation: external share END"

# Preconditions
if ! mountpoint -q "$SHARE_PATH"; then
  echo "ERROR: $SHARE_PATH is not mounted. Run mount_external_drive.sh first."
  exit 1
fi

# Ensure Samba is installed (safe if already installed)
sudo apt update
sudo apt install -y samba

# Backup config once
if [ ! -f "${SMB_CONF}.bak_srv_automation" ]; then
  sudo cp -a "$SMB_CONF" "${SMB_CONF}.bak_srv_automation"
fi

# Remove any previous srv_automation share block (idempotent)
if sudo grep -qF "$MARK_BEGIN" "$SMB_CONF"; then
  sudo sed -i "/$MARK_BEGIN/,/$MARK_END/d" "$SMB_CONF"
fi

# Append srv_automation share block (auth required; no guest)
sudo tee -a "$SMB_CONF" > /dev/null <<EOF

${MARK_BEGIN}
[${SHARE_NAME}]
   path = ${SHARE_PATH}
   browseable = yes
   read only = no
   guest ok = no
   valid users = ${USER}
   create mask = 0664
   directory mask = 0775
${MARK_END}
EOF

# Build interface binding using interface NAMES (works better with tailscale /32)
IFACES=("lo")

if ip link show tailscale0 >/dev/null 2>&1; then
  IFACES+=("tailscale0")
fi

if ip link show wlan0 >/dev/null 2>&1; then
  IFACES+=("wlan0")
fi

# If we have more than just lo, enforce binding
if [ "${#IFACES[@]}" -gt 1 ]; then
  echo "Configuring Samba to listen on interfaces: ${IFACES[*]}"

  # Replace or insert 'interfaces = ...'
  if sudo grep -qE '^\s*interfaces\s*=' "$SMB_CONF"; then
    sudo sed -i "s|^\s*interfaces\s*=.*|   interfaces = ${IFACES[*]}|" "$SMB_CONF"
  else
    sudo sed -i "/^\[global\]/a\\
   interfaces = ${IFACES[*]}
" "$SMB_CONF"
  fi

  # Replace or insert 'bind interfaces only = yes'
  if sudo grep -qE '^\s*bind interfaces only\s*=' "$SMB_CONF"; then
    sudo sed -i "s|^\s*bind interfaces only\s*=.*|   bind interfaces only = yes|" "$SMB_CONF"
  else
    sudo sed -i "/^\[global\]/a\\
   bind interfaces only = yes
" "$SMB_CONF"
  fi
else
  echo "No tailscale0 or wlan0 detected; not restricting Samba interfaces."
fi

# Validate Samba config before restart
echo "Validating Samba config..."
sudo testparm -s > /dev/null

# Enable and restart Samba services
sudo systemctl enable smbd >/dev/null 2>&1 || true
sudo systemctl restart smbd
sudo systemctl enable nmbd >/dev/null 2>&1 || true
sudo systemctl restart nmbd

# Verify listeners
echo "Verifying Samba listeners..."
sudo ss -tlnp | grep smbd || true

# Ensure it's listening on the Tailscale IP (if tailscale0 exists)
TAILSCALE_IP="$(ip -o -4 addr show dev tailscale0 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1 || true)"
if [ -n "$TAILSCALE_IP" ]; then
  if ! sudo ss -tlnp | grep -q "${TAILSCALE_IP}:445"; then
    echo "ERROR: smbd is not listening on Tailscale IP ${TAILSCALE_IP}:445"
    echo "Next checks:"
    echo "  - Confirm tailscale0 has the IP: ip -4 addr show tailscale0"
    echo "  - Confirm smb.conf [global] has: interfaces = lo tailscale0 [wlan0] and bind interfaces only = yes"
    exit 1
  fi
fi

WLAN_IP="$(ip -o -4 addr show dev wlan0 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1 || true)"

echo "Samba share configured:"
echo "  From Windows (Tailscale): \\\\${TAILSCALE_IP:-<tailscale-ip>}\\${SHARE_NAME}"
echo "  From Windows (LAN):       \\\\${WLAN_IP:-<lan-ip>}\\${SHARE_NAME}"
echo "NOTE: You must create a Samba password for your user (one-time):"
echo "  sudo smbpasswd -a ${USER}"

echo "Drive exposure over Samba complete."

