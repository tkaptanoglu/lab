#!/bin/bash
# composite/deploy_navidrome.sh
# Purpose: Apply namespace, deployment, and service YAMLs and verify results

set -euo pipefail

echo "--- Step 1: Applying Navidrome Deployment YAML and verifying ---"
./srv_automation/imperative/shell/atomic/svc/navidrome/apply_navidrome_deployment.sh

echo "--- Step 2: Applying Navidrome Service YAML and verifying ---"
./srv_automation/imperative/shell/atomic/svc/navidrome/apply_navidrome_service.sh

echo "--- Navidrome Deploy: COMPLETE ---"

