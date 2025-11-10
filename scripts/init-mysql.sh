#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${PROJECT_ROOT}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Arquivo .env não encontrado em ${ENV_FILE}" >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "${ENV_FILE}"
set +a

if command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  COMPOSE_CMD="docker compose"
fi

pushd "${PROJECT_ROOT}" >/dev/null

${COMPOSE_CMD} --env-file "${ENV_FILE}" up -d mysql >/dev/null

CONTAINER_ID="$(${COMPOSE_CMD} --env-file "${ENV_FILE}" ps -q mysql)"
if [[ -z "${CONTAINER_ID}" ]]; then
  echo "Não foi possível obter o ID do container mysql" >&2
  exit 1
fi

echo "Aguardando MySQL ficar saudável..."
until [[ "$(docker inspect -f '{{.State.Health.Status}}' "${CONTAINER_ID}")" == "healthy" ]]; do
  sleep 2
done

echo "MySQL pronto. Provisionando demais serviços..."

${COMPOSE_CMD} --env-file "${ENV_FILE}" up -d >/dev/null

popd >/dev/null

echo "Serviços reiniciados. Ambiente pronto para uso."
