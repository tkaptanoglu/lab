#!/bin/bash
# atomic/generate_and_store_join_command.sh
# Purpose: Generate a kubeadm join command and persist it securely on disk

set -euo pipefail

echo "Generating worker join command..."

OUT_DIR="/var/lib/srv_automation/k8s"
OUT_FILE="${OUT_DIR}/join-command.sh"

sudo mkdir -p "${OUT_DIR}"

JOIN_CMD="$(sudo kubeadm token create --print-join-command)"

sudo tee "${OUT_FILE}" > /dev/null <<EOF
#!/bin/bash
${JOIN_CMD}
EOF

sudo chown root:root "${OUT_FILE}"
sudo chmod 600 "${OUT_FILE}"

echo "Join command saved to: ${OUT_FILE}"
echo "Copy securely to a worker and run: sudo ./join-command.sh"

