#!/bin/bash
# workflow/navidrome_service.sh
# Purpose: Stand up Navidrome service with persistent storage

set -euo pipefail

echo "=== Navidrome Service Workflow: START ==="

echo "--- Step 1/4: Setting up external storage ---"
./srv_automation/composite/setup_external_drive.sh

echo "--- Step 2/4: Apply music namespace ---"
./srv_automation/composite/apply_music_namespace.sh

echo "--- Step 3/4: Applying PersistentVolume and PersistentVolumeClaim ---"
./srv_automation/composite/apply_music_storage.sh

echo "--- Step 4/4: Deploying Navidrome application ---"
./srv_automation/composite/deploy_navidrome.sh

echo "=== Navidrome Service Workflow: COMPLETE ==="

