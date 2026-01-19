#!/bin/bash
# atomic: reboot.sh
# Purpose: Reboot the system

# NOTE:
# This is a destructive atomic so needs to be the final atomic in a workflow.

set -euo pipefail

echo "Rebooting the system..."
sudo reboot

