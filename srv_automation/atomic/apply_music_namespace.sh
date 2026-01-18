#!/bin/bash
# atomic/apply_music_namespace.sh
# Purpose: Apply music namespace YAML and verify namespace exists

set -euo pipefail

echo "Applying music namespace YAML..."

kubectl apply -f ./manifests/navidrome/music-namespace.yaml

echo "Verifying namespace 'music' exists..."
kubectl get namespace music >/dev/null

echo "Namespace 'music' applied and verified."

