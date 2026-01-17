#!/bin/bash
# workflow: preinit.sh
# Purpose: Initial bootstrap after first boot / cloud-init completion

set -euo pipefail

echo "=== Preinit workflow started ==="

echo "--- Step 1/6: Wait for cloud-init to finish ---"
./srv_automation/atomic/wait_for_cloud_init.sh

echo "--- Step 2/6: Update and upgrade system packages ---"
./srv_automation/atomic/update_and_upgrade.sh

echo "--- Step 3/6: Ensure scripts have executable permissions ---"
./srv_automation/composite/set_script_runnable_permissions.sh

# Vault installation is a part of preinit because other scripts will need secrets.
echo "--- Step 4/6: Install Vault ---"
./srv_automation/atomic/install_vault.sh

echo "--- Step 5/6: Enable cgroups (requires reboot) ---"
./srv_automation/atomic/enable_cgroups.sh

# NOTE:
# enable_cgroups.sh may already reboot the system.
# If it does NOT reboot, this ensures a reboot happens.

echo "--- Step 5/6: Reboot the system ---"
./srv_automation/atomic/reboot.sh

