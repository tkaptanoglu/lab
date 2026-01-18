#!/bin/bash
# composite/apply_music_storage.sh
# Purpose: Apply PV and PVC YAMLs and verify results

set -euo pipefail

echo "--- Step 1: Applying PersistentVolume YAML and verifying ---"
./srv_automation/atomic/apply_pv.sh

echo "--- Step 2: Applying PersistentVolumeClaim YAML and verifying ---"
./srv_automation/atomic/apply_pvc.sh

echo "--- Music Storage Apply: COMPLETE ---"

