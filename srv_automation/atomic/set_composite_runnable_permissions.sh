#!/bin/bash
# atomic: set_composite_runnable_permissions.sh
# Purpose: Ensure all composite scripts are runnable

set -euo pipefail

echo "Setting executable permissions on composite scripts..."

# Make all composite scripts executable.
# Do not fail if no files match or if permissions are already set.

# WARNING: THIS FILE NEEDS TO BE EXECUTABLE ALREADY BEFORE IT CAN RUN.
# If the automation fails to run this script, set it to executable manually by running:
#   sudo chmod +x ./srv_automation/automatic/set*runnable_permissions.sh

sudo chmod +x ./srv_automation/composite/*.sh 2>/dev/null || true

echo "Composite script permissions ensured."

