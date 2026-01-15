#!/bin/bash
# workflow: preinit.sh
# Purpose: Initial bootstrap after first boot / cloud-init completion

set -euo pipefail

echo "=== Preinit workflow started ==="

echo "--- Step 1/5: Wait for cloud-init to finish ---"
./srv_automation/atomic/wait_for_cloud_init.sh

echo "--- Step 2/5: Update and upgrade system packages ---"
./srv_automation/atomic/upgrade_and_update.sh

echo "--- Step 3/5: Ensure scripts have executable permissions ---"
./srv_automation/composite/set_script_runable_permissions.sh

echo "--- Step 4/5: Enable cgroups (requires reboot) ---"
./srv_automation/atomic/enable_cgroups.sh

# NOTE:
# enable_cgroups.sh may already reboot the system.
# If it does NOT reboot, this ensures a reboot happens.

echo "--- Step 5/5: Reboot the system ---"
./srv_automation/atomic/reboot.sh

