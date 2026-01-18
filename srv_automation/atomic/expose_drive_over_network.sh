#!/bin/bash
# atomic/expose_drive_over_network.sh
# Purpose: Expose /mnt/external over the network via Samba (SMB) for Windows access

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

# Determine which interface to bind to (Tailscale preferred)
BIND_INTERFACES=()
if ip link show tailscale0 >/dev/null 2>&1; then
  BIND_INTERFACES+=("tailscale0")
fi
if ip link show wlan0 >/dev/null 2>&1; then
  BIND_INTERFACES+=("wlan0")
fi

# Resolve interface IPs (best effort). If none, we won't restrict interfaces.
BIND_IPS=()
for ifc in "${BIND_INTERFACES[@]}"; do
  ip4="$(ip -o -4 addr show dev "$ifc" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1 || true)"
  if [ -n "$ip4" ]; then
    BIND_IPS+=("$ip4")
  fi
done

# Backup config once
if [ ! -f "${SMB_CONF}.bak_srv_automation" ]; then
  sudo cp -a "$SMB_CONF" "${SMB_CONF}.bak_srv_automation"
fi

# Remove any previous srv_automation block (idempotent)
if sudo grep -qF "$MARK_BEGIN" "$SMB_CONF"; then
  sudo sed -i "/$MARK_BEGIN/,/$MARK_END/d" "$SMB_CONF"
fi

# Build the share block
# - Auth required (guest ok = no)
# - Uses filesystem permissions (force user/group not set)
# - create/directory masks are reasonable defaults
SHARE_BLOCK=""
SHARE_BLOCK+="${MARK_BEGIN}\n"
SHARE_BLOCK+="[${SHARE_NAME}]\n"
SHARE_BLOCK+="   path = ${SHARE_PATH}\n"
SHARE_BLOCK+="   browseable = yes\n"
SHARE_BLOCK+="   read only = no\n"
SHARE_BLOCK+="   guest ok = no\n"
SHARE_BLOCK+="   valid users = @${USER}\n"
SHARE_BLOCK+="   create mask = 0664\n"
SHARE_BLOCK+="   directory mask = 0775\n"
SHARE_BLOCK+="${MARK_END}\n"

# Note on valid users:
# Samba "valid users" expects samba users; group syntax differs across setups.
# Using a single user is the least surprising; we will allow the current user explicitly.
# We'll append a safer line below if needed.

# Append block
printf "%b" "$SHARE_BLOCK" | sudo tee -a "$SMB_CONF" > /dev/null

# If you prefer to allow the current user explicitly (more reliable than @group):
# Replace the 'valid users' line to be just the username (idempotent)
sudo sed -i "s/^\(\s*valid users =\).*/\1 ${USER}/" "$SMB_CONF"

# Optional: restrict Samba to specific interfaces if we have IPs
# This minimizes exposure and matches your "Tailscale preferred" requirement.
if [ "${#BIND_IPS[@]}" -gt 0 ]; then
  echo "Configuring Samba to listen on: ${BIND_INTERFACES[*]} (IPs: ${BIND_IPS[*]})"
  # Ensure [global] has interfaces/bind only
  # Add if missing; otherwise replace.
  if sudo grep -qE '^\s*interfaces\s*=' "$SMB_CONF"; then
    sudo sed -i "s/^\s*interfaces\s*=.*/   interfaces = ${BIND_IPS[*]} ${BIND_INTERFACES[*]}/" "$SMB_CONF"
  else
    sudo sed -i "/^\[global\]/a\\
   interfaces = ${BIND_IPS[*]} ${BIND_INTERFACES[*]}\\
   bind interfaces only = yes\\
" "$SMB_CONF"
  fi
else
  echo "No tailscale0/wlan0 IPv4 detected; not restricting Samba interfaces."
fi

# Validate Samba config before restart
echo "Validating Samba config..."
sudo testparm -s > /dev/null

# Enable and restart Samba services
sudo systemctl enable smbd 2>/dev/null || true
sudo systemctl restart smbd
sudo systemctl enable nmbd 2>/dev/null || true
sudo systemctl restart nmbd

echo "Samba share configured: \\\\$(hostname)\\${SHARE_NAME}"
echo "From Windows: \\\\SERVER_IP\\${SHARE_NAME}"
echo "NOTE: You must create a Samba password for your user (one-time):"
echo "  sudo smbpasswd -a ${USER}"
echo "Then access from Windows with username '${USER}'."

echo "Drive exposure over Samba complete."

