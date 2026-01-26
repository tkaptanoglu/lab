#/bin/bash
# composite: set_script_runnable_permissions.sh
# Purpose: Ensure all automation scripts are executable (atomics, composites, workflows)

set -euo pipefail

echo "=== Setting runnable permissions for automation scripts ==="

echo "--- Atomics ---"
./srv_automation/imperative/shell/atomic/bootstrap/set_atomic_runnable_permissions.sh

echo "--- Composites ---"
./srv_automation/imperative/shell/atomic/bootstrap/set_composite_runnable_permissions.sh

echo "--- Workflows ---"
./srv_automation/imperative/shell/atomic/bootstrap/set_workflow_runnable_permissions.sh

echo "=== Finished setting runnable permissions ==="

