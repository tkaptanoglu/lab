#!/bin/bash
# atomic/apply_navidrome_pv.sh
# Purpose: Apply the PersistentVolume YAML and verify PVs exist

set -euo pipefail

echo "Applying PersistentVolume YAML..."

kubectl apply -f ./manifests/navidrome/navidrome-data-pv.yaml
kubectl apply -f ./manifests/navidrome/navidrome-music-pv.yaml

echo "Verifying PersistentVolumes..."
kubectl get pv

# Minimal verification: ensure the expected PV names exist
for pv in pv-navidrome-music pv-navidrome-data; do
  if ! kubectl get pv "$pv" >/dev/null 2>&1; then
    echo "ERROR: Expected PV not found: $pv"
    exit 1
  fi
done

echo "PersistentVolumes applied and verified."

