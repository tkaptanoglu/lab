#!/bin/bash
# composite/export_worker_join_command.sh
# Purpose: Persist a worker join command and optionally export it over HTTP

set -euo pipefail

echo "--- Join Command Export: Generating and persisting join command ---"
./srv_automation/imperative/shell/atomic/k8s/cluster-formation/generate_and_store_join_command.sh

echo "--- Join Command Export: Optionally enabling HTTP export service ---"
./srv_automation/imperative/shell/atomic/k8s/cluster-formation/enable_join_command_http_export.sh

echo "--- Join Command Export: COMPLETE ---"

