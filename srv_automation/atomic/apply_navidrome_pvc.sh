#!/bin/bash
# atomic/apply_pvc.sh
# Purpose: Apply the PersistentVolumeClaim YAML and verify PVCs are Bound in the music namespace

set -euo pipefail

echo "Applying PersistentVolumeClaim YAML..."

kubectl apply -f ./manifests/navidrome/navidrome-pvc.yaml

echo "Verifying PersistentVolumeClaims in namespace 'music'..."
kubectl -n music get pvc

# Minimal verification: ensure the expected PVC names exist
for pvc in pvc-navidrome-music pvc-navidrome-data; do
  if ! kubectl -n music get pvc "$pvc" >/dev/null 2>&1; then
    echo "ERROR: Expected PVC not found in namespace 'music': $pvc"
    exit 1
  fi
done

# Ensure they are Bound (best-effort; allow a brief settle time)
echo "Waiting briefly for PVCs to become Bound..."
for pvc in pvc-navidrome-music pvc-navidrome-data; do
  for i in 1 2 3 4 5; do
    phase="$(kubectl -n music get pvc "$pvc" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
    if [ "$phase" = "Bound" ]; then
      break
    fi
    sleep 2
  done
  phase="$(kubectl -n music get pvc "$pvc" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
  if [ "$phase" != "Bound" ]; then
    echo "ERROR: PVC did not reach Bound state: $pvc (phase=$phase)"
    echo "Debug:"
    kubectl -n music describe pvc "$pvc" || true
    exit 1
  fi
done

echo "PersistentVolumeClaims applied and verified (Bound)."

