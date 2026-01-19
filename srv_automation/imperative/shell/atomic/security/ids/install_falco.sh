#!/bin/bash
# atomic/security/ids/install_falco.sh
# Installs Falco from the official Falco DEB repository and enables it as a systemd service.
# Uses the Modern eBPF driver and keeps falcoctl rules updates enabled.

set -euo pipefail

echo "Installing Falco (Modern eBPF) ..."

# Step 1: Add Falco repository key (idempotent)
if [ ! -f /usr/share/keyrings/falco-archive-keyring.gpg ]; then
  echo "--- Step 1: Adding Falco repository key ---"
  curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg
else
  echo "--- Step 1: Falco repository key already present ---"
fi

# Step 2: Add Falco apt repo (idempotent)
FALCO_LIST="/etc/apt/sources.list.d/falcosecurity.list"
FALCO_LINE="deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main"

echo "--- Step 2: Ensuring Falco apt repository is configured ---"
if [ ! -f "${FALCO_LIST}" ]; then
  echo "${FALCO_LINE}" | sudo tee "${FALCO_LIST}" >/dev/null
else
  if ! grep -qF "${FALCO_LINE}" "${FALCO_LIST}"; then
    echo "${FALCO_LINE}" | sudo tee -a "${FALCO_LIST}" >/dev/null
  fi
fi

# Step 3: Update apt metadata
echo "--- Step 3: apt update ---"
sudo apt-get update -y

# Step 4: Install Falco non-interactively, explicitly selecting modern_ebpf and leaving falcoctl enabled
#    (These env vars are documented for DEB/RPM installs and avoid the dialog prompts.)
echo "--- Step 4: Installing Falco package (non-interactive, modern_ebpf) ---"
sudo env \
  FALCO_FRONTEND=noninteractive \
  FALCO_DRIVER_CHOICE=modern_ebpf \
  apt-get install -y falco

# Step 5: Enable + start the Falco modern eBPF service
echo "--- Step 5: Enabling and starting falco-modern-bpf.service ---"
sudo systemctl enable falco-modern-bpf.service >/dev/null 2>&1 || true
sudo systemctl restart falco-modern-bpf.service

# Step 6: Verify
echo "--- Step 6: Verifying Falco service is running ---"
sudo systemctl --no-pager --full status falco-modern-bpf.service

echo "Falco installation complete."
echo "Tip: View warnings with: sudo journalctl _COMM=falco -p warning --no-pager"

