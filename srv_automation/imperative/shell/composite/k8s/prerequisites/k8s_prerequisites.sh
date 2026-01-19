#!/bin/bash
# composite/k8s_prerequisites.sh
# Purpose: Apply kernel module and sysctl prerequisites for Kubernetes

set -euo pipefail

echo "--- Kubernetes Prerequisites: Loading kernel modules ---"
./srv_automation/atomic/k8s/prerequisites/load_kernel_modules.sh

echo "--- Kubernetes Prerequisites: Applying sysctl settings ---"
./srv_automation/atomic/k8s/prerequisites/set_sysctl_k8s.sh

echo "--- Kubernetes Prerequisites: COMPLETE ---"

