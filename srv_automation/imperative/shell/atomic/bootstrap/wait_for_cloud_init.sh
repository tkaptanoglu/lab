#!/bin/bash
# atomic: wait_for_cloud_init.sh
# Purpose: Wait for cloud-init to finish to avoid conflicts.

set -euo pipefail

echo "Waiting for cloud-init to finish"
sudo cloud-init status --wait

echo "cloud-init is done."
