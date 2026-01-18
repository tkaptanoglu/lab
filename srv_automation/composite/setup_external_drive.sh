#!/bin/bash
# composite/setup_external_drive.sh
# Purpose: Mount external drive and expose it over the network

set -euo pipefail

echo "--- Step 1: Mounting external drive (/dev/sda1 -> /mnt/external) ---"
./srv_automation/atomic/mount_external_drive.sh

echo "--- Step 2: Installing Samba ---"
./srv_automation/atomic/install_samba.sh

echo "--- Step 3: Exposing external drive over the network ---"
./srv_automation/atomic/expose_drive_over_network.sh

echo "--- External Drive Setup: COMPLETE ---"

