#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

CONTAINER_NAME="${CONTAINER_NAME:-hotel_postgres}"
DB_NAME="${DB_NAME:-hotel_db}"
DB_USER="${DB_USER:-hotel_user}"
RESTORE_DB="${RESTORE_DB:-hotel_db_restore}"

run_step() {
  echo
  echo "==> $*"
  "$@"
}

run_terraform_plan() {
  local environment="$1"
  local log_file
  local summary

  log_file="$(mktemp)"

  echo
  echo "==> terraform -chdir=infra/envs/${environment} plan -refresh=false -input=false -no-color"
  if ! terraform -chdir="infra/envs/${environment}" plan -refresh=false -input=false -no-color > "${log_file}"; then
    cat "${log_file}" >&2
    rm -f "${log_file}"
    return 1
  fi

  summary="$(grep -E '^Plan:|^No changes\\.' "${log_file}" | tail -n 1 || true)"
  if [ -n "${summary}" ]; then
    echo "${summary}"
  else
    echo "Terraform plan completed."
  fi

  rm -f "${log_file}"
}

query_db() {
  local database="$1"
  local sql="$2"

  docker exec -i "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${database}" -At -c "${sql}"
}

echo "Running smoke/integration checks from ${ROOT_DIR}"

run_step terraform fmt -recursive -check

run_step terraform -chdir=infra/envs/dev init -input=false
run_step terraform -chdir=infra/envs/dev validate
run_terraform_plan dev

run_step terraform -chdir=infra/envs/prod init -input=false
run_step terraform -chdir=infra/envs/prod validate
run_terraform_plan prod

run_step docker compose up -d

echo
echo "==> Waiting for PostgreSQL health check"
for _ in {1..30}; do
  if docker exec "${CONTAINER_NAME}" pg_isready -U "${DB_USER}" -d "${DB_NAME}" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done
docker exec "${CONTAINER_NAME}" pg_isready -U "${DB_USER}" -d "${DB_NAME}"

booking_count="$(query_db "${DB_NAME}" "SELECT COUNT(*) FROM hotel_bookings;")"
event_count="$(query_db "${DB_NAME}" "SELECT COUNT(*) FROM booking_events;")"
city_count="$(query_db "${DB_NAME}" "SELECT COUNT(DISTINCT city) FROM hotel_bookings;")"
status_count="$(query_db "${DB_NAME}" "SELECT COUNT(DISTINCT status) FROM hotel_bookings;")"

if [ "${booking_count}" -lt 100 ]; then
  echo "Expected at least 100 bookings, got ${booking_count}." >&2
  exit 1
fi

if [ "${event_count}" -lt 1 ]; then
  echo "Expected booking events, got ${event_count}." >&2
  exit 1
fi

if [ "${city_count}" -lt 2 ]; then
  echo "Expected multiple cities, got ${city_count}." >&2
  exit 1
fi

if [ "${status_count}" -lt 2 ]; then
  echo "Expected multiple statuses, got ${status_count}." >&2
  exit 1
fi

query_plan="$(docker exec -i "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" -At -c "SET enable_seqscan = off; EXPLAIN SELECT org_id, status, COUNT(*), SUM(amount) FROM hotel_bookings WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days' GROUP BY org_id, status;")"
if [[ "${query_plan}" != *"idx_hotel_bookings_city_created_org_status"* ]]; then
  echo "Expected query plan to use idx_hotel_bookings_city_created_org_status." >&2
  echo "${query_plan}" >&2
  exit 1
fi

run_step ./scripts/backup.sh
run_step ./scripts/restore.sh

restored_booking_count="$(query_db "${RESTORE_DB}" "SELECT COUNT(*) FROM hotel_bookings;")"
restored_event_count="$(query_db "${RESTORE_DB}" "SELECT COUNT(*) FROM booking_events;")"

if [ "${restored_booking_count}" != "${booking_count}" ]; then
  echo "Restored booking count mismatch: source=${booking_count}, restored=${restored_booking_count}." >&2
  exit 1
fi

if [ "${restored_event_count}" != "${event_count}" ]; then
  echo "Restored event count mismatch: source=${event_count}, restored=${restored_event_count}." >&2
  exit 1
fi

echo
echo "Smoke/integration checks passed."
echo "Bookings: ${booking_count}; events: ${event_count}; restored database: ${RESTORE_DB}."
