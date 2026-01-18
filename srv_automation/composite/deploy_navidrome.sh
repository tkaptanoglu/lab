#!/bin/bash
# composite/deploy_navidrome.sh
# Purpose: Apply namespace, deployment, and service YAMLs and verify results

set -euo pipefail

echo "--- Step 1: Applying music Namespace YAML and verifying ---"
./srv_automation/atomic/apply_music_namespace.sh

echo "--- Step 2: Applying Navidrome Deployment YAML (3 replicas) and verifying ---"
./srv_automation/atomic/apply_navidrome_deployment.sh

echo "--- Step 3: Applying Navidrome Service YAML and verifying ---"
./srv_automation/atomic/apply_navidrome_service.sh

echo "--- Navidrome Deploy: COMPLETE ---"

