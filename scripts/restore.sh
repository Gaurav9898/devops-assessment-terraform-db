#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-hotel_postgres}"
DB_USER="${DB_USER:-hotel_user}"
DB_PASSWORD="${DB_PASSWORD:-hotel_password}"
RESTORE_DB="${RESTORE_DB:-hotel_db_restore}"
BACKUP_FILE="${1:-}"

if ! docker ps --format '{{.Names}}' | grep -qx "${CONTAINER_NAME}"; then
  echo "Container ${CONTAINER_NAME} is not running. Start it with: docker compose up -d" >&2
  exit 1
fi

if [ -z "${BACKUP_FILE}" ]; then
  BACKUP_FILE="$(ls -t backups/*.dump 2>/dev/null | head -n 1 || true)"
fi

if [ -z "${BACKUP_FILE}" ] || [ ! -f "${BACKUP_FILE}" ]; then
  echo "No backup file found. Run ./scripts/backup.sh first or pass a backup path." >&2
  exit 1
fi

if [[ ! "${RESTORE_DB}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
  echo "Invalid RESTORE_DB value: ${RESTORE_DB}. Use letters, numbers, and underscores only; it must not start with a number." >&2
  exit 1
fi

docker exec -e PGPASSWORD="${DB_PASSWORD}" "${CONTAINER_NAME}" \
  psql -U "${DB_USER}" -d postgres -v ON_ERROR_STOP=1 \
  -c "DROP DATABASE IF EXISTS ${RESTORE_DB};"

docker exec -e PGPASSWORD="${DB_PASSWORD}" "${CONTAINER_NAME}" \
  psql -U "${DB_USER}" -d postgres -v ON_ERROR_STOP=1 \
  -c "CREATE DATABASE ${RESTORE_DB};"

docker exec -i -e PGPASSWORD="${DB_PASSWORD}" "${CONTAINER_NAME}" \
  pg_restore -U "${DB_USER}" -d "${RESTORE_DB}" < "${BACKUP_FILE}"

echo "Restored ${BACKUP_FILE} into database ${RESTORE_DB}."
echo "Verify with:"
echo "docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d ${RESTORE_DB} -c \"SELECT COUNT(*) FROM hotel_bookings;\""
