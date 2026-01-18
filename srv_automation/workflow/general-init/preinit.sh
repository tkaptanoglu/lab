#!/bin/bash
# workflow: preinit.sh
# Purpose: Initial bootstrap after first boot / cloud-init completion

set -euo pipefail

echo "=== Preinit workflow started ==="

echo "--- Step 1/7: Wait for cloud-init to finish ---"
./srv_automation/atomic/wait_for_cloud_init.sh

echo "--- Step 2/7: Update and upgrade system packages ---"
./srv_automation/atomic/update_and_upgrade.sh

echo "--- Step 3/7: Ensure scripts have executable permissions ---"
./srv_automation/composite/bootstrap/set_script_runnable_permissions.sh

# Vault installation is a part of preinit because other scripts will need secrets.
echo "--- Step 4/7: Install Vault (skipping) ---"
#./srv_automation/atomic/install_vault.sh

echo "--- Step 5/7: Enable cgroups (requires reboot) ---"
./srv_automation/atomic/enable_cgroups.sh

echo "--- Step 6/7: Install public SSH key(s) ---"
./srv_automation/atomic/install_ssh_key_from_github.sh

# NOTE:
# enable_cgroups.sh may already reboot the system.
# If it does NOT reboot, this ensures a reboot happens.

echo "--- Step 7/7: Reboot the system ---"
./srv_automation/atomic/reboot.sh

