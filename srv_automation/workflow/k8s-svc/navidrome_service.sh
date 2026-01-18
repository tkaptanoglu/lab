#!/bin/bash
# workflow/navidrome_service.sh
# Purpose: Stand up Navidrome service with persistent storage

set -euo pipefail

echo "=== Navidrome Service Workflow: START ==="


# START: STORAGE
echo "--- Step 1/4: Setting up external storage ---"
./srv_automation/composite/storage/setup_external_drive.sh
# END: STORAGE


# START: NAMESPACE
echo "--- Step 2/4: Apply music namespace ---"
./srv_automation/atomic/apply_music_namespace.sh
# END: NAMESPACE

# START: K8S STORAGE
echo "--- Step 3/4: Applying PersistentVolume and PersistentVolumeClaim ---"
./srv_automation/composite/k8s/storage/apply_music_storage.sh
# END: K8S STORAGE


# START: DEPLOY NAVIDROME
echo "--- Step 4/4: Deploying Navidrome application ---"
./srv_automation/composite/k8s/services/deploy_navidrome.sh
# END: DEPLOY NAVIDROME


echo "=== Navidrome Service Workflow: COMPLETE ==="

