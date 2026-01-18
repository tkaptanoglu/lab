#!/bin/bash
# atomic/create_kubectl_aliases.sh
# Purpose: Add kubectl convenience aliases to ~/.bashrc in an idempotent way.

set -euo pipefail

BASHRC="${HOME}/.bashrc"
MARKER_BEGIN="# >>> kubectl aliases BEGIN (srv_automation)"
MARKER_END="# <<< kubectl aliases END (srv_automation)"

echo "Adding kubectl aliases to ${BASHRC}..."

# Remove previous block if it exists (idempotent update)
if grep -qF "${MARKER_BEGIN}" "${BASHRC}"; then
  sed -i "/${MARKER_BEGIN}/,/${MARKER_END}/d" "${BASHRC}"
fi

# Append fresh block
cat >> "${BASHRC}" <<EOF

${MARKER_BEGIN}
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kgp='kubectl get pods'
alias kl='kubectl logs'
${MARKER_END}
EOF

echo "Kubectl aliases added. To activate them now, run:"
echo "  source ~/.bashrc"

