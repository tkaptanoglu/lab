#!/bin/bash
# atomic/untaint_control_plane_node.sh
# Purpose: Allow scheduling workloads on the control-plane node (master+worker)

set -euo pipefail

echo "Untainting control-plane node to allow scheduling..."

NODE_NAME="$(hostname)"

# Support both taint keys; ignore if not present
kubectl taint nodes "${NODE_NAME}" node-role.kubernetes.io/control-plane- 2>/dev/null || true
kubectl taint nodes "${NODE_NAME}" node-role.kubernetes.io/master- 2>/dev/null || true

echo "Control-plane node untainted."

