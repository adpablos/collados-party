#!/usr/bin/env bash
# Despliega la última versión de main en el server: git pull + compose up.
# Uso: scripts/deploy.sh
# Requiere acceso SSH por tailnet al server (ver docs/despliegue.md).
set -euo pipefail

DEPLOY_HOST="${DEPLOY_HOST:-100.83.154.97}" # treasure-map-prod-01 (tailnet)
DEPLOY_USER="${DEPLOY_USER:-adpablos}"
DEPLOY_SSH_KEY="${DEPLOY_SSH_KEY:-$HOME/.ssh/treasure_map_prod_github_actions_ed25519}"
APP_DIR="/opt/collados-party"
PUBLIC_URL="https://collados.alexdepablos.es"

echo "→ Desplegando en ${DEPLOY_USER}@${DEPLOY_HOST}:${APP_DIR}"
ssh -i "${DEPLOY_SSH_KEY}" -o IdentitiesOnly=yes "${DEPLOY_USER}@${DEPLOY_HOST}" \
  "cd '${APP_DIR}' && git pull --ff-only && sudo docker compose up -d --wait"

echo "→ Comprobando ${PUBLIC_URL}"
curl -fsS -o /dev/null --retry 3 --retry-delay 2 "${PUBLIC_URL}"
echo "✔ ${PUBLIC_URL} responde"
