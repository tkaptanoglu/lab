#!/bin/bash
# workflow/kubernetes_master_node.sh
# Purpose: Turn a Kubernetes-ready node into a control-plane node that can also schedule workloads,
#          and is ready for other workers to join.
#
# Assumes: workflow/kubernetes_readiness.sh has already been run.

set -euo pipefail

echo "=== Kubernetes Master Node Workflow: START ==="


# START: CONTROL PLANE
echo "--- Step 1/4: Initializing Kubernetes control plane ---"
./srv_automation/imperative/shell/composite/k8s/control-plane/kubeadm_init_control_plane.sh

echo "--- Step 2/4: Allow scheduling on this node (untaint) ---"
./srv_automation/imperative/shell/atomic/k8s/control-plane/untaint_control_plane_node.sh
# END: CONTROL PLANE


# START: NETWORKING
echo "--- Step 3/4: Installing Flannel CNI ---"
./srv_automation/imperative/shell/atomic/k8s/networking/install_flannel_cni.sh
# END: NETWORKING


# START: CLUSTER FORMING
echo "--- Step 4/4: Exporting worker join command ---"
./srv_automation/imperative/shell/composite/k8s/cluster-forming/export_worker_join_command.sh
# END: CLUSTER FORMING


echo "=== Kubernetes Master Node Workflow: COMPLETE ==="

