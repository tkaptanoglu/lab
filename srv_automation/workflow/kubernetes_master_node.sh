#!/bin/bash
# workflow/kubernetes_master_node.sh
# Purpose: Turn a Kubernetes-ready node into a control-plane node that can also schedule workloads,
#          and is ready for other workers to join.
#
# Assumes: workflow/kubernetes_readiness.sh has already been run.

set -euo pipefail

echo "=== Kubernetes Master Node Workflow: START ==="

echo "--- Step 1/4: Initializing Kubernetes control plane ---"
./srv_automation/composite/kubeadm_init_control_plane.sh

echo "--- Step 2/4: Installing Flannel CNI ---"
./srv_automation/atomic/install_flannel_cni.sh

echo "--- Step 3/4: Allow scheduling on this node (untaint) ---"
./srv_automation/atomic/untaint_control_plane_node.sh

echo "--- Step 4/4: Printing worker join command ---"
./srv_automation/composite/print_worker_join_command.sh

echo "=== Kubernetes Master Node Workflow: COMPLETE ==="

