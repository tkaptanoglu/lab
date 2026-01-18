#!/bin/bash
# atomic/expose_drive_over_network.sh
# Purpose: Expose /mnt/external over Samba (SMB) and make it reachable over Tailscale.
#
# Key idea:
# - Samba listens on localhost/LAN (works reliably)
# - Tailscale Serve forwards tailnet TCP/445 -> localhost:445
#   so \\100.x.y.z\external works from anywhere on your tailnet.

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

# Ensure Samba is installed
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

# Validate Samba config before restart
echo "Validating Samba config..."
sudo testparm -s > /dev/null

# Enable and restart Samba services
sudo systemctl enable smbd >/dev/null 2>&1 || true
sudo systemctl enable nmbd >/dev/null 2>&1 || true
sudo systemctl restart smbd
sudo systemctl restart nmbd

echo "Verifying Samba listeners (local/LAN)..."
sudo ss -tlnp | grep smbd || true

echo "NOTE: You must create a Samba password for your user (one-time):"
echo "  sudo smbpasswd -a ${USER}"

# --- Tailscale exposure: forward tailnet TCP/445 to localhost:445 ---
if command -v tailscale >/dev/null 2>&1 && ip link show tailscale0 >/dev/null 2>&1; then
  TAILSCALE_IP="$(ip -o -4 addr show dev tailscale0 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1 || true)"
  if [ -n "$TAILSCALE_IP" ]; then
    echo "Enabling Tailscale Serve TCP forwarder: tailnet:445 -> localhost:445 ..."
    # This publishes port 445 on the tailnet and forwards to local smbd.
    # (Idempotent: re-running overwrites the same serve config.)
    sudo tailscale serve --tcp 445 tcp://localhost:445

    echo "Tailscale SMB access should work from Windows as:"
    echo "  \\\\${TAILSCALE_IP}\\${SHARE_NAME}"
  else
    echo "tailscale0 present but no IPv4 detected; skipping tailscale serve."
  fi
else
  echo "Tailscale not present; skipping tailscale serve."
fi

echo "Drive exposure over Samba complete."

