#!/bin/bash
# atomic/expose_drive_over_network.sh
# Purpose: Expose /mnt/external over Samba (SMB) and make it reachable over Tailscale.
#
# Approach:
# - Configure Samba share: \\<ip>\external
# - Keep Samba on LAN/localhost (reliable)
# - Use Tailscale Serve to forward tailnet TCP/445 -> 127.0.0.1:445 (so it works off-LAN)

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
    echo "Resetting any previous Tailscale Serve config..."
    # reset can print output; keep script non-interactive
    sudo tailscale serve reset < /dev/null >/dev/null 2>&1 || true

    echo "Enabling Tailscale Serve TCP forwarder: tailnet:445 -> 127.0.0.1:445 ..."
    # IMPORTANT: --bg prevents the CLI from prompting / hanging.
    # Redirect stdin from /dev/null to guarantee non-interactive behavior.
    if ! sudo tailscale serve --bg --tcp 445 tcp://127.0.0.1:445 < /dev/null; then
      echo "ERROR: Failed to enable tailscale serve for TCP/445."
      echo "Try running manually: sudo tailscale serve --bg --tcp 445 tcp://127.0.0.1:445"
      exit 1
    fi

    echo "Confirming Tailscale Serve status..."
    if ! tailscale serve status 2>/dev/null | grep -q "tcp.*445"; then
      echo "ERROR: tailscale serve did not register a TCP/445 handler."
      echo "Run: tailscale serve status"
      exit 1
    fi

    echo "Tailscale SMB access should work from Windows as:"
    echo "  \\\\${TAILSCALE_IP}\\${SHARE_NAME}"
  else
    echo "tailscale0 present but no IPv4 detected; skipping Tailscale Serve."
  fi
else
  echo "Tailscale not present; skipping Tailscale Serve."
fi

echo "Drive exposure over Samba complete."

